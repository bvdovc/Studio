package sym.objectmodel.common
{
	public class PDU_VG3R extends ComponentBase
	{
		public static const TYPE1SINGLE_PHASE:int=1;
		public static const TYPE3WYE_PHASE:int=2;
		public static const TYPE3DELTA_PHASE:int=3;
		
		private static const CACHE_PREFIX:String = "cache_pdu_vg3r_";
		
		private static const _mySize:Size = new Size(Size.USIZE, 2);
		
		public function PDU_VG3R(position:Position, type:int = PDU_VG3R.TYPE1SINGLE_PHASE)
		{
			super("pdu", position, _mySize);
			_type = type;
		}
		
		/**
		 * creates PDU_VG3R with given position data. Puts the instance into cache if not cached previously and return cached instance
		 */
		public static function createIfNotCached(positionType:int, index:Number, factoryName:String):PDU_VG3R{
			var key:String = generateCacheKey(positionType, index, factoryName);
			if(!ObjectCache.instance.hasKey(key)){
				ObjectCache.instance.put(key, new PDU_VG3R(new Position(positionType, index))); 
			}
			return ObjectCache.instance.get(key) as PDU_VG3R;
		}
		
		
		/**
		 * generates cache key for const static PDU_VG3R objects with given position type and index
		 */
		public static function generateCacheKey(positionType:int, index:Number, factoryName:String):String{
			return CACHE_PREFIX + positionType + "_" + index + "_" + factoryName;
		}
		
	}
}