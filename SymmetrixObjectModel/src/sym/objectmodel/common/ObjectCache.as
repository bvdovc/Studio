package sym.objectmodel.common
{
    import flash.utils.Dictionary;
    
    public class ObjectCache
    {
        private static var _inst:ObjectCache = new ObjectCache();
        private var _cache:Dictionary = new Dictionary();
        
        
        public function ObjectCache()
        {
            preInitCache();
        }
        
        public static function get instance():ObjectCache{
            return _inst;
        }
        
        public function hasKey(key:Object):Boolean{
            return _cache[key] != null;
        }
        
        public function get(key:Object):Object{
            return _cache[key];
        }
        
        public function put(key:Object, value:Object, replaceExisting:Boolean = true):Object{
            if(!replaceExisting && hasKey(key))
                return get(key);
            return (_cache[key] = value);
        }
        
        public function remove(key:Object):void{
            _cache[key] = null;
        }
        
        /**
        * initialize shared cache objects
        */
        private function preInitCache():void{ 
            _cache[PortConfiguration.ENGINE_DIRECTOR_10K_POSITION_CACHE_KEY] = new Position(Position.ENGINE_DIRECTOR_10ke);
            _cache[PortConfiguration.ENGINE_DIRECTOR_20K_40K_POSITION_CACHE_KEY] = new Position(Position.ENGINE_DIRECTOR_2040k);
            _cache[PortConfiguration.ENGINE_DIRECTOR_VG3R_POSITION_CACHE_KEY] = new Position(Position.ENGINE_DIRECTOR_VG3R);
        }
    }
}