package sym.objectmodel.common
{
	
	public class Vanguard extends DAE
	{
        public static const SIZE:Size = new Size(Size.USIZE, 2);
        
		public function Vanguard(position:Position, parentEngine:int)
		{
			super("vanguard", position, SIZE, DAE.Vanguard, parentEngine);  
		}
		
		public static function createFromXml(xml:XML):ComponentBase
		{
			var vrd:sym.objectmodel.common.Vanguard = new sym.objectmodel.common.Vanguard(new Position(xml.@positionType, xml.@positionIndex), xml.@parentEngine);
			return vrd;
		}
		
		public static function validateXml(xml:XML, seria:String):Boolean
		{
			if(parseInt(xml.@positionType.toString()) != Position.BAY_ENCLOSURE){
				return false;
			}			
			return true;
		}
        
		public override function get daeName():String
		{
			return VANGUARD_NAME;
		}
		
        /**
         *  creates clone for given parent
         * @param parent reference of parent component
         * @return 
         * 
         */        
        public override function clone(parent:ComponentBase = null):ComponentBase{
            var clone:sym.objectmodel.common.Vanguard  = new sym.objectmodel.common.Vanguard(position, parentEngine);
            
            clone.cloneBasicData(this);
            clone.id = id;
            clone.parent = parent;
            
            return clone;
        }
	}
}