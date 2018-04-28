package sym.objectmodel.common
{
	import mx.utils.StringUtil;
	
	import sym.objectmodel.common.ComponentBase;
	import sym.objectmodel.common.Position;

	public class PDP extends ComponentBase
	{
        private static const CACHE_PREFIX:String = "cache_pdp_";
		
		// for deserialization from xml
		public static var missingXML:XML = null;
        
		public function PDP(position:Position)
		{
			super("pdp", position, null);
        }

		public static function createFromXml(xml:XML):ComponentBase
		{
			var pdp:PDP=new PDP(new Position(xml.@positionType, xml.@positionIndex));
			return pdp;
		}
		
		public static function validateXml(xml:XML, seria:String):Boolean
		{
			if(Position.BACKPANEL_PDP != parseInt(xml.@positionType.toString())){
				return false;
			}
			return true;
		}
        
        public override function get visible():Boolean {
			if(sym.objectmodel.common.Tabasco)
				return true;
            var pwm:IPowerTypeManager = parentConfiguration.factory as IPowerTypeManager;
            
            return pwm.isPDPVisible(this);
        }
        
        /**
         * generates cache key for const static PDP objects with given position type and index
         */
        public static function generateCacheKey(positionType:int, index:Number, factoryName:String, bayType:int):String{
            return StringUtil.substitute("{0}_{1}_{2}_{3}_{4}", CACHE_PREFIX, positionType, index, factoryName, bayType);
        }
        
        /**
         * creates PDP with given position data. Puts the instance into cache if not cached previously and return cached instance
         */
        public static function createIfNotCached(positionType:int, index:Number, factoryName:String, bayType:int):PDP{
            var key:String = generateCacheKey(positionType, index, factoryName, bayType);
            if(!ObjectCache.instance.hasKey(key)){
                ObjectCache.instance.put(key, new PDP(new Position(positionType, index))); 
            }
            return ObjectCache.instance.get(key) as PDP;
        }
        
        /**
         *  creates clone for given parent
         * @param parent reference of parent component
         * @return 
         * 
         */        
        public override function clone(parent:ComponentBase = null):ComponentBase{
            var clone:PDP = new PDP(position);
            clone.cloneBasicData(this);
            
            clone.parent = parent;
            
            return clone;
        }
        
        public override function get propertiesEnabled():Boolean{
            return false;
        }
	}
}
