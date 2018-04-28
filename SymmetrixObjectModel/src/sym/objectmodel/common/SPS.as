package sym.objectmodel.common
{
    public class SPS extends ComponentBase
    {
        public static const TYPE_STANDARD:int = 1;
        public static const TYPE_LION:int = 2;
                
        private static const _mySize:Size = new Size(Size.USIZE, 2);
        private static const CACHE_PREFIX:String = "cache_sps_";
        
        protected var _parentEngine:int; //engine number or -1 if IB module (this is for M family)
        
        public function SPS(position:Position, type:int = SPS.TYPE_STANDARD, engIndex:int = -1)
        {
            super("sps", position, _mySize);
            _type= type;
            _parentEngine = engIndex;
        }

        public static function createFromXml(xml:XML):ComponentBase
        {
            var sps:SPS = new SPS(new Position(xml.@positionType, xml.@positionIndex));
            return sps;
        }
		
		public static function validateXml(xml:XML, seria:String):Boolean
		{
			return true;
		} 
        
        /**
         * generates cache key for const static SPS objects with given position type and index
         */
        public static function generateCacheKey(positionType:int, index:Number, factoryName:String):String{
            return CACHE_PREFIX + positionType + "_" + index + "_" + factoryName;
        }
        
        /**
         * creates SPS with given position data. Puts the instance into cache if not cached previously and return cached instance
         */
        public static function createIfNotCached(positionType:int, index:Number, factoryName:String):SPS{
            var key:String = generateCacheKey(positionType, index, factoryName);
            if(!ObjectCache.instance.hasKey(key)){
                ObjectCache.instance.put(key, new SPS(new Position(positionType, index))); 
            }
            return ObjectCache.instance.get(key) as SPS;
        }
        
        
        /**
         *  creates clone for given parent
         * @param parent reference of parent component
         * @return 
         * 
         */        
        public override function clone(parent:ComponentBase = null):ComponentBase{
            var clone:SPS = new SPS(position);
            clone.cloneBasicData(this);
            
            clone.parent = parent;
            
            return clone;
        } 
        
        public override function get propertiesEnabled():Boolean{
            return parentConfiguration is Configuration_VG3R &&   
                (parentConfiguration.factory as IPowerTypeManager).getCurrentSPSType() == TYPE_LION;
        }
        
        public function get parentEngine():int{
            return _parentEngine;
        }
    }
}
