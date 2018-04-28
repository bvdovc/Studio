package sym.controller.model
{
    import mx.collections.ArrayCollection;

    [Bindable]
    public class DataTable
    {
        private var _columns:int;
        private var _rowCollection:ArrayCollection = new ArrayCollection();
        
        public function DataTable(columns:int = 1)
        {
            _columns = columns;
        }
        
        public function get columns():int{
            return _columns;
        }
        
        public function get rows():int{
            return _rowCollection.length;
        }
        
        public function get data():ArrayCollection{
            return _rowCollection;
        }
        
        /**
        * creates and appends data row
        * @returns created DataRow instance
        */
        public function createRow():DataRow{
            var dataRow:DataRow = new DataRow(_columns);
            _rowCollection.addItem(dataRow);
            return dataRow;
        }
        
        /**
        * appends data row
        */
        public function appendRow(dataRow:DataRow):void{
            _rowCollection.addItem(dataRow);
        }
        
        /**
        * adds item
        */
        public function addItemAt(item:Object, row:int, column:int):void{
            if(row >= rows || row < 0){
                return;  //ignore, incorrect row index
            }
            if(column >= _columns || column < 0){
                return; //ignore, incorrect column index
            }
            
            (_rowCollection[row] as DataRow).addItemAt(item, column);
        }
    }
}