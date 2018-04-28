package sym.controller.events
{
	import flash.events.Event;
	
	/**
	 * Update VMax model with selected vmax 
	 * 
	 */
	public class VMaxSelectionChangedEvent extends Event
	{
		private var _currentVmax:String="";
		public static const SELECTION_CHANGED:String = "vmax_selection_changed_event";
		
		public function VMaxSelectionChangedEvent(type:String, vmax:String)
		{
			super(type);
			this._currentVmax = vmax;
		}
		
		public function get currentVmax():String
		{
			return _currentVmax;
		}
		
		public override function clone():Event
		{
			return new VMaxSelectionChangedEvent(type, currentVmax);
		}
	}
}