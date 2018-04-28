package sym.objectmodel.common
{
	public class Worktray extends ComponentBase
	{
		private static const _mySize:Size = new Size(Size.USIZE, 2);
		private static const CACHE_PREFIX:String = "cache_worktray_";
		
		public function Worktray(position:Position)
		{
			super("worktray", position, _mySize);
		}
		
		/**
		 * generates cache key for const static Worktray objects with given position type and index
		 */
		public static function generateCacheKey(positionType:int, index:Number):String{
			return CACHE_PREFIX + positionType + "_" + index;
		}
		
		/**
		 * creates Worktray with given position data. Puts the instance into cache if not cached previously and return cached instance
		 */
		public static function createIfNotCached(positionType:int, index:Number):Worktray{
			var key:String = generateCacheKey(positionType, index);
			if(!ObjectCache.instance.hasKey(key)){
				ObjectCache.instance.put(key, new Worktray(new Position(positionType, index))); 
			}
			return ObjectCache.instance.get(key) as Worktray;
		}
		
		/**
		 * gets cached Worktray by position type and index
		 */
		public static function getFromCacheByPosition(positionType:int, index:Number):Worktray{
			return ObjectCache.instance.get(generateCacheKey(positionType, index)) as Worktray;
		}
	}
}