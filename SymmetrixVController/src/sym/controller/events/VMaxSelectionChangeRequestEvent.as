package sym.controller.events
{
	import flash.events.Event;
	
	/**
	 *  Dispatched when VMax model is selected
	 *  keeps selected vmax 
	 */ 
	
	public class VMaxSelectionChangeRequestEvent extends Event
	{
		private var _selectedVmax:String = "";

		public static const CHANGE_REQUEST:String="vmax_selection_change_request_event";

		public function VMaxSelectionChangeRequestEvent(type:String, vmax:String)
		{
			super(type);
			this._selectedVmax=vmax;
		}

		public function get vmax():String
		{
			return _selectedVmax;
		}
		
		public override function clone():Event
		{
			return new VMaxSelectionChangeRequestEvent(type, vmax);
		}
	}
}