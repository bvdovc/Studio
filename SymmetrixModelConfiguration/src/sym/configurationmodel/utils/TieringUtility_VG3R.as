package sym.configurationmodel.utils
{
	import mx.collections.ArrayCollection;
	
	import sym.configurationmodel.common.ConfigurationFilter;
	import sym.objectmodel.common.Constants;
	import sym.objectmodel.common.DAE;
	import sym.objectmodel.common.DriveGroup;
	import sym.objectmodel.driveUtils.DriveDef;
	import sym.objectmodel.driveUtils.DriveRegister;
	import sym.objectmodel.driveUtils.enum.DriveRaidLevel;
	import sym.objectmodel.driveUtils.enum.DriveType;
	import sym.objectmodel.driveUtils.enum.HostType;

	/**
	 * Represents Drive count calculation logic for Tier solutions
	 */	
	public class TieringUtility_VG3R
	{
		// drive mix options
		/* vg3r Open Systems */
		public static const TIER_CUSTOM_CONFIG:int = 0;
		public static const TIER_2_COST:int = 1;
		public static const TIER_2_PERF:int = 2; 
		public static const TIER_1_EFD:int = 3; 
//		public static const TIER_2_MIX_COST:int = 2;
//		public static const TIER_3_BALANCED:int = 3;
//		public static const TIER_3_MIX_BALANCED:int = 4;
//		public static const TIER_3_PERF:int = 5;
//		public static const TIER_3_MIX_PERF:int = 6;
		
		// tier types
		public static const EFD_TIER:int = 1;
		public static const PERF_TIER:int = 2;
		public static const CAP_TIER:int = 3;
		
		// performance percent per each VMAX System
		public static const PERFORMANCE_PERCENTS_100K:Object = {
			960: 0.1,
			1200: 0.9
		};
		public static const PERFORMANCE_PERCENTS_200K:Object = {
			960: 0.2,
			1200: 0.8
		};
		public static const PERFORMANCE_PERCENTS_400K:Object = {
			960: 0.45,
			1200: 0.55
		};
		
		
		public static const QUICK_TIER_DRIVE_MAP:Object = initTiering();
		private static const DAETYPE_TIER_MAP:Object = initTierDAEMap();

		public static const ONE_SPARE_PER_ACTIVE_COUNT_NUMBER:int = 50;
		public static const ONE_SPARE_PER_ACTIVE_COUNT_NUMBER_PM2000:int = 48;
		public static const ACTIVE_DRIVE_COUNT:int = 1;
		public static const SPARE_DRIVE_COUNT:int = 2;
		public static const OVERALL_DRIVE_COUNT:int = 3;
		
        public static const RAID_POPULATION_ORDER:Array = [ 
            DriveRaidLevel.R614, 
            DriveRaidLevel.R57,
            DriveRaidLevel.R66,
            DriveRaidLevel.R53,
            DriveRaidLevel.R1 ];
        
        public static const COST_TIERS:Array = [TIER_2_COST];
//        public static const BALANCED_TIERS:Array = [TIER_3_BALANCED, TIER_3_MIX_BALANCED];
        public static const PERFORMANCE_TIERS:Array = [TIER_2_PERF];
        public static const FLASH_TIERS:Array = [TIER_1_EFD];
        
        public static const USABLE_CAPACITY_MAXIMUMS:Object = generateCapacityMaximums();
				
		public function TieringUtility_VG3R()
		{
		}
			
		/**
		 * Initializes Quick Tier solutions - Array of DriveGroup objects
		 * @return tier drive map
		 * 
		 */		
		private static function initTiering():Object
		{
			var tiers:Object = new Object();
			 
			tiers[TIER_2_COST] = [
				DriveGroup.create(DriveRegister.register(DriveType.FC_SAS_10K_1TB, DriveRaidLevel.R66, DriveDef.getSupportedSize(DriveType.FC_SAS_10K_1TB)), 0.75),
				DriveGroup.create(DriveRegister.register(DriveType.FC_SAS_10K_300GB, DriveRaidLevel.R1, DriveDef.getSupportedSize(DriveType.FC_SAS_10K_300GB)), 0.25)
			];
			/*tiers[TIER_2_MIX_COST] = [
				DriveGroup.create(DriveRegister.register(DriveType.SATA_SAS_7K_2TB, DriveRaidLevel.R66, DriveDef.getSupportedSize(DriveType.SATA_SAS_7K_2TB)),  0.71),
				DriveGroup.create(DriveRegister.register(DriveType.FC_SAS_10K_300GB, DriveRaidLevel.R1, DriveDef.getSupportedSize(DriveType.FC_SAS_10K_300GB)),  0.29)
			]; 
			tiers[TIER_3_BALANCED] = [
				DriveGroup.create(DriveRegister.register(DriveType.FC_SAS_10K_1TB, DriveRaidLevel.R66, DriveDef.getSupportedSize(DriveType.FC_SAS_10K_1TB)),  0.585),
				DriveGroup.create(DriveRegister.register(DriveType.FC_SAS_15K_300GB, DriveRaidLevel.R1, DriveDef.getSupportedSize(DriveType.FC_SAS_15K_300GB)),  0.39),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_200GB, DriveRaidLevel.R53, DriveDef.getSupportedSize(DriveType.FLASH_SAS_200GB)),  0.025)
			];
			tiers[TIER_3_MIX_BALANCED] = [
				DriveGroup.create(DriveRegister.register(DriveType.SATA_SAS_7K_2TB, DriveRaidLevel.R66, DriveDef.getSupportedSize(DriveType.SATA_SAS_7K_2TB)),  0.53),
				DriveGroup.create(DriveRegister.register(DriveType.FC_SAS_15K_300GB, DriveRaidLevel.R1, DriveDef.getSupportedSize(DriveType.FC_SAS_15K_300GB)),  0.44),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_200GB, DriveRaidLevel.R53, DriveDef.getSupportedSize(DriveType.FLASH_SAS_200GB)),  0.03)
			]; */ 
			tiers[TIER_2_PERF] = [
				DriveGroup.create(DriveRegister.register(DriveType.FC_SAS_10K_1TB, DriveRaidLevel.R66, DriveDef.getSupportedSize(DriveType.FC_SAS_10K_1TB))),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_960GB, DriveRaidLevel.R53, DriveDef.getSupportedSize(DriveType.FLASH_SAS_960GB)))
			];
			/*tiers[TIER_3_MIX_PERF] = [
				DriveGroup.create(DriveRegister.register(DriveType.SATA_SAS_7K_2TB, DriveRaidLevel.R66, DriveDef.getSupportedSize(DriveType.SATA_SAS_7K_2TB)),  0.5),
				DriveGroup.create(DriveRegister.register(DriveType.FC_SAS_15K_300GB, DriveRaidLevel.R1, DriveDef.getSupportedSize(DriveType.FC_SAS_15K_300GB)),  0.4),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_200GB, DriveRaidLevel.R53, DriveDef.getSupportedSize(DriveType.FLASH_SAS_200GB)),  0.1)
			]; */
			tiers[TIER_1_EFD] = [
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_960GB, DriveRaidLevel.R53, DriveDef.getSupportedSize(DriveType.FLASH_SAS_960GB)), 1)
			];
			
			return tiers;
		}
		
		/**
		 * Updates quick Performance drive mix percent values
		 * @param vmax indicates current VMAX array
		 */		
		public static function updatePerformancePercents(vmax:String):void
		{
			for each (var driveGroup:DriveGroup in QUICK_TIER_DRIVE_MAP[TIER_2_PERF])
			{
				switch(vmax)
				{						
					default:
					{
						throw new ArgumentError("Only 100/200/400K VMAX arrays are supported!");
					}
				}
			}
		}
		
		/**
		 * Initialize allowed tiers per daeType
		 * @return 
		 * 
		 */		
		private static function initTierDAEMap():Object{
			var result:Object = new Object();
			
			result[DAE.Viking] = [TIER_2_COST, TIER_2_PERF, TIER_1_EFD];
//			result[DAE.MixedVoyager] = [TIER_2_MIX_COST, TIER_3_MIX_BALANCED, TIER_3_MIX_PERF];
			
			return result;
		}
		
		/**
		 * Gets allowed tiers per daetype 
		 * @param daeType
		 * @return 
		 * 
		 */		
		public static function getAllowedTiers(daeType:int):ArrayCollection
		{
			return new ArrayCollection(DAETYPE_TIER_MAP[daeType]);
		}
		
		/**
		 * Gets default DAE type for quick tier solution
		 * @param tier indicates tier solution
		 * @return DAE type
		 * 
		 */		
		public static function getDefaultDAEtype(tier:int):int
		{
			return (DAETYPE_TIER_MAP[DAE.Viking] as Array).indexOf(tier) != -1 ? DAE.Viking : DAE.MixedVoyager;
		}
		
		public static function getAllTiers():Array
		{
			return COST_TIERS.concat(PERFORMANCE_TIERS).concat(FLASH_TIERS);
		}
		
		public static function isCostTier(tier:int):Boolean
		{
			return COST_TIERS.indexOf(tier) != -1;
		}

		/*public static function isBalancedTier(tier:int):Boolean
		{
			return BALANCED_TIERS.indexOf(tier) != -1;
		}*/
		
		public static function isPerformanceTier(tier:int):Boolean
		{
			return PERFORMANCE_TIERS.indexOf(tier) != -1;
		}
		
		public static function isFlashTier(tier:int):Boolean
		{
			return FLASH_TIERS.indexOf(tier) != -1;
		}
		
		/**
		 * Gets tier type to which drive type belongs 
		 * @param drive indicates drive type
		 * @return tier type - EFD/Perf/Cap Tier
		 * 
		 */		
		public static function getTierType(drive:DriveType):int
		{
			if (drive.isFC_SAS && drive.capacity != DriveType.FC_SAS_10K_1TB.capacity)
			{
				return PERF_TIER;
			}
			
			if (drive.isSATA_SAS || drive.capacity == DriveType.FC_SAS_10K_1TB.capacity)
			{
				return CAP_TIER;
			}
			
			return EFD_TIER;
		}
		
		/**
		 * Gets number of Tier types in drive mix selection 
		 * @param selectedTier indicates selected tier option
		 * @param customDP indicates custom data provider drive groups
		 * @return <i>1, 2 </i> or <i>3<i/> as possible values
		 * 
		 */		
		public static function getTierCount(selectedTier:int, customDP:ArrayCollection = null):int
		{
			if (selectedTier != TIER_CUSTOM_CONFIG)
			{
				return getDriveGroups(selectedTier).length;
			}
            
            var efdTiers:int = 0;
            var perfTiers:int = 0;
            var capTiers:int = 0;
			for each (var dg:DriveGroup in customDP)
			{
				var tierType:int = getTierType(dg.driveDef.type);
				
				if (tierType == TieringUtility_VG3R.EFD_TIER)
				{
					efdTiers = 1;
				}
				if (tierType == TieringUtility_VG3R.PERF_TIER)
				{
					perfTiers = 1;	
				}
				if (tierType == TieringUtility_VG3R.CAP_TIER)
				{
					capTiers = 1;
				}
			}
			return efdTiers + perfTiers + capTiers;
		}
		
		/**
		 * Gets min usable capacity for predefined quick tier
		 * @param tier indicates quick tier solution
		 * @return min capacity
		 * 
		 */					
		public static function getMinCap(tier:int):Number
		{
			if (tier == TIER_2_COST)
			{
				return 9.4;
			}
			if (tier == TIER_2_PERF)
			{
				return 24.1;
			}
			if (tier == TIER_1_EFD)
			{
				return 2.8;
			}
			/*if (tier == TIER_2_MIX_COST)
			{
				return 14.5;
			}
			if (tier == TIER_3_BALANCED)
			{
				return 21.5;
			}
			if (tier == TIER_3_MIX_BALANCED)
			{
				return 19.2;
			}
			if (tier == TIER_3_PERF)
			{
				return 10.5;
			}
			if (tier == TIER_3_MIX_PERF)
			{
				return 20.8;
			}*/
			
			return 0;
		}
		
		/**
		 * Gets drive groups for specific tier 
		 * @param tier indicates tier solution
		 * @param sortByModulo indicates if drive groups are sorted by Modulo population number
		 * @param sortByTierType indicates if drive groups are sorted by Tier type 
		 * @return all drive groups
		 * 
		 */		
		public static function getDriveGroups(tier:int, sortByModulo:Boolean = false, sortByTierType:Boolean = false):Array
		{
			var driveGroups:Array = [];
			for each (var driveGroup:DriveGroup in QUICK_TIER_DRIVE_MAP[tier]) 
			{
				if (sortByModulo || sortByTierType)
				{
					driveGroups.push({group: driveGroup, sortField: sortByModulo ? driveGroup.driveDef.raid.mod : TieringUtility_VG3R.getTierType(driveGroup.driveDef.type)});
				}
				else
				{
					driveGroups.push(driveGroup);
				}
			}
			
			if (sortByModulo || sortByTierType)
			{
				var temp:Array = driveGroups.sortOn("sortField", sortByModulo ? Array.DESCENDING : Array.NUMERIC);
				driveGroups = new Array();
				
				for each (var driveObj:Object in temp)
				{
					driveGroups.push(driveObj["group"]);
				}
			}
			
			return driveGroups;
		}
		
		/**
		 * Calculates usable capacity for given input capacity, tiering and drive type  
		 * @param tiering indicates tiering solution 
		 * @param driveDefID indicates drive definition id 
		 * @param capacity indicates user input Capacity value
		 * @return 
		 * 
		 */		
		private static function calculateUsableCapacity(tiering:int, driveDefID:int, capacity:Number):Number 
		{
			var driveGroups:Object = tiering == ConfigurationFilter.TIER_SOLUTION_DEFAULT ? 
				AllFlashArrayUtility.BASE_DRIVE_GROUPS[AllFlashArrayUtility.systemDriveRAID.name] : QUICK_TIER_DRIVE_MAP[tiering];
			
			for each (var driveMap:DriveGroup in driveGroups)
			{
				if (driveDefID == driveMap.driveDef.id)
				{
					if (!driveMap.percent)
						return 0;
					
					return Math.round(driveMap.percent * capacity * 1000); // TB conversion to GB
				}
			}
			
			return 0;
		}
		
		/**
		 * Calculates row capacity 
		 * @param tiering indicates tiering solution 
		 * @param drive indicates drive definition
		 * @param capacity user input Capacity
		 * @return 
		 * 
		 */		
		private static function calculateRowCapacity(tiering:int, drive:DriveDef, capacity:Number):Number 
		{
			return calculateUsableCapacity(tiering, drive.id, capacity) / drive.raid.factor;
		}
		
		/**
		 * Calculates number of active drives for specific tier
		 * @param tier indicates quick tier solution
		 * @param driveGroup indicates one drive group in tier
		 * @param capacity indicates user capacity input value
		 * @param hostType indicates OpenSystem or Mainframe host type. Default values is <code> OS </code>
		 * @return active drive count
		 * 
		 */		
		public static function calculateNoActives(tier:int, dg:DriveGroup, capacity:Number, hostType:String = HostType.OPEN_SYSTEMS):int
		{
			var rgs:int = dg.driveDef.raid.raidGroupSize;
			return Math.max(rgs, rgs * Math.round(calculateRowCapacity(tier, dg.driveDef, capacity) / (rgs * dg.driveDef.type.getFormattedCapacity(hostType))));
		
		}
        
        /**
         * Clones drive group instances and creates new array 
         * @param driveGroups
         * 
         */        
        public static function cloneDriveGroups(driveGroups:Array):Array
        {
            var dgClone:Array = new Array();
            for each(var driveGroup:DriveGroup in driveGroups)
            {
                dgClone.push(driveGroup.cloneDG());
            }
            return dgClone;
        }
		
        /**
         * Generates maximal usable capacities for each quick tier based on Engine count 
         * @return 
         * 
         */        
        private static function generateCapacityMaximums():Object
        {
            var result:Object = new Object();
            
            result[TIER_2_COST] = {
                1 : 272,
                2 : 544,
                3 : 817,
                4 : 1091,
                5 : 1365,
                6 : 1637,
                7 : 1909,
                8 : 2181
            };
            result[TIER_2_PERF] = {
				1 : 544,
				2 : 544,
				3 : 1784,
				4 : 2310,
				5 : 2787,
				6 : 3345,
				7 : 3903,
				8 : 4350
            };
            result[TIER_1_EFD] = {
                1 : 498,
                2 : 544,
                3 : 1491,
                4 : 1987,
                5 : 2484,
                6 : 2981,
                7 : 3477,
                8 : 3974
			};
            /*result[TIER_1_EFD] = {
                1 : 208,
                2 : 416,
                3 : 624,
                4 : 832,
                5 : 1040,
                6 : 1248,
                7 : 1456,
                8 : 1664
            };
            result[TIER_2_MIX_COST] = {
                1 : 230,
                2 : 453,
                3 : 676,
                4 : 898,
                5 : 1121,
                6 : 1344,
                7 : 1567,
                8 : 1789
            };
            result[TIER_3_BALANCED] = {
                1 : 199,
                2 : 397,
                3 : 595,
                4 : 794,
                5 : 993,
                6 : 1192,
                7 : 1391,
                8 : 1589
            };
            result[TIER_3_MIX_BALANCED] = {
                1 : 159,
                2 : 309,
                3 : 458,
                4 : 607,
                5 : 756,
                6 : 905,
                7 : 1055,
                8 : 1204
            };
            result[TIER_3_PERF] = {
                1 : 206,
                2 : 408,
                3 : 613,
                4 : 817,
                5 : 1022,
                6 : 1277,
                7 : 1431,
                8 : 1636 
            };
            result[TIER_3_MIX_PERF] = {
                1 : 169,
                2 : 327,
                3 : 485,
                4 : 643,
                5 : 802,
                6 : 960,
                7 : 1119,
                8 : 1276
            };*/
            
            return result;
        } 
	}
}