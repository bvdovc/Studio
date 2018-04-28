package sym.objectmodel.common
{

	public class KVM extends ComponentBase
	{
        private static const _mySize:Size = new Size(Size.USIZE, 1);
        private static const CACHE_PREFIX:String = "cache_kvm_";
         
		public function KVM(position:Position)
		{
			super("kvm", position, _mySize);
		}

		public static function createFromXml(xml:XML):ComponentBase
		{
			var kvm:KVM=new KVM(new Position(xml.@positionType, xml.@positionIndex));
			return kvm;
		}
		
		public static function validateXml(xml:XML, seria:String):Boolean
		{
			if(parseInt(xml.@positionType.toString()) != Position.BAY_ENCLOSURE){
				return false;
			}
			
			return true;
		}
        
        /**
         * generates cache key for const static kvm objects with given position type and index
         */
        public static function generateCacheKey(positionType:int, index:Number):String{
            return CACHE_PREFIX + positionType + "_" + index;
        }
        
        /**
         * creates kvm with given position data. Puts the instance into cache if not cached previously and return cached instance
         */
        public static function createIfNotCached(positionType:int, index:Number):KVM{
            var key:String = generateCacheKey(positionType, index);
            if(!ObjectCache.instance.hasKey(key)){
                ObjectCache.instance.put(key, new KVM(new Position(positionType, index))); 
            }
            return ObjectCache.instance.get(key) as KVM;
        }
        
        /**
         * gets cached kvm by position type and index
         */
        public static function getFromCacheByPosition(positionType:int, index:Number):KVM{
            return ObjectCache.instance.get(generateCacheKey(positionType, index)) as KVM;
        }
        
        /**
         *  creates clone for given parent
         * @param parent reference of parent component
         * @return 
         * 
         */        
        public override function clone(parent:ComponentBase = null):ComponentBase{
            var clone:KVM = new KVM(position);
            clone.cloneBasicData(this);
            
            clone.parent = parent;
            
            return clone;
        }  
		
		public override function get visibleInRearView():Boolean 
		{
			return !(parentConfiguration is Configuration_VG3R);
		}

		public override function get propertiesEnabled():Boolean{
            return false;
        }

	}
}
