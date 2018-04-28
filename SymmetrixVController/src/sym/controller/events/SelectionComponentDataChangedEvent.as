package sym.controller.events
{
    import flash.events.Event;
    
    import mx.collections.ArrayCollection;
    
    public class SelectionComponentDataChangedEvent extends Event
    {
        public static const DATA_SOURCE_CHANGED:String = "SelectionDataSource_Changed";
        
        private var _dataSource:ArrayCollection;
		private var _dpType:String;
        
        public function SelectionComponentDataChangedEvent(type:String, dataSource:ArrayCollection, dpType:String)
        {
            super(type);
            _dataSource = dataSource;
			_dpType = dpType;
        }
        
        public function get dataSource():ArrayCollection{
            return _dataSource;
        }

		public function get dpType():String{
            return _dpType;
        }
        
        public override function clone():Event{
            return new SelectionComponentDataChangedEvent(type, _dataSource, dpType);
        }
    }
}