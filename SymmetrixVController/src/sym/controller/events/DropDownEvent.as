package sym.controller.events
{
	import flash.events.Event;
	
	public class DropDownEvent extends Event
	{
		public static const SHOW:String = "show_event";
		public static const HIDE:String = "hide_event";
		
		public function DropDownEvent(type:String)
		{
			super(type);
		}
		
		public override function clone():Event
		{
			return new DropDownEvent(type);
		}
	}
}