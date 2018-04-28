package sym.controller.model
{
    import sym.controller.NavigationContoller;
    import sym.objectmodel.common.ComponentBase;
    import sym.objectmodel.common.Constants;

    /**
     * Breadcrumb data provider holds instances of this class
     */
    [Bindable]
    public class BreadcrumbItem
    {
        private var _id:String;
        private var _selectedItem:ComponentBase;
        private var _label:String;
        private var _tooltip:String;
        private var _isHome:Boolean;
        
        public function BreadcrumbItem(id:String, label:String, component:ComponentBase = null, isHome:Boolean = false)
        {
            _id = id;
            setSelectedItem(component);
            _label = label;
            _isHome = isHome;
        }
        
        private function setSelectedItem(component:ComponentBase):void
        {
            _selectedItem = component;
            if(_selectedItem){
                _tooltip = NavigationContoller.instance.toolTipProvider.getToolTip(!_selectedItem.visibleInFrontView ? Constants.REAR_VIEW_PERSPECTIVE : Constants.FRONT_VIEW_PERSPECTIVE, _selectedItem);
            }
        }

        public function get selectedItem():ComponentBase
        {
            return _selectedItem;
        }

        public function get id():String
        {
            return _id;
        }

        public function get label():String
        {
            return _label;
        }

        public function get isHome():Boolean
        {
            return _isHome;
        }
        
        public function get toolTip():String
        {
            return _tooltip;
        }
        
        public function get isLastItem():Boolean
        {
            if(!NavigationContoller.instance.breadcrumbDP || 
                NavigationContoller.instance.breadcrumbDP.length == 0){
                return false;
            }
            return NavigationContoller.instance.breadcrumbDP.getItemIndex(this) == (NavigationContoller.instance.breadcrumbDP.length - 1);
        }
    }
}