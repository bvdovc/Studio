package sym.objectmodel.driveUtils.enum
{
	/**
	 * Contains Drive RAID level protection information 
	 */	
	public class DriveRaidLevel extends Enum
	{
		private var _factor:Number;
		private var _mod:int;
		
		private static const _1:DriveRaidLevel = new DriveRaidLevel("Mirrored", 1 / 2, 2);
		private static const _53:DriveRaidLevel = new DriveRaidLevel("RAID 5(3+1) ", 3 / 4, 4);
		private static const _57:DriveRaidLevel = new DriveRaidLevel("RAID 5(7+1) ", 7 / 8, 4);
		private static const _57_forTabasco:DriveRaidLevel = new DriveRaidLevel("RAID 5(7+1)  ", 7 / 8, 8);
		private static const _66:DriveRaidLevel = new DriveRaidLevel("RAID 6(6+2) ", 3 / 4, 8);
		private static const _614:DriveRaidLevel = new DriveRaidLevel("RAID 6(14+2)", 7 / 8, 8);
		
		private static const _53_Nebula:DriveRaidLevel = new DriveRaidLevel("RAID 5(3+1)", 3 / 4, 4);
		private static const _57_Nebula:DriveRaidLevel = new DriveRaidLevel("RAID 5(7+1)", 7 / 8, 8);
		private static const _66_Nebula:DriveRaidLevel = new DriveRaidLevel("RAID 6(6+2)", 3 / 4, 8);
		
		public static const VMAX_XML_NAME:String = "protection";
		
		public function DriveRaidLevel(name:String, factor:Number, mod:int)
		{
			super();
			_name = name;
			_factor = factor;
			_mod = mod;
		} 
		
		/**
		 * Gets drive RAID factor number 
		 * @return raid factor
		 * 
		 */		
		public function get factor():Number
		{
			return _factor;
		}
		
		/**
		 * Gets drive RAID modulo population 
		 * @return modulo population number
		 * 
		 */		
		public function get mod():int
		{
			return _mod;
		}
		
		/**
		 * Gets drive RAID group size  
		 * @return RAID group size
		 * 
		 */		
		public function get raidGroupSize():int
		{
			return this.isMod8 ? 2 * mod : mod;
		}
		
		public function get isMod8():Boolean
		{
			return this == R614 || this == R57;
		}
		
		public static function get R1():DriveRaidLevel
		{
			return _1;
		}
		
		public static function get R53():DriveRaidLevel
		{
			return _53;
		}
		
		public static function get R57():DriveRaidLevel
		{
			return _57;
		}
		
		public static function get R57_forTabasco():DriveRaidLevel
		{
			return _57_forTabasco;
		}
		
		public static function get R66():DriveRaidLevel
		{
			return _66;
		}
		
		public static function get R614():DriveRaidLevel
		{
			return _614;
		}
		
		public static function get R53_Nebula():DriveRaidLevel
		{
			return _53_Nebula;
		}
		
		public static function get R57_Nebula():DriveRaidLevel
		{
			return _57_Nebula;
		}
		
		public static function get R66_Nebula():DriveRaidLevel
		{
			return _66_Nebula;
		}

		/**
		 * Gets all drive RAIDs
		 * @return 
		 * 
		 */		
		public static function get values():Array
		{
			return [R1, R53, R57, R66, R614, _57_forTabasco];
		}
		
		/**
		 * Gets all drive RAIDs
		 * @return 
		 * 
		 */	
		public static function get values_Nebula():Array
		{
			return [R53_Nebula, R57_Nebula, R66_Nebula];
		}
	}
}