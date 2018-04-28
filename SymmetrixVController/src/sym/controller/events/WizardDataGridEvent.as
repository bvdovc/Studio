package sym.controller.events
{
    import flash.events.Event;
    
    public class WizardDataGridEvent extends Event
    {
        public static const DRIVE_COUNT_EDIT_SESSION_REQUEST:String = "TiersDGEditSessionRequest";
        
        public var rowIndex:int;
        
        public function WizardDataGridEvent(type:String)
        {
            super(type);
        }
        
        public override function clone():Event
        {
            var event:WizardDataGridEvent = new WizardDataGridEvent(type);
            event.rowIndex = rowIndex;
            return event;
        }
    }
}