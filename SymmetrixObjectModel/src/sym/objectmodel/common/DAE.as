package sym.objectmodel.common
{
    

    /**
     * base class representing generic DAE (disk array enclosure)
     */
    public class DAE extends ComponentBase
    {
        public static const D15:int = 1;
        public static const Vanguard:int = 2;
        public static const MixedD15:int = 3;
        public static const MixedVanguard:int = 4;
		public static const Voyager:int = 5;
		public static const Viking:int = 6;
		public static const MixedVoyager:int = 7;
		public static const Tabasco:int = 8;
		public static const Nebula:int = 9; //need to change
		public static const D15_NAME:String = "standard dae";
		public static const VANGUARD_NAME:String = "high-density dae";
		public static const VOYAGER_NAME:String = "60-Drive DAE";
		public static const VIKING_NAME:String = "120-Drive DAE";
		public static const TABASCO_NAME:String = "25-Drive DAE";
		public static const NEBULA_NAME:String = "24-Drive DAE";

        protected var _parentEngine:int; 
        
        public var indexBehindEngine:int;

        public function DAE(id:String, position:Position, size:Size, daeType:int, parentEngine:int)
        {
            super(id, position, size);

            if (daeType != DAE.D15 && daeType != DAE.Vanguard && daeType != DAE.Viking && daeType != DAE.Voyager && daeType != DAE.MixedVoyager 
				&& daeType != DAE.Tabasco && daeType != DAE.Nebula)
            {
                throw new ArgumentError("unknown DAE type");
            }

            _type = daeType;
            _parentEngine = parentEngine;
        }

        public function get parentEngine():int
        {
            return _parentEngine;
        }

        public override function serializeToXML():XML
        {
            var xml:XML = super.serializeToXML();
            xml.@type = _type;
            xml.@parentEngine = _parentEngine;
            return xml;
        }
		
        /**
         * Compares dae by type
         */
        public override function equals(component:ComponentBase):Boolean
        {
            return super.equals(component) && this._type == (component as DAE)._type;
        }
        
		public function get daeName():String
		{
			return this.id;
		}
		
        /**
         *  creates clone for given parent
         * @param parent reference of parent component
         * @return 
         * 
         */        
        public override function clone(parent:ComponentBase = null):ComponentBase{
            var clone:DAE = new DAE(id, position, size, type, parentEngine);
            clone.cloneBasicData(this);
             
            clone.parent = parent;
            
            return clone;
        }

    }
}
