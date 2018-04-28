package sym.objectmodel.common
{
	public class EthernetSwitch extends ComponentBase
	{
		private static const _mySize:Size = new Size(Size.USIZE, 1);
		private static const CACHE_PREFIX:String = "cache_ethernetSwitch_";
		
		public function EthernetSwitch(position:Position)
		{
			super("ethernet switch", position, _mySize);
		}
		
		/**
		 * creates EthernetSwitch with given position data. Puts the instance into cache if not cached previously and return cached instance
		 */
		public static function createIfNotCached(positionType:int, index:Number, factoryName:String):EthernetSwitch{
			var key:String = generateCacheKey(positionType, index, factoryName);
			if(!ObjectCache.instance.hasKey(key)){
				ObjectCache.instance.put(key, new EthernetSwitch(new Position(positionType, index))); 
			}
			return ObjectCache.instance.get(key) as EthernetSwitch;
		}
		
		/**
		 * generates cache key for const static EthernetSwitch objects with given position type and index
		 */
		public static function generateCacheKey(positionType:int, index:Number, factoryName:String):String{
			return CACHE_PREFIX + positionType + "_" + index + "_" + factoryName;
		}
        
	}
}