package sym.configurationmodel.pm2000
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import sym.configurationmodel.common.ConfigurationFactoryBase_VG3R;
	import sym.configurationmodel.utils.IntUtil;
	import sym.configurationmodel.utils.TieringUtility_VG3R;
	import sym.objectmodel.common.Bay;
	import sym.objectmodel.common.Configuration_VG3R;
	import sym.objectmodel.common.Constants;
	import sym.objectmodel.common.DAE;
	import sym.objectmodel.common.DriveGroup;
	import sym.objectmodel.common.Nebula;
	import sym.objectmodel.common.PortConfiguration;
	import sym.objectmodel.common.Position;
	import sym.objectmodel.driveUtils.DictionaryExt;
	import sym.objectmodel.driveUtils.DriveDef;
	import sym.objectmodel.driveUtils.DriveRegister;
	import sym.objectmodel.driveUtils.enum.DriveRaidLevel;
	import sym.objectmodel.driveUtils.enum.DriveType;
	
	public class ConfigurationFactory extends ConfigurationFactoryBase_VG3R
	{
		public static const FACTORY_NAME:String = "pm2000_factory"
		public static const SERIES_NAME:String = "pm_2000"
			
		private static const NO_ENGINES:int = 2;
		private static const NO_SYSTEM_BAYS:int = 1;
		public static const TOTAL_USABLE_CAPACITY:Number = 526; //TB
		private var isRaid:String = "";
		
		public function ConfigurationFactory()
		{
			super();
			
			_currentPortConfig = PortConfiguration.CONFIG_ALL_FLASH_pm2000;
		}
		
		public override function get seriesName():String
		{
			return SERIES_NAME;
		}
		
		public override function get modelName():String
		{
			return Constants.PowerMax_2000;
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
			return [DAE.Nebula];
		}
		
		public override function get totCapacity():Number
		{
			return TOTAL_USABLE_CAPACITY;
		}
		
		public override function populateWithDrives(config:Configuration_VG3R, dae:DAE=null):void
		{
			if(!config)
				throw new ArgumentError("Configuration must be provided to populate drives");
			
			if(!config.driveCountMap)
				throw new ArgumentError("Configuration drive map each engine must be specified");
			
			if(config.containsDrives)
				return; // if config DAEs already populated with Drives do nothing
			
			for(var engineNo:int = 1; engineNo <= config.noEngines; engineNo++)
			{
				var nebulaDAEs:Array = config.getDAEsBehindEngine(engineNo, DAE.Nebula);
				
				if(nebulaDAEs.length > 0)
				{
					var nebulaDriveMap:DictionaryExt = extractDriveMapByDaeType(config.driveCountMap[engineNo - 1] as Dictionary, DAE.Nebula);
					this.populateDAEs(nebulaDAEs, nebulaDriveMap, config.noEngines);
				}
			}
		
		}
		
		public override function createConfiguration(noEngines:int,
													 sysBayType:int,
													 driveType:String,
													 noDrives:int,
													 dispersedBays:Array,
													 driveGroups:Array,
													 tier:int=TieringUtility_VG3R.TIER_CUSTOM_CONFIG,
													 osCapacity:Number=0,
													 mfCapacity:Number=0,
													 isDispersionClone:Boolean=false):Configuration_VG3R
		{
			var cfg:Configuration_VG3R = new Configuration_VG3R();
			cfg.factory = this;
			cfg.noEngines = noEngines;
			cfg.tierSolution = tier;
			cfg.sysBayType = sysBayType;
			cfg.osUsableCapacity = osCapacity;
			cfg.mfUsableCapacity = mfCapacity;
			cfg.daeType = DAE.Nebula;
			cfg.driveType = driveType;
			cfg.numberOfDrives = noDrives;
			
			var bay:Bay;
			var sysBayValues:Array = [this.noSystemBays];
			
			bay = generateSystemBay(0, sysBayType, cfg.daeType, sysBayValues, null, factoryName(), noEngines);
			cfg.addChild(bay);
			
			var engineDriveMap:Array = new Array();
			for(var en:int = 0; en < noEngines; en++)
				engineDriveMap[en] = new Dictionary();
			
			mapDriveCountToEngineArray(noEngines, engineDriveMap, driveGroups, DAE.Nebula);
			
			var noNebulaPerEngine: int = MAX_DAES_BEHIND_ENGINE_NEBULA;
			
			cfg.driveCountMap = engineDriveMap;
			cfg.driveGroups = TieringUtility_VG3R.cloneDriveGroups(driveGroups);
			
			var noNebulaDAEs:int = noNebulaPerEngine * noEngines;
			
			cfg.id = this.seriesName + noEngines + cfg.activesAndSpares;
			
			spreadNebulaDAEs(cfg, noNebulaDAEs);
			
			return cfg;
		}
		
		public function spreadNebulaDAEs(cfg:Configuration_VG3R, totalNebula:int):void
		{
			const nebulaPerEngine:int = MAX_DAES_BEHIND_ENGINE_NEBULA;
			const sysNebulaLocations:Array = SB_NEBULA_LOCATIONS_2ENGINES;
			
			var engineIndex:int = 1;
			var daeIndex:int = 0;
			var indexBehindEngine:int = 0; //this is dae population order index (used for drive spread)
			var dae:DAE = null;
			var noNebulaPerSystemBay:int = 2 * cfg.noEngines;
			
			for each(var bay:Bay in cfg.children)
			{
				if(bay.isSystemBay)
				{
					indexBehindEngine = 0;
					
					var parentEngineInd:int; //DAE's emgine index
					var daePos:int; // DAE's index position within sys bay
					
					for(daeIndex = 0; daeIndex < noNebulaPerSystemBay; daeIndex++)
					{
						parentEngineInd =  daeIndex >= nebulaPerEngine ? engineIndex + 1 : engineIndex;
						daePos = sysNebulaLocations[daeIndex];
						
						bay.addChild(dae = new Nebula(Position.getFromCacheByType(Position.BAY_ENCLOSURE, daePos), parentEngineInd));
						
						dae.indexBehindEngine = indexBehindEngine;
						
						indexBehindEngine++;
					}
					
					engineIndex += cfg.sysBayType;
				}
			}
			
			cfg.noNebula = totalNebula;
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
			
			//determine hoe many drives go in each engine
			
			var driveReminder:Dictionary = new Dictionary(); //remaining drives that should be split equally as much as possible
			var evenDrivesPerEngine:Dictionary = new Dictionary(); //even number of drives for each engine per drive def
			var ids:ArrayCollection = new ArrayCollection();
			var totalDrivesPerEngine:Array = new Array();
			
			for (var eng:int = 0; eng < noEngines; eng++)
			{
				totalDrivesPerEngine.push(0);
			}
			
			for(var defId:String in dgSum)
			{
				var def:DriveDef = DriveRegister.getById(int(defId));
				var minRqsPerEngine:int = def.raid.raidGroupSize; // min raid group size per engine
				
				//spread even drives as much as possible
				//remainig drives will be spread later
				//e.g 22drives total = 8x RAID53, 2 Engines
				var evenCountPerEngine:int = int((dgSum[defId] / minRqsPerEngine) / noEngines) * minRqsPerEngine;
				evenDrivesPerEngine[defId] = evenCountPerEngine;
				
				driveReminder[defId] = int(dgSum[defId]) - evenCountPerEngine * noEngines;
				ids.addItem(int(defId)); //add id of drive def that have ramaining drives
				
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
			
			//spread the remainig drives
			
			for(var ind:int = 0; ind < ids.length; ind++)
			{
				var drivesToAdd:int = int(driveReminder[ids[ind]]); //get drive count to add
				var dd:DriveDef = DriveRegister.getById(ids[ind]); //determine RAID size
				var di:int = dd.raid.raidGroupSize / 2;
				
				while(di <= drivesToAdd)
				{
					var engWithMinimum:int = IntUtil.minValueIndex(totalDrivesPerEngine);
					var dpe:int = dd.raid.raidGroupSize / 2; //track current drive count per engine
					
					for(di, dpe; dpe <= minRqsPerEngine && di <= drivesToAdd; di += dd.raid.raidGroupSize/2, dpe += dd.raid.raidGroupSize/2)
					{
						totalDrivesPerEngine[engWithMinimum] += (dd.raid.raidGroupSize / 2);
						engineDrives[engWithMinimum][dd.id].active += (dd.raid.raidGroupSize / 2);
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
					activesAndSpares.spare = Math.ceil(Number(activesAndSpares.active) / TieringUtility_VG3R.ONE_SPARE_PER_ACTIVE_COUNT_NUMBER_PM2000);
				}
			}
		}
		
		/**
		 * gets allowed port configuration
		 */
		public override function getAllowedPortConfigurations():ArrayCollection
		{
			var portConfigs:ArrayCollection = new ArrayCollection();
			portConfigs.addAll(new ArrayCollection(PORT_CONFIGS_PM2000));
			return portConfigs;
		}
		
		/**
		 * Validates supported drive types for PM2000 AFA based on provided capacity, RAID and number of engines.
		 * @param totCapacity indicates total usable capacity
		 * @param raid indicates RAID level protection
		 * @param engineCount indicates selected number of engines
		 * @return collection of supported DriveType instances
		 * 
		 */			
		public override function validateSupportedDriveTypes(totCapacity:Number, raid:DriveRaidLevel, engineCount:int):ArrayCollection
		{
			var drivePacksForRaid53ForNebula:ArrayCollection = new ArrayCollection([5.6, 11.3, 22.6]);
			var drivePacksForRaid66ForNebula:ArrayCollection = new ArrayCollection([11.3, 22.6, 45.2]);
			var drivePacksForRaid57ForNebula:ArrayCollection = new ArrayCollection([13.2, 26.4, 52.8]);
			var driveTypes:ArrayCollection = new ArrayCollection([DriveType.FLASH_NVM_1920GB, DriveType.FLASH_NVM_3840GB, DriveType.FLASH_NVM_7680GB]);
			var minCapacityPackPerEngine:Number = 1;
			var maxCapacityPackPerEngine:Number = 11;
			
			var supportedDrives:ArrayCollection = new ArrayCollection();
			var drivePacks:ArrayCollection;
			
			var minimumCapacityPack:Number;
			
			if(raid == DriveRaidLevel.R53_Nebula)
			{
				drivePacks = drivePacksForRaid53ForNebula;
				minimumCapacityPack = 5.6
			}
			else if(raid == DriveRaidLevel.R57_Nebula)
			{
				maxCapacityPackPerEngine = 5;
				drivePacks = drivePacksForRaid57ForNebula;
				minimumCapacityPack = 13.2
			}
			else if(raid == DriveRaidLevel.R66_Nebula)
			{
				maxCapacityPackPerEngine = 5;
				drivePacks = drivePacksForRaid66ForNebula;
				minimumCapacityPack = 11.3;
			}
			
			var supportedCapacity:Number = this.getSupportedCapacity(totCapacity, minimumCapacityPack);
			
			for(var i:int = 0; i <= 2; i++)
			{
				if(supportedCapacity / drivePacks[i] <= maxCapacityPackPerEngine * engineCount && supportedCapacity / drivePacks[i] >= minCapacityPackPerEngine * engineCount)
				{
					supportedDrives.addItem(driveTypes[i]);
				}
			}
			
			return supportedDrives;
			
		}
		
	}
}