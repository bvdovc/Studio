package sym.configurationmodel.utils
{
	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;
	
	import sym.configurationmodel.common.ConfigurationFactoryBase_VG3R;
	import sym.configurationmodel.common.ConfigurationFilter;
	import sym.configurationmodel.pm2000.ConfigurationFactory;
	import sym.configurationmodel.pm8000.ConfigurationFactory;
	import sym.configurationmodel.v250f.ConfigurationFactory;
	import sym.configurationmodel.v450f.ConfigurationFactory;
	import sym.configurationmodel.v950f.ConfigurationFactory;
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
	 * @author nmilic
	 * 
	 */	
	public class AllFlashArrayUtility
	{
		public static const BASE_CONFIG_V_BRICK_CAPACITY:Number = 53; // 52.67 TB
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
		public static const BASE_250F_CONFIG_MAXIMUM_CAPACITY:Number = sym.configurationmodel.v250f.ConfigurationFactory.TOTAL_USABLE_CAPACITY; // 1083
		
		public static const BASE_PM2000_CONFIG_MINIMUM_CAPACITY:Number = FLASH_CAPACITY_PACK_5TB; //5.6TB
		public static const BASE_PM2000_CONFIG_MINIMUM_CAPACITY_FOR_RAID57:Number = FLASH_CAPACITY_PACK_13TB; //13.2TB
		public static const BASE_PM2000_CONFIG_MAXIMUM_CAPACITY:Number = sym.configurationmodel.pm2000.ConfigurationFactory.TOTAL_USABLE_CAPACITY; //526 TB if RAID5(7+1) is chosen
		public static const BASE_PM2000_CONFIG_MAXIMUM_CAPACITY_FOR_RAID53:Number = 492.7; //when RAID5(3+1) is chosen
		public static const BASE_PM2000_CONFIG_MAXIMUM_CAPACITY_FOR_RAID66:Number = 451; //when RAID6(6+2) is chosen
		
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
		
		public static const MAXIMUM_USABLE_CAPACITY:Object = generateMaxCapacities();
		
		public static var systemDriveRAID:DriveRaidLevel;
		public static var driveGroups:ArrayCollection = new ArrayCollection();
		
		// 13/26TB capacity block for 450/850F
		// 2.8/5.6/11.3/22.6/45.1 TB for 250F
		public static var capacityBlock:Number;
		
		// # of capacity chunks/blocks
		public static var noCapacityChunks:Number;
		
		public function AllFlashArrayUtility()
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
		 * Generates maximal usable capacities for AFA 450/850f (4/8 engines) based on selected RAID - R5/R6
		 * @return 
		 * 
		 */        
		private static function generateMaxCapacities():Object
		{
			var res:Array = new Array();

			res[DriveRaidLevel.R57.name] = {
				4: sym.configurationmodel.v450f.ConfigurationFactory.TOTAL_USABLE_CAPACITY, // 2000 TB
				8: sym.configurationmodel.v950f.ConfigurationFactory.TOTAL_USABLE_CAPACITY // 4300 TB
			};
			
			res[DriveRaidLevel.R614.name] = {
				4: 1488, // 1475 TB
				8: 2962  // 2950 TB
			};
			
			return res;
		}
		
		/**
		 * Calculates active drives for specified capacity 
		 * @param capacityOS capacity indicates OpenSystems capacity input from the user.<br/>
		 * For the 450/850F specific Flash Pack capacity 13/26TB or vBrick capacity 53TB.<br/>
		 * For the 250F, specific Flash Pack capacity 2.8/5.6/11.3/22.6/45.1/90.2 TB
		 * @param capacityMF indicates Mainframe capacity input from the user.
		 * Default value is NaN indicating that OS is default host connectivity
		 * 
		 */		
		public static function calculateActiveDrives(capacity:Number, hostType:String):DriveGroup
		{
			var driveGroup:DriveGroup;
			var activeDrives:int = 0;
			
			// set driveGroup
			switch(capacity)
			{
				case FLASH_BLOCK_CAPACITY_13TB:
				{
					// 13TB capacity block drives
					if (systemDriveRAID == DriveRaidLevel.R57)
					{
						// 1.92TB drives
						driveGroup = BASE_DRIVE_GROUPS[DriveRaidLevel.R57.name][1];
					}			
					if (systemDriveRAID == DriveRaidLevel.R614)
					{
						// 0.96TB drives
						driveGroup = BASE_DRIVE_GROUPS[DriveRaidLevel.R614.name][1];
					}
					
					break;
				}
				case FLASH_BLOCK_CAPACITY_26TB:
				{
					// 26TB capacity block drives
					if (systemDriveRAID == DriveRaidLevel.R57)
					{
						// 3.84TB drives
						// clone since we already have this group as base drive group
						driveGroup = BASE_DRIVE_GROUPS[DriveRaidLevel.R57.name][0].cloneDG();
					}
					
					if (systemDriveRAID == DriveRaidLevel.R614)
					{
						// 1.92TB drives
						// clone since we already have this group as base drive group
						driveGroup = BASE_DRIVE_GROUPS[DriveRaidLevel.R614.name][0].cloneDG();
					}
					
					break;
				}

				case BASE_CONFIG_V_BRICK_CAPACITY:
				{
					
					if(systemDriveRAID == DriveRaidLevel.R53)
					{
						driveGroup = BASE_DRIVE_GROUPS[DriveRaidLevel.R53][0];
					}
					// 53TB vBrick capacity drives
					if (systemDriveRAID == DriveRaidLevel.R57)
					{
						// 3.84TB drives
						driveGroup = BASE_DRIVE_GROUPS[DriveRaidLevel.R57.name][0];
					}
					
					if (systemDriveRAID == DriveRaidLevel.R614)
					{
						// 1.92TB drives
						driveGroup = BASE_DRIVE_GROUPS[DriveRaidLevel.R614.name][0];
					}
					
					break;
				}
					
					case BASE_250F_CONFIG_MINIMUM_CAPACITY:
					{
						if (systemDriveRAID == DriveRaidLevel.R53)
						{
							// 3.84TB drives
							driveGroup = BASE_DRIVE_GROUPS[DriveRaidLevel.R53.name][0];
						}
						
						if (systemDriveRAID == DriveRaidLevel.R57_forTabasco)
						{
							// 3.84TB drives
							driveGroup = BASE_DRIVE_GROUPS[DriveRaidLevel.R57_forTabasco.name][0];
						}
						
						if (systemDriveRAID == DriveRaidLevel.R66)
						{
							// 1.92TB drives
							driveGroup = BASE_DRIVE_GROUPS[DriveRaidLevel.R66.name][0];
						}
						break;
					}
					
				default:
				{
					// base config for specified input Capacity
					// we use larger drives 3.84/1.92 TB to calculate
					// clone to keep original base DriveGroup
					driveGroup = BASE_DRIVE_GROUPS[systemDriveRAID.name][0].cloneDG();
					break;
				}
			}
			
			if (hostType == HostType.OPEN_SYSTEMS)
			{
				// 100% OS
				activeDrives = TieringUtility_VG3R.calculateNoActives(ConfigurationFilter.TIER_SOLUTION_DEFAULT, driveGroup, capacity);
			}
			else if (hostType == HostType.MAINFRAME_HOST)
			{
				// 100% MF
				activeDrives = TieringUtility_VG3R.calculateNoActives(ConfigurationFilter.TIER_SOLUTION_DEFAULT, driveGroup, capacity, hostType);
			}
			driveGroup.activeCount = activeDrives;
			
			return driveGroup;
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
		public static function getAppropriateDriveGroup(drive:DriveType):DriveGroup
		{
			var driveGroup:DriveGroup;
			
			for each (var dg:DriveGroup in BASE_DRIVE_GROUPS[systemDriveRAID.name])
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
		public static function calculateEFDcount(capacity:Number, bricks:int, cfgFactory:ConfigurationFactoryBase_VG3R, hostType:String, driveType:DriveType = null):ArrayCollection
		{
			var driveGroup:DriveGroup;
			
			if (driveGroups.length > 0)
			{
				// remove all if collection is not empty
				driveGroups.removeAll();
			}
			

			if (cfgFactory is sym.configurationmodel.v250f.ConfigurationFactory)//we need to determinate minimum capacity pack depending on RAID level WORK IN PROGRESS !!!!
			{
				// 250F calculation
				capacityBlock = supportedCapacityPacks250f[systemDriveRAID.name][driveType.capacity];
				var minimumCapacityPack:Number;
				
				if(systemDriveRAID.name == DriveRaidLevel.R57_forTabasco.name)
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
				driveGroup = getAppropriateDriveGroup(driveType);
				
				driveGroup.activeCount = noCapacityChunks * driveGroup.driveDef.raid.raidGroupSize;
				
				driveGroups.addItem(driveGroup);
				
				return driveGroups;
			}
						
			else if(cfgFactory is sym.configurationmodel.v950f.ConfigurationFactory) //we need to determinate minimum capacity pack depending on RAID level WORK IN PROGRESS !!!!
			{
				capacityBlock = supportedCapacityPacks950f[systemDriveRAID.name][driveType.capacity];
				var minimumCapacityPack:Number = 53;
				
				if (!capacityBlock)
				{
					throw new ArgumentError("Drive type" + driveType.name + " is not suppported for 250F AFA");
				}
				
				// set supported capacity
				capacity = cfgFactory.getSupportedCapacity(capacity, minimumCapacityPack);
				
				noCapacityChunks = Math.round(capacity / capacityBlock);
				
				// set drive group
				driveGroup = getAppropriateDriveGroup(driveType);
				
				driveGroup.activeCount = noCapacityChunks * driveGroup.driveDef.raid.raidGroupSize;
				
				driveGroups.addItem(driveGroup);
				
				return driveGroups;
				
			}
			
			else if (cfgFactory is sym.configurationmodel.pm2000.ConfigurationFactory)//we need to determinate minimum capacity pack depending on RAID level WORK IN PROGRESS !!!!
			{
				// PM2000 calculation
				capacityBlock = supportedCapacityPacksPM2000[systemDriveRAID.name][driveType.capacity];
				var minCapacity:Number;
				
				if (!capacityBlock)
				{
					throw new ArgumentError("Drive type" + driveType.name + " is not suppported for PM-2000 AFA");
				}
				
				if(systemDriveRAID.name == DriveRaidLevel.R53_Nebula.name)
					minCapacity = 5.6;
				else if(systemDriveRAID.name == DriveRaidLevel.R57_Nebula.name)
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
				driveGroup = getAppropriateDriveGroup(driveType);
				
				driveGroup.activeCount = noCapacityChunks * driveGroup.driveDef.raid.raidGroupSize;
				
				driveGroups.addItem(driveGroup);
				
				return driveGroups;
			}
			
			else if (cfgFactory is sym.configurationmodel.pm8000.ConfigurationFactory)
			{
				// PM8000 calculation
				capacityBlock = supportedCapacityPacksPM8000[systemDriveRAID.name][driveType.capacity];
				var minCapacity:Number;
				
				if (!capacityBlock)
				{
					throw new ArgumentError("Drive type" + driveType.name + " is not suppported for PM-8000");
				}
				
				
				if(systemDriveRAID.name == DriveRaidLevel.R53_Nebula.name)
					minCapacity = 5.6;
				else if(systemDriveRAID.name == DriveRaidLevel.R57_Nebula.name)
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
				driveGroup = getAppropriateDriveGroup(driveType);
				
				driveGroup.activeCount = noCapacityChunks * driveGroup.driveDef.raid.raidGroupSize;
				
				driveGroups.addItem(driveGroup);
				
				return driveGroups;
			}

			var baseDG:DriveGroup;
			// total capacity for chunks
			var capacityChunks:Number;
			
			// set base vBrick config DriveGroup
			baseDG = calculateActiveDrives(BASE_CONFIG_V_BRICK_CAPACITY, hostType);
			baseDG.activeCount *= bricks;
				
			driveGroups.addItem(baseDG);
			
			/*detemrnines which capacity block 13/26 TB should be used for drive calculation
			  and capacity chunks spreading through vBricks/Engines */
			
			capacityChunks = capacity - bricks * BASE_CONFIG_V_BRICK_CAPACITY;
			
			if (capacityChunks == 0)
				// no remaining capacity
				// meaining only base 53TB v-Brick pack is allowed
				return driveGroups;
			
			if (hostType == HostType.MAINFRAME_HOST &&
				!(cfgFactory is sym.configurationmodel.v250f.ConfigurationFactory))
			{
				// 450/850F 100% Mainframe host
				// 26TB packs are only allowed - 3.84/1.92 TB drives are only supported
				noCapacityChunks = Math.ceil(capacityChunks / FLASH_BLOCK_CAPACITY_26TB);
				capacityBlock = FLASH_BLOCK_CAPACITY_26TB;
			}
			else 
			{
				// round to the nearest/greater integer
				noCapacityChunks = Math.ceil(capacityChunks / FLASH_BLOCK_CAPACITY_13TB);
				
				if (noCapacityChunks % 2 == 0)
				{
					// use 26TB block, 3.84/1.92TB drives
					noCapacityChunks /= 2;
					capacityBlock = FLASH_BLOCK_CAPACITY_26TB;
				}
				else
				{
					// use 13TB block, 1.92/0.96TB drives
					capacityBlock = FLASH_BLOCK_CAPACITY_13TB;
				}
			}
			
			driveGroup = calculateActiveDrives(capacityBlock, hostType);
			driveGroup.activeCount *= noCapacityChunks;
			
			driveGroups.addItem(driveGroup);
			
			/*it is possible if 13TB block are used, that
			  all those drives can not fit within selected number of engines.
			  So, validate if config can be generated with selected drive groups
			  if not, try only with larger drives 26TB 3.84/1.92TB drives
			*/
			noCapacityChunks = capacityBlock == FLASH_BLOCK_CAPACITY_13TB ? (noCapacityChunks + 1) / 2 : noCapacityChunks + 1;
			
			while (!cfgFactory.createConfiguration(bricks, Configuration_VG3R.DUAL_ENGINE_BAY,"",0, [-1], driveGroups.toArray(), -1))
			{
				driveGroups.removeItemAt(driveGroups.getItemIndex(driveGroup));	
				// use then 26 TB block, so that we have only one larger drive type 3.84/1.92 TB
				capacityBlock = FLASH_BLOCK_CAPACITY_26TB;
				
				driveGroup = calculateActiveDrives(capacityBlock, hostType);
				driveGroup.activeCount *= noCapacityChunks;
				
				noCapacityChunks -= 1;
				
				driveGroups.addItem(driveGroup);
			}
			
			return driveGroups;
		}

	}
}