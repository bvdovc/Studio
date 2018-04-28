package sym.controller.events
{
    import flash.events.Event;
    
    import mx.collections.ArrayCollection;
    
    import sym.controller.model.PropertiesPanelItems;
    
    public class PropertiesLoadEvent extends Event
    {
        public static const PROPERTY_LIST_LOADED:String = "propertiesLoaded";
        public static const PROPERTY_LIST_LOAD_FAILED:String ="propertiesLoadingFailed";
        
        private var _propertiesPanelItems:PropertiesPanelItems;
        
        
        public function PropertiesLoadEvent(type:String, propertiesPanelItems:PropertiesPanelItems = null)
        {
            super(type);
            _propertiesPanelItems = propertiesPanelItems;
        }
        
        public function get properties():PropertiesPanelItems{
            return _propertiesPanelItems;
        }
        
        public override function clone():Event{
            return new PropertiesLoadEvent(type, properties);
        }
    }
}