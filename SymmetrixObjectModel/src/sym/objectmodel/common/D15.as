package sym.objectmodel.common
{

    public class D15 extends DAE
    { 
        public static const SIZE:Size = new Size(Size.USIZE, 3);
        
        public function D15(position:Position, parentEngine:int)
        {
            super("d15", position, SIZE, DAE.D15, parentEngine); 
        }

        public static function createFromXml(xml:XML):ComponentBase
        {
            var d15:sym.objectmodel.common.D15 = new sym.objectmodel.common.D15(new Position(xml.@positionType, xml.@positionIndex), xml.@parentEngine);
            return d15;
        }
		
		public static function validateXml(xml:XML, seria:String):Boolean
		{
			return true;
		}
        
		public override function get daeName():String
		{
			return D15_NAME;
		}
		
        /**
         *  creates clone for given parent
         * @param parent reference of parent component
         * @return 
         * 
         */        
        public override function clone(parent:ComponentBase = null):ComponentBase{
            var clone:sym.objectmodel.common.D15 = new sym.objectmodel.common.D15(position, parentEngine);
            
            clone.cloneBasicData(this);
            clone.id = id;
            clone.parent = parent;
            
            return clone;
        }
    }
}
