package sym.objectmodel.driveUtils.enum
{
	/**
	 * Contains Drive Technology type information
	 */	
	public class DriveType extends Enum
	{
		private var _cap:int;
		private var _spare:String;
		private var _iops:int;
		private var _speed:Number;
		
		private static const _200GB_FLASH:DriveType = new DriveType("200GB Flash", 200, 3600);
		private static const _400GB_FLASH:DriveType = new DriveType("400GB Flash", 400, 3600);
		private static const _800GB_FLASH:DriveType = new DriveType("800GB Flash", 800, 3600);
		private static const _960GB_FLASH:DriveType = new DriveType("960GB Flash", 960, 3600);
		private static const _1600GB_FLASH:DriveType = new DriveType("1.6TB Flash", 1600, 3600);
		private static const _1920GB_FLASH:DriveType = new DriveType("1.92TB Flash", 1920, 3600);
		private static const _3840GB_FLASH:DriveType = new DriveType("3.84TB Flash", 3840, 3600);
		private static const _7680GB_FLASH:DriveType = new DriveType("7.68TB Flash", 7680, 3600);
		private static const _15360GB_FLASH:DriveType = new  DriveType("15.36TB Flash", 15360, 3600);
		private static const _300GB_15K_FC:DriveType = new DriveType("300GB 15K SAS", 300, 375, 15);
		private static const _300GB_10K_FC:DriveType = new DriveType("300GB 10K SAS", 300, 250, 10);
		private static const _600GB_10K_FC:DriveType = new DriveType("600GB 10K SAS", 600, 250, 10);
		private static const _1TB_10K_FC:DriveType = new DriveType("1.2TB 10K SAS", 1200, 250, 10);
		private static const _2TB_7K_SATA:DriveType = new DriveType("2TB 7.2K SAS", 2000, 150, 7.2);
		private static const _4TB_7K_SATA:DriveType = new DriveType("4TB 7.2K SAS", 4000, 150, 7.2);
		
		private static const _1920GB_FLASH_NVM:DriveType = new DriveType("1.92TB NVMe", 1920, 3600);
		private static const _3840GB_FLASH_NVM:DriveType = new DriveType("3.84TB NVMe", 3840, 3600);
		private static const _7680GB_FLASH_NVM:DriveType = new DriveType("7.68TB NVMe", 7680, 3600);
		
		private static const EFD_RPM_SPEED:Number = 90;
		public static const DRIVE_CAPACITY_XML_NAME:String = "drive_size";
		public static const DRIVE_SPEED_XML_NAME:String = "drive_speed";
		
		private static const DRIVE_CAPACITY_MAP:Object = {
			100: {OS: 98.49, MF: 95.61},
			200: {OS: 196.97, MF: 191.21},
			300: {OS: 288.19, MF: 279.77},
			400: {OS: 393.84, MF: 382.33},
			600: {OS: 576.39, MF: 559.54},
			800: {OS: 787.69, MF: 744.66},
			900: {OS: 881.13, MF: 855.37},
			960: {OS: 940.59, MF: 913.09},
			1000: {OS: 969.89, MF: 941.53},
			1200: {OS: 1181.77, MF: 1147.22},
			1600: {OS: 1575.2, MF: 1600},
			1920: {OS: 1881.19, MF: 1826.18},
			2000: {OS: 1882.72, MF: 1827.67},
			3840: {OS: 3726.38, MF: 3652.36},
			4000: {OS: 3939.23, MF: 3824.03},
			7680: {OS: 7522.95, MF: 7522.45},
			15360: {OS: 15047.2, MF: 15047.2}
		};
		
		public function DriveType(name:String, cap:int, iops:int, rpm:Number = EFD_RPM_SPEED)
		{
			super();
			_name = name;
			_cap = cap;
			_spare = _name + " SPARE";
			_iops = iops;
			_speed = rpm;
		}

		public function get spareName():String
		{
			return _spare;
		}
		
		public function get iops():int
		{
			return _iops;
		}
		
		public function get speed():Number
		{
			return _speed;
		}

		public static function get SATA_SAS_7K_4TB():DriveType 
		{
			return _4TB_7K_SATA;
		}
		
		public static function get SATA_SAS_7K_2TB():DriveType 
		{
			return _2TB_7K_SATA;
		}
		
		public static function get FC_SAS_10K_1TB():DriveType
		{
			return _1TB_10K_FC;
		}

		public static function get FC_SAS_10K_600GB():DriveType
		{
			return _600GB_10K_FC;
		}
		
		public static function get FC_SAS_10K_300GB():DriveType
		{
			return _300GB_10K_FC;
		}
		
		public static function get FC_SAS_15K_300GB():DriveType
		{
			return _300GB_15K_FC;
		}
		
		public static function get FLASH_SAS_1600GB():DriveType
		{
			return _1600GB_FLASH;
		}
		
		public static function get FLASH_SAS_960GB():DriveType
		{
			return _960GB_FLASH;
		}
		
		public static function get FLASH_SAS_1920GB():DriveType
		{
			return _1920GB_FLASH;
		}
		
		public static function get FLASH_NVM_1920GB():DriveType
		{
			return _1920GB_FLASH_NVM;
		}

		public static function get FLASH_SAS_3840GB():DriveType
		{
			return _3840GB_FLASH;
		}
		
		public static function get FLASH_NVM_3840GB():DriveType
		{
			return _3840GB_FLASH_NVM;
		}
		
		public static function get FLASH_SAS_800GB():DriveType
		{
			return _800GB_FLASH;
		}
		
		public static function get FLASH_SAS_400GB():DriveType
		{
			return _400GB_FLASH;
		}
		
		public static function get FLASH_SAS_200GB():DriveType
		{
			return _200GB_FLASH;
		}
		public static function get 	FLASH_SAS_7680GB():DriveType
		{
			return _7680GB_FLASH;
		}
		
		public static function get 	FLASH_NVM_7680GB():DriveType
		{
			return _7680GB_FLASH_NVM;
		}
		public static function get FLASH_SAS_15360GB():DriveType
		{
			return _15360GB_FLASH;
		}

		/**
		 * Gets all drive types 
		 * @return 
		 * 
		 */		
		public static function get values():Array
		{
			return FLASH.concat(FC_SAS).concat(SATA_SAS);
		}
		
		/**
		 * Gets all drive types supported by 100/200/400K family series
		 * @return 
		 * 
		 */	
		public static function get values_family():Array
		{
			return FLASH_FAMILY.concat(FC_SAS).concat(SATA_SAS);
		}
			
		/**
		 * Gets all FLASH drive types
		 * @return 
		 * 
		 */		
		public static function get FLASH():Array
		{
			return [FLASH_SAS_15360GB, FLASH_SAS_7680GB, FLASH_SAS_3840GB, FLASH_SAS_1920GB, FLASH_SAS_1600GB, FLASH_SAS_960GB, FLASH_SAS_800GB, FLASH_SAS_400GB, FLASH_SAS_200GB, FLASH_NVM_1920GB, FLASH_NVM_3840GB, FLASH_NVM_7680GB];
		}
		
		/**
		 * Gets all FLASH drive types supported for 100/200/400K family series
		 * @return
		 */
		public static function get FLASH_FAMILY():Array
		{
			return [FLASH_SAS_1920GB, FLASH_SAS_1600GB, FLASH_SAS_960GB, FLASH_SAS_800GB, FLASH_SAS_400GB, FLASH_SAS_200GB];

		}
		
		/**
		 * Gets all FC SAS drive types
		 * @return 
		 * 
		 */		
		public static function get FC_SAS():Array
		{
			return [FC_SAS_10K_1TB, FC_SAS_10K_600GB, FC_SAS_10K_300GB, FC_SAS_15K_300GB];
		}
		
		/**
		 * Gets all SATA SAS drive types
		 * @return 
		 * 
		 */		
		public static function get SATA_SAS():Array
		{
			return [SATA_SAS_7K_4TB, SATA_SAS_7K_2TB];
		}
			
		public function get isEFD():Boolean
		{
			return FLASH.indexOf(this) != -1;
		}

		public function get isFC_SAS():Boolean
		{
			return FC_SAS.indexOf(this) != -1;
		}
		
		public function get isSATA_SAS():Boolean
		{
			return SATA_SAS.indexOf(this) != -1;
		}
		
		
		/**
		 * Gets drive numeric capacity
		 * @return drive capacity
		 * 
		 */		
		public function get capacity():Number 
		{
			return _cap;
		}
		
		/**
		 * Gets formatted capacity per host type 
		 * @@param hostType indicates OS/MF host type
		 * @return drive formatted capacity
		 * 
		 */	
		public function getFormattedCapacity(hostType:String):Number
		{
			return DRIVE_CAPACITY_MAP[capacity][hostType];
		}
	}
}