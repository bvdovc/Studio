package sym.configurationmodel.v250f
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	
	import sym.configurationmodel.common.ConfigurationFactoryBase_VG3R;
	import sym.configurationmodel.utils.IntUtil;
	import sym.configurationmodel.utils.TieringUtility_VG3R;
	import sym.objectmodel.common.Bay;
	import sym.objectmodel.common.Configuration_VG3R;
	import sym.objectmodel.common.Constants;
	import sym.objectmodel.common.DAE;
	import sym.objectmodel.common.Drive;
	import sym.objectmodel.common.DriveGroup;
	import sym.objectmodel.common.Engine;
	import sym.objectmodel.common.EnginePort;
	import sym.objectmodel.common.InfinibandSwitch;
	import sym.objectmodel.common.PDP;
	import sym.objectmodel.common.PDU;
	import sym.objectmodel.common.PortConfiguration;
	import sym.objectmodel.common.Position;
	import sym.objectmodel.common.Tabasco;
	import sym.objectmodel.driveUtils.DictionaryExt;
	import sym.objectmodel.driveUtils.DriveDef;
	import sym.objectmodel.driveUtils.DriveRegister;
	import sym.objectmodel.driveUtils.enum.DriveRaidLevel;
	import sym.objectmodel.driveUtils.enum.DriveType;
	
	public class ConfigurationFactory extends ConfigurationFactoryBase_VG3R
	{
		
		public static const FACTORY_NAME:String = "250f_Factory";
		public static const SERIES_NAME:String = "250F_";
		
		private static const NO_ENGINES:int = 2;
		private static const NO_SYSTEM_BAYS:int = 1;
		public static const TOTAL_USABLE_CAPACITY:Number = 1083; //TB
		
		public function ConfigurationFactory()
		{
			super();
			
			_currentPortConfig = PortConfiguration.CONFIG_ALL_FLASH_250F;
			
		}
		
		public override function get seriesName():String
		{
			return SERIES_NAME;
		}
		
		public override function get modelName():String
		{
			return Constants.VMAX_250F;
		}
		
		protected override function factoryName():String
		{
			return FACTORY_NAME;
		}
		
		public override function get noEngines():int
		{
			return NO_ENGINES;
		}
		
		public override function get noSystemBays():int
		{
			return NO_SYSTEM_BAYS;
		}
		
		public override function get daeType():Array
		{
			return [DAE.Tabasco];
		}
		
		public override function get totCapacity():Number
		{
			return TOTAL_USABLE_CAPACITY;
		}
		
		public override function populateWithDrives(config:Configuration_VG3R, dae:DAE = null):void
		{
			if (!config)
				throw new ArgumentError("Configuration must be provided to populate drives");
			
			if (!config.driveCountMap)
				throw new ArgumentError("Configuration drive map for each engine must be specified");
			
			if (config.containsDrives)
			{
				// if config DAEs are already populated with Drives do nothing
				return; 
			}
			
			for (var engineNo:int = 1; engineNo <= config.noEngines; engineNo++)
			{
				var tabascoDAEs:Array = config.getDAEsBehindEngine(engineNo, DAE.Tabasco);
				
				if (tabascoDAEs.length > 0)
				{
					var tabascoDriveMap:DictionaryExt = extractDriveMapByDaeType(config.driveCountMap[engineNo - 1] as Dictionary, DAE.Tabasco);
					this.populateDAEs(tabascoDAEs, tabascoDriveMap, 0);
				}
			}
		}
		
		public override function createConfiguration(noEngines:int,
													 sysBayType:int,
													 driveType:String,
													 noDrives:int,
													 dispersedBays:Array,
													 driveGroups:Array,
													 tier:int = TieringUtility_VG3R.TIER_CUSTOM_CONFIG,
													 osCapacity:Number = 0,
													 mfCapacity:Number = 0,
													 isDispersionClone:Boolean = false):Configuration_VG3R
		{
			var cfg:Configuration_VG3R = new Configuration_VG3R();
			cfg.factory = this;
			cfg.noEngines = noEngines;
			cfg.tierSolution = tier;
			cfg.sysBayType = sysBayType; 
			//cfg.totCapacity = capacity;
			cfg.osUsableCapacity = osCapacity;
			cfg.mfUsableCapacity = mfCapacity;
			cfg.daeType = DAE.Tabasco;
			
			cfg.driveType = driveType;
			cfg.numberOfDrives = noDrives;
			
			var bay:Bay;
			var sysBayValues:Array = [this.noSystemBays];
			
			bay = generateSystemBay(0, sysBayType, cfg.daeType, sysBayValues, null, factoryName(), noEngines);
			cfg.addChild(bay);
			
			var engineDriveMap:Array = new Array(); 
			for(var ne:int = 0; ne < noEngines; ne++) 
				engineDriveMap[ne] = new Dictionary(); //values - [driveDef.id] = {active:int, spare:int}
			
			mapDriveCountToEngineArray(noEngines, engineDriveMap, driveGroups, DAE.Tabasco);
			
			var noTabascoPerEngine:int = MAX_DAES_BEHIND_ENGINE_TABASCO;
			
			cfg.driveCountMap = engineDriveMap;
			cfg.driveGroups = TieringUtility_VG3R.cloneDriveGroups(driveGroups);
			
			var noTabascoDAEs:int = noTabascoPerEngine * noEngines;
			
			cfg.id = this.seriesName + noEngines + cfg.activesAndSpares;
			
			spreadTabascoDAEs(cfg, noTabascoDAEs);
			
			return cfg;
		}
		
		public function spreadTabascoDAEs(cfg:Configuration_VG3R, totalTabasco:int):void
		{
			const tabascoPerEngine:int = MAX_DAES_BEHIND_ENGINE_TABASCO;
			const sysTabascoLocations:Array =  SB_TABASCO_LOCATIONS_2ENGINES;
			
			var engineIndex:int = 1;
			var daeIndex:int = 0; 
			var indexBehindEngine:int = 0; //this is dae population order index (used for drive spread) 
			var dae:DAE = null;
			var noTabascoPerSystemBay:int = 2 * cfg.noEngines;
			
			for each (var bay:Bay in cfg.children)
			{
				//populate system bay
				if(bay.isSystemBay)
				{
					indexBehindEngine = 0;
					
					var parentEngineInd:int; // DAE's engine index 
					var daePos:int; // DAE's index position within sys bay
									
					for(daeIndex = 0; daeIndex < noTabascoPerSystemBay; daeIndex++)
					{
						parentEngineInd = cfg.dualEngine && daeIndex >= tabascoPerEngine ? engineIndex + 1 : engineIndex;
						daePos = sysTabascoLocations[daeIndex];
						
						bay.addChild(dae = new Tabasco(Position.getFromCacheByType(Position.BAY_ENCLOSURE, daePos), parentEngineInd));
						
						dae.indexBehindEngine = indexBehindEngine;
						
						indexBehindEngine++;
					}
					
					engineIndex += cfg.sysBayType;			
				}
			}
			
			cfg.noTabasco = totalTabasco;
		}
		
		protected override function mapDriveCountToEngineArray(noEngines:int, engineDrives:Array, driveGroups:Array, driveSize:int):void
		{
			var dgSum:Dictionary = new Dictionary();
			var emptyCollection:Boolean = true;
			
			for each(var gr:DriveGroup in driveGroups)
			{
				if(gr.driveDef.size == driveSize)
				{
					emptyCollection = false;
					var id:String = gr.driveDef.id.toString();
					if(!dgSum[id])
					{
						dgSum[id] = gr.activeCount;
						continue;
					}
					
					dgSum[id] = dgSum[id] + gr.activeCount;
				}
			}
			
			if(emptyCollection)
			{
				return;
			}
			
			// determine how many drives go in each engine
			
			var driveReminder:Dictionary = new Dictionary(); //remaining drives that should be split equally as much as possible
			var evenDrivesPerEngine:Dictionary = new Dictionary();  //even number of drives for each engine per drive def
			var ids:ArrayCollection = new ArrayCollection();
			var totalDrivesPerEngine:Array = new Array();
			
			for (var eng:int = 0; eng < noEngines; eng++)
			{
				totalDrivesPerEngine.push(0);
			}
			
			for (var defId:String in dgSum)
			{
				var def:DriveDef = DriveRegister.getById(int(defId));
				// min raid group size per engine/2DAEs
				var minRgsPerEngine:int = 2 * def.raid.raidGroupSize;
				
				// spread even drives as much as possible
				// remaining drives will be spread later
				// e.g. 24 drives total = 4x RAID53, 2 Engines
				// 4 RAIDs behind 1st engine, 2 RAIDs behind 2nd engine i.e. 16 drives behind 1st engine, 8 behind 2nd engine
				var evenCountPerEngine:int = int( dgSum[defId] / (minRgsPerEngine * noEngines) ) * minRgsPerEngine;
				evenDrivesPerEngine[defId] = evenCountPerEngine;
				
				driveReminder[defId] = int(dgSum[defId]) - evenCountPerEngine * noEngines;
				ids.addItem(int(defId)); //add id of drive def that have remaining drives
				
				//append total count behind every engine
				for(var engX:int = 0; engX < noEngines; engX++)
				{
					totalDrivesPerEngine[engX] += evenCountPerEngine;
					if(engineDrives[engX][def.id] == null)
					{
						engineDrives[engX][def.id] = {active: evenCountPerEngine, spare: 0};
					}
				}
			}
			
			//spread the remaining drives
			
			for(var ind:int = 0; ind < ids.length; ind++)  //iterate through def ids and put them behind minimum populated engine
			{
				var drivesToAdd:int = int(driveReminder[ids[ind]]);  //get drive count to add
				var dd:DriveDef = DriveRegister.getById(ids[ind]);  //determine RAID size
				var di:int = dd.raid.raidGroupSize;
				
				while (di <= drivesToAdd)
				{
					var engWithMinimum:int = IntUtil.minValueIndex(totalDrivesPerEngine);
					var dpe:int = dd.raid.raidGroupSize;  // track current drive count per engine
					
					for (di, dpe; dpe <= minRgsPerEngine && di <= drivesToAdd; di += dd.raid.raidGroupSize, dpe += dd.raid.raidGroupSize )
					{
						totalDrivesPerEngine[engWithMinimum] += dd.raid.raidGroupSize;
						engineDrives[engWithMinimum][dd.id].active += dd.raid.raidGroupSize;
					}
				}
			}
			
			//calculate spare count for each drive def per each engine
			//populate total number of drives for each engine
			for(var engi:int = 0; engi < engineDrives.length; engi++)
			{
				var map:Dictionary = engineDrives[engi] as Dictionary;
				
				for each(var activesAndSpares:Object in map)
				{
					activesAndSpares.spare = Math.ceil(Number(activesAndSpares.active) / TieringUtility_VG3R.ONE_SPARE_PER_ACTIVE_COUNT_NUMBER);
				}
			}
			
		}
		/**
		 * gets allowed port configurations
		 */
		public override function getAllowedPortConfigurations():ArrayCollection{
			var portconfigs:ArrayCollection = new ArrayCollection();
			portconfigs.addAll(new ArrayCollection(PORT_CONFIGS_250F));
			return portconfigs;
		}
	}
}