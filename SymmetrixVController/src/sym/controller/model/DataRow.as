package sym.controller.model
{
    import mx.collections.ArrayCollection;

    [Bindable]
    public class DataRow
    {
        private var _columns:int;
        private var _row:ArrayCollection = new ArrayCollection();
        
        public function DataRow(cols:int)
        {
            super();
            _columns = cols;
            for(var i:int = 0; i < _columns; i++){
                _row.addItem(null);
            }
        }
        
        
        public function get columns():int{
            return _columns;
        }
        
        public function get data():ArrayCollection{
            return _row;
        }
        
        /**
        * appends new item
        */
        public function addItemAt(value:Object, index:int):void{
            if(index >= _columns){
                return; // do not add items over limit
            }
            
            _row[index] = value;
        }
    }
}