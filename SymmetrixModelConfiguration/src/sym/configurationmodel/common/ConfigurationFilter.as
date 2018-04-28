package sym.configurationmodel.common
{
	import sym.objectmodel.common.Engine;
	import sym.objectmodel.driveUtils.enum.DriveType;
	import sym.objectmodel.driveUtils.enum.HostType;

	/**
	 * configuration filter.
	 */
	public class ConfigurationFilter
	{ 
        public static const FILTER_DAE_TYPE:String = "daeType";
        public static const FILTER_DAE_COUNT:String = "daeCount";
        public static const FILTER_ENGINES:String = "noEngines";
        public static const FILTER_DISPERSED:String = "dispersed";
		public static const FILTER_DISPERSED_M:String = "dispersed_m";
        public static const FILTER_STORAGE_BAYS:String = "noStorageBays";
        public static const FILTER_SYSTEM_BAYS:String = "noSystemBays";
        public static const FILTER_SYSBAYS_TYPE:String = "sysBayType";
        public static const FILTER_DATA_MOVERS:String = "noDataMovers";
        public static const FILTER_TIERING:String = "tiering";
        public static const FILTER_USABLE_CAPACITY:String = "totCapacity";
        public static const FILTER_HOST_TYPE:String = "hostType";
		public static const FILTER_DRIVE_TYPE:String = "driveType";
		public static const FILTER_DRIVES:String = "noDrives";
        
        /**
         * D15 only
         */
        public static const DAETYPED15:int = 1;
        
        /**
         * Vanguard only
         */
        public static const DAETYPEVanguard:int = 2;
        
        /**
         * MixedD15 (confs that have both D15 and Vanguard but starts with D15)
         */
        public static const DAETYPEMixedD15:int = 3;
        
        /**
         * MixedVanguard (confs that have both D15 and Vanguard but starts with Vanguard)
         */
        public static const DAETYPEMixedVangaurd:int = 4;
        
		/**
		 * Voyager only 
		 */		
		public static const DAETYPEVoyager:int = 5;
		/**
		 * Viking only 
		 */		
		public static const DAETYPEViking:int = 6;
		/**
		 * Mixed config - Viking and Voyager 
		 */		
		public static const DAETYPEMixedVoyager:int = 7;
		
        public static const NO_ENGINE_DEFAULT:int = -1;
		public static const NO_DRIVES_DEFAULT:int = -1;
        public static const NO_STORAGE_BAYS_DEFAULT:int = -1;
        public static const NO_DISPERSED_DEFAULT:int = DISPERSEDNON;
        public static const NO_DISPERSED_DEFAULT_M:Array = DISPERSEDNON_M;
        public static const NO_DAE_DEFAULT:int = DAETYPED15;
		public static const NO_DAE_DEFAULT_MFAMILY:int = -1;
        public static const NO_DAE_COUNT_DEFAULT:int = -1;
		public static const NO_DATA_MOVER_DEFAULT:int = -1;
		public static const NO_SYSTEM_BAYS_DEFAULT:int = -1;
		public static const USABLE_CAPACITY_DEFAULT:Number = -1; // TB 
		public static const TIER_SOLUTION_DEFAULT:int = -1;
		public static const SYSTEM_BAY_TYPE_DEFAULT:int = SINGLE_ENGINE_BAY;
		public static const DRIVE_TYPE_DEFAULT:String = "ANY";
        
		/**
		 * number of engines in an configuration
		 * use -1 for any
		 */
		public var noEngines:int = NO_ENGINE_DEFAULT;
		
		/**
		 * number of drives in an configuration
		 * use -1 for any
		 */
		public var noDrives:int = NO_DRIVES_DEFAULT;
		
		/**
		 * number of storage bays in an configuration
		 * use -1 for any
		 */
		public var noStorageBays:int = NO_STORAGE_BAYS_DEFAULT;

		/**
		 * number of system bays in an configuration
		 * use -1 for any
		 */
		public var noSystemBays:int = NO_SYSTEM_BAYS_DEFAULT;

		/**
		 * how much floor space does configuration take
		 * TBD: rethink
		 */
		public var floorSpace:int = -1;
		
		/**
		 * type of connectivity a configuration allows
		 * TBD: rethink how to filter by it
		 */
		public var connectivityType:int = -1;
		

		/**
		 * 1-phase configurations
		 */
		public static const PWRTYPE1:int = 1;
		
		/**
		 * 3-phase configurations
		 */
		public static const PWRTYPE3:int = 2;

		/**
		 * type of power supply (1 or 3 phase)
		 */
		public var powerType:int = PWRTYPE1;
		 
        /**
         * DAE type to filter by
         */
        public var daeType:int = NO_DAE_DEFAULT_MFAMILY;
        /**
         * filter by non-dispersed configurations
         */
        public static const DISPERSEDNON:int = -1;
        
		/**
		 * filter by non-dispersed configurations
		 */
		public static const DISPERSEDNON_M:Array = [-1];
		
        /**
         * filter by dispersed on 3rd engine
         */
        public static const DISPERSED3:int = 3;

        /**
         * filter by dispersed on 5th engine
         */
        
        public static const DISPERSED5:int = 5;
        /**
         * filter by dispersed on 7th engine
         */
        public static const DISPERSED7:int = 7;

		/**
		 * dispersion to filter by
		 */
		public var dispersed:int = DISPERSEDNON; 
		
		/**
		 * dispersion to filter by
		 */
		public var dispersed_m:Array = DISPERSEDNON_M; 
		
		/**
		 * daeCount to filter by
		 */
		public var daeCount:int = NO_DAE_COUNT_DEFAULT;
		
		/**
		 * 2 Data Movers in configuration
		 */
		public static const DATA_MOVER_2:int = 2;
		
		/**
		 * 3 Data Movers in configuration
		 */
		
		public static const DATA_MOVER_3:int = 3;
		/**
		 * 4 Data Movers in configuration
		 */
		public static const DATA_MOVER_4:int = 4;
		
		/**
		 * number of Data Mover to filter by
		 * -1 for any
		 */
		public var noDataMovers:int = NO_DATA_MOVER_DEFAULT;
		
		/**
		 * Tier to filter by
		 */ 
		public var tiering:int = TIER_SOLUTION_DEFAULT;

		/**
		 * total usable capacity (TB is used)
		 */ 
		public var totCapacity:Number = USABLE_CAPACITY_DEFAULT; 
		
		public var driveType:String = DRIVE_TYPE_DEFAULT;
		/**
		 * host tyoe selection - OS/MF/Mixed 
		 * </br> Default - OS(Open Systems)
		 */		
		public var hostType:String = HostType.OPEN_SYSTEMS; 

		/**
		 * Single engine bay type
		 */ 
		public static const SINGLE_ENGINE_BAY:int = 1;
		
		/**
		 * Dual engine bay type
		 */ 
		public static const DUAL_ENGINE_BAY:int = 2;
		
		/**
		 * System Bay type to filter by(single/dual engine)
		 * Default - Single engine
		*/
		public var sysBayType:int = SYSTEM_BAY_TYPE_DEFAULT;
        
		public function ConfigurationFilter()
		{
		}
        
        public function clone():ConfigurationFilter{
            var filter:ConfigurationFilter = new ConfigurationFilter();
            filter.connectivityType = this.connectivityType;
            filter.daeCount = this.daeCount;
            filter.daeType = this.daeType;
            filter.dispersed = this.dispersed;
            filter.floorSpace = this.floorSpace;
            filter.noEngines = this.noEngines;
            filter.noStorageBays  = this.noStorageBays;
            filter.powerType = this.powerType;
			filter.noDataMovers = this.noDataMovers;
			//new
			filter.driveType = this.driveType;
			filter.noDrives = this.noDrives;
            return filter;
        }
		
		public function cloneMSeries():ConfigurationFilter{
			var filter:ConfigurationFilter = new ConfigurationFilter();
			filter.connectivityType = this.connectivityType;
			filter.daeCount = this.daeCount;
			filter.daeType = this.daeType;
			filter.dispersed_m = this.dispersed_m;
			filter.floorSpace = this.floorSpace;
			filter.noEngines = this.noEngines;
			filter.noStorageBays  = this.noStorageBays;
			filter.noSystemBays  = this.noSystemBays;
			filter.powerType = this.powerType;
			filter.noDataMovers = this.noDataMovers;
			filter.tiering = this.tiering;
			filter.sysBayType = this.sysBayType;
			filter.totCapacity = this.totCapacity;
			filter.hostType = this.hostType;
			//new drive type
			filter.driveType = this.driveType;
			filter.noDrives = this.noDrives;
			return filter;
		}
	}
}