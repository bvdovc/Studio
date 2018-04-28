package sym.configurationmodel.pm8000
{
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	
	import sym.configurationmodel.common.ConfigurationFactoryBase_VG3R;
	import sym.configurationmodel.utils.IntUtil;
	import sym.configurationmodel.utils.TieringUtility_VG3R;
	import sym.objectmodel.common.Bay;
	import sym.objectmodel.common.ComponentBase;
	import sym.objectmodel.common.Configuration_VG3R;
	import sym.objectmodel.common.Constants;
	import sym.objectmodel.common.DAE;
	import sym.objectmodel.common.Drive;
	import sym.objectmodel.common.EthernetSwitch;
	import sym.objectmodel.common.InfinibandSwitch;
	import sym.objectmodel.common.KVM;
	import sym.objectmodel.common.Nebula;
	import sym.objectmodel.common.PortConfiguration;
	import sym.objectmodel.common.Position;
	import sym.objectmodel.common.Tabasco;
	import sym.objectmodel.driveUtils.DictionaryExt;
	import sym.objectmodel.driveUtils.DriveDef;
	import sym.objectmodel.driveUtils.DriveRegister;
	import sym.objectmodel.driveUtils.enum.DriveRaidLevel;
	import sym.objectmodel.driveUtils.enum.DriveType;
	import sym.objectmodel.driveUtils.enum.HostType;
	
	
	public class ConfigurationFactory extends ConfigurationFactoryBase_VG3R
	{
		
		public static const FACTORY_NAME:String = "pm8000_factory"
		public static const SERIES_NAME:String = "pm_8000"
		
		private static const NO_ENGINES:int = 8;
		private static const NO_SYSTEM_BAYS:int = 2;
		private static const DISPERSED_VALUES:Array = [2];
		public static const TOTAL_USABLE_CAPACITY:Number = 1683.2; // TBu
		
		public var remainingDrivesForSecondDAE:int = 0; // global variable used for remaining drives in dual engine second DAE
		public var raid4_8_drives:Boolean; // used for determination of raid group used in drive population logic
		
		private static const NO_SYSTEM_BAYS_1:Object = {1: 1, 2: 1};// Single/Dual-engine
		private static const NO_SYSTEM_BAYS_2:Object = {1: 2, 2: 1};
		
		private var NO_ENGINES_MAP:Object = {
			1: {noSysBays: NO_SYSTEM_BAYS_1, DAEs: {1: {1: IntUtil.sequence(1, 6), 2: IntUtil.sequence(1, 2)}}}, // 1engine->1bay for single/dual engine -> different DAEs number for single and dual-engine 
			2: {noSysBays: NO_SYSTEM_BAYS_2, DAEs:{1: IntUtil.sequence(2, 4), 2: IntUtil.sequence(2, 12)}}
		};
		
		public function ConfigurationFactory()
		{
			super();
			_currentPortConfig = PortConfiguration.CONFIG_ALL_FLASH_SINGLE_ENGINE_PM8000;
		}

		public override function get seriesName():String
		{
			return SERIES_NAME;
		}
		
		public override function get modelName():String
		{
			return Constants.PowerMax_8000;
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
		
		public override function get dispersed_m():Array
		{
			return DISPERSED_VALUES;
		}
		
		public override function get totCapacity():Number
		{
			return TOTAL_USABLE_CAPACITY;
		}
		
		public override function get daeType():Array
		{
			return [DAE.Nebula];
		}
		
		public override function get sysBayType():Array
		{
			return [Configuration_VG3R.DUAL_ENGINE_BAY];
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
			
			if(noEngines <= 0) 
			{
				return null;
			}
			
			var noSysBays:int; 
			
			if(noEngines > 1)           //for multi engine configs we have different port configuration
				_currentPortConfig = 29;
			else
				_currentPortConfig = 28;
			
			
			if(noEngines > 4)
				noSysBays = 2;
			else
				noSysBays = 1;
			
			if (noSysBays <= 0)
				// it's not supposed to happen but check it
				return null;
			
			
			var cfg:Configuration_VG3R = new Configuration_VG3R();
			cfg.factory = this;
			cfg.noEngines = noEngines;
			cfg.tierSolution = tier;
			cfg.sysBayType = sysBayType; 
			//cfg.totCapacity = capacity;
			cfg.osUsableCapacity = osCapacity;
			cfg.mfUsableCapacity = mfCapacity;
			cfg.daeType = DAE.Nebula;
			
			cfg.driveType = driveType;
			cfg.numberOfDrives = noDrives;
			
			//dispersed system
			var sysBayValues:Array = IntUtil.sequence(1, noSysBays); 
			cfg.dispersed_m = dispersedBays; 
			
			if(dispersedBays[0] != -1)
			{
				for(var l:int = 0; l < dispersedBays.length; l++)
				{
					var idx:int = sysBayValues.indexOf(dispersedBays[l]);
					if(idx != -1)
					{
						sysBayValues.splice(idx, 1);
					}
				}
			}
			
			var bay:Bay;
			var maxNumberOfEnginesPerBay:int;
			for(var i:int = 0; i < noSysBays; i++)
			{
				if(i == 1)
					maxNumberOfEnginesPerBay = noEngines - 4;
				else
				{
					if(noEngines > 4)
						maxNumberOfEnginesPerBay = 4;
					else
						maxNumberOfEnginesPerBay = noEngines;
				}
				bay = generateSystemBay(i, sysBayType, cfg.daeType, dispersedBays[0] != -1 ? sysBayValues : null, dispersedBays[0] != -1 ? dispersedBays : null, factoryName(), maxNumberOfEnginesPerBay);
				cfg.addChild(bay);
			} 
			
			var engineDriveMap:Array = new Array(); 
			for(var ne:int = 0; ne < noEngines; ne++) 
				engineDriveMap[ne] = new Dictionary(); //values - [driveDef.id] = {active:int, spare:int}
			
			mapDriveCountToEngineArray(noEngines, engineDriveMap, driveGroups, DAE.Nebula);
			
			
			// we have different implementation of number of DAEs behind engines, different approach is needed
			
			cfg.driveCountMap = engineDriveMap;
			cfg.driveGroups = TieringUtility_VG3R.cloneDriveGroups(driveGroups);
			
			var noNebulaDAEs:int = 0;
			
			for(var i:int = 1; i <= noEngines; i++)
			{
				if(i%2 == 0)
					noNebulaDAEs = noNebulaDAEs + 1;
				else
					noNebulaDAEs = noNebulaDAEs + 2;
			}
			
			cfg.id = this.seriesName + noEngines + cfg.activesAndSpares;
			
			spreadNebulaDAEs(cfg, noNebulaDAEs);
			
			return cfg;
		}
		
		/**
		 * gets allowed port configuration
		 */
		public override function getAllowedPortConfigurations():ArrayCollection
		{
			var portConfigs:ArrayCollection = new ArrayCollection();
			if(_currentPortConfig == 29)
				portConfigs.addAll(new ArrayCollection(PORT_CONFIG_MULTI_ENGINE_PM8000));
			else
				portConfigs.addAll(new ArrayCollection(PORT_CONFIG_SINGLE_ENGINE_PM8000));
			return portConfigs;
		}
		
		public function spreadNebulaDAEs(cfg:Configuration_VG3R, totalNebulas:int):void
		{
			//nebula DAEs are added differently
			
			const sysNebulaLocations:Array = SB_NEBULA_LOCATION_PM8000_ALL_ENGINES;
			var noNebulaFirstSystemBay:int = 0;
			var noNebulaSecondSystemBay:int = 0;
			
			if(cfg.noEngines <= 4)
			{
				for(var i:int = 1; i <= cfg.noEngines ; i++)
				{
					if(i%2 == 0)
						noNebulaFirstSystemBay = noNebulaFirstSystemBay + 1;
					else
						noNebulaFirstSystemBay = noNebulaFirstSystemBay + 2;
				}
			}
			else
			{
				for(var i:int = 1; i <= 4 ; i++)
				{
					if(i%2 == 0)
						noNebulaFirstSystemBay = noNebulaFirstSystemBay + 1;
					else
						noNebulaFirstSystemBay = noNebulaFirstSystemBay + 2;
				}
				for(var j:int = 5; j <= cfg.noEngines; j++)
				{
					if(j%2 == 0)
						noNebulaSecondSystemBay = noNebulaSecondSystemBay + 1;
					else
						noNebulaSecondSystemBay= noNebulaSecondSystemBay + 2;
				}				
			}
			
			var systemBayIndicator:Boolean = true; // indicator if we are on the first or second bay
			var engineIndex:int = 1;
			var daeIndex:int = 0; 
			var indexBehindEngine:int = 0; //this is dae population order index (used for drive spread) 
			var dae:DAE = null;
			var noNebulaInSystemBay:int;
			var isFirstBay:Boolean = true;
			
			for each(var bay:Bay in cfg.children)
			{
				if(isFirstBay)
				{
					noNebulaInSystemBay = noNebulaFirstSystemBay;
					indexBehindEngine = 0;
				}
				else
				{
					noNebulaInSystemBay = noNebulaSecondSystemBay;
					indexBehindEngine = 5;
				}

				if(cfg.noEngines > 4)
					isFirstBay = false;
				if(systemBayIndicator)
				{
					if(bay.isSystemBay) //this should be correct always but check it anyway
					{
						
						var parentEngineInd:int; // DAE's engine index 
						var daePos:int; // DAE's index position within sys bay
						
						for(daeIndex = 0; daeIndex < noNebulaInSystemBay; daeIndex++)
						{
							parentEngineInd = engineIndex++;
							if(parentEngineInd % 2 == 0)
							{
								daePos = sysNebulaLocations[daeIndex];
								
								bay.addChild(dae = new Nebula(Position.getFromCacheByType(Position.BAY_ENCLOSURE, daePos), parentEngineInd));
								
								dae.indexBehindEngine = indexBehindEngine;
								
								indexBehindEngine++;
							}
							else
							{
								daePos = sysNebulaLocations[daeIndex];
								
								bay.addChild(dae = new Nebula(Position.getFromCacheByType(Position.BAY_ENCLOSURE, daePos), parentEngineInd));
								
								dae.indexBehindEngine = indexBehindEngine;
								
								daePos = sysNebulaLocations[daeIndex+1];
								
								daeIndex++;
								
								bay.addChild(dae = new Nebula(Position.getFromCacheByType(Position.BAY_ENCLOSURE, daePos), parentEngineInd));
								
								dae.indexBehindEngine = indexBehindEngine;
								
								indexBehindEngine++;
							}
						}
					}
					systemBayIndicator = true;
				}
			}
	
			cfg.noNebula = totalNebulas;
		}
		
		public override function validateSupportedDriveTypes(totCapacity:Number, raid:DriveRaidLevel, engineCount:int):ArrayCollection
		{
			var supportedDrives:ArrayCollection = new ArrayCollection();
			var driveTypes:ArrayCollection = new ArrayCollection([DriveType.FLASH_NVM_1920GB, DriveType.FLASH_NVM_3840GB, DriveType.FLASH_NVM_7680GB]);
			
			var drivePacksForRaid66ForNebula:ArrayCollection = new ArrayCollection([11.3, 22.6, 45.1]);
			var drivePacksForRaid57ForNebula:ArrayCollection = new ArrayCollection([13.2, 26.4, 52.6]);
			var drivePacksForRaid53ForNebula:ArrayCollection = new ArrayCollection([5.6, 11.3, 22.6]);
			
			var maxNumberOfCapacityPacksPerDAE:int = 4;
			
			var drivePacks:ArrayCollection;
			if(raid == DriveRaidLevel.R66_Nebula)
			{
				drivePacks = drivePacksForRaid66ForNebula;
				raid4_8_drives = true;
			}
			else if(raid == DriveRaidLevel.R53_Nebula)
			{
				maxNumberOfCapacityPacksPerDAE = 8;
				drivePacks = drivePacksForRaid53ForNebula;
				raid4_8_drives = false;
			}
			else
			{
				drivePacks = drivePacksForRaid57ForNebula;
				raid4_8_drives = true;
			}
			
			var numberOfDAEs:int = 0; //based on number of DAEs we will calculate supported drive types
			
			var i:int = 1;
			while(i<=engineCount)
			{
				if(i%2 !=0)
					numberOfDAEs += 2;
				else
					numberOfDAEs++;
				i++;
			}
			
			var actualNumberOfCapacityPacks:Number;
			for(var j:int = 0; j < driveTypes.length; j++)
			{
				actualNumberOfCapacityPacks = totCapacity/drivePacks[j];
				if(actualNumberOfCapacityPacks % 1 != 0 && actualNumberOfCapacityPacks > 1)
				{
					actualNumberOfCapacityPacks = actualNumberOfCapacityPacks - (actualNumberOfCapacityPacks % 1) + 1;
				}
				if(actualNumberOfCapacityPacks >= engineCount && actualNumberOfCapacityPacks <= maxNumberOfCapacityPacksPerDAE*engineCount)
					supportedDrives.addItem(driveTypes[j]);
			}
			return supportedDrives;
		}
		
		public override function populateWithDrives(config:Configuration_VG3R, dae:DAE = null):void
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
					this.populateDAEs(nebulaDAEs, nebulaDriveMap, config.noEngines, engineNo);
				}
			}
		}
		
		protected override function populateDAEs(daes:Array, driveMap:DictionaryExt, engineCount:Number, engineNo:int = 0):void
		{
			var populationIndices:Array;
			
			//populate Vikings/Voyagers/Tabasco
			if(driveMap.keys.length > 0 && daes.length > 0)
			{
				daes.sortOn('indexBehindEngine', Array.NUMERIC);
				
				var ddids:ArrayCollection = new ArrayCollection(driveMap.keys);
				ddids.sort = new Sort();
				//ddids.sort.compareFunction = sortIdsByRaidSize;
				
				populationIndices = new Array();
				for(var ind:int = 0; ind < daes.length; ind++)
				{
					populationIndices.push(0);
				}
				
				for(var q:int = 0; q < ddids.length; q++)
				{
					// for Tabasco it should be always one drive definition (same RAID, same drive Type)
					var driveDef:DriveDef = DriveRegister.getById(int(ddids[q]));
					var actives:int = int(driveMap[driveDef.id].active);
					var spares:int = int(driveMap[driveDef.id].spare);
					var totalDrives:int = actives + spares;
					
					var posType:int =  Position.DAE_NEBULA_ENCLOSURE;
					var positionIndexArray:Array = NEBULA_POPULATION_INDICES;
					
					var driveNo:int = 0;
				}
				while (driveNo < totalDrives)
				{
					var spare:int = 1;
					
					var numOfDaes:int = 0;
					var engineIndicator:Boolean = false // if we have another engine after odd one, we have to feel second dae before exiting 
					var minNumberOfDrivesPerDae:int;
			
					if(engineNo % 2 == 0)
						numOfDaes = 1;
					else
					{
						if(engineCount > engineNo)
							engineIndicator = true;
						numOfDaes = 2;						
					}

					
					if(engineNo % 2 == 0)
					{
						var driveIndex:int = 25;
						driveNo += remainingDrivesForSecondDAE;
						for(var i:int = 0; i < actives - remainingDrivesForSecondDAE; i++)
						{
							(daes[numberOfDAEs] as DAE).addChild(new Drive(new Position(posType, positionIndexArray[driveIndex--]), driveDef, false));
							driveNo++;
						}
						driveNo++; // added because we added second spare in previuos DAE
						remainingDrivesForSecondDAE = 0;

					}
					else
					{
						for(var numberOfDAEs:int = 0; numberOfDAEs < numOfDaes; numberOfDAEs++)
						{
							if(numberOfDAEs == 0)
							{
								var bool:Boolean = true;
								var numberOfDrives:int = 0;
								var numberOfDrivesForSecondDAE:int = 0;
								while(bool)
								{
									if(actives - numberOfDrives > numberOfDrives )
									{
										(daes[numberOfDAEs] as DAE).addChild(new Drive(new Position(posType, positionIndexArray[numberOfDrives+1]), driveDef, false));
										numberOfDrives++;
										driveNo++;
										numberOfDrivesForSecondDAE++;
										if(numberOfDrives == 12)
										{
											for(var index:int = numberOfDrives; numberOfDrives < actives - 12; index++)
											{
												(daes[numberOfDAEs] as DAE).addChild(new Drive(new Position(posType, positionIndexArray[index]), driveDef, false));
												numberOfDrives++;
												driveNo++
											}
											bool = false;
										}
									}
									else
										bool = false;
								}
							}
							else
							{
								var secondEngineDrives:int = 1;
								for (var driveIndex:int = 0 ; driveIndex < numberOfDrivesForSecondDAE; driveIndex++)
								{
									(daes[numberOfDAEs] as DAE).addChild(new Drive(new Position(posType, positionIndexArray[driveIndex+1]), driveDef, false));
									driveNo++;
									if(driveIndex <= 8)
										remainingDrivesForSecondDAE++;
								}
								if(engineIndicator)
								{
									var indexForSecondEngine:int = 25;
									for(var i=0;i < remainingDrivesForSecondDAE; i++)
									{
										(daes[numberOfDAEs] as DAE).addChild(new Drive(new Position(posType, positionIndexArray[indexForSecondEngine--]), driveDef, false));
										driveNo++;
									}
									(daes[numberOfDAEs] as DAE).addChild(new Drive(new Position(posType, positionIndexArray[12]), driveDef, true));

										
								}
								(daes[numberOfDAEs] as DAE).addChild(new Drive(new Position(posType, positionIndexArray[13]), driveDef, true));
								driveNo++;
							}
						}
					}
					
				}
			}
		}
		
		public override function getCurrentPortConfiguration():PortConfiguration
		{
			var pc:ArrayCollection = getAllowedPortConfigurations();		
			for each (var port:PortConfiguration in pc) {
				if (port.type == _currentPortConfig) {
					return port;
				}
			}
			
			return null;
		}
	}
}