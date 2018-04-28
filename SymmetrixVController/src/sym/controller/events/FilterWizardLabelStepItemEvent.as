package sym.controller.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.Label;
	
	/**
	 * sets Label step item fontWeight style  
	 */	
	public class FilterWizardLabelStepItemEvent extends Event
	{
		public static const WIZARD_LABEL_STATE_ITEM_CHANGED:String = "label state item changed event";
		private var _currentState:int;
		
		public function FilterWizardLabelStepItemEvent(type:String, currentState:int)
		{
			super(type);
			this._currentState = currentState;
		}
		
		public function get currentState():int
		{
			return _currentState;
		}

		public override function clone():Event
		{
			return new FilterWizardLabelStepItemEvent(type, currentState);
		}
	}
}