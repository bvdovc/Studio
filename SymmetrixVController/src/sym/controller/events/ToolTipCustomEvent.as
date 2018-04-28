package sym.controller.events
{
	import flash.events.Event;
	
	/**
	 * Used to simulate mouse over/toolTip functionality 
	 * @author nmilic
	 * 
	 */		
	public class ToolTipCustomEvent extends Event
	{
		public static const SHOW_TOOLTIP:String = "show_toolTip";
		public static const HIDE_TOOLTIP:String = "hide_toolTip";
		public static const START_TOOLTIP:String = "start_toolTip";
					
		private var _targetComponent:Object;
		
		public function ToolTipCustomEvent(type:String, target:Object)
		{
			super(type);
			_targetComponent = target;
		}
			
		public function get targetComponent():Object
		{
			return _targetComponent;
		}

		public override function clone():Event
		{
			return new ToolTipCustomEvent(type, target);
		}
	}
}