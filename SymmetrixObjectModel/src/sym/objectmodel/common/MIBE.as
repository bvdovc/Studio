package sym.objectmodel.common
{

	public class MIBE extends ComponentBase
	{
        private static const _mySize:Size = new Size(Size.USIZE, 1);
        private static const CACHE_PREFIX:String = "cache_mibe_";
        
		public function MIBE(position:Position)
		{
			super("mibe", position, _mySize);
		}

		public static function createFromXml(xml:XML):ComponentBase
		{
			var mibe:MIBE=new MIBE(new Position(xml.@positionType, xml.@positionIndex));
			return mibe;
		}
		
		public static function validateXml(xml:XML, seria:String):Boolean
		{
			if(parseInt(xml.@positionType.toString()) != Position.BAY_ENCLOSURE){
				return false;
			}
			
			return true;
		}
        
        
        /**
         * generates cache key for const static mibe objects with given position type and index
         */
        public static function generateCacheKey(positionType:int, index:Number):String{
            return CACHE_PREFIX + positionType + "_" + index;
        }
        
        /**
         * creates mibe with given position data. Puts the instance into cache if not cached previously and return cached instance
         */
        public static function createIfNotCached(positionType:int, index:Number):MIBE{
            var key:String = generateCacheKey(positionType, index);
            if(!ObjectCache.instance.hasKey(key)){
                ObjectCache.instance.put(key, new MIBE(new Position(positionType, index))); 
            }
            return ObjectCache.instance.get(key) as MIBE;
        }
        
        /**
         * gets cached mibe by position type and index
         */
        public static function getFromCacheByPosition(positionType:int, index:Number):MIBE{
            return ObjectCache.instance.get(generateCacheKey(positionType, index)) as MIBE;
        }
        
        /**
         *  creates clone for given parent
         * @param parent reference of parent component
         * @return 
         * 
         */        
        public override function clone(parent:ComponentBase = null):ComponentBase{
            var clone:MIBE = new MIBE(position);
            clone.cloneBasicData(this);
            
            clone.parent = parent;
            
            return clone;
        }
	}
}
