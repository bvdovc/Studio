package sym.objectmodel.common
{

	public class PDU extends ComponentBase
	{ 
        public static const TYPE1PHASE:int=1;
        public static const TYPE3PHASE:int=2;
        
        private static const CACHE_PREFIX:String = "cache_pdu_";
        
		public function PDU(position:Position, type:int = TYPE1PHASE)
		{
			super("pdu", position, null);
			_type=type;
		}

		public function set type(pwrType:int):void
		{
			_type=pwrType;
		}

        public override function get visible():Boolean {
            var pwm:IPowerTypeManager = parentConfiguration.factory as IPowerTypeManager;
			if(sym.objectmodel.common.Tabasco)
				return true;
            return pwm.isPDUVisible(this);
        }

        public override function serializeToXML():XML
		{
			var xml:XML=super.serializeToXML();
			return xml;
		}

		public static function createFromXml(xml:XML):ComponentBase
		{
			var pdu:PDU=new PDU(new Position(xml.@positionType, xml.@positionIndex));
			return pdu;
		}
		
		public static function validateXml(xml:XML, seria:String):Boolean
		{
			if(Position.BACKPANEL_PDU != parseInt(xml.@positionType.toString())){
				return false;
			}
			return true;
		}
        
        /**
         * generates cache key for const static PDP objects with given position type and index
         */
        public static function generateCacheKey(positionType:int, index:Number, bayType:int):String{
            return CACHE_PREFIX + positionType + "_" + index + "_" + bayType;
        }
        
        /**
         * creates PDP with given position data. Puts the instance into cache if not cached previously and return cached instance
         */
        public static function createIfNotCached(positionType:int, index:Number, bayType:int):PDU{
            var key:String = generateCacheKey(positionType, index, bayType);
            if(!ObjectCache.instance.hasKey(key)){
                ObjectCache.instance.put(key, new PDU(new Position(positionType, index))); 
            }
            return ObjectCache.instance.get(key) as PDU;
        }
        
        /**
         *  creates clone for given parent
         * @param parent reference of parent component
         * @return 
         * 
         */        
        public override function clone(parent:ComponentBase = null):ComponentBase{
            var clone:PDU = new PDU(position);
            clone.cloneBasicData(this);
            
            clone.parent = parent;
            
            return clone;
        }
        
        public override function get propertiesEnabled():Boolean{
            return false;
        }
	}
}
