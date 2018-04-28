package sym.objectmodel.utils
{
	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;
	
	import sym.objectmodel.common.Configuration_VG3R;
	import sym.objectmodel.common.Constants;
	import sym.objectmodel.common.DAE;
	import sym.objectmodel.common.DriveGroup;
	import sym.objectmodel.driveUtils.DriveRegister;
	import sym.objectmodel.driveUtils.enum.DriveRaidLevel;
	import sym.objectmodel.driveUtils.enum.DriveType;
	import sym.objectmodel.driveUtils.enum.HostType;
	
	/**
	 * Class represents VMAX All Flash product structure and drive calculation logic
	 * 
	 */	
	public class AllFlashArray
	{
		public static const BASE_CONFIG_V_BRICK_CAPACITY:Number = 53; // 52.67
		public static const FLASH_BLOCK_CAPACITY_13TB:Number = 13; // 13.17 TB
		public static const FLASH_BLOCK_CAPACITY_26TB:Number = 26; // 26.34 TB
		
		// Flash capacity packs for 250F
		public static const FLASH_CAPACITY_PACK_2TB:Number = 2.8; // 2.8 TB
		public static const FLASH_CAPACITY_PACK_5TB:Number = 5.6; // 5.6 TB
		public static const FLASH_CAPACITY_PACK_11TB:Number = 11.3; // 11.3 TB
		public static const FLASH_CAPACITY_PACK_22TB:Number = 22.6; // 22.6 TB
		public static const FLASH_CAPACITY_PACK_45TB:Number = 45.1; // 45.1 TB
		public static const FLASH_CAPACITY_PACK_90TB:Number = 90.2; // 90.24 TB
		
		// Flash capacity packs for 250F when RAID5(7+1) is chosen
		public static const FLASH_CAPACITY_PACK_6TB:Number = 6.6; // 6.6 TB
		public static const FLASH_CAPACITY_PACK_13TB:Number = 13.2; // 13.2 TB
		public static const FLASH_CAPACITY_PACK_26TB:Number = 26.3; // 26.3 TB
		public static const FLASH_CAPACITY_PACK_52TB:Number = 52.6; // 52.6 TB
		public static const FLASH_CAPACITY_PACK_105TB:Number = 105.3; // 105.3 TB
		
		// maximum capacities constants for PM 2000 and PM 8000
		public static const MAXIMUM_CAPACITY_PM2000_RAID57:Number = 514.7;
		public static const MAXIMUM_CAPACITY_PM2000_RAID53:Number = 440.6;
		public static const MAXIMUM_CAPACITY_PM2000_RAID66:Number = 440.6;
		
		public static const MAXIMUM_CAPACITY_PM8000_RAID57:Number = 1683.2;
		public static const MAXIMUM_CAPACITY_PM8000_RAID66:Number = 1443.2;
		
		
		public static const FLASH_CAPACITY_PACK_210TB:Number = 210.6; //210.6 TB, used for 950f and raid 6
		
		// supported capacoty packs per specific RAID for specific drive type
		public static const supportedCapacityPacks250f:Object = generateSupported250fPacks();
		public static const supportedCapacityPacks950f:Object = generateSupported950fPacks();
		public static const supportedCapacityPacksPM2000:Object = generateSupportedPM2000Packs();
		public static const supportedCapacityPacksPM8000:Object = generateSupportedPM8000Packs();
		
		public static const BASE_250F_CONFIG_MINIMUM_CAPACITY:Number = FLASH_CAPACITY_PACK_11TB; //11.3TB
		public static const BASE_250F_CONFIG_MINIMUM_CAPACITY_FOR_RAID57:Number = FLASH_CAPACITY_PACK_13TB; //13.2TB
		
		//max usable capacity for 250f
		public static const TOTAL_USABLE_CAPACITY_250F:Number = 1083;
		
		//max usable capacity for 950f
		public static const TOTAL_USABLE_CAPACITY_RAID5:Number = 4300; //RAID5(7+1)
		public static const TOTAL_USABLE_CAPACITY_RAID6:Number = 2962; //RAID6(14+2)
		
		public static const BASE_PM2000_CONFIG_MINIMUM_CAPACITY:Number = FLASH_CAPACITY_PACK_5TB; //5.6TB
		public static const BASE_PM2000_CONFIG_MINIMUM_CAPACITY_FOR_RAID57:Number = FLASH_CAPACITY_PACK_13TB; //13.2TB
		public static const BASE_PM2000_CONFIG_MAXIMUM_CAPACITY_FOR_RAID53:Number = 497.2; //when RAID5(3+1) is chosen
		public static const BASE_PM2000_CONFIG_MAXIMUM_CAPACITY_FOR_RAID66:Number = 451; //when RAID6(6+2) is chosen
		public static const BASE_PM2000_CONFIG_MAXIMUM_CAPACITY_FOR_RAID57:Number = 526;//when RAID5(7+1) is chosen
		
		public static const BASE_DRIVE_GROUPS:Object = initBaseDG();
		public static const SUPPORTED_DRIVE_TYPES:Object = initDriveTypes();
		// supported drives for 250F
		public static const SUPPORTED_DRIVE_TYPES_250F:Object = {
			960: Constants.WIZARD_DRIVE_TYPE_960GB,
				1920: Constants.WIZARD_DRIVE_TYPE_1920GB,
				3840: Constants.WIZARD_DRIVE_TYPE_3840GB,
				7680: Constants.WIZARD_DRIVE_TYPE_7680GB,
				15360: Constants.WIZARD_DRIVE_TYPE_15360
		};
		
		// supported drives for PM2000
		public static const SUPPORTED_DRIVE_TYPES_PM2000:Object = {
			1920: Constants.WIZARD_DRIVE_TYPE_1920GB_NVM,
				3840: Constants.WIZARD_DRIVE_TYPE_3840GB_NVM,
				7680: Constants.WIZARD_DRIVE_TYPE_7680GB_NVM
		};
		
		// 13/26TB capacity block for 450/850F
		// 2.8/5.6/11.3/22.6/45.1 TB for 250F
		public static var capacityBlock:Number;
		
		// # of capacity chunks/blocks
		public static var noCapacityChunks:Number;
		
		public function AllFlashArray()
		{
		}
		/**
		 * Initializes basic drive groups for specific RAID
		 * @return 
		 * 
		 */		
		private static function initBaseDG():Object
		{
			var bdg:Object = new Object();
			
			bdg[DriveRaidLevel.R57.name] = [
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_15360GB, DriveRaidLevel.R57, DAE.Viking), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_7680GB, DriveRaidLevel.R57, DAE.Viking), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_3840GB, DriveRaidLevel.R57, DAE.Viking), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_1920GB, DriveRaidLevel.R57, DAE.Viking), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_960GB, DriveRaidLevel.R57, DAE.Viking), 1)
			];
			
			bdg[DriveRaidLevel.R614.name] = [
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_15360GB, DriveRaidLevel.R614, DAE.Viking), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_7680GB, DriveRaidLevel.R614, DAE.Viking), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_3840GB, DriveRaidLevel.R614, DAE.Viking), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_1920GB, DriveRaidLevel.R614, DAE.Viking), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_960GB, DriveRaidLevel.R614, DAE.Viking), 1)
			];
			
			bdg[DriveRaidLevel.R53.name] = [
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_15360GB, DriveRaidLevel.R53, DAE.Tabasco), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_7680GB, DriveRaidLevel.R53, DAE.Tabasco), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_3840GB, DriveRaidLevel.R53, DAE.Tabasco), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_1920GB, DriveRaidLevel.R53, DAE.Tabasco), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_960GB, DriveRaidLevel.R53, DAE.Tabasco), 1)
			];
			
			bdg[DriveRaidLevel.R57_forTabasco.name] = [
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_15360GB, DriveRaidLevel.R57_forTabasco, DAE.Tabasco), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_7680GB, DriveRaidLevel.R57_forTabasco, DAE.Tabasco), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_3840GB, DriveRaidLevel.R57_forTabasco, DAE.Tabasco), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_1920GB, DriveRaidLevel.R57_forTabasco, DAE.Tabasco), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_960GB, DriveRaidLevel.R57_forTabasco, DAE.Tabasco), 1)
			];
			
			bdg[DriveRaidLevel.R66.name] = [
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_15360GB, DriveRaidLevel.R66, DAE.Tabasco), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_7680GB, DriveRaidLevel.R66, DAE.Tabasco), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_3840GB, DriveRaidLevel.R66, DAE.Tabasco), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_1920GB, DriveRaidLevel.R66, DAE.Tabasco), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_SAS_960GB, DriveRaidLevel.R66, DAE.Tabasco), 1)
			];
			
			bdg[DriveRaidLevel.R53_Nebula.name] = [
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_NVM_7680GB, DriveRaidLevel.R53_Nebula, DAE.Nebula), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_NVM_3840GB, DriveRaidLevel.R53_Nebula, DAE.Nebula), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_NVM_1920GB, DriveRaidLevel.R53_Nebula, DAE.Nebula), 1),
			];
			
			bdg[DriveRaidLevel.R57_Nebula.name] = [
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_NVM_7680GB, DriveRaidLevel.R57_Nebula, DAE.Nebula), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_NVM_3840GB, DriveRaidLevel.R57_Nebula, DAE.Nebula), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_NVM_1920GB, DriveRaidLevel.R57_Nebula, DAE.Nebula), 1),
			];
			
			bdg[DriveRaidLevel.R66_Nebula.name] = [
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_NVM_7680GB, DriveRaidLevel.R66_Nebula, DAE.Nebula), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_NVM_3840GB, DriveRaidLevel.R66_Nebula, DAE.Nebula), 1),
				DriveGroup.create(DriveRegister.register(DriveType.FLASH_NVM_1920GB, DriveRaidLevel.R66_Nebula, DAE.Nebula), 1),
			];
			
			return bdg;
		}
		
		/**
		 * Generates supported capacity packs for 250f AFA
		 * based on selected RAID and specific drive type 
		 * @return 
		 * 
		 */		
		private static function generateSupported250fPacks():Object
		{
			var packs:Object = new Object();
			
			packs[DriveRaidLevel.R53.name] = {
				960: FLASH_CAPACITY_PACK_2TB,
				1920: FLASH_CAPACITY_PACK_5TB,
				3840: FLASH_CAPACITY_PACK_11TB,
				7680: FLASH_CAPACITY_PACK_22TB,
				15360: FLASH_CAPACITY_PACK_45TB
			};
			packs[DriveRaidLevel.R57_forTabasco.name] = {
				960: FLASH_CAPACITY_PACK_6TB,
				1920: FLASH_CAPACITY_PACK_13TB,
				3840: FLASH_CAPACITY_PACK_26TB,
				7680: FLASH_CAPACITY_PACK_52TB,
				15360: FLASH_CAPACITY_PACK_105TB
			};
			packs[DriveRaidLevel.R66.name] = {
				960: FLASH_CAPACITY_PACK_5TB,
				1920: FLASH_CAPACITY_PACK_11TB,
				3840: FLASH_CAPACITY_PACK_22TB,
				7680: FLASH_CAPACITY_PACK_45TB,
				15360: FLASH_CAPACITY_PACK_90TB
			};
			
			return packs;	
		}
		
		public static function generateSupported950fPacks():Object
		{
			var packs:Object = new Object();
			
			packs[DriveRaidLevel.R57.name] = {
				960: FLASH_CAPACITY_PACK_6TB,
				1920: FLASH_CAPACITY_PACK_13TB,
				3840: FLASH_CAPACITY_PACK_26TB,
				7680: FLASH_CAPACITY_PACK_52TB,
				15360: FLASH_CAPACITY_PACK_105TB
			};
			packs[DriveRaidLevel.R614.name] = {
				960: FLASH_CAPACITY_PACK_13TB,
				1920: FLASH_CAPACITY_PACK_26TB,
				3840: FLASH_CAPACITY_PACK_52TB,
				7680: FLASH_CAPACITY_PACK_105TB,
				15360: FLASH_CAPACITY_PACK_210TB
			}
			
			return packs;
		}
		
		
		private static function generateSupportedPM2000Packs():Object
		{
			var packs:Object = new Object();
			
			packs[DriveRaidLevel.R53_Nebula.name] = {
				1920: FLASH_CAPACITY_PACK_5TB,
				3840: FLASH_CAPACITY_PACK_11TB,
				7680: FLASH_CAPACITY_PACK_22TB
			};
			packs[DriveRaidLevel.R57_Nebula.name] = {
				1920: FLASH_CAPACITY_PACK_13TB,
				3840: FLASH_CAPACITY_PACK_26TB,
				7680: FLASH_CAPACITY_PACK_52TB
			};
			packs[DriveRaidLevel.R66_Nebula.name] = {
				1920: FLASH_CAPACITY_PACK_11TB,
				3840: FLASH_CAPACITY_PACK_22TB,
				7680: FLASH_CAPACITY_PACK_45TB
			};
			
			return packs;	
		}
		
		private static function generateSupportedPM8000Packs():Object
		{
			var packs:Object = new Object();
			
			packs[DriveRaidLevel.R57_Nebula.name] = {
				1920: FLASH_CAPACITY_PACK_13TB,
				3840: FLASH_CAPACITY_PACK_26TB,
				7680: FLASH_CAPACITY_PACK_52TB
			};
			packs[DriveRaidLevel.R53_Nebula.name] = {
				1920: FLASH_CAPACITY_PACK_5TB,
				3840: FLASH_CAPACITY_PACK_11TB,
				7680: FLASH_CAPACITY_PACK_22TB
			};
			packs[DriveRaidLevel.R66_Nebula.name] = {
				1920: FLASH_CAPACITY_PACK_11TB,
				3840: FLASH_CAPACITY_PACK_22TB,
				7680: FLASH_CAPACITY_PACK_45TB
			};
			
			return packs;
		}
		
		
		/**
		 * Initializes supported Flash drive types for 450/850F AFA.
		 * <p>Supported EFD for R57 are: 3.84TB, 1.92TB </p>
		 * <p>Supported EFD for R614 are: 1.92TB, 0.96TB </p>
		 * 
		 * @return array of allowed Flash drives
		 * 
		 */		
		private static function initDriveTypes():Object{
			var efd:Object = new Object();
			
			efd[DriveRaidLevel.R57.name] = [DriveType.FLASH_SAS_15360GB, DriveType.FLASH_SAS_7680GB, DriveType.FLASH_SAS_3840GB, DriveType.FLASH_SAS_1920GB, DriveType.FLASH_SAS_960GB];
			
			efd[DriveRaidLevel.R614.name] = [DriveType.FLASH_SAS_15360GB, DriveType.FLASH_SAS_7680GB, DriveType.FLASH_SAS_3840GB, DriveType.FLASH_SAS_1920GB, DriveType.FLASH_SAS_960GB];
			
			return efd;
		}
		
		/**
		 * Gets drive RAIDs for AFA model. </br>
		 * RAID 5(7+1), RAID 6(14+1) are allowed raid values.
		 * @return raid array
		 * 
		 */		
		public static function get supportedRAIDs():Array
		{
			return [DriveRaidLevel.R57, DriveRaidLevel.R614];
		}
		/**
		 * Gets drive RAIDs for AFA model 250F. </br>
		 * RAID 5(3+1), RAID 6(6+2) are allowed raid values.
		 * @return raid array
		 * 
		 */	
		public static function get supportedRAIDs_250F():Array
		{
			return [DriveRaidLevel.R57_forTabasco, DriveRaidLevel.R53, DriveRaidLevel.R66];
		}
		
		/**
		 * Gets drive RAIDs for PM 2000 model. </br>
		 * RAID 5(3+1), RAID 5(7+1), RAID 6(6+2) are allowed raid values.
		 * @return raid array
		 * 
		 */	
		public static function get supportedRAIDs_PM():Array
		{
			return [DriveRaidLevel.R57_Nebula, DriveRaidLevel.R53_Nebula, DriveRaidLevel.R66_Nebula];
		}
		
		/**
		 * Gets supported host types for AFA
		 * @return 
		 * 
		 */		
		public static function getHostTypes(is250f:Boolean):Array
			
		{
			// for 250f only OpenSystems is currently supported
			return is250f ? [HostType.OPEN_SYSTEMS] : [HostType.OPEN_SYSTEMS, HostType.MAINFRAME_HOST, HostType.MIXED];
		}
		
		/**
		 * Gets appropriate drive group based on selected drive type and RAID protection
		 * @param drive indicates selected drive type
		 * @return DriveGroup instance
		 * 
		 */		
		public static function getAppropriateDriveGroup(drive:DriveType, drRaidLevel:DriveRaidLevel):DriveGroup
		{
			var driveGroup:DriveGroup;
			
			for each (var dg:DriveGroup in BASE_DRIVE_GROUPS[drRaidLevel.name])
			{
				if (dg.driveDef.type.name == drive.name)
				{
					driveGroup = dg;
					break;
				}
			}
			
			return driveGroup;
		}
		
		/**
		 * Calculates Flash drives based on selected capacity, # of V-Bricks (Engines).<br/>
		 * Add EFD drives to the DriveGroup collection 
		 * @param capacity indicates selected usable capacity - MF or OS capacity
		 * @param bricks indicates selected # of V-Bricks (Engines)
		 * @param cfgFactory indicates configuration factory for AFA - 250/450/850F
		 * @param driveType indicates selected EFD type for the 250F
		 * 
		 */		
		public static function calculateEFDcount(capacity:Number, bricks:int, cfgFactory:Object, model:Number, drRaidLevel:DriveRaidLevel, hostType:String, driveType:DriveType = null):Number
		{
			var driveGroup:DriveGroup;
			var numberOfDrives:Number;
			
			if (model == 250)
			{
				// 250F calculation
				capacityBlock = supportedCapacityPacks250f[drRaidLevel.name][driveType.capacity];
				var minimumCapacityPack:Number;
				
				if(drRaidLevel.name == DriveRaidLevel.R57_forTabasco.name)
					minimumCapacityPack = 13.2;
				else
					minimumCapacityPack = 11.3;
				
				
				if (!capacityBlock)
				{
					throw new ArgumentError("Drive type" + driveType.name + " is not suppported for 250F AFA");
				}
				
				
				// set supported capacity
				capacity = cfgFactory.getSupportedCapacity(capacity, minimumCapacityPack);
				
				noCapacityChunks = Math.round(capacity / capacityBlock);
				
				// set drive group
				driveGroup = getAppropriateDriveGroup(driveType, drRaidLevel);
				
				numberOfDrives = driveGroup.activeCount = noCapacityChunks * driveGroup.driveDef.raid.raidGroupSize;
				
				return numberOfDrives;
			}
				
			else if(model == 950)
			{
				capacityBlock = supportedCapacityPacks950f[drRaidLevel.name][driveType.capacity];
				var minimumCapacityPack:Number = 13.2;
				
				if (!capacityBlock)
				{
					throw new ArgumentError("Drive type" + driveType.name + " is not suppported for 250F AFA");
				}
				
				// set supported capacity
				capacity = cfgFactory.getSupportedCapacity(capacity, minimumCapacityPack);
				
				noCapacityChunks = Math.round(capacity / capacityBlock);
				
				// set drive group
				driveGroup = getAppropriateDriveGroup(driveType, drRaidLevel);
				
				numberOfDrives = driveGroup.activeCount = noCapacityChunks * driveGroup.driveDef.raid.raidGroupSize;
				
				return numberOfDrives;
				
			}
				
			else if (model == 2000)
			{
				// PM2000 calculation
				capacityBlock = supportedCapacityPacksPM2000[drRaidLevel.name][driveType.capacity];
				var minCapacity:Number;
				
				if (!capacityBlock)
				{
					throw new ArgumentError("Drive type" + driveType.name + " is not suppported for PM-2000 AFA");
				}
				
				if(drRaidLevel.name == DriveRaidLevel.R53_Nebula.name)
					minCapacity = 5.6;
				else if(drRaidLevel.name == DriveRaidLevel.R57_Nebula.name)
					minCapacity = 13.2;
				else
					minCapacity = 11.3;
				// set supported capacity
				capacity = cfgFactory.getSupportedCapacity(capacity, minCapacity);
				
				if(capacityBlock == capacity)
				{
					noCapacityChunks = 1; //for minimum capacity selected is only one chunk
				}else
					noCapacityChunks = Math.round(capacity / capacityBlock);
				
				// set drive group
				driveGroup = getAppropriateDriveGroup(driveType, drRaidLevel);
				
				numberOfDrives = driveGroup.activeCount = noCapacityChunks * driveGroup.driveDef.raid.raidGroupSize;
				
				return numberOfDrives;
			}
				
			else if (model == 8000)
			{
				// PM8000 calculation
				capacityBlock = supportedCapacityPacksPM8000[drRaidLevel.name][driveType.capacity];
				var minCapacity:Number;
				
				if (!capacityBlock)
				{
					throw new ArgumentError("Drive type" + driveType.name + " is not suppported for PM-8000");
				}
				
				
				if(drRaidLevel.name == DriveRaidLevel.R53_Nebula.name)
					minCapacity = 5.6;
				else if(drRaidLevel.name == DriveRaidLevel.R57_Nebula.name)
					minCapacity = 13.2;
				else
					minCapacity = 11.3;
				// set supported capacity
				capacity = cfgFactory.getSupportedCapacity(capacity, minCapacity);
				
				if(capacityBlock == capacity)
				{
					noCapacityChunks = 1; //for minimum capacity selected is only one chunk
				}else
					noCapacityChunks = Math.round(capacity / capacityBlock);
				
				// set drive group
				driveGroup = getAppropriateDriveGroup(driveType, drRaidLevel);
				
				numberOfDrives = driveGroup.activeCount = noCapacityChunks * driveGroup.driveDef.raid.raidGroupSize;
				
				return numberOfDrives;
			}
			
			return numberOfDrives;
		}
		
	}
}

