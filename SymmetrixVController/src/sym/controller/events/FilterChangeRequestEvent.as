package sym.controller.events
{
	import flash.events.Event;
	
	public class FilterChangeRequestEvent extends Event
	{
		public static const CHANGE_REQUEST:String = "filter_request_changed";
        public static const REPLACE_REQUEST:String = "filter_replace_request";
		private var _filterType:String;
		private var _filterValue:Object;
        private var _filterIndex:int;
		
		public function FilterChangeRequestEvent(type:String, filterType:String, filterValue:Object, filterIndex:int=-1)
		{
			super(type);
			this._filterType = filterType;
			this._filterValue = filterValue;
            this._filterIndex = filterIndex;
		}
		
		public function get filterType():String
		{
			return _filterType;
		}

		public function get filterValue():Object
		{
			return _filterValue;
		}
		
        public function get filterIndex():int {
            return _filterIndex;
        }
        
		public override function clone():Event
		{
			return new FilterChangeRequestEvent(type, _filterType, _filterValue, _filterIndex);
		}
	}
}