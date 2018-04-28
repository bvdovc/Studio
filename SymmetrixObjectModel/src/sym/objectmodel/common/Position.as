package sym.objectmodel.common
{
    /**
     * Class representing position of HW component 
     */
    public class Position
    {
        public static const UNDEFINED:int = 0;
        public static const BAY_ENCLOSURE:int = 1;
        public static const FLOOR:int = 2;
        public static const UPPERHALFBAY:int = 3;
        public static const LOWERHALFBAY:int = 4;
        public static const VERTICAL_BAY_ENCLOSURE:int = 5;
        public static const DAE:int = 6;
        public static const BACKPANEL_PDU:int = 7;
        public static const BACKPANEL_PDP:int = 8;
        public static const ENGINESIDE_SPS_LEFT:int = 9;
        public static const ENGINESIDE_SPS_RIGHT:int = 10;
        public static const UPPERHALFBAYVERTICAL:int = 11;
        public static const LOWERHALFBAYVERTICAL:int = 12;
        public static const MIDDLEBAYVERTICAL:int = 13;
        public static const BAY_HALF_ENCLOSURE_LEFT:int = 14;
        public static const BAY_HALF_ENCLOSURE_RIGHT:int = 15;
        public static const ENGINE_DIRECTOR_10ke:int = 16;
        public static const ENGINE_DIRECTOR_2040k:int = 17;
        public static const ENGINE_DIRECTOR_VG3R:int = 18;
        public static const VOYAGER_ENCLOSURE:int = 19;
        public static const VIKING_ENCLOSURE:int = 20;
        public static const DAE_TABASCO_ENCLOSURE:int = 21;
		public static const DAE_NEBULA_ENCLOSURE:int = 22;
        
        public static const ROTATION90:Number = 1.57079633;
        public static const ROTATION270:Number = -1.57079633;
		
		public static const PDU_DEPTH:int = 1;
		public static const PDP_DEPTH:int = 2;
        
        protected var _type:int;
        protected var _index:Number;
        protected var _rotation:Number;
        protected var _flip:Boolean = false;
        protected var _mirrorY:Boolean = false;
        protected var _mirrorX:Boolean = false;
		protected var _depth:int;
        
        private static const POSITION_CACHE_PREFIX:String = "cache_position_";
        
        public function Position(type:int, index:Number = 0, flip:Boolean = false, rotation:Number = Number.NaN)
        {
            _type = type;
            _index = index;
            _flip = flip;
            _rotation = rotation;
            
            switch (_type) {
                case UPPERHALFBAYVERTICAL:
                case LOWERHALFBAYVERTICAL:
                    _rotation = ROTATION90;
                    break;
                case ENGINESIDE_SPS_RIGHT:
                    _rotation = ROTATION90;
                    _flip = true;
                    break;
                case ENGINESIDE_SPS_LEFT:
                    _rotation = ROTATION270;
                    _flip = true;
                    break;
                case MIDDLEBAYVERTICAL:
                    _rotation = ROTATION270;
                    break;
                case BACKPANEL_PDU:
					_depth = PDU_DEPTH;
                    if (index == 1 || index == 5) {
                        _mirrorY = true;
                    }
                    break;
                case BACKPANEL_PDP:
					_depth = PDP_DEPTH;
                    if (index == 0 || index == 4) {
                        _mirrorX = true;
                    } else if (index == 1 || index == 5) {
                        _mirrorX = true;
                        _mirrorY = true;
                    } else if (index == 3) {
                        _mirrorY = true;
                    }
					else if(index == 7){
						_mirrorY = true;
					}
					
                    break;
            }
        }
        
        public function get type():int {
            return _type;
        }

        public function get index():Number {
            return _index;
        }

        public function set index(idx:Number):void {
            _index = idx;
        }
        
        public function get rotation():Number {
            return _rotation;
        }
        
        public function set rotation(value:Number):void {
            _rotation = value;
        }

        public function get mirrorY():Boolean {
            return _mirrorY;
        }

        public function get mirrorX():Boolean {
            return _mirrorX;
        }

        public function get flip():Boolean {
            return _flip;
        }
        
        public function set flip(value:Boolean):void {
            _flip = value;
        }
        
		public function get depth():int
		{
			return _depth;
		}

		
        /**
        * generates cache key for const static position objects with given type and index
        */
        public static function generateCacheKey(type:int, index:Number):String{
            return POSITION_CACHE_PREFIX + type + "_" + index;
        }
        
        /**
        * gets position from cache
        */
        public static function getFromCacheByKey(key:String):Position{
			var obj:Position = ObjectCache.instance.get(key) as Position;
            return ObjectCache.instance.get(key) as Position;
        }
        
        /**
        * gets cached position by type and index
        */
        public static function getFromCacheByType(type:int, index:Number):Position{
            return getFromCacheByKey(generateCacheKey(type, index));
        }
		
		public function clone():Position {
			var pos:Position = new  Position(this.type, this.index, this.flip, this.rotation);
			pos._mirrorX = this.mirrorX;
			pos._mirrorY = this.mirrorY;
			
			return pos;
		}
    }
}