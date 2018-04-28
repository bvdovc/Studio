package sym.objectmodel.driveUtils
{
	import sym.objectmodel.common.DAE;
	import sym.objectmodel.driveUtils.enum.DriveRaidLevel;
	import sym.objectmodel.driveUtils.enum.DriveType;

	/**
	 * Contains Drive information(technology, capacity, speed, raid)
	 */	
	[Bindable]
	public class DriveDef
	{
		public var id:int;
		public var type:DriveType;
		public var raid:DriveRaidLevel;
		public var size:int;
		
		/**
		 * Gets supported Drive Types for specific Size 
		 * @param filterBy indicates input drive size parameter to filter by
		 * @return supported drive types
		 * 
		 */		
		public static function getSupportedDrives(filterBy:Object):Array
		{
			var types:Array = [];
			
			if(filterBy == null) return types;
			
			for each (var type:DriveType in DriveType.values_family)
			{
				if (filterBy == DAE.Viking && (type == DriveType.SATA_SAS_7K_2TB || type == DriveType.SATA_SAS_7K_4TB))
				{
					continue;
				}
				
				types.push(type);
			}
			
			return types;
		}
		
		/**
		 * Gets supported Drive Size for specific drive type
		 * @param driveType indicates drive type
		 * @param customTier indicates if custom tier solution is selected
		 * @return supported DAE types
		 * 
		 */		
		public static function getSupportedSize(driveType:DriveType, customTier:Boolean = false):Object
		{
			if (driveType == DriveType.SATA_SAS_7K_2TB || driveType == DriveType.SATA_SAS_7K_4TB)
			{
				return customTier ? [DAE.Voyager] : DAE.Voyager;
			}
			
			return customTier ? [DAE.Viking, DAE.Voyager] : DAE.Viking;
		}
		
		/**
		 * Gets all drive size values
		 * @return 
		 * 
		 */		
		public static function getSizeValues():Array
		{
			return [DAE.Viking, DAE.Voyager];
		}
		
		/**
		 * Gets appropriate Drive Type by drive capacity and speed parameters exported from XML
		 * @param cap indicates drive capacity
		 * @param speed indicates drive speed
		 * @return drive type
		 * 
		 */		
		public static function getDriveType(cap:int, speed:Number):DriveType
		{
			var driveType:DriveType;
			
			for each (var type:DriveType in DriveType.values)
			{
				if (type.capacity == cap && type.speed == speed)
				{
					driveType = type;
					break;
				}
			}
			
			return driveType;
		}
	}
}