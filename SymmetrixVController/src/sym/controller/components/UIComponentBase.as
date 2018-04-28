package sym.controller.components
{
    import mx.core.UIComponent;
    
    import sym.objectmodel.common.ComponentBase;
    
    /**
    * UIComponent which hold associated ComponentBase instance 
    */
    public class UIComponentBase extends UIComponent
    {
        private var _cb:ComponentBase;
        private var _selected:Boolean = false;
        
        public function UIComponentBase(componentBase:ComponentBase)
        {
            super();
            _cb = componentBase;
        }
        
        /**
        * returns instance of associated component base
        */
        public function get componentBase():ComponentBase{
            return _cb;
        }
        
        public function get selected():Boolean {
            return _selected;
        }

        public function set selected(value:Boolean):void {
            _selected = value;
        }
    }
}