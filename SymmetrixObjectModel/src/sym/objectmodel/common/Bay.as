package sym.objectmodel.common
{
    public class Bay extends ComponentBase
    {
        public static const TYPEUNKNOWN:int = 0;
        public static const TYPEMOHAWKSYSBAY:int = 1;
        public static const TYPEMOHAWKSTGBAY:int = 2;
        public static const TYPETITANSYSBAY:int = 3;
        public static const TYPETITANSTGBAY:int = 4;

        public static const ID_SYSTEM_BAY:String = "SYSTEMBAY";
        public static const ID_SYSTEM_BAY_D15 :String = "SYSTEMBAYD15";
        public static const ID_SYSTEM_BAY_VANGUARD:String = "SYSTEMBAYVanguard";
        public static const ID_SYSTEM_BAY_VOYAGER:String = "SYSTEMBAYVOYAGER";
        public static const ID_SYSTEM_BAY_VIKING:String = "SYSTEMBAYVIKING";
		public static const ID_SYSTEM_BAY_TABASCO:String = "SYSTEMBAYTABASCO";
		public static const ID_SYSTEM_BAY_NEBULA:String = "SYSTEMBAYNEBULA";
        public static const ID_SBAY1A:String = "SBAY1A";
        public static const ID_SBAY2A:String = "SBAY2A";
        public static const ID_SBAY3A:String = "SBAY3A";
        public static const ID_SBAY4A:String = "SBAY4A";
        public static const ID_SBAY1B:String = "SBAY1B";
        
        protected var _dispersed:int = -1;
        protected var _dispersed_m:Array = [-1];
		
		public var positionIndex:int = -1;
		public var attachedToSystemBayWithIndex:int;
		
        public function Bay(id:String, type:int, position:Position)
        {
            super(id, null, null);

            _type = type;
            _position = position;
        }

        public function get dispersed():int
        {
            return _dispersed;
        }

        public function set dispersed(value:int):void
        {
            _dispersed = value;
        }

		public function get dispersed_m():Array
		{
			return _dispersed_m;
		}
		
		public function set dispersed_m(value:Array):void
		{
			_dispersed_m = value;
		}
        public function get isStorageBay():Boolean
        {
            return (id != ID_SYSTEM_BAY && id != ID_SYSTEM_BAY_D15 && id != ID_SYSTEM_BAY_VANGUARD && 
					id != ID_SYSTEM_BAY_VOYAGER && id != ID_SYSTEM_BAY_VIKING && id != ID_SYSTEM_BAY_TABASCO && id != ID_SYSTEM_BAY_NEBULA);
        }
		
		public function get isSystemBay():Boolean
		{
			return (id == ID_SYSTEM_BAY || id == ID_SYSTEM_BAY_D15 || id == ID_SYSTEM_BAY_VANGUARD ||
				id == ID_SYSTEM_BAY_VOYAGER || id == ID_SYSTEM_BAY_VIKING || id == ID_SYSTEM_BAY_TABASCO || id == ID_SYSTEM_BAY_NEBULA);
		}

        public function get countDAEs():int
        {
            var count:int = 0;

            for each (var child:ComponentBase in _children)
            {
                if (child is DAE)
                {
                    count++;
                }
            }

            return count;
        }
		
		public function get countDataMovers():int
		{
			var count:int = 0;
			
			for each (var child:ComponentBase in _children)
			{
				if (child is DataMover)
				{
					count++;
				}
			}
			
			return count;
		}

        public function get sortOrder():int
        {
            if (_dispersed != -1)
            {
                return _position.index + 100;
            }

            return _position.index;
        }

        public override function serializeToXML():XML
        {
            var xml:XML = super.serializeToXML();
            xml.@type = _type;
			xml.@dispersed = this.dispersed;
            return xml;
        }

        public static function createFromXml(xml:XML):ComponentBase
        {
            var bay:Bay = new Bay(xml.@id, xml.@type, new Position(xml.@positionType, xml.@positionIndex));
			bay.dispersed = xml.@dispersed;
            return bay;
        }
		
		public static function validateXml(xml:XML, seria:String):Boolean
		{
			if(parseInt(xml.@positionType.toString()) != Position.FLOOR){
				return false;
			}
						
			return true;
		}

        /**
        * Compares bays by type
        */
        public override function equals(component:ComponentBase):Boolean
        {
            return super.equals(component) && this.type == component.type;
        }
        
        /**
         *  creates clone for given parent
         * @param parent reference of parent component
         * @return 
         * 
         */        
        public override function clone(parent:ComponentBase = null):ComponentBase{
            var clone:Bay = new Bay(id, type, position);
            clone.cloneBasicData(this);
             
            clone._dispersed = _dispersed;
            clone.parent = parent;
            
            return clone;
        }

    }
}
