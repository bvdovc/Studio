package sym.controller.events
{
	import flash.events.Event;
	
	/**
	 * holds (breadcrumb) view for navigation 
	 */
	[Bindable]
	public class NavigationRequestEvent extends Event
	{
		private var _view:String; 
		public static const _NAVIGATION_REQUEST:String = "navigation request event";
		
		public function NavigationRequestEvent(type:String, view:String)
		{
			super(type);
			_view = view;
		}
		
		
		public function get view():String
		{
			return _view;
		}

	}
}