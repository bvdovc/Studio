package sym.controller.events
{
    import flash.events.Event;

    /**
     * Holds current wizard state model for updating FilterWizardPopUp component
     */
    public class FilterWizardEvent extends Event
    {
        public static const FILTER_WIZARD_STATE_CHANGED:String = "Filter wizard state changed event";
        public static const FILTER_WIZARD_OPEN_REQUEST:String = "WizardOpenRequest";
        private var _model:Object;

        public function FilterWizardEvent(type:String, model:Object)
        {
            super(type);
            _model = model;
        }

        public function get model():Object
        {
            return _model;
        }

        public override function clone():Event
        {
            return new FilterWizardEvent(type, model);
        }
    }
}
