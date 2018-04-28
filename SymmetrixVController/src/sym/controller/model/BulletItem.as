package sym.controller.model
{
    [Bindable]
    public class BulletItem
    {
        private var _indent:int;
        private var _value:String;
        
        public function BulletItem(value:String, indent:int = 0)
        {
            _indent = indent;
            _value = value;
        }
        
        public function get indent():int{
            return _indent;
        }
        
        public function get value():String{
            return _value;
        }
    }
}