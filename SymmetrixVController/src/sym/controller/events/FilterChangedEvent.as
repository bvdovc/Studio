package sym.controller.events
{
	import flash.events.Event;
	
	public class FilterChangedEvent extends Event
	{
		public static const FILTER_CHANGED:String = "filter_selection_changed_event";
		public static const RELOAD_CONFIGS:String = "reload_configs";
		
		public function FilterChangedEvent(type:String)
		{
			super(type);
		}
			
		public override function clone():Event
		{
			return new FilterChangedEvent(type);
		}
	}
}