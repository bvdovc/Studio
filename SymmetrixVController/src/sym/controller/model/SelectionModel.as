package sym.controller.model
{ 
    import mx.collections.ArrayCollection;
    
    import sym.objectmodel.common.ComponentBase;

    /**
    * Contains different objects used in SymmController and Navigation util
    */
    [Bindable]
    public class SelectionModel
    { 
        //currently selected vmax config
        public var vmaxConfiguration:String;
        
		//previous configuration
		public var previousConfiguration:ComponentBase;

		//currently seen component (drill down)
        public var currentComponent:ComponentBase;
        
        //currently selected configuration
        public var currentConfiguration:ComponentBase;
        
        //selection component data provider (configurations, engines, filtered components ...)
        public var selectionComponentDataProvider:ArrayCollection; 
        
        //determines whether filter is turned on/off
        public var showFilter:Boolean;
        
        //determines if selection component is shown/hidden
        public var showSelectionComponent:Boolean;
    }
}