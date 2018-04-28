package sym.objectmodel.common
{
	public class DataMover extends ComponentBase
	{
		private static const dm_size:Size = new Size(Size.USIZE, 2);
		private static const CACHE_PREFIX:String = "cache_data_mover_";
		
		public static const DM2:int = 2;
		public static const DM3:int = 3;
		public static const DM4:int = 4;
		
//		private var _parentBay:String;
		
		public function DataMover(position:Position)
		{
			super("data_mover", position, dm_size);
			
//			_parentBay = parentBay;
		}
		
		public static function createFromXml(xml:XML):ComponentBase
		{
			var dataMover:DataMover = new DataMover(new Position(xml.@positionType, xml.@positionIndex));
			return dataMover;
		}
		
		public static function validateXml(xml:XML, seria:String):Boolean
		{
			if(Constants.DATA_MOVER_POSITION.indexOf(parseInt(xml.@positionType.toString())) < 0){
				return false;
			}
			
			return true;
		} 
		
		/**
		 * generates cache key for const static data mover objects with given position type and index
		 */
		public static function generateCacheKey(positionType:int, index:Number):String {
			return CACHE_PREFIX + positionType + "_" + index;
		}
		
		/**
		 * creates data mover with given position data. Puts the instance into cache if not cached previously and return cached instance
		 */
		public static function createIfNotCached(positionType:int, index:Number):DataMover {
			var key:String = generateCacheKey(positionType, index);
			if(!ObjectCache.instance.hasKey(key)){
				ObjectCache.instance.put(key, new DataMover(new Position(positionType, index))); 
			}
			return ObjectCache.instance.get(key) as DataMover;
		}
		
		/**
		 *  creates clone for given parent
		 * @param parent reference of parent component
		 * @return 
		 * 
		 */        
		public override function clone(parent:ComponentBase = null):ComponentBase{
			var clone:DataMover = new DataMover(position);
			clone.cloneBasicData(this);
			
			clone.parent = parent;
			
			return clone;
		}
        
        public override function get propertiesEnabled():Boolean{
            return false;
        }
	}
}