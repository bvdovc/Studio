package sym.objectmodel.driveUtils
{
	import sym.objectmodel.driveUtils.enum.DriveRaidLevel;
	import sym.objectmodel.driveUtils.enum.DriveType;

	public class DriveRegister
	{
		private static var _register:DictionaryExt = new DictionaryExt();
		private static var _count:int = 0;
		
		public static function register(type:DriveType, raid:DriveRaidLevel, size:Object):DriveDef
		{
			var def:DriveDef = null;
			for (var key:Object in _register) 
			{
				def = _register[key] as DriveDef;
				if (def.raid == raid && def.type == type && def.size == size)	
				{
					return def;
				}
			}
			
			def = new DriveDef();
			def.id = _count++;
			def.type = type;
			def.raid = raid;
			def.size = int(size);
			
			_register[def.id] = def;
			return def;
		}
		
		public static function getById(id:int):DriveDef
		{
			return _register[id] as DriveDef;
		}
		
		public static function getDefs():Array
		{
			return _register.values;
		}
	}
}