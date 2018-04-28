package sym.objectmodel.common
{
	import sym.objectmodel.driveUtils.DriveDef;

	/**
	 * class representing Drive types
	 */
	public class Drive extends ComponentBase
	{
		// number of drives per Disk Array Enclosure(DAE)
		public static const D15_DRIVES_NUMBER:int = 15;
		public static const VANGURAD_DRIVES_NUMBER:int = 25;
		public static const VIKING_DRIVES_NUMBER:int = 120;
		public static const VOYAGER_DRIVES_NUMBER:int = 60;
		public static const TABASCO_DRIVES_NUMBER:int = 25;
		public static const NEBULA_DRIVES_NUMBER:int = 24;
		
		private var _spare:Boolean;
		
		public function Drive(position:Position, drive:DriveDef, spare:Boolean = false)	
		{
			super(spare ? drive.type.spareName : drive.type.name, position, null);
			
			if (!drive.type.isEFD && !drive.type.isFC_SAS && !drive.type.isSATA_SAS)
			{
				throw new ArgumentError("unknown Drive type");
			}
			
			_spare = spare;
			_type = drive.id + 1;
		}
		
		public function get isSpare():Boolean
		{
			return _spare;
		}
	}
}