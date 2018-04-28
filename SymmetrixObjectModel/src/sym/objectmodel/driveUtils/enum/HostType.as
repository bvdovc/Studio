package sym.objectmodel.driveUtils.enum
{
	/**
	 * Contains information regarding Host connectivity types (Open Systems or Mainframe) 
	 */	
	public class HostType extends Enum
	{
		public static const OPEN_SYSTEMS:String = "OS";
		public static const MAINFRAME_HOST:String = "MF";
		public static const MIXED:String = "Mixed"; // MF + OS
		
		private static const _OS:HostType = new HostType(OPEN_SYSTEMS);
		private static const _MF:HostType = new HostType(MAINFRAME_HOST);
		private static const _MIXED:HostType = new HostType(MIXED);
		
		public static const XML_TAG_NAME:String = "host_type";
		
		public function HostType(name:String)
		{
			super();
			_name = name;
		}
		
		public static function get OpenSystems():HostType
		{
			return _OS;
		}

		public static function get Mainframe():HostType
		{
			return _MF;
		}

		public static function get Mixed():HostType
		{
			return _MIXED;
		}

		/**
		 * Gets all host connectivity types 
		 * @return 
		 * 
		 */		
		public static function get values():Array
		{
			return [OpenSystems, Mainframe, Mixed];
		}
	}
}