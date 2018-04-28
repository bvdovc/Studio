package sym.objectmodel.common
{

	public class UPS extends ComponentBase
	{
        private static const _upsSize:Size = new Size(Size.USIZE, 1);
        private static const CACHE_PREFIX:String = "cache_ups_";
        
        
		public function UPS(position:Position)
		{
			super("ups", position, _upsSize);
		}

		public static function createFromXml(xml:XML):ComponentBase
		{
			var ups:UPS=new UPS(new Position(xml.@positionType, xml.@positionIndex));
			return ups;
		}
		
		public static function validateXml(xml:XML, seria:String):Boolean
		{
			if(parseInt(xml.@positionType.toString()) != Position.BAY_ENCLOSURE){
				return false;
			}
			
			return true;
		}
        
        /**
         * generates cache key for const static UPS objects with given position type and index
         */
        public static function generateCacheKey(positionType:int, index:Number):String{
            return CACHE_PREFIX + positionType + "_" + index;
        }
        
        /**
         * creates UPS with given position data. Puts the instance into cache if not cached previously and return cached instance
         */
        public static function createIfNotCached(positionType:int, index:Number):UPS{
            var key:String = generateCacheKey(positionType, index);
            if(!ObjectCache.instance.hasKey(key)){
                ObjectCache.instance.put(key, new UPS(new Position(positionType, index))); 
            }
            return ObjectCache.instance.get(key) as UPS;
        }
        
        /**
         *  creates clone for given parent
         * @param parent reference of parent component
         * @return 
         * 
         */        
        public override function clone(parent:ComponentBase = null):ComponentBase{
            var clone:UPS = new UPS(position);
            clone.cloneBasicData(this);
            
            clone.parent = parent;
            
            return clone;
        }
        
        public override function get propertiesEnabled():Boolean{
            return false;
        }
	}
}
