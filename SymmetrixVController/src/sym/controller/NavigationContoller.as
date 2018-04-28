package sym.controller
{
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    
    import mx.collections.ArrayCollection;
    import mx.resources.ResourceManager;
    
    import avmplus.getQualifiedClassName;
    
    import sym.controller.events.ComponentSelectionChangedEvent;
    import sym.controller.events.NavigationRequestEvent;
    import sym.controller.events.RefreshNavigationEvent;
    import sym.controller.model.BreadcrumbItem;
    import sym.controller.utils.IToolTipProvider;
    import sym.controller.utils.ToolTipProvider;
    import sym.objectmodel.common.Bay;
    import sym.objectmodel.common.ComponentBase;
    import sym.objectmodel.common.Constants;
    import sym.objectmodel.common.ControlStation;
    import sym.objectmodel.common.DAE;
    import sym.objectmodel.common.DataMover;
    import sym.objectmodel.common.InfinibandSwitch;

    /**
     * NavigationController
     * controller for navigation via breadcrumb
     */
    public class NavigationContoller extends EventDispatcher
    { 
        private static const _instance:NavigationContoller = new NavigationContoller();

        public static const HOME_VIEW:String = "HomeView"; 
 
        //breadcrumb data provider
        [Bindable]
        private var _breadcrumbDP:ArrayCollection = new ArrayCollection();

        private var _toolTipProvider:IToolTipProvider = new ToolTipProvider();
        
        public function get breadcrumbDP():ArrayCollection
        {
            return _breadcrumbDP;
        }
        
        /**
        * gets tooltip provider used in breadcrumb items
        */
        public function get toolTipProvider():IToolTipProvider{
            return _toolTipProvider;
        }

        /**
         * Gets singleton instance of NavigationContoller
         */
        public static function get instance():NavigationContoller
        {
            return _instance;
        }

        public function NavigationContoller(target:IEventDispatcher = null)
        {
            super(target);

            appendItem(HOME_VIEW, ResourceManager.getInstance().getString("main", "HOME_NAV_TITLE"), null, true);

            SymmController.instance.eventHandler.addEventListener(ComponentSelectionChangedEvent.BREADCRUMB_CHANGED, onComponentSelectionChanged);
        }

        /**
         * Method for initialising breadcrumb data provider
         */
        public function initialize():void
        {
            breadcrumbDP.removeAll(); 
            appendItem(HOME_VIEW, ResourceManager.getInstance().getString("main", "HOME_NAV_TITLE"), null, true);
            NavigationContoller.instance.dispatchEvent(new RefreshNavigationEvent(RefreshNavigationEvent.REFRESH_NAVIGATION, breadcrumbDP));
        }

        /**
         * called when one of the breadcrumb items is selected
         * Navigate to the specific breadcrumb view
         */
        public function navigate(item:BreadcrumbItem):void
        {
            if (item.id == HOME_VIEW)
            {
                NavigationContoller.instance.dispatchEvent(new NavigationRequestEvent(NavigationRequestEvent._NAVIGATION_REQUEST, item.id));
                return;
            }
 
			if(SymmController.instance.selectionDataProvider.length > 0){
	            SymmController.instance.showComponent(item.selectedItem);
			}
        }

        /**
         * hanldes selection change and drilldown selection
         * Crops breadcrumb items
         */
        public function onComponentSelectionChanged(event:ComponentSelectionChangedEvent):void
        {
            if (breadcrumbDP != null)
            {
                var selectedItem:BreadcrumbItem = null;
                for each (var item:BreadcrumbItem in breadcrumbDP)
                {
                    if (item.selectedItem && (getQualifiedClassName(item.selectedItem) == getQualifiedClassName(event.selectedItem)))
                    {
                        selectedItem = item;
                        break;
                    }
                }

				if (selectedItem)
                {
                    var index:int = breadcrumbDP.getItemIndex(selectedItem);
                    removeItemsFromIndex(index);
                }
				else if(selectedItem == null && event.selectedItem.isConfiguration)
				{
					removeItemsFromIndex(1);	
				}

                var label:String = event.selectedItem.id;
          
				if (event.selectedItem is DAE)
				{
					label = (event.selectedItem as DAE).daeName;
				}
                
                if(event.selectedItem is Bay || event.selectedItem is DataMover || 
					event.selectedItem is ControlStation || event.selectedItem.isEngine ||
					event.selectedItem is InfinibandSwitch)
				{
					label = toolTipProvider.getToolTip(Constants.FRONT_VIEW_PERSPECTIVE, event.selectedItem);
                }
                appendItem(event.selectedItem.id, label, event.selectedItem);
                NavigationContoller.instance.dispatchEvent(new RefreshNavigationEvent(RefreshNavigationEvent.REFRESH_NAVIGATION, breadcrumbDP));
            }
        }

        /**
         * appends new breadcrumb item
         */
        private function appendItem(id:String, label:String, cb:ComponentBase = null, isHome:Boolean = false):void
        {
            var breadCrumbItem:BreadcrumbItem = new BreadcrumbItem(id, label.toUpperCase(), cb, isHome);
            breadcrumbDP.addItem(breadCrumbItem);
        }

        /**
         * removes items from given index including himself
         */
        public function removeItemsFromIndex(index:int):void
        {
            for (var i:int = breadcrumbDP.length - 1; i >= index; i--)
            {
                breadcrumbDP.removeItemAt(i);
            }
        }
    }
}
