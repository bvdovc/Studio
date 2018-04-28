package sym.controller.events
{
    import flash.events.Event;
    
    import sym.objectmodel.common.ComponentBase;
    /**
     * Component Drag Drop Event 
     * @author pokimsla
     * <p>
     * <i>Currently used for dragging VG3R Engine ports and configuration icons</i>
     * </p>
     */
    public class ComponentDragDropEvent extends Event
    {
        private var _component:ComponentBase;
        private var _mouseX:Number;
        private var _mouseY:Number;
        private var _isMove:Boolean; //move or remove action on engine ports/configuration icons

        public static const COMPONENT_DROPPED:String = "ComponentDropppedEvent";
        public static const COMPONENT_DRAG_STARTED:String = "ComponentDragStartedEvent";
		public static const COMPONENT_MOVED:String = "ComponentMovedEvent";
        
        public function ComponentDragDropEvent(type:String, component:ComponentBase, isMoveOrRemoveAction:Boolean = false, mouseX:Number = NaN, mouseY:Number = NaN)
        {
            super(type);
            
            _component = component;
            _mouseX = mouseX;
            _mouseY = mouseY;
            _isMove = isMoveOrRemoveAction;
        }
        
        public function get component():ComponentBase
        {
            return _component;
        }
        
        public function get mouseX():Number
        {
            return _mouseX;    
        }
        
        public function get mouseY():Number
        {
            return _mouseY;
        }
        
        public function get isMoveOrRemove():Boolean
        {
            return _isMove;
        }
        
        public override function clone():Event
        {
            return new ComponentDragDropEvent(type, _component, _isMove, _mouseX, _mouseY);
        }
        
    }
}