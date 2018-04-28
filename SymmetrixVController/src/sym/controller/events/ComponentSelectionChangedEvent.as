package sym.controller.events
{
	import flash.events.Event;
	
	import sym.objectmodel.common.ComponentBase;

	/**
	 * component selection changed from selection list
	 */
	public class ComponentSelectionChangedEvent extends Event
	{ 
        public static const COMPONENT_SELECTION_CHANGED:String = "ComponentSelectionChanged";
		public static const BREADCRUMB_CHANGED:String = "BreadcrumbChanged";
        
		private var _selectedItem:ComponentBase;

		public function ComponentSelectionChangedEvent(type:String, selectedItem:ComponentBase, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._selectedItem=selectedItem;
		}

		public function get selectedItem():ComponentBase
		{
			return _selectedItem;
		}

		public override function clone():Event
		{
			return new ComponentSelectionChangedEvent(type, _selectedItem, bubbles, cancelable);
		}
	}
}
