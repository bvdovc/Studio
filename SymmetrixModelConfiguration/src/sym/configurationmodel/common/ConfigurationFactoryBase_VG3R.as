package sym.configurationmodel.common
{
	
	import flash.sampler.NewObjectSample;
	import flash.text.engine.CFFHinting;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.collections.Sort;
	
	import flashx.textLayout.elements.Configuration;
	
	import sym.configurationmodel.utils.AllFlashArrayUtility;
	import sym.configurationmodel.utils.IntUtil;
	import sym.configurationmodel.utils.TieringUtility_VG3R;
	import sym.configurationmodel.v250f.ConfigurationFactory;
	import sym.configurationmodel.v450f.ConfigurationFactory;
	import sym.configurationmodel.v950f.ConfigurationFactory;
	import sym.objectmodel.common.Bay;
	import sym.objectmodel.common.ComponentBase;
	import sym.objectmodel.common.Configuration_VG3R;
	import sym.objectmodel.common.Constants;
	import sym.objectmodel.common.DAE;
	import sym.objectmodel.common.Drive;
	import sym.objectmodel.common.DriveGroup;
	import sym.objectmodel.common.Engine;
	import sym.objectmodel.common.EnginePort;
	import sym.objectmodel.common.EnginePortGroup;
	import sym.objectmodel.common.EthernetSwitch;
	import sym.objectmodel.common.InfinibandSwitch;
	import sym.objectmodel.common.KVM;
	import sym.objectmodel.common.ObjectCache;
	import sym.objectmodel.common.PDP;
	import sym.objectmodel.common.PDU;
	import sym.objectmodel.common.PDU_VG3R;
	import sym.objectmodel.common.PortConfiguration;
	import sym.objectmodel.common.Position;
	import sym.objectmodel.common.SPS;
	import sym.objectmodel.common.Viking;
	import sym.objectmodel.common.Voyager;
	import sym.objectmodel.driveUtils.DictionaryExt;
	import sym.objectmodel.driveUtils.DriveDef;
	import sym.objectmodel.driveUtils.DriveRegister;
	import sym.objectmodel.driveUtils.enum.DriveRaidLevel;
	import sym.objectmodel.driveUtils.enum.DriveType;
	import sym.objectmodel.driveUtils.enum.HostType;

	public class ConfigurationFactoryBase_VG3R extends ConfigurationFactoryBase
	{
		private static const DAE_TYPE_VALUES:Array = [DAE.Voyager, DAE.Viking];
		
		private static const NO_SYSTEM_BAYS_1:Object = {1: 1, 2: 1};// Single/Dual-engine
		private static const NO_SYSTEM_BAYS_2:Object = {1: 2, 2: 1};
		private static const NO_SYSTEM_BAYS_3:Object = {1: 3, 2: 2};
		private static const NO_SYSTEM_BAYS_4:Object = {1: 4, 2: 2};
		private static const NO_SYSTEM_BAYS_5:Object = {1: 5, 2: 3};
		private static const NO_SYSTEM_BAYS_6:Object = {1: 6, 2: 3};
		private static const NO_SYSTEM_BAYS_7:Object = {1: 7, 2: 4};
		private static const NO_SYSTEM_BAYS_8:Object = {1: 8, 2: 4};
		
		private static const SB_VOYAGER_LOCATIONS_1ENGINE:Array = [13, 17, 9, 21, 27, 5];
		private static const SB_VOYAGER_LOCATIONS_2ENGINES:Array = [13, 17, 9, 5];
		private static const SB_VIKING_LOCATIONS_1ENGINE:Array = [13, 17, 9, 21, 27, 5]//[11, 14, 8, 17, 27, 5];
		private static const SB_VIKING_LOCATIONS_2ENGINES:Array = [13, 17, 9, 5]//[11, 8, 14, 5];
		private static const STRGBAY_VOYAGER_LOCATIONS:Array = [9, 25, 13, 29, 5, 21, 17, 33];
		private static const STRGBAY_VIKING_LOCATIONS:Array = [9, 25, 13, 29, 5, 21, 17, 33];//[8, 20, 11, 23, 5, 17, 14, 26];
		private static const MIXED_DAE_POSITION:Array = [13, 9, 5, 17, 21, 27];
		
		public static const SB_TABASCO_LOCATIONS_2ENGINES:Array = [7, 9, 17, 19];
		public static const SB_NEBULA_LOCATIONS_2ENGINES:Array = [7, 9, 17, 19];
		
		//Nebula locations for PowerMax 8000
		public static const SB_NEBULA_LOCATION_PM8000_ALL_ENGINES:Array = [3, 5, 7, 31, 33, 35];
		
		public static const MAX_DAES_2_ENGINE_SYSBAY:int = 4;
		public static const MAX_DAES_1_ENGINE_SYSBAY:int = 6;
		public static const MAX_DAES_IN_STORAGEBAY:int = 8;
		public static const MAX_DAES_1_ENGINE_TOTAL:int = 6;
		public static const MAX_DAES_2_ENGINE_TOTAL:int = 4;
        public static const MAX_DAES_BEHIND_ENGINE:Object = {1: 6, 2: 2}; // Single/Dual engine
		public static const MAX_DAES_BEHIND_ENGINE_TABASCO:int = 2;
		public static const MAX_DAES_BEHIND_ENGINE_NEBULA: int = 2;
		public static const MAX_DAES_TABASCO_SYSBAY:int = 4;
			
		private static const SYSBAY_TYPES:Array = [Configuration_VG3R.SINGLE_ENGINE_BAY, Configuration_VG3R.DUAL_ENGINE_BAY];
		
		private static const STORAGE_BAY_1A:String = "sb1A";
		private static const STORAGE_BAY_2A:String = "sb2A"; 
		private static const STORAGE_BAY_3A:String = "sb3A"; 
		private static const STORAGE_BAY_4A:String = "sb4A"; 
		
		private static const SBAY1A:int = 10;
		private static const SYSTEMBAYPOSITION:int = 20;
		private static const SBAY2A:int = 40;
		private static const SBAY3A:int = 50;
		private static const SBAY4A:int = 80;
		
		private const CACHE_POSITION_SPS_LEFT_1:String = Position.generateCacheKey(Position.BAY_HALF_ENCLOSURE_LEFT, 1);
		private const CACHE_POSITION_SPS_RIGHT_1:String = Position.generateCacheKey(Position.BAY_HALF_ENCLOSURE_RIGHT, 1);
		private const CACHE_POSITION_SPS_LEFT_19:String = Position.generateCacheKey(Position.BAY_HALF_ENCLOSURE_LEFT, 19);
		private const CACHE_POSITION_SPS_RIGHT_19:String = Position.generateCacheKey(Position.BAY_HALF_ENCLOSURE_RIGHT, 19);
		private const CACHE_POSITION_SPS_LEFT_39:String = Position.generateCacheKey(Position.BAY_HALF_ENCLOSURE_LEFT, 39);
		private const CACHE_POSITION_SPS_RIGHT_39:String = Position.generateCacheKey(Position.BAY_HALF_ENCLOSURE_RIGHT, 39);
		private const CACHE_POSITION_PDUVG3R_LEFT_29:String = Position.generateCacheKey(Position.BAY_HALF_ENCLOSURE_RIGHT, 29);
		private const CACHE_POSITION_PDUVG3R_RIGHT_29:String = Position.generateCacheKey(Position.BAY_HALF_ENCLOSURE_RIGHT, 29);
		private const CACHE_POSITION_ETHERNET_22:String = Position.generateCacheKey(Position.BAY_ENCLOSURE, 22);
		
		public static const PORT_CONFIGS:Array = [
			PortConfiguration.createIfNotCached(PortConfiguration.CONFIG1_VG3R, PortConfiguration.ENGINE_DIRECTOR_VG3R_POSITION_CACHE_KEY).clone()
		]; 

		public static const PORT_CONFIGS_ALL_FLASH:Array = [
			PortConfiguration.createIfNotCached(PortConfiguration.CONFIG_ALL_FLASH, PortConfiguration.ENGINE_DIRECTOR_VG3R_POSITION_CACHE_KEY).clone()
		]; 
		
		public static const PORT_CONFIGS_250F:Array = [
			PortConfiguration.createIfNotCached(PortConfiguration.CONFIG_ALL_FLASH_250F, PortConfiguration.ENGINE_DIRECTOR_VG3R_POSITION_CACHE_KEY).clone()
		]; 
		public static const PORT_CONFIGS_PM2000:Array = [
			PortConfiguration.createIfNotCached(PortConfiguration.CONFIG_ALL_FLASH_pm2000, PortConfiguration.ENGINE_DIRECTOR_VG3R_POSITION_CACHE_KEY).clone()
		];
		
		public static const PORT_CONFIG_SINGLE_ENGINE_PM8000:Array = [
			PortConfiguration.createIfNotCached(PortConfiguration.CONFIG_ALL_FLASH_SINGLE_ENGINE_PM8000, PortConfiguration.ENGINE_DIRECTOR_VG3R_POSITION_CACHE_KEY).clone()
		];
		
		public static const PORT_CONFIG_MULTI_ENGINE_PM8000:Array = [
			PortConfiguration.createIfNotCached(PortConfiguration.CONFIG_ALL_FLASH_MULTI_ENGINE_PM8000, PortConfiguration.ENGINE_DIRECTOR_VG3R_POSITION_CACHE_KEY).clone()
		];
		
		private var NO_ENGINES_MAP:Object = {
			1: {noSysBays: NO_SYSTEM_BAYS_1, DAEs: {1: {1: IntUtil.sequence(1, 6), 2: IntUtil.sequence(1, 2)}}}, // 1engine->1bay for single/dual engine -> different DAEs number for single and dual-engine 
			2: {noSysBays: NO_SYSTEM_BAYS_2, DAEs:{1: IntUtil.sequence(2, 4), 2: IntUtil.sequence(2, 12)}},
			3: {noSysBays: NO_SYSTEM_BAYS_3, DAEs:{2: IntUtil.sequence(3, 6), 3: IntUtil.sequence(3, 18)}},
			4: {noSysBays: NO_SYSTEM_BAYS_4, DAEs:{2: IntUtil.sequence(4, 8), 4: IntUtil.sequence(4, 24)}},
			5: {noSysBays: NO_SYSTEM_BAYS_5, DAEs:{3: IntUtil.sequence(5, 10), 5: IntUtil.sequence(5, 30)}},
			6: {noSysBays: NO_SYSTEM_BAYS_6, DAEs:{3: IntUtil.sequence(6, 12), 6: IntUtil.sequence(6, 36)}},
			7: {noSysBays: NO_SYSTEM_BAYS_7, DAEs:{4: IntUtil.sequence(7, 14), 7: IntUtil.sequence(7, 42)}},
			8: {noSysBays: NO_SYSTEM_BAYS_8, DAEs:{4: IntUtil.sequence(8, 16), 8: IntUtil.sequence(8, 48)}}
		}
			
		// flag if wizard is opened
		public var wizardTiering:Boolean = false;
		
        private static const VIKING_POPULATION_INDICES:Array = generateDrivePopulationIndices(DAE.Viking);
        private static const VOYAGER_POPULATION_INDICES:Array = generateDrivePopulationIndices(DAE.Voyager);
        public static const TABASCO_POPULATION_INDICES:Array = generateDrivePopulationIndices(DAE.Tabasco);
		public static const NEBULA_POPULATION_INDICES:Array = generateDrivePopulationIndices(DAE.Nebula);
		
		
		/**
		 * Sets SPS type, port config and tier solution for M factory
		 * 
		 */		
		public function ConfigurationFactoryBase_VG3R()
		{
            _currentSPSType = SPS.TYPE_LION;
			_currentPortConfig = PortConfiguration.CONFIG1_VG3R;
			_currentTierSolution = ConfigurationFilter.TIER_SOLUTION_DEFAULT;
		}

		/**
		 * initializes cache values
		 */
		public override function initializeCache():void
		{
			ObjectCache.instance.put(CACHE_POSITION_PDUVG3R_LEFT_29, new Position(Position.BAY_HALF_ENCLOSURE_LEFT, 29), false); //put if null
			ObjectCache.instance.put(CACHE_POSITION_PDUVG3R_RIGHT_29, new Position(Position.BAY_HALF_ENCLOSURE_RIGHT, 29), false); //put if null
			
			ObjectCache.instance.put(CACHE_POSITION_ETHERNET_22, new Position(Position.BAY_HALF_ENCLOSURE_LEFT, 22), false); //put if null
			ObjectCache.instance.put(CACHE_POSITION_ETHERNET_22, new Position(Position.BAY_HALF_ENCLOSURE_RIGHT, 22), false); //put if null
			
			// Bay Enclosures caches
			for (var enclosure:int=1; enclosure <= 41; enclosure++)
			{
				ObjectCache.instance.put(Position.generateCacheKey(Position.BAY_ENCLOSURE, enclosure), new Position(Position.BAY_ENCLOSURE, enclosure), false);
			}
		}
        
		protected function factoryName():String
		{
			return "";
		}
		
		public override function get daeType():Array
		{
			return DAE_TYPE_VALUES;
		}
		
		public function get dispersed_m():Array
		{
			return null;
		}
		
		
		public function get baseConfigs():Array
		{
			return [];
		}
		
		public function get mixedConfigs():Array
		{
			return [];
		}
		
		public function get seriesName():String
		{
			return "";
		} 
		
		public function get modelName():String
		{
			return "";
		} 
		
		public function get totCapacity():Number
		{
			return -1;
		}

		public override function get sysBayType():Array
		{
			return SYSBAY_TYPES;
		}
		
		public override function isKVMvisible(kvm:KVM, viewSide:String):Boolean 
		{
			if (viewSide == Constants.REAR_VIEW_PERSPECTIVE)
			{
				return kvm.visibleInRearView;	
			}
			
			return true;
		} 
		
		public function get engineIOPS():Object
		{
			return 0;
        }
            
        
        /**
         * Generates array of drive population indices
         * @param daeType
         * @return array 
         */        
        private static function generateDrivePopulationIndices(daeType:int):Array
        {	
			var indices:Array;
			
			if (daeType == DAE.Tabasco)
			{
				indices = [];
				
				for (var i:int = 1; i <= Drive.TABASCO_DRIVES_NUMBER; i++)
				{
					indices.push(i);
				}
				
				return indices;
			}
			
			if(daeType == DAE.Nebula)
			{
				indices = [];
				
				for(var n:int = 0; n <= 25; n++)
				{
					indices.push(n);
				}
				
				return indices;
			}
			
            indices = daeType == DAE.Viking ? 
                [100, 105, 110, 115, 101, 106, 111, 116, 102, 107, 112, 117, 103, 108, 113, 118, 104, 109, 114, 119] :
                [48, 51, 54, 57, 49, 52, 55, 58, 50, 53, 56, 59];
            
            const offset:int = daeType == DAE.Viking ? 20 : 12;
            const appendRows:int = daeType == DAE.Viking ? 5 : 4;
            
            for(var row:int = 1; row <= appendRows; row++)
            {
                for(var ind:int = 0; ind < offset; ind++)
                {
                    indices.push(indices[ind] - offset * row);
                }
            }
            
            return indices;
        }
        
		/**
		 * Gets most complex configs from base configs
		 * @param baseConfigurations indicates default base configs
		 * @return 
		 * 
		 */		
		private function getMostComplexConfigs(baseConfigurations:Array):Array
		{
			var configs:Array = [];
			var maxDaeCount:int = noEngines * MAX_DAES_1_ENGINE_TOTAL;
			
			for each (var cfg:Configuration_VG3R in baseConfigurations)
			{
				if (cfg.totalDaeNumber == maxDaeCount)
				{
					configs.push(cfg);
				}
			}
			
			return configs;
		}
		
		/**
		 * Check disperse filter result
		 * @param filter specifies configuration filter 
		 * @return <code> true </code> if disperse config can be generated. Otherwise <code> false </code>
		 * 
		 */
		

		public function validateDispersedValues(filter:ConfigurationFilter):Boolean
		{
			if (filter.dispersed_m[0] == ConfigurationFilter.NO_DISPERSED_DEFAULT)
			{
				return true;
			}
			
			var ind:int;
			var systemBays:int;
			var dispersedValues:Array = filter.dispersed_m.sort(Array.NUMERIC);

			for each (var config:Configuration_VG3R in _configurations)
			{
				var engines:int=filter.noEngines == -1 ? config.noEngines : filter.noEngines;
				if (config.noEngines == engines && config.noEngines > 1)
				{
					systemBays = filter.noSystemBays == -1 ? config.countSystemBay : filter.noSystemBays;
					if (config.countSystemBay == systemBays)
					{
						var noSysBays:int = NO_ENGINES_MAP[engines].noSysBays[config.sysBayType];
						if(config.factory.seriesName == "pm_8000")
							noSysBays = 2;
							
						if (noSysBays > 0 && noSysBays == systemBays)
						{
							if (systemBays >= dispersedValues[0] && systemBays >= dispersedValues[dispersedValues.length - 1])
							{
								return true;
							}
						}
					}
				}
			}
			
			return false;
		}
        
        /**
         * Determines and maps number of drives per each drive definition for each drive
		 * @param noEngines indicates total number of engines
         * @param engineDrives array holding dictionary with key value pairs -  [driveDef.id] = { active:int, spare:int }
         * @param driveGroups list of drive groups containing drive definitions and active drive count
         * @param driveSize   Viking or Voyager
         * @return Number of DAEs which should be validated on later use
         */        
        protected function mapDriveCountToEngineArray(noEngines:int, engineDrives:Array, driveGroups:Array, driveSize:int):void
        {
            //for each group find even number of drives that is spread across Engines using formula NUMBER_OF_ENGINES * RAID_SIZE * RAID_GROUP_COUNT = TOTAL_DRIVES_PER_GROUP
            //even drive count for each group behind each engine is equal to DRIVES_PER_ENGINE * RAID
           
            //lets sum up drives for the same drive definision
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
            
            //for each drive group determine how many drives go in each engine
            
            var driveReminder:Dictionary = new Dictionary(); //remaining drives that should be split equally as much as possible
            var evenDrivesPerEngine:Dictionary = new Dictionary();  //even number of drives for each engine per drive def
            var ids:ArrayCollection = new ArrayCollection();
            var totalDrivesPerEngine:Array = new Array();
           
            for(var eng:int = 0; eng < noEngines; eng++)
            {
                totalDrivesPerEngine.push(0);
            }
            
            for( var defId:String in dgSum)
            {
                var def:DriveDef = DriveRegister.getById(int(defId));
                
                var even_count:int = int( dgSum[defId] / (def.raid.raidGroupSize * noEngines) ) * def.raid.raidGroupSize;
                evenDrivesPerEngine[defId] = even_count;
                
                driveReminder[defId] = int(dgSum[defId]) - even_count * noEngines;
                ids.addItem(int(defId)); //add id of drive def that have remaining drives, then we will sort it from highest to lowest RAID size and try to spread evenly
                
                //append total count behind every engine
                for(var engX:int = 0; engX < noEngines; engX++)
                {
                    totalDrivesPerEngine[engX] += even_count;
                    if(engineDrives[engX][def.id] == null)
                    {
                        engineDrives[engX][def.id] = {active: even_count, spare: 0};
                    }
                }
            }
            
            //spread the remaining DAEs
            
            //sort ids by associated RAID size
            ids.sort = new Sort();
            ids.sort.compareFunction = sortIdsByRaidSize;
            ids.refresh();
            
            for(var ind:int = 0; ind < ids.length; ind++)  //iterate through def ids sorted by RAID size from bigger to smaller and put them behind minimum populated engine
            {
                var drivesToAdd:int = int(driveReminder[ids[ind]]);  //get drive count to add
                var dd:DriveDef = DriveRegister.getById(ids[ind]);  //determine RAID size
                
                for(var di:int = dd.raid.raidGroupSize; di <= drivesToAdd; di += dd.raid.raidGroupSize)
                {
                    var engWithMinimum:int = IntUtil.minValueIndex(totalDrivesPerEngine); 
                    
                    totalDrivesPerEngine[engWithMinimum] += dd.raid.raidGroupSize;
                    engineDrives[engWithMinimum][dd.id].active += dd.raid.raidGroupSize;
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
         * Calculates number of daes per engine
         * @param engineDriveMap Engine-Drive map containing number of drives per each drive type for each engine
         * @param daeType Viking or voyager
         * @return number od DAEs per engine.
         * <p>
         * <b>Description:</b>
         * </p>
         * <b>Method does not validate returned DAE count. It simply returns needed number of DAES that can fit provided drives</b>
         * <p>
         * Finds engine with maximal number of drives, tries to fit as much as possible drives to a minimum number of DAEs starting from biggest to lowest (first MOD8 than MOD4)
         * </p>
         * <i>Note that this method does not populate DAEs. For this purpose separate method will be implemented</i>
         */        
        private function determineDAECountPerEngine(engineDriveMap:Array, daeType:int):int
        {
            var fullestEngineIndex:int = 0;
            var maxDriveCount:int = 0;
            var edMap:Dictionary = null;
            
            //find fullest engine - we will use him to determine minimal DAE count for each engine
            for(var fe:int = 0; fe < engineDriveMap.length; fe++)
            {
                edMap = engineDriveMap[fe];
                var count:int = 0;
                
                for(var ddId:Object in edMap)
                {
                    var ddef:DriveDef = DriveRegister.getById(int(ddId)); //get drive definition so we can determing drive size (DAETYPE)
                    if(ddef.size == daeType)
                    {
                        var driveCountObj:Object = edMap[ddId];
                        count += int(driveCountObj.active) + int(driveCountObj.spare);
                    }
                }
                
                if(count == 0) return 0;  //at least one RAID group must exist behind each engine - so, no point going further
                
                if(maxDriveCount < count)
                {
                    fullestEngineIndex = fe;
                    maxDriveCount = count;
                }
            }
            
            edMap = engineDriveMap[fullestEngineIndex] as Dictionary;   //get the maximum engine so that we can determine DAE count based on drives in this engine
            
            const maxDrivesPerDAE:int = daeType == DAE.Viking? Drive.VIKING_DRIVES_NUMBER : Drive.VOYAGER_DRIVES_NUMBER;
            
            //sort drive def ids by RAID size starting from biggest to smalles group (and from MOD8 to MOD4)
            var ddids:ArrayCollection = new ArrayCollection();
            
            for (var did:Object in edMap)
            {
                if(DriveRegister.getById(int(did)).size == daeType)
                {
                    ddids.addItem(did);
                }
            }
            
            ddids.sort = new Sort();
            ddids.sort.compareFunction = sortIdsByRaidSize;
            ddids.refresh();
            
            //Drive spreading, pressured not-outspread method
            //this is not correct method of populating DAEs, we are just trying to fit as narrowly as possible
            //spares are populated one by one in dae with minimal number of drives
            var currentDAE:int = 0;
            var daeArray:Array = new Array();   //DAE drive empty slot count
            daeArray.push(maxDrivesPerDAE);     //there will definitely be one at the beggining
            
            
            //get each drive definition and its number of active and spare drives
            for(var x:int = 0; x < ddids.length; x++)   
            {
                var driveDefinition:DriveDef = DriveRegister.getById(int(ddids[x]));
                var driveCountMap:Object = edMap[ddids[x]];
                var activeCount:int = driveCountMap.active;
                var spareCount:int = driveCountMap.spare;
                
                currentDAE = 0;  //always reset and try to populate from beggining
                
                if(driveDefinition.raid.isMod8) //modulo8 -> special treatment, spreading across 2 DAEs
                {
                    if(daeArray.length < 2) //add another DAE
                    {
                        daeArray.push(maxDrivesPerDAE);
                    }
                } 
               
                var daeFreeRaidSlots:int = 0;  //free slots in current DAE
                var raidSize:int = driveDefinition.raid.mod;
                
				while(activeCount > 0)
                {
                    
                    daeFreeRaidSlots = int(daeArray[currentDAE] / raidSize);   //how much RAID groups can be fit 
                    
                    var raidGroupCount:int = IntUtil.min(daeFreeRaidSlots, activeCount/raidSize); //how much RAID groups are available for placing
                    
                    if(raidGroupCount > 0)      //place them - reduce free slot number, reduce number of active drives
                    {
                        daeArray[currentDAE] -= raidGroupCount * raidSize; 
                        activeCount -= raidGroupCount * raidSize;
                    }
                    else   //there are still non-populated active drives but there are no place in current DAE, go to next
                    {   
                        currentDAE++;
                        if(daeArray.length == currentDAE)  //add if there isn't next one
                        {
                            daeArray.push(maxDrivesPerDAE); 
                        }
                        continue;
                    }
                }
                
                //determine if all DAEs are fully populated
                //maxValueIndex returns index of dae free slot array that have maximum value
                //if this number is 0 that means there are no free slots any more -> add new DAE
                var maxIndex:int = IntUtil.maxValueIndex(daeArray);
                if(daeArray[maxIndex] == 0 && spareCount > 0)
                {
                    daeArray.push(maxDrivesPerDAE);
                    maxIndex = daeArray.length - 1;
                }
                
                //its OK for MOD8 too, because thay will be populated first in paired DAEs
                //place one by one in least occupied DAE
                while(spareCount > 0)
                {
                    if(daeArray[maxIndex] == 0) //all daes are populated
                    {
                        daeArray.push(maxDrivesPerDAE);
                        maxIndex = daeArray.length - 1;
                    }
                    daeArray[maxIndex]--;
                    spareCount--;
                    maxIndex = IntUtil.maxValueIndex(daeArray);
                }
            }
            
            return daeArray.length;
        }
        
        /**
         * Compare function for drive definition sorting by RAID size 
         * @param id1
         * @param id2
         * @param fields
         * @return 
         * 
         */        
        private function sortIdsByRaidSize(id1:int, id2:int, fields:Array = null):int
        {
            var def1:DriveDef = DriveRegister.getById(id1);
            var def2:DriveDef = DriveRegister.getById(id2);
            
            var pop1:int = TieringUtility_VG3R.RAID_POPULATION_ORDER.indexOf(def1.raid);
            var pop2:int = TieringUtility_VG3R.RAID_POPULATION_ORDER.indexOf(def2.raid);
            
            if(pop1 < pop2) return -1;
            else if(pop1 == pop2) return 0;
            else return 1;
        }
        
        /**
         * Creates configuration clone for given dispersed values 
         * @param cfg
         * @param dispersedValues
         * @return configuration
         * IF same configuration doesn't exist it will be added
         */        
        public function createDispersionClone(cfg:Configuration_VG3R, dispersedValues:Array):Configuration_VG3R
        {
            dispersedValues.sort(Array.NUMERIC);
            var disConfig:Configuration_VG3R = createConfiguration(cfg.noEngines, cfg.sysBayType, cfg.driveType, cfg.numberOfDrives, dispersedValues, cfg.driveGroups, cfg.tierSolution, cfg.osUsableCapacity, cfg.mfUsableCapacity, true);
            
            if(disConfig)
            {
				// set capacity, host type, File storage use
				disConfig.totCapacity = cfg.totCapacity;
				disConfig.hostType = cfg.hostType;
				disConfig.fileCapacity = cfg.fileCapacity;
				disConfig.osUsableCapacity = cfg.osUsableCapacity;
				disConfig.mfUsableCapacity = cfg.mfUsableCapacity;
				disConfig.enginePorts = cfg.enginePorts;
				disConfig.engineModules = cfg.engineModules;
				// populate engines with modules from its base config
				//this.populateEngine(disConfig, null, cfg);
				
                appendConfiguration(disConfig);
            }
            
            return disConfig;
        }
		/**
		 * Creates configuration, non-mixed and mixed
		 * @param noEngines         Total number of engines  
		 * @param sysBayType   		Single/Dual-Engine bay type
		 * @param dispersedBays     Array of dispersed system bay indices.  [-1] if this is not dispersed configuration
		 * @param driveGroups       List of drive definitions with their number 
		 * @param tier              Tier selection - Custom Config is default
		 * @param osCapacity        Open System capacity, default value 0
		 * @param mfCapacity        Mainframe capacity, default value 0
		 * @param isDispersionClone indicates if this is a (non) dispersion clone of existing config       
		 * @return VG3R Configuration instance
		 * <p>
		 * <i>The method requires valid parameters</i>
		 * </p>
		 */      
        public function createConfiguration(noEngines:int,
											sysBayType:int,
											driveType:String,
											noDrives: int,
											dispersedBays:Array,
											driveGroups:Array,
											tier:int = TieringUtility_VG3R.TIER_CUSTOM_CONFIG,
											osCapacity:Number = 0,
											mfCapacity:Number = 0,
											isDispersionClone:Boolean = false):Configuration_VG3R
        {
            if(noEngines <= 0) 
            {
                return null;
            }
			
			//skip validation when import is from sizer XML
			if(ComponentBase.importConf950SizerXML == false)
			{
	            if(!validateDriveGroupForEngineCount(noEngines, driveGroups, isDispersionClone))
	            {
	                return null;
	            }
			}
            
            var noSysBays:int = NO_ENGINES_MAP[noEngines].noSysBays[sysBayType];
			
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
     		
            //determine and set DAE type
            var dg:DriveGroup = driveGroups[0] as DriveGroup;
            cfg.daeType = dg.driveDef.size;
   
            for(var dgi:int = 1; dgi < driveGroups.length; dgi++)
            {
                dg = driveGroups[dgi] as DriveGroup;
                if(cfg.daeType !=  dg.driveDef.size)
                {
                    cfg.daeType = DAE.MixedVoyager;
                    break;
                }
            }
             
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
            //generates system bays
            for(var i:int = 0; i < noSysBays; i++)
            {
                bay = generateSystemBay(i, sysBayType, cfg.daeType, dispersedBays[0] != -1 ? sysBayValues : null, dispersedBays[0] != -1 ? dispersedBays : null, factoryName(), noEngines);
                cfg.addChild(bay);
            } 
            
            //removing Infiniband switches and IB modules if this is configuration with only one engine
            //in this case bay will exist and will be the first system bay
            if(cfg.noEngines == 1)
            {
                for(var childIndex:int = 0; childIndex < bay.children.length; childIndex++)
                {
                    if(bay.children[childIndex] is InfinibandSwitch)
                    {
                        delete bay.children[childIndex];
                        childIndex --;
                    }
                    if(bay.children[childIndex] is Engine)
                    {
                        var engine:Engine = bay.children[childIndex] as Engine;
                        for(var epIndex:int = 0; epIndex < engine.children.length; epIndex++)
                        {
                            var enginePort:EnginePort = engine.children[epIndex] as EnginePort;
                            if(enginePort && enginePort.type == EnginePort.IB_MODULE && engine.removeChild(enginePort)) 
                            {
                                epIndex--;
                            }
                        }
                    }
                }
            }
            //calculate number of daes 
            
            var engineDriveMap:Array = new Array(); 
            for(var ne:int = 0; ne < noEngines; ne++) 
				engineDriveMap[ne] = new Dictionary(); //values - [driveDef.id] = {active:int, spare:int}
			
            mapDriveCountToEngineArray(noEngines, engineDriveMap, driveGroups, DAE.Viking);
            mapDriveCountToEngineArray(noEngines, engineDriveMap, driveGroups, DAE.Voyager);
            
            var noVikingsPerEngine:int = determineDAECountPerEngine(engineDriveMap, DAE.Viking);
            var noVoyagersPerEngine:int = determineDAECountPerEngine(engineDriveMap, DAE.Voyager);
            
            if((noVikingsPerEngine + noVoyagersPerEngine) > MAX_DAES_BEHIND_ENGINE[sysBayType])
            {
                return null;
            }
             
            cfg.driveCountMap = engineDriveMap;
            cfg.driveGroups = TieringUtility_VG3R.cloneDriveGroups(driveGroups);
        
            var noVikingDAEs:int = noVikingsPerEngine * noEngines;
            var noVoyagerDAEs:int = noVoyagersPerEngine * noEngines;
            
			if (this.modelName == Constants.VMAX_450F || this.modelName == Constants.VMAX_950F)
			{
				// 450/850f configuration ID
				if(this.modelName == Constants.VMAX_450F)
				{
	            	cfg.id = this.seriesName + noEngines + noVikingDAEs + cfg.activesAndSpares;
				}
				else //hardcoded for now, should be made more generic
				{
					cfg.id = "950" + noEngines + noVikingDAEs + cfg.activesAndSpares;
				}
			}
			else
			{
				// VMAX3 - 100/200/400K config ID
	            cfg.id = this.seriesName + noEngines + noVoyagerDAEs + noVikingDAEs + cfg.activesAndSpares + sysBayType;
			}
			
			// this will not be executed since Storage Bays are removed from configurations
			// the only bays that participate into configs are System bays
            if(cfg.dualEngine && (noVikingDAEs + noVoyagerDAEs)/noSysBays > 4) //we need storage bays
            {
                for (var n:int = 1; n <= noSysBays; n++)
                {
                    var sb:Bay = generateStorageBay("sb" + n + "A", cfg);
                    sb.attachedToSystemBayWithIndex = n - 1;
                }
            }
            
            spreadDAEs(cfg, noVikingDAEs, noVoyagerDAEs);
            //fixBayPositions(cfg);
            return cfg;
        }
        
        /**
         * Does simple validation of drive groups - determines if drives can be spread across given number of engines 
         * @param engines
         * @param driveGroups
         * @param isDispersionClone
         * @return 
         */        
        private function validateDriveGroupForEngineCount(engines:int, driveGroups:Array, isDispersionClone:Boolean = false):Boolean
        {
            if(!driveGroups || driveGroups.length == 0) return false;
			
			if (isDispersionClone)
				// no need for drive validation when creating dispersion clone
				return true;
            
            var dgSum:Dictionary = new Dictionary();
            
            for each(var dgroup:DriveGroup in driveGroups)
            { 
                var id:String = dgroup.driveDef.id.toString();
                if(!dgSum[id])
                {
                    dgSum[id] = dgroup.activeCount;
                    continue;
                }
                
                dgSum[id] = dgSum[id] + dgroup.activeCount;
            }
            
            for(var key:Object in dgSum)
            {
                var driveDef:DriveDef = DriveRegister.getById(int(key));
                
				// 450/850 AFA validation logic
				if (AllFlashArrayUtility.capacityBlock && 
					(this is sym.configurationmodel.v450f.ConfigurationFactory || this is sym.configurationmodel.v950f.ConfigurationFactory))
				{
					// 13TB Flash capacity block
					if (driveDef.type == AllFlashArrayUtility.SUPPORTED_DRIVE_TYPES[AllFlashArrayUtility.systemDriveRAID.name][1] &&
						dgSum[key] < driveDef.raid.raidGroupSize)
					{
						return false;
					}
					// 26TB Flash capacity block
					if (driveDef.type == AllFlashArrayUtility.SUPPORTED_DRIVE_TYPES[AllFlashArrayUtility.systemDriveRAID.name][0] &&
						dgSum[key] < driveDef.raid.raidGroupSize * engines)
					{
						return false;
					}
				}
				else if (dgSum[key] < (driveDef.raid.raidGroupSize * engines))
                {
                    return false;
                }
            }
            return true;
        }
        
        /**
         * Validates drive group activeCount divisiblity  
         * @param driveGroups
         * @return index of first invalid row
         * <p>Returns -1 if all items are valid</p>
         */        
        public function validateDriveDivisibility(driveGroups:Array):int
        {
            for each(var dg:DriveGroup in driveGroups)
            {
                if(dg.activeCount == 0 || dg.activeCount % dg.driveDef.raid.raidGroupSize != 0)
                {
                    return driveGroups.indexOf(dg);
                }
            }
            return -1;
        }
        
        /**
         * Creates DAES and spreads them across bays for given configuration
         * @param cfg  Configuration
         * @param totalVikings number of Viking DAEs 
         * @param totalVoyagers number of Voyager DAEs
         * <i>
         * <p>
         * Note that this method expects Configuration object that contains all bays (system and storage)
         * </p>
         * <p>
         * Method expects valid number of vikings and voyagers that will be spread across bays
         * </p>
         * </i>
         */        
        public function spreadDAEs(cfg:Configuration_VG3R, totalVikings:int, totalVoyagers:int):void
        {
            const vikingsPerEngine:int = totalVikings / cfg.noEngines;        //number of vikings behind every engine (evenly spread)
            const voyagersPerEngine:int = totalVoyagers / cfg.noEngines;      //number of voyagers behind every engine (evenly spread)
            const isMixed:Boolean = totalVikings > 0 && totalVoyagers > 0;
            
            const maxDAEsPerSystemBay:int = cfg.singleEngine ? MAX_DAES_1_ENGINE_SYSBAY : MAX_DAES_2_ENGINE_SYSBAY; //maximal DAE count per system bay
			
			// flag for even(odd) number of egnines per system bay
			var evenEnginesPerSysBay:Boolean = cfg.noEngines % cfg.countSystemBay == 0;
			var noEnginesPerBay:int = evenEnginesPerSysBay ? cfg.noEngines / cfg.countSystemBay : cfg.sysBayType;
			
			// 1 bay can house min 1 engine for dual-engine bay type
            var vikingsPerSystemBay:int = IntUtil.min(vikingsPerEngine * noEnginesPerBay, maxDAEsPerSystemBay);      //number of vikings in system bay
            var voyagersPerSystemBay:int = IntUtil.min(voyagersPerEngine * noEnginesPerBay, maxDAEsPerSystemBay - vikingsPerSystemBay);    //number of voyagers in system bay for mixed and non-mixed.
           
			//this is curently not applicable since we don't have Storage Bays anymore
			const vikingsPerStorageBay:int = vikingsPerEngine * cfg.sysBayType - vikingsPerSystemBay;                //remaining vikings after system bay population
            const voyagersPerStorageBay:int = voyagersPerEngine * cfg.sysBayType - voyagersPerSystemBay;            //remaining voyagers after sys bay population
			
            var sysVikingLocations:Array = cfg.singleEngine ? SB_VIKING_LOCATIONS_1ENGINE : SB_VIKING_LOCATIONS_2ENGINES; 
            const sysVoyagerLocations:Array = cfg.singleEngine ? SB_VOYAGER_LOCATIONS_1ENGINE : SB_VOYAGER_LOCATIONS_2ENGINES; 
            
            if(isMixed)
            {
                sysVikingLocations = sysVoyagerLocations;
            }
            
            var engineIndex:int = 1;
            var daeIndex:int = 0; 
            var vikingsAdded:int = 0;  //if this is mixed configuration than we should keep tracking DAE position index   
            var indexBehindEngine:int = 0; //this is dae population order index (used for drive spread) 
            var dae:DAE = null;
            
            for each (var bay:Bay in cfg.children)
            {         
                //populate system bay
                if(bay.isSystemBay)
                {
					// in case we've odd number of engines for dual-engine system
					// last system Bay has less DAEs than first bays which have even DAEs spreaded per bay
					if (!evenEnginesPerSysBay && bay.positionIndex == cfg.countSystemBay - 1)
						
					{
						// DAE count per system bay is decreased by DAE count per one engine
						// apply only for last system bay since second engine for dual-engine system is redundant
						
						vikingsPerSystemBay -= vikingsPerEngine;
						voyagersPerSystemBay -= voyagersPerEngine;
					}
					
                    indexBehindEngine = 0; //reset for each sys bay (engine)
					
					var parentEngineInd:int; // DAE's engine index 
					var daePos:int; // DAE's index position within sys bay
					
                    //following loops are exclusive if this is non-mixed config (one will work)
                    for (daeIndex = 0; daeIndex < vikingsPerSystemBay; daeIndex++)
                    {
						parentEngineInd = cfg.dualEngine && daeIndex >= vikingsPerEngine ? engineIndex + 1 : engineIndex;
						daePos = cfg.dualEngine && isMixed && daeIndex == vikingsPerEngine ? sysVikingLocations[daeIndex + 1] : sysVikingLocations[daeIndex];
						
						bay.addChild(dae = new Viking(Position.getFromCacheByType(Position.BAY_ENCLOSURE, daePos), parentEngineInd));
					
						dae.indexBehindEngine = indexBehindEngine;
						
                        indexBehindEngine++;
                    }
                    
					if (isMixed)
					{
						vikingsAdded = daeIndex; //keep track of DAE index
					}
                    
					// add Voyager DAEs
                    for (daeIndex = 0; daeIndex < voyagersPerSystemBay; daeIndex++)
                    {
						parentEngineInd = cfg.dualEngine && daeIndex >= voyagersPerEngine ? engineIndex + 1 : engineIndex;
						// if mixed and dual-engine config then spread evenly DAEs across engines
						// behind one engine is 1 Voyager, 1 Viking 
						daePos = cfg.dualEngine && isMixed && (daeIndex < voyagersPerEngine && voyagersPerEngine < voyagersPerSystemBay) ? sysVoyagerLocations[daeIndex + vikingsAdded - 1] : sysVoyagerLocations[daeIndex + vikingsAdded]; 
						
                        bay.addChild(dae = new Voyager(Position.getFromCacheByType(Position.BAY_ENCLOSURE, daePos), parentEngineInd));
                        dae.indexBehindEngine = indexBehindEngine;

						indexBehindEngine++;
                    }
                    
                    engineIndex += cfg.sysBayType;
                }
            }
            
            engineIndex = 1;
            
            //determine if there are DAEs for StorageBays (assuming also that there are storage bays added before this method)
            if(cfg.dualEngine && cfg.countStorageBay > 0)
            {
				// this will not be executed since storage bays are not included in configuration
                const stgVikingLocations:Array = isMixed ? STRGBAY_VOYAGER_LOCATIONS : STRGBAY_VIKING_LOCATIONS;   //if mixed, place it as there are 4U in order to avoid DAE overlapping
                
                for each(var bay:Bay in cfg.children)
                {
               /*     if(bay.isStorageBay)
                    { 
                        daeIndex = 0;
                        //following conditions are exclusive because this is non-mixed config (one will work)
                        if(vikingsPerStorageBay > 0)
                        {  
                            for(daeIndex = 0; daeIndex < vikingsPerStorageBay; daeIndex +=2)
                            {
                                bay.addChild(dae = new Viking(Position.getFromCacheByType(Position.BAY_ENCLOSURE, stgVikingLocations[daeIndex]), engineIndex));
                                dae.indexBehindEngine = indexBehindEngine;
                                bay.addChild(dae = new Viking(Position.getFromCacheByType(Position.BAY_ENCLOSURE, stgVikingLocations[daeIndex + 1]), engineIndex + 1));
                                dae.indexBehindEngine = indexBehindEngine;
                                indexBehindEngine++;
                            }
                        }
                        
                        //if this is mixed configuration than we should keep tracking DAE position index
                        vikingsAdded = daeIndex; 
                        if(!isMixed)
                        {
                            vikingsAdded = 0;
                        }
                        
                        if(voyagersPerStorageBay > 0)
                        {
                            for(daeIndex = 0; daeIndex < voyagersPerStorageBay; daeIndex += 2)
                            {
                                bay.addChild(dae = new Voyager(Position.getFromCacheByType(Position.BAY_ENCLOSURE, STRGBAY_VOYAGER_LOCATIONS[daeIndex + vikingsAdded]), engineIndex));
                                dae.indexBehindEngine = indexBehindEngine;
                                bay.addChild(dae = new Voyager(Position.getFromCacheByType(Position.BAY_ENCLOSURE, STRGBAY_VOYAGER_LOCATIONS[daeIndex + vikingsAdded + 1]), engineIndex + 1));
                                dae.indexBehindEngine = indexBehindEngine; 
                                indexBehindEngine++;
                            }
                        }
                        
                        engineIndex += 2;
                    }*/
                }
            }
            
            cfg.noVoyager = totalVoyagers;
            cfg.noViking = totalVikings;
        }
        
        /**
         * Calculates needed Engine count for given drive groups and quick tier (custom tier has custom selection of engine count) 
         * @param driveGroups
         * @param tier
         * @param sysBayType
         * @return engine count
         * <p>
         * Engine count, dae count ... are all mutual dependent, thus we are trying to make config with the minimum possible number of engine. <br/>
         * When we find that minimum, it will be the number for cost configs or the number of engines for performance configs will have upper limit twice as big as cost engine count.
         * </p>
         * <i>Note that results should be validated. This method will return zero if there's no possible system or it can return number of engines greater than allowed number for current system</i>
         */        
        public function calculateEngineCount(driveGroups:Array, tier:int, sysBayType:int):int
        { 
            var engineCount:int = 0;
            
            if(tier != TieringUtility_VG3R.TIER_CUSTOM_CONFIG)
            { 
                var engineDriveMap:Array;                
                for(var engCount:int = 1; engCount <= noEngines; engCount++)
                {
                    engineDriveMap = new Array();
                    engineCount = engCount;
                    
                    for(var ne:int = 0; ne < engCount; ne++) 
                        engineDriveMap[ne] = new Dictionary(); //values - [driveDef.id] = {active:int, spare:int}
                    
                    mapDriveCountToEngineArray(engCount, engineDriveMap, driveGroups, DAE.Viking);
                    mapDriveCountToEngineArray(engCount, engineDriveMap, driveGroups, DAE.Voyager);
                    
                    var noVikingsPerEngine:int = determineDAECountPerEngine(engineDriveMap, DAE.Viking);
                    var noVoyagersPerEngine:int = determineDAECountPerEngine(engineDriveMap, DAE.Voyager);
                    
                    if((noVikingsPerEngine + noVoyagersPerEngine) > MAX_DAES_BEHIND_ENGINE[sysBayType])
                    {
                        continue; 
                    }

                    if(TieringUtility_VG3R.isPerformanceTier(tier))
                    {
                        var lowEngineLimit:int = engCount;
                        var maxEngineLimit:int = 2 * lowEngineLimit;
                        var totalDriveIOPS:int = 0;
                        
                        for each (var dg:DriveGroup in driveGroups)
                        {
                            totalDriveIOPS += dg.driveDef.type.iops * dg.activeCount;
                        }
                        
                        engineCount = totalDriveIOPS < engineIOPS[sysBayType] ? 1 : totalDriveIOPS / engineIOPS[ConfigurationFilter.DUAL_ENGINE_BAY];
                        
                        if(maxEngineLimit > noEngines)
                        {
                            maxEngineLimit = noEngines;
                        }
                        
                        if (engineCount < lowEngineLimit)
                        {
                            engineCount = lowEngineLimit;
                        }
                        else if (engineCount > maxEngineLimit)
                        {
                            engineCount = maxEngineLimit;
                        }
                    }
					
					if (NO_ENGINES_MAP[engineCount].noSysBays[sysBayType] <= 0)
					{
						continue;
					}
					
                    return engineCount;
                }  
            }
            return engCount > noEngines ? 0 : engCount;   
        } 
        
		/**
		 * generates storage bay
		 * @param strgBay storage bay name
		 * @param cfg configuration to attach storage bay to
		 */
		private function generateStorageBay(stgBay:String, cfg:Configuration_VG3R):Bay
		{
			var bay:Bay = createStorageBay(stgBay, cfg, factoryName()); 
			cfg.addChild(bay);
			
			return bay;
		}
		
		/**
		 * creates storage bay
		 * @param strgBay storage bay name
		 * @param cfg configuration to attach storage bay to
		 * @param noSystemBays total number of system bays within configuration
		 * @param factory name of the factory
		 */
		public function createStorageBay(stgBay:String, cfg:Configuration_VG3R, factory:String):Bay
		{
			var bay:Bay = null;
			if(stgBay == STORAGE_BAY_1A)
			{
        		bay = new Bay(Bay.ID_SBAY1A, Bay.TYPETITANSTGBAY, new Position(Position.FLOOR, SBAY1A));
			}
			else 
			{
				if(cfg.dispersed_m[0] != -1)
				{
					var sysBays:Array = IntUtil.sequence(2, cfg.countSystemBay);
					
					for(var j:int = 0; j < cfg.dispersed_m.length; j++)
					{
						var idx:int = sysBays.indexOf(cfg.dispersed_m[j]);
						if (idx != -1)
						{
							sysBays.splice(idx,1);
						}
					}
					
					var newArray:Array = sysBays.concat(cfg.dispersed_m);
					var positions:Array = [SBAY2A, SBAY3A, SBAY4A];
					
					var pos:int;
					if(stgBay == STORAGE_BAY_2A)
					{
						for(var k:int = 0; k < newArray.length; k++)
						{
							if(newArray[k] == 2)
							{
								if(k == 1)
								{
									var oldPos:int = positions[k];
									pos = positions[k] + 10;
									(cfg.children[1] as Bay).position.index = oldPos;
								}
								else
								{
									pos = positions[k];
								}
								break;
							}
						}
						bay = new Bay(Bay.ID_SBAY2A, Bay.TYPETITANSTGBAY, new Position(Position.FLOOR, pos));
					}
					else if(stgBay == STORAGE_BAY_3A)
					{
						for(var l:int = 0; l < newArray.length; l++)
						{
							if(newArray[l] == 3)
							{
								if(l == 0 || l == 2)
								{
									var oldPoss:int = positions[l];
									pos = positions[l] - 10;
									(cfg.children[2] as Bay).position.index = oldPoss;
								}
								else
								{
									pos = positions[l];
								}
								
								break;
							}
						}
						bay = new Bay(Bay.ID_SBAY3A, Bay.TYPETITANSTGBAY, new Position(Position.FLOOR, pos));
					}
					else if(stgBay == STORAGE_BAY_4A)
					{
						for(var m:int = 0; m < newArray.length; m++)
						{
							if(newArray[m] == 4)
							{
								if(m == 0 || m == 2)
								{
									pos = positions[m];
								}
								else
								{
									var oldPosit:int = positions[m];
									pos = positions[m] +  10;
									(cfg.children[3] as Bay).position.index = oldPosit;
								}
								
								break;
							}
						}
						bay = new Bay(Bay.ID_SBAY4A, Bay.TYPETITANSTGBAY, new Position(Position.FLOOR, pos));
					}
				}
				else 
				{
					if(stgBay == STORAGE_BAY_2A)
					{
						bay = new Bay(Bay.ID_SBAY2A, Bay.TYPETITANSTGBAY, new Position(Position.FLOOR, SBAY2A));
					}
					else if(stgBay == STORAGE_BAY_3A)
					{
						bay = new Bay(Bay.ID_SBAY3A, Bay.TYPETITANSTGBAY, new Position(Position.FLOOR, SBAY3A));
					}
					else if(stgBay == STORAGE_BAY_4A)
					{
						bay = new Bay(Bay.ID_SBAY4A, Bay.TYPETITANSTGBAY, new Position(Position.FLOOR, SBAY4A));
					}
				}
			}
			bay.addChild(PDU_VG3R.createIfNotCached(Position.BAY_HALF_ENCLOSURE_LEFT, 35, factory));
			bay.addChild(PDU_VG3R.createIfNotCached(Position.BAY_HALF_ENCLOSURE_RIGHT, 35, factory));
			return bay;
		}
		
		/**
		 * generates system bay
		 * @param index index of system bay
		 * @param sysBayType Single/Dual-engine type
		 * @param daeType type of dae disc
		 * @param sysBayValues array of not dispersed bays
		 * @param dispersedValues array of dispersed bays
		 * @param factory name of a factory
		 */
		public function generateSystemBay(index:int, sysBayType:int, daeType:int, sysBayValues:Array, dispersedValues:Array, factory:String, sysNoEngines:int):Bay
		{
			var sbay:Bay = null;
			var position:int;
			var engineCounter:int = 1;
			if(dispersedValues != null && dispersedValues[0] != -1)
			{
				var allVAlues:Array = sysBayValues.concat(dispersedValues);
				var pos:int = allVAlues.indexOf(index + 1);
				position = pos > 1 ? SYSTEMBAYPOSITION + pos * 10 + 20 : SYSTEMBAYPOSITION + pos *  10;
			}
			else
			{
				position = (index > 1) ? SYSTEMBAYPOSITION + index * 10 + 20 : SYSTEMBAYPOSITION + index * 10;
			}
			
//			position = (index > 1) ? SYSTEMBAYPOSITION + index * 10 + 20 : SYSTEMBAYPOSITION + index * 10;
			
			if(daeType == DAE.Voyager)
			{
				sbay = new Bay(Bay.ID_SYSTEM_BAY_VOYAGER, Bay.TYPETITANSYSBAY, new Position(Position.FLOOR, position));
			}
			else if(daeType == DAE.Viking || daeType == DAE.MixedVoyager)
			{
				sbay = new Bay(Bay.ID_SYSTEM_BAY_VIKING, Bay.TYPETITANSYSBAY, new Position(Position.FLOOR, position));
			}
			else if(daeType == DAE.Nebula)
			{
				if(factory == "pm8000_factory")
				{
					
					if(index == 1)
						engineCounter = 5;
					sbay = new Bay(Bay.ID_SYSTEM_BAY_NEBULA, Bay.TYPETITANSYSBAY, new Position(Position.FLOOR, position));
					
					sbay.positionIndex = index;
					
					sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_LEFT, 1), SPS.TYPE_LION,engineCounter));
					sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_RIGHT, 1), SPS.TYPE_LION, engineCounter));
					if(index == 0)
					{
						sbay.addChild(EthernetSwitch.createIfNotCached(Position.BAY_HALF_ENCLOSURE_LEFT, 19, factory));
						sbay.addChild(EthernetSwitch.createIfNotCached(Position.BAY_HALF_ENCLOSURE_RIGHT, 19, factory));
					}
					
					var eng:Engine = new Engine(engineCounter.toString(), Position.getFromCacheByType(Position.BAY_ENCLOSURE, 11));
					engineCounter++;
					sbay.addChild(eng);
					
					// add PDU/PDP to system bay
					for(var pos1:int = 6; pos1 < 8; pos1++){
						sbay.addChild(PDU.createIfNotCached(Position.BACKPANEL_PDU, pos1, sbay.type));
					}
					
					if(sysNoEngines >= 2)
					{
						var engine2:Engine = new Engine(engineCounter.toString(), Position.getFromCacheByType(Position.BAY_ENCLOSURE, 17));
						sbay.addChild(engine2); 
						sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_LEFT, 13), SPS.TYPE_LION, engineCounter));
						sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_RIGHT, 13),SPS.TYPE_LION, engineCounter));
						engineCounter++;
						if(index == 0)
						{
							sbay.addChild(InfinibandSwitch.createIfNotCached(Position.BAY_ENCLOSURE, 37, factory, getAllowedIBswitch()));
							sbay.addChild(InfinibandSwitch.createIfNotCached(Position.BAY_ENCLOSURE, 36, factory, getAllowedIBswitch()));
						}
					}
					
					if(sysNoEngines>=3)
					{
						var engine3:Engine = new Engine(engineCounter.toString(), Position.getFromCacheByType(Position.BAY_ENCLOSURE, 23));
						sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_LEFT, 25), SPS.TYPE_LION, engineCounter));
						sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_RIGHT, 25),SPS.TYPE_LION, engineCounter));
						sbay.addChild(engine3);
						engineCounter++;
					}
					
					if(sysNoEngines>=4)
					{
						var engine4:Engine = new Engine(engineCounter.toString(), Position.getFromCacheByType(Position.BAY_ENCLOSURE, 29));
						sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_LEFT, 39), SPS.TYPE_LION, engineCounter));
						sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_RIGHT, 39),SPS.TYPE_LION, engineCounter));
						sbay.addChild(engine4);
						engineCounter++;
					}
					
					return sbay;
				}
				else
				{
					sbay = new Bay(Bay.ID_SYSTEM_BAY_NEBULA, Bay.TYPETITANSYSBAY, new Position(Position.FLOOR, position));
					
					sbay.positionIndex = index;
					
					sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_LEFT, 1), SPS.TYPE_LION, index * sysBayType + 1));
					sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_RIGHT, 1), SPS.TYPE_LION, index * sysBayType + 1));
					
					var eng:Engine = new Engine((index * sysBayType + 1).toString(), Position.getFromCacheByType(Position.BAY_ENCLOSURE, 5));
					
					sbay.addChild(eng);
					
					// add PDU/PDP to system bay
					for(var pos1:int = 6; pos1 < 8; pos1++){
						sbay.addChild(PDU.createIfNotCached(Position.BACKPANEL_PDU, pos1, sbay.type));
					}
					
					if(sysNoEngines == Configuration_VG3R.DUAL_ENGINE_BAY)
					{
						var engine2:Engine = new Engine(sysNoEngines.toString(), Position.getFromCacheByType(Position.BAY_ENCLOSURE, 15));
						sbay.addChild(engine2); 
						sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_LEFT, 11), SPS.TYPE_LION, sysNoEngines));
						sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_RIGHT, 11),SPS.TYPE_LION, sysNoEngines));
					}
					return sbay;
				}
			}
			else if(daeType == DAE.Tabasco)
			{
				sbay = new Bay(Bay.ID_SYSTEM_BAY_TABASCO, Bay.TYPETITANSYSBAY, new Position(Position.FLOOR, position));
				
				sbay.positionIndex = index;
				
				sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_LEFT, 1), SPS.TYPE_LION, index * sysBayType + 1));
				sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_RIGHT, 1), SPS.TYPE_LION, index * sysBayType + 1));
				
				var engine:Engine = new Engine((index * sysBayType + 1).toString(), Position.getFromCacheByType(Position.BAY_ENCLOSURE, 5));
				
				sbay.addChild(engine);
			
				// add PDU/PDP to system bay
				for(var pos1:int = 6; pos1 < 8; pos1++){
					sbay.addChild(PDU.createIfNotCached(Position.BACKPANEL_PDU, pos1, sbay.type));
					sbay.addChild(PDP.createIfNotCached(Position.BACKPANEL_PDP, pos1, factory, sbay.type));
				}
				
				if(sysNoEngines == Configuration_VG3R.DUAL_ENGINE_BAY)
				{
					var engine2:Engine = new Engine(sysNoEngines.toString(), Position.getFromCacheByType(Position.BAY_ENCLOSURE, 15)); 
					sbay.addChild(engine2); 
					sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_LEFT, 11), SPS.TYPE_LION, sysNoEngines));
					sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_RIGHT, 11),SPS.TYPE_LION, sysNoEngines));
				}
				return sbay;
			}
			
			sbay.positionIndex = index;
			
			sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_LEFT, 39), SPS.TYPE_LION, index * sysBayType + 1));
			sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_RIGHT, 39), SPS.TYPE_LION, index * sysBayType + 1));

			var engine:Engine = new Engine((index * sysBayType + 1).toString(), Position.getFromCacheByType(Position.BAY_ENCLOSURE, 33));
            
			sbay.addChild(engine);
			
			sbay.addChild(PDU_VG3R.createIfNotCached(Position.BAY_HALF_ENCLOSURE_LEFT, 29, factory));
			sbay.addChild(PDU_VG3R.createIfNotCached(Position.BAY_HALF_ENCLOSURE_RIGHT, 29, factory));
			
			// when index is 0 it means that this system bay is leading one
			if(index == 0)
			{
				sbay.addChild(InfinibandSwitch.createIfNotCached(Position.BAY_ENCLOSURE, 37, factory, getAllowedIBswitch()));
				sbay.addChild(InfinibandSwitch.createIfNotCached(Position.BAY_ENCLOSURE, 36, factory, getAllowedIBswitch()));
				
				sbay.addChild(KVM.createIfNotCached(Position.BAY_ENCLOSURE, 23));
				sbay.addChild(EthernetSwitch.createIfNotCached(Position.BAY_HALF_ENCLOSURE_LEFT, 22, factory));
				sbay.addChild(EthernetSwitch.createIfNotCached(Position.BAY_HALF_ENCLOSURE_RIGHT, 22, factory));
				
                if(sysNoEngines > 1)
                {
				    sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_LEFT, 1), SPS.TYPE_LION));
				    sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_RIGHT, 1), SPS.TYPE_LION));
                }
			}
			
			var evenEngineInd:int = index * sysBayType + Configuration_VG3R.DUAL_ENGINE_BAY;
			
			if(sysBayType == Configuration_VG3R.DUAL_ENGINE_BAY && evenEngineInd <= sysNoEngines)
			{
				var engine2:Engine = new Engine(evenEngineInd.toString(), Position.getFromCacheByType(Position.BAY_ENCLOSURE, 27)); 
				sbay.addChild(engine2); 
				sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_LEFT, 19), SPS.TYPE_LION, evenEngineInd));
				sbay.addChild(new SPS(new Position(Position.BAY_HALF_ENCLOSURE_RIGHT, 19),SPS.TYPE_LION, evenEngineInd));
			}
			
			return sbay;
		}
		
		/**
		 * gets allowed port configurations
		 */
		public override function getAllowedPortConfigurations():ArrayCollection{
			var portconfigs:ArrayCollection = new ArrayCollection();
			portconfigs.addAll(new ArrayCollection(PORT_CONFIGS));
			return portconfigs;
		}
		
		/**
		 * Gets allowed InfiniBand switch type for current system
		 * @return Dingo if 100/200K system. Otherwise, if 400K, 450f and 850f it is Stingray switch
		 * 
		 */		
		public function getAllowedIBswitch():int
		{
			if (this is sym.configurationmodel.v450f.ConfigurationFactory || this is sym.configurationmodel.v950f.ConfigurationFactory)
			{
				return InfinibandSwitch.TYPE_STINGRAY;
			}
			
			return InfinibandSwitch.TYPE_DINGO;
		}
		
		/**
		 * returns all configurations that match suplied filter
		 */
		public override function filter(filter:ConfigurationFilter):Array
		{
			var filteredConfigurations:Array = [];
			
			for each (var conf:Configuration_VG3R in _configurations)
			{
				if (matches(conf, filter))
				{
					filteredConfigurations.push(conf);
				}
			}
			
			return filteredConfigurations;
		}
		
		protected function matches(conf:Configuration_VG3R, filter:ConfigurationFilter):Configuration_VG3R
		{
		
     		// filter by dae type
			if (filter.daeType != -1 && conf.daeType != filter.daeType)
			{
				return null;
			}
			 
			// filter by engines
			if (filter.noEngines != -1 && filter.noEngines != conf.noEngines)
			{
				return null;
			}
			// filter by driveType
			if (filter.driveType != "0" && filter.driveType != "ANY")
			{
					for each (var driveGroup:DriveGroup in conf.driveGroups)
					{
						var driveTypeName:String = driveGroup.driveDef.type.name;
						if(filter.driveType != driveTypeName)
						{
							return null;
						}
							
					}
				
			}
			
			// filter by numberOfDrives
			if (filter.noDrives != -1 && filter.noDrives != conf.numberOfDrives && filter.noDrives != conf.activesAndSpares)
			{
				/*for each (var noDrives:Configuration_VG3R in conf.activesAndSpares)
				{
					dp.addItem(drives.activesAndSpares);
				}*/
				return null;
			}
			
			// filter by no. of system bays
			if (filter.noSystemBays != -1)
			{
				if (conf.countSystemBay != filter.noSystemBays)
				{
					return null;
				}
			}
			
			
			//filter by dispersed
			if(filter.dispersed_m != null && filter.dispersed_m.length > 0 && filter.dispersed_m[0] != -1)
			//if(filter.dispersed_m != null && filter.dispersed_m.length > 0)
			{
				if(conf.dispersed_m.length != filter.dispersed_m.length)
				{
					return null;
				}
				var len:int = conf.dispersed_m.length;
				filter.dispersed_m.sort(Array.NUMERIC);
				for(var i:int; i < len; i++)
				{
					if(conf.dispersed_m[i] != filter.dispersed_m[i])
					{
						return null;
					}
				}
			}
			
			// filter by tier 
			if (filter.tiering != -1 && filter.tiering != conf.tierSolution)
			{
				return null;
			}
			
			return conf;
		}
		
		/**
		 * fixes bay positions for given confguration
		 */
		public static function fixBayPositions(cfg:Configuration_VG3R):void
		{
			cfg.children.sortOn('sortOrder', Array.NUMERIC);
			
			var i:int = 0;
			for each (var bay:Bay in cfg.children)
			{
				bay.position = Position.getFromCacheByType(Position.FLOOR, i++);
			}
		}	
		
		/**
		 * Generates VG3R config through wizard 
		 * @param noEngines 	    Total number of Engines
		 * @param sysBayType  	    System Bay type - Single/Dual engine type
		 * @param driveGroups       List of drive definitions with their number 
		 * @param tier			    Tier selection
		 * @param capacity 		    Total usable capacity
		 * @param dispersion 	    Array of dispersed system bay indices
		 * @param osCapacity        Open System capacity, default value 0
		 * @param mfcapacity        Mainframe capacity, default value 0
		 * @param portGroups        Array of selected engine port groups 
		 * @return generated config
		 * 
		 */		
		public function wizardConfigGenerator(noEngines:int,
											  driveType:String,
											  noDrives: int,
											  sysBayType:int,
											  driveGroups:Array,
											  tier:int,
											  capacity:Number,
											  dispersion:Array,
											  hostType:String,
											  osCapacity:Number,
											  mfCapacity:Number,
											  portGroups:ArrayCollection):Configuration_VG3R
		{
			var cfg:Configuration_VG3R;
		 
			if(noEngines <= 0 || noEngines > this.noEngines)
            {
                return null;
            }
            cfg = createConfiguration(noEngines, sysBayType, driveType, noDrives, dispersion, driveGroups, tier);
			
			if (cfg)
			{
                cfg.totCapacity = capacity;
                cfg.hostType = hostType;
				cfg.driveType = driveType;
				cfg.numberOfDrives = noDrives;
							
				// sets Open System and Mainframe capacity information for Property page 
				switch(cfg.hostType)
				{
					case HostType.OPEN_SYSTEMS:
						cfg.osUsableCapacity = capacity;
						cfg.mfUsableCapacity = 0;
						break;
					case HostType.MAINFRAME_HOST:
						cfg.mfUsableCapacity = capacity;
						cfg.osUsableCapacity = 0;
						break;
					case HostType.MIXED:
						cfg.osUsableCapacity = osCapacity;
						cfg.mfUsableCapacity = mfCapacity;
						break;
				}
					
				// populuate Engine with selected ports/modules
				this.populateEngine(cfg, portGroups.toArray());
				
				this.appendConfiguration(cfg);
			}
			
			return cfg;
		} 
		
		public override function populateWithDrives(config:Configuration_VG3R, dae:DAE = null):void
		{
            if(dae.children.length > 0)
            {
                return;
            }
            
            if(config.driveCountMap == null)
            {
                return; //this shouldn't be the case but validate for every case
            }
            
            var vikingDaes:Array = config.getDAEsBehindEngine(dae.parentEngine, DAE.Viking); 	
            var voyagerDaes:Array = config.getDAEsBehindEngine(dae.parentEngine, DAE.Voyager);
			
            if(vikingDaes.length > 0) 
            {
                var vikingMap:DictionaryExt = extractDriveMapByDaeType(config.driveCountMap[dae.parentEngine - 1] as Dictionary, DAE.Viking);
                populateDAEs(vikingDaes, vikingMap, 0);
            }
            
            if(voyagerDaes.length > 0)
            {
                var voyagerMap:DictionaryExt = extractDriveMapByDaeType(config.driveCountMap[dae.parentEngine - 1] as Dictionary, DAE.Voyager);
                populateDAEs(voyagerDaes, voyagerMap, 0);
            }
		} 
        
        /**
         * Populates given daes with drives from given map
         * @param daes
         * @param driveMap
         * 
         */        
        protected function populateDAEs(daes:Array, driveMap:DictionaryExt, engineCount:Number, engineNo:int = 0):void
        {
            var populationIndices:Array;
            
            //populate Vikings/Voyagers/Tabasco
            if(driveMap.keys.length > 0 && daes.length > 0)
            {
                daes.sortOn('indexBehindEngine', Array.NUMERIC);
                
                var ddids:ArrayCollection = new ArrayCollection(driveMap.keys);
                ddids.sort = new Sort();
                ddids.sort.compareFunction = sortIdsByRaidSize;
                
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
                    
					var posType:int = driveDef.size == DAE.Nebula ? Position.DAE_NEBULA_ENCLOSURE : DAE.Viking ? Position.VIKING_ENCLOSURE : 
						driveDef.size == DAE.Tabasco ? Position.DAE_TABASCO_ENCLOSURE : Position.VOYAGER_ENCLOSURE;
                    var positionIndexArray:Array = driveDef.size == DAE.Nebula ? NEBULA_POPULATION_INDICES: driveDef.size == DAE.Viking ? VIKING_POPULATION_INDICES : 
						driveDef.size == DAE.Tabasco ? TABASCO_POPULATION_INDICES : VOYAGER_POPULATION_INDICES;
					
					var driveNo:int = 0;
					
					while (driveNo < totalDrives)
					{
						var indexOfMinPopulated:int = IntUtil.minValueIndex(populationIndices);
						var driveIndex:int = int(populationIndices[indexOfMinPopulated]);
						
						if (driveDef.size == DAE.Tabasco)
						{
							// Tabasco population with drives
							// spread first active drives, then spares
							for (var rgs:int = 0; rgs < driveDef.raid.raidGroupSize && driveNo < totalDrives; rgs++)
							{
								(daes[indexOfMinPopulated] as DAE).addChild(new Drive(new Position(posType, positionIndexArray[driveIndex]), driveDef, driveNo >= actives));
						
								driveNo++;
								driveIndex = ++populationIndices[indexOfMinPopulated];
							}	
						}
						else if(driveDef.size == DAE.Nebula)
						{
							
							for(var numberOfDAEs:int = 0; numberOfDAEs < 2; numberOfDAEs++)
							{
								for(var numberOfDrives:int = 0; numberOfDrives < (totalDrives-spares) / 2; numberOfDrives++)
								{
									(daes[numberOfDAEs] as DAE).addChild(new Drive(new Position(posType, positionIndexArray[numberOfDrives]+1), driveDef, false));					
									driveNo++;
								}
								if(numberOfDAEs == 0)
								{
									(daes[numberOfDAEs] as DAE).addChild(new Drive(new Position(posType, positionIndexArray[24]+1), driveDef, true));
									driveNo++;

								}
							}
							
							
						}
						else
						{
							// Viking/Voyager population
							// spread the drives - spares first
							(daes[indexOfMinPopulated] as DAE).addChild(new Drive(new Position(posType, positionIndexArray[driveIndex]), driveDef, driveNo < spares));
							
							driveNo++; 
							populationIndices[indexOfMinPopulated]++;
						}
						
					}
                }
            } 
        }
		
        /**
         * Returns Drive map dictionary for given dae type
         * @param driveMap
         * @param daeType
         * @return 
         * 
         */        
        public function extractDriveMapByDaeType(driveMap:Dictionary, daeType:int):DictionaryExt
        {
            var filteredDriveMap:DictionaryExt = new DictionaryExt();
            
            for(var ddid:Object in driveMap)
            {
                if(DriveRegister.getById(int(ddid)).size == daeType)
                {
                    filteredDriveMap[ddid] = driveMap[ddid];
                }
            }
            return filteredDriveMap;
        }
        
        /**
         * Calculates valid count of active drives for drive group with given index for current system
         * @param driveGroups Drive group array
         * @param driveGroupIndex Index of drive group to be tested 
         * @return active count (0 if none is supported)
         */        
        public function calculateMaxValidDriveCount(driveGroups:Array, driveGroupIndex:int):int
        {  
            var driveGroupsClone:Array = TieringUtility_VG3R.cloneDriveGroups(driveGroups);
            var generatedCfg:Configuration_VG3R = null;
            var driveGroup:DriveGroup = driveGroupsClone[driveGroupIndex] as DriveGroup;
            var activeCount:int = driveGroup.activeCount; 
            var maxSupportCount:int = 0;
            
            const maxDrives:int = int(noEngines * Drive.VIKING_DRIVES_NUMBER * MAX_DAES_1_ENGINE_SYSBAY / driveGroup.driveDef.raid.raidGroupSize) * driveGroup.driveDef.raid.raidGroupSize;
            
            if(driveGroup.activeCount > maxDrives)
            {
                driveGroup.activeCount = maxDrives;
            }
                
                
            for (var eng:int = noEngines; eng > 0; eng--)
            { 
                while(driveGroup.activeCount > 0 && generatedCfg == null)
                {
                    generatedCfg = createConfiguration(eng, ConfigurationFilter.SINGLE_ENGINE_BAY,"",0, ConfigurationFilter.DISPERSEDNON_M, driveGroupsClone);
                    if (generatedCfg)
                    {  
                        if(maxSupportCount == 0)
                        {
                            maxSupportCount = driveGroup.activeCount;
                        }
                        break;
                    }
                    driveGroup.activeCount -= driveGroup.driveDef.raid.raidGroupSize;
                }
                
                driveGroup.activeCount = activeCount;
            } 
            
            return maxSupportCount;
        }
        
		/**
		 * Calculates maximum active drives which can be placed in maximum usable capacity for current VMAX array
		 * @param driveGroups indicates DriveGroup array
		 * @param driveGroupIndex indicates index of drive group to be tested
		 * @return supported max drive count (0 if none)
		 * 
		 */		
		public function calculateCapacityLimitMaxDrives(driveGroups:ArrayCollection, driveGroupIndex:int):int
		{  
			var driveGroupsClone:ArrayCollection = new ArrayCollection(TieringUtility_VG3R.cloneDriveGroups(driveGroups.toArray()));
			var driveGroup:DriveGroup = driveGroupsClone[driveGroupIndex] as DriveGroup;
			var activeCount:int = driveGroup.activeCount; 
			var maxValidDriveCount:int = 0;
			
			while (driveGroup.activeCount > 0)
			{
				var maxCap:Number = this is sym.configurationmodel.v450f.ConfigurationFactory || this is sym.configurationmodel.v950f.ConfigurationFactory ?
					AllFlashArrayUtility.MAXIMUM_USABLE_CAPACITY[AllFlashArrayUtility.systemDriveRAID.name][this.noEngines] : this.totCapacity;
				if (this.calculateCapacity(driveGroupsClone) <= maxCap)
				{
					maxValidDriveCount = driveGroup.activeCount;
					break;
				}
				
				driveGroup.activeCount -= driveGroup.driveDef.raid.raidGroupSize;
			}
			// keeps old active count value
			driveGroup.activeCount = activeCount;
			
			return maxValidDriveCount;
		}
		
		/**
		 * Calculates total usable capacity required for selected drive mix.<br/>
		 * Appropriate DriveGroup capacity percentage values will be updated also.
		 * @param driveGroups indicates array of selected drive groups
		 * @param hostType indicates OS or MF host type. Default values is <code> OS </code>
		 * @return usable capacity in TBu
		 * 
		 */		
		public function calculateCapacity(driveGroups:ArrayCollection, hostType:String = HostType.OPEN_SYSTEMS):Number
		{
			// capacity in GBu
			var totGBCap:Number = 0;
			
			for each (var dg:DriveGroup in driveGroups)
			{
				totGBCap += dg.activeCount * dg.driveDef.raid.factor * dg.driveDef.type.getFormattedCapacity(hostType);
			}
			
			for each (dg in driveGroups)
			{
				dg.percent = (dg.activeCount * dg.driveDef.raid.factor * dg.driveDef.type.getFormattedCapacity(hostType)) / totGBCap;
			}
			
			return totGBCap /= 1000;  //convert to TBu
		}
		
        /**
         * Calculates max count of active drives for drive group with given index that could be supported if other groups are adjusted (this would be full maximum)
         * @param driveGroups Drive group array
         * @param driveGroupIndex Index of drive group to be tested 
         * @return active count (0 if none is supported)
         */        
        public function calculateAdaptableMaxDriveCount(driveGroups:Array, driveGroupIndex:int):int
        {  
            var driveGroupsClone:Array = TieringUtility_VG3R.cloneDriveGroups(driveGroups);
            var generatedCfg:Configuration_VG3R = null;
            var driveGroup:DriveGroup = driveGroupsClone[driveGroupIndex] as DriveGroup;
            var activeCount:int = driveGroup.activeCount; 
            var maxSupportCount:int = 0;
            
            var minimalUpperEngineLimit:DriveGroup = minimalUpperEngineLimit = findGroupWithMinimalUpperEngineLimit(driveGroupsClone);
            
            const maxDrives:int = int(noEngines * Drive.VIKING_DRIVES_NUMBER * MAX_DAES_1_ENGINE_SYSBAY / driveGroup.driveDef.raid.raidGroupSize) * driveGroup.driveDef.raid.raidGroupSize;
            
            if(driveGroup.activeCount > maxDrives)
            {
                driveGroup.activeCount = maxDrives;
            }
            //set minimal required count for each group for current eng count
            while(minimalUpperEngineLimit.activeCount < (minimalUpperEngineLimit.driveDef.raid.raidGroupSize * noEngines))
            {
                minimalUpperEngineLimit.activeCount = minimalUpperEngineLimit.driveDef.raid.raidGroupSize * noEngines;
            }
            
            while(driveGroup.activeCount > 0 && generatedCfg == null)
            {
                generatedCfg = createConfiguration(noEngines, ConfigurationFilter.SINGLE_ENGINE_BAY,"",0, ConfigurationFilter.DISPERSEDNON_M, driveGroupsClone);
                if (generatedCfg)
                {  
                    if(maxSupportCount == 0)
                    {
                        maxSupportCount = driveGroup.activeCount;
                    }
                    break;
                }
                driveGroup.activeCount -= driveGroup.driveDef.raid.raidGroupSize;
            }
            
            return maxSupportCount;
        }
        
        /**
         * Calculates minimal valid count of active drives for drive group with given index for current system
         * @param driveGroups Drive group array
         * @param driveGroupIndex Index of drive group to be tested 
         * @return active count (0 if none is supported)
         */        
        public function calculateMinValidDriveCount(driveGroups:Array, driveGroupIndex:int):int
        {   
            var driveGroupsClone:Array = TieringUtility_VG3R.cloneDriveGroups(driveGroups);
            var generatedCfg:Configuration_VG3R = null;
            var driveGroup:DriveGroup = driveGroupsClone[driveGroupIndex] as DriveGroup;
            var activeCount:int = driveGroup.activeCount;
            var minSupportCount:int = 0;
            
            
            for (var eng:int = 1; eng <= noEngines; eng++)
            {  
                driveGroup.activeCount = eng * driveGroup.driveDef.raid.raidGroupSize;
                generatedCfg = createConfiguration(eng, ConfigurationFilter.SINGLE_ENGINE_BAY,"",0, ConfigurationFilter.DISPERSEDNON_M, driveGroupsClone);
                if(generatedCfg)
                {   
                    minSupportCount = driveGroup.activeCount; 
                    break;
                }
            } 
            driveGroup.activeCount = activeCount;
            
            return minSupportCount;
        }
        
        /**
         * Tests if greater amount of active drives for given group can applied to generate bigger configurations 
         * @param driveGroups
         * @param currentDriveGroup
         * @return 
         * <p>Steps:<br/>
         * 1. Increase given group active count for one raid group <br/>
         * 2. Find group with minimal upper limit of supported engines
         * 3. Increase it's active count number by one raid group
         * 4. Try to build configuration
         * 5. If there is no configuration, loop through steps 2-4 until group with minimal upper limit of engines until it fits in current engine count iteration or until we find first valid config
         * </p>
         */        
        public function testGreaterAmountOfDrives(driveGroups:Array, currentDriveGroup:int):Boolean
        {
            var dgClone:Array = TieringUtility_VG3R.cloneDriveGroups(driveGroups);
            
            var currentGroup:DriveGroup = dgClone[currentDriveGroup] as DriveGroup;
            //currentGroup.activeCount += currentGroup.driveDef.raid.raidGroupSize;  //try bigger number
            
            for(var engCount:int = 1; engCount <= noEngines; engCount++)
            {
                var minGroup:DriveGroup = findGroupWithMinimalUpperEngineLimit(dgClone);
                if(minGroup.activeCount > (engCount * minGroup.driveDef.raid.raidGroupSize))
                {
                    continue;
                }
                var config:Configuration_VG3R = createConfiguration(engCount, ConfigurationFilter.SINGLE_ENGINE_BAY,"",0, ConfigurationFilter.DISPERSEDNON_M, dgClone, TieringUtility_VG3R.TIER_CUSTOM_CONFIG);
                if(config)
                {
                    return true;
                }
                minGroup.activeCount += minGroup.driveDef.raid.raidGroupSize;
            }
            
            return false;
        }
        
        private function findGroupWithMinimalUpperEngineLimit(driveGroups:Array):DriveGroup
        {
            var minimalUpperEngineGroup:DriveGroup = driveGroups[0] as DriveGroup;
            for(var ind:int = 1; ind < driveGroups.length; ind++)
            {
                var dg2:DriveGroup = driveGroups[ind] as DriveGroup;
                
                if(dg2.activeCount/dg2.driveDef.raid.raidGroupSize < minimalUpperEngineGroup.activeCount/minimalUpperEngineGroup.driveDef.raid.raidGroupSize)
                {
                    minimalUpperEngineGroup = dg2;
                }
            }
            return minimalUpperEngineGroup;
        }
        
        /**
         * Gets the list of supported engine counts for given drive groups  
         * @param driveGroups list of drive groups containing drive definitions and active drive count
         * @param sysBayType indicates system bay type - Single/Dual engine type
         * @return 
         * 
         */        
        public function getSupportedEngines(driveGroups:Array, sysBayType:int = ConfigurationFilter.SINGLE_ENGINE_BAY):ArrayCollection
        {
            var result:ArrayCollection = new ArrayCollection();
            
            for(var cEngines:int = 1; cEngines <= noEngines; cEngines++)
            {
                var cfg:Configuration_VG3R = createConfiguration(cEngines, sysBayType,"",0, ConfigurationFilter.DISPERSEDNON_M, driveGroups, TieringUtility_VG3R.TIER_CUSTOM_CONFIG);
                if(cfg)
                {
                    result.addItem(cEngines);
                }
            }
            
            return result;
        }
	
		/**
		 * Populates Engine with selected Engine Ports/Modules from wizard
		 * @param config indicates current VG3R configuration
		 * @param portGroups indicates array of EnginePortGroup instances
		 * @param baseConfig indicates base config from which we create dispersion clone config
		 * 
		 */		
		public function populateEngine(config:Configuration_VG3R, portGroups:Array, baseConfig:Configuration_VG3R = null):void
		{	
			if (baseConfig)
			{
				for (var i:int = 0; i < baseConfig.noEngines; i++)
				{
					var engine:Engine = config.getEngineByIndex(i+1) as Engine;
					var baseEngine:Engine = baseConfig.getEngineByIndex(i+1) as Engine;
					
					for each (var ep:EnginePort in baseEngine.children) 
					{
						// copy Engine Ports from base config to new config
						engine.placeEnginePort(ep, Engine.getSlotNumberByPosition(ep.position.index));
					}
				}
				
				return;
			}
			
			var isMultiEngine:Boolean = false;
			if(config.noEngines > 1)
				isMultiEngine = true;
			
			for (var ind:int = 0; ind < config.noEngines; ind++)
			{
				var engine:Engine = config.getEngineByIndex(ind+1) as Engine;
				var populationInd:int = 0;
				if(config.noEngines >= 2)
				{
					//if configurations have 2 or more engines add IB module to slot 10
					engine.placeEnginePort(EnginePort.IB_MODULE_PROTOTYPE, Engine.getSlotNumberByPosition(Engine.IB_MODULE_UPPER_POSITION));					
				}
				if (portGroups.length > 1 && (portGroups[1] as EnginePortGroup).port.isMainframe)
				{
					// we should place FICON first behind engine before any FC module
					// so we switch FC and FICON places in data provider
					
					var pgFicon:EnginePortGroup = portGroups[1] as EnginePortGroup;
					// set FC on FICON's place
					portGroups[1] = portGroups[0];
					// set FICON on FC place
					portGroups[0] = pgFicon;					
				}	
				for each (var pg:EnginePortGroup in portGroups)
				{
					// Compression module is exception since it does not have ports
					if (pg.engineCountMap[ind] != null || pg.port.type == EnginePort.COMPRESSION_ASTEROID)
					{
						// number of slots required to place engine ports
						var requiredSlots:int = pg.getRequiredSlots(ind);
						
						// Compression should be placed in the last Slot 9 for 450/850F OpenSystems only
						if (pg.port.type == EnginePort.COMPRESSION_ASTEROID)
							populationInd = 3;
								
						for (var slot:int = 1; slot <= requiredSlots; slot++)
						{
							// set new position index since index has default -1 value
							pg.port.position.index = Engine.ENGINE_PORT_POPULATION_ORDER[populationInd++];
							
							engine.placeEnginePort(pg.port, Engine.getSlotNumberByPosition(pg.port.position.index));
						}
					}
				}
			}
			
		}
		
		public function validateSupportedDriveTypesFor950F(totCapacity:Number, raid:DriveRaidLevel, engineCount:int, hostType:String):ArrayCollection
		{
			var supportedDrives:ArrayCollection = new ArrayCollection();
			
			var minimumCapacityPacks:Number = 11.3;
						
			var supportedCapacity:Number = this.getSupportedCapacity(totCapacity, minimumCapacityPacks);
			
			//add all drive types to supported drives
			supportedDrives.addItem(DriveType.FLASH_SAS_960GB);
			supportedDrives.addItem(DriveType.FLASH_SAS_1920GB);
			supportedDrives.addItem(DriveType.FLASH_SAS_3840GB);
			supportedDrives.addItem(DriveType.FLASH_SAS_7680GB);
			supportedDrives.addItem(DriveType.FLASH_SAS_15360GB);
			
			
			// validates all drive types and removes all unpropriet ones  REFACTORED
			/*var maximumCapacity:Number;
			var indicator:Boolean;
			
			if(raid == DriveRaidLevel.R57)
			{
				maximumCapacity = 210.6;
				indicator = true;
			} else
			{
				maximumCapacity = 421.1;
				indicator = false;
			}
			if(supportedCapacity < maximumCapacity * engineCount)
			{
				supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_15360GB));
				if(supportedCapacity < maximumCapacity/2 * engineCount)
				{
					supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_7680GB));
					if(supportedCapacity < maximumCapacity/4 * engineCount && indicator == false)
					{
						supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_3840GB));
					}
					if(hostType == HostType.MAINFRAME_HOST)
					{
						if(supportedCapacity < maximumCapacity/4 * engineCount && indicator == true)
							supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_3840GB));
						else if(supportedCapacity < maximumCapacity/8 * engineCount && indicator == false)
							supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_1920GB));
						if(supportedCapacity < maximumCapacity/8 * engineCount && indicator == true)
							supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_1920GB));
					}
				}
			}
			if(190 * engineCount < supportedCapacity)
				supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_960GB));
			if(380 * engineCount < supportedCapacity)
				supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_1920GB));
			if(760 * engineCount < supportedCapacity)
				supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_3840GB));
			if(1520 * engineCount < supportedCapacity)
				supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_7680GB));*/
			
			
					
			// validates all drive types and removes all unpropriet ones  NEED TO BE REFACTORE
			if(raid == DriveRaidLevel.R57)
			{
				if(supportedCapacity < 210.6 * engineCount)
				{
					supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_15360GB));
					if(supportedCapacity < 105.3 * engineCount)
					{
						supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_7680GB));
						if(hostType == HostType.MAINFRAME_HOST){
							if(supportedCapacity < 52.6 * engineCount)
								supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_3840GB));
							if(supportedCapacity < 26.3  * engineCount)
								supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_1920GB));
							
						}
					}
				}
				if(190 * engineCount < supportedCapacity)
					supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_960GB));
				if(380 * engineCount < supportedCapacity)
					supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_1920GB));
				if(760 * engineCount < supportedCapacity)
					supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_3840GB));
				if(1520 * engineCount < supportedCapacity)
					supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_7680GB));
					
			}

			if(raid == DriveRaidLevel.R614)
			{
				if(supportedCapacity < 421.1 * engineCount)
				{
					supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_15360GB));
					if(supportedCapacity < 210.6 * engineCount)
					{
						supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_7680GB));
						if(supportedCapacity < 105.3 * engineCount)
						{
							supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_3840GB));
							if(hostType == HostType.MAINFRAME_HOST)
							{
								if(supportedCapacity < 52.6 * engineCount)
									supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_1920GB));
							}
						}
					}
				}
				if(190 * engineCount < supportedCapacity)
					supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_960GB));
				if(380 * engineCount < supportedCapacity)
					supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_1920GB));
				if(760 * engineCount < supportedCapacity)
					supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_3840GB));
				if(1520 * engineCount < supportedCapacity)
					supportedDrives.removeItemAt(supportedDrives.getItemIndex(DriveType.FLASH_SAS_7680GB));
			}
			
			return supportedDrives;
	}
		
		
		/**
		 * Validates supported drive types for 250F AFA based on provided capacity, RAID and number of engines.
		 * @param totCapacity indicates total usable capacity
		 * @param raid indicates RAID level protection
		 * @param engineCount indicates selected number of engines
		 * @return collection of supported DriveType instances
		 * 
		 */			
		public function validateSupportedDriveTypes(totCapacity:Number, raid:DriveRaidLevel, engineCount:int):ArrayCollection
		{
			var supportedDrives:ArrayCollection = new ArrayCollection();
			var drivePacksForRaid53:ArrayCollection = new ArrayCollection([2.8, 5.6, 11.3, 22.6, 45.2]);
			var drivePacksForRaid66:ArrayCollection = new ArrayCollection([5.6, 11.3, 22.6, 45.1, 90.3]);
			var drivePacksForRaid57:ArrayCollection = new ArrayCollection([6.6, 13.2, 26.4, 52.8, 105.6]);
			var driveTypes:ArrayCollection = new ArrayCollection([DriveType.FLASH_SAS_960GB, DriveType.FLASH_SAS_1920GB, DriveType.FLASH_SAS_3840GB, DriveType.FLASH_SAS_7680GB, DriveType.FLASH_SAS_15360GB]);
			var drivePacks:ArrayCollection;
			var minCapacityPackPerEngine:Number = 2;
			var maxCapacityPackPerEngine:Number = 12;
			
			var minimumCapacityPack:Number;
			
			if(raid == DriveRaidLevel.R53)
			{
				drivePacks = drivePacksForRaid53;
				minimumCapacityPack = 11.3;
			}
			else if(raid == DriveRaidLevel.R57_forTabasco)
			{
				drivePacks = drivePacksForRaid57;
				maxCapacityPackPerEngine = 6;
				minimumCapacityPack = 13.2;
			}
			else if(raid == DriveRaidLevel.R66)
			{
				drivePacks = drivePacksForRaid66;
				maxCapacityPackPerEngine = 6;
				minimumCapacityPack = 11.3;
			}
			var supportedCapacity:Number = this.getSupportedCapacity(totCapacity, minimumCapacityPack);	
			
			supportedCapacity = new Number(supportedCapacity.toFixed(2));
			
			for(var i:int = 4; i >= 0; i--)
			{
				if(supportedCapacity / drivePacks[i] <= maxCapacityPackPerEngine * engineCount && supportedCapacity / drivePacks[i] >= minCapacityPackPerEngine * engineCount)
				{
					supportedDrives.addItem(driveTypes[i]);
				}
			}
			
			return supportedDrives;
		}
		
		/**
		 * Calculates capacity which can be divided with 11.3 for 250F AFA only.
		 * @param cap chosen capacity
		 * @return formated capacity
		 */
		public function getSupportedCapacity(cap:Number, minimumCapacity:Number):Number
		{			
			if(cap % minimumCapacity != 0)
			{
				cap = cap/minimumCapacity - ((cap / minimumCapacity)%1);
				cap = (cap + 1) * minimumCapacity;
			}
			return cap;
		}
	}
}
 
