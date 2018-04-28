package sym.objectmodel.common
{

	public class Server extends ComponentBase
	{
        private static const _mySize:Size = new Size(Size.USIZE, 1);
        private static const CACHE_PREFIX:String = "cache_server_";
        
		public function Server(position:Position)
		{
			super("server", position, _mySize); 
		}

		public static function createFromXml(xml:XML):ComponentBase
		{
			var server:Server=new Server(new Position(xml.@positionType, xml.@positionIndex));
			return server;
		}
		
		public static function validateXml(xml:XML, seria:String):Boolean
		{
			if(parseInt(xml.@positionType.toString()) != Position.BAY_ENCLOSURE){
				return false;
			}
			
			return true;
		}
        
        /**
         * generates cache key for const static Server objects with given position type and index
         */
        public static function generateCacheKey(positionType:int, index:Number):String{
            return CACHE_PREFIX + positionType + "_" + index;
        }
        
        /**
         * creates Server with given position data. Puts the instance into cache if not cached previously and return cached instance
         */
        public static function createIfNotCached(positionType:int, index:Number):Server{
            var key:String = generateCacheKey(positionType, index);
            if(!ObjectCache.instance.hasKey(key)){
                ObjectCache.instance.put(key, new Server(new Position(positionType, index))); 
            }
            return ObjectCache.instance.get(key) as Server;
        }
        
        /**
         *  creates clone for given parent
         * @param parent reference of parent component
         * @return 
         * 
         */        
        public override function clone(parent:ComponentBase = null):ComponentBase{
            var clone:Server = new Server(position);
            clone.cloneBasicData(this);
            
            clone.parent = parent;
            
            return clone;
        }   
        
        public override function get propertiesEnabled():Boolean{
            return false;
        }
	}
}
