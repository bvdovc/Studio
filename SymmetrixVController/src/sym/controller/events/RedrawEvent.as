package sym.controller.events
{
    import flash.events.Event;
    
    public class RedrawEvent extends Event
    {
        public static const REDRAW_EVENT:String = "redraw_event";
        
        public function RedrawEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }
}