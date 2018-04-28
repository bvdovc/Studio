package sym.objectmodel.common
{
	public class InfinibandSwitch extends ComponentBase
	{
		public static const TYPE_DINGO:int = 1; // 100/200K
		public static const TYPE_STINGRAY:int = 2; // 400K
		
		private static const CACHE_PREFIX:String = "cache_infinibandSwitch";
		private static const _mySize:Size = new Size(Size.USIZE, 1);
		
		public function InfinibandSwitch(position:Position, type:int)
		{
			super("infinibandSwitch", position, _mySize);
			_type = type;
		}
		
		/**
		 * creates InfinibandSwitch with given position data. Puts the instance into cache if not cached previously and return cached instance
		 */
		public static function createIfNotCached(positionType:int, index:Number, factoryName:String, type:int):InfinibandSwitch{
			var key:String = generateCacheKey(positionType, index, factoryName);
			if(!ObjectCache.instance.hasKey(key)){
				ObjectCache.instance.put(key, new InfinibandSwitch(new Position(positionType, index), type)); 
			}
			return ObjectCache.instance.get(key) as InfinibandSwitch;
		}
		
		
		/**
		 * generates cache key for const static InfinibandSwitch objects with given position type and index
		 */
		public static function generateCacheKey(positionType:int, index:Number, factoryName:String):String{
			return CACHE_PREFIX + positionType + "_" + index + "_" + factoryName;
		}
        
	}
}