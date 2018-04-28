package sym.controller.events
{
    import flash.events.Event;
    
    /**
    * view refresh request event
    * <p>View should handle different types of refresh requests
    * - RefreshCentralModelUI
    * - RefreshSelectionList
    * 
    * </p>
    */
    public class ViewRefreshRequestEvent extends Event
    {
        public static const REFRESH_CENTRAL_MODEL_UI:String = "RefreshCentralModelUI";
        public static const REFRESH_SELECTION_LIST:String = "RefreshSelectionList";
        
        private var _value:Object;
        
        public function ViewRefreshRequestEvent(type:String, value:Object)
        {
            super(type);
            this._value = value;
        }
        
        /**
        * Holds object for refreshing view 
        * - ComponentBase
        * - List<ComponentBase>
        * - ...
        */
        public function get value():Object{
            return _value;
        }
        
        public override function clone():Event{
            return new ViewRefreshRequestEvent(type, _value);
        }
    }
}