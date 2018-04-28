package sym.objectmodel.common
{
	public class ControlStation extends ComponentBase
	{
		private static const _controlStationSize:Size = new Size(Size.USIZE, 1);
		private static const CACHE_PREFIX:String = "cache_controlStation_";
		
		public static const NO_CONTROL_STATION:int = 2;
		
		public function ControlStation(position:Position)
		{
			super("control_station", position, _controlStationSize);
		}
		
		public static function createFromXml(xml:XML):ComponentBase
		{
			var controlStation:ControlStation = new ControlStation(new Position(xml.@positionType, xml.@positionIndex));
			return controlStation;
		}
		
		public static function validateXml(xml:XML, seria:String):Boolean
		{
			if(parseInt(xml.@positionType.toString()) != Position.BAY_ENCLOSURE){
				return false;
			}
			return true;
		}
		
		/**
		 * generates cache key for const static ControlStation objects with given position type and index
		 */
		public static function generateCacheKey(positionType:int, index:Number):String{
			return CACHE_PREFIX + positionType + "_" + index;
		}
		
		/**
		 * creates ControlStation with given position data. Puts the instance into cache if not cached previously and return cached instance
		 */
		public static function createIfNotCached(positionType:int, index:Number):ControlStation{
			var key:String = generateCacheKey(positionType, index);
			if(!ObjectCache.instance.hasKey(key)){
				ObjectCache.instance.put(key, new ControlStation(new Position(positionType, index))); 
			}
			return ObjectCache.instance.get(key) as ControlStation;
		}
		
		/**
		 *  creates clone for given parent
		 * @param parent reference of parent component
		 * @return 
		 * 
		 */        
		public override function clone(parent:ComponentBase = null):ComponentBase{
			var clone:ControlStation = new ControlStation(position);
			clone.cloneBasicData(this);
			
			clone.parent = parent;
			
			return clone;
		}
        
        public override function get propertiesEnabled():Boolean{
            return false;
        }
		
	}
}