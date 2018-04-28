package sym.controller.model
{
    import mx.collections.ArrayCollection;
    import mx.utils.StringUtil;

    [Bindable]
    public class PropertyItem
    {
        private var _hasHeading:Boolean = false;
        private var _hasParagraph:Boolean = false;
        private var _hasTable:Boolean = false;
        private var _hasBullets:Boolean = false;
        private var _hasImage:Boolean = false;
        private var _imageRatio:Number = NaN;
        private var _imageHeight:Number = NaN;
        
        private var _heading:String = null;
        private var _paragraph:String = null;
        private var _bullets:ArrayCollection = null;
        private var _table:DataTable = null;
        private var _image:String = null;
        
        public function get imageHeight():Number
        {
            return _imageHeight;
        }

        public function set imageHeight(value:Number):void
        {
            _imageHeight = value;
        }

        public function set heading(value:String):void{
            if(!value || StringUtil.trim(value).length == 0){
                _hasHeading = false;
                _heading = null;
                return;
            }
            _hasHeading = true;
            _heading = value;
        }
        
        public function set paragraph(value:String):void{
            if(!value || StringUtil.trim(value).length == 0){
                _hasParagraph = false;
                _paragraph = null;
                return;
            }
            _hasParagraph = true;
            _paragraph = value;
        }
        
        public function set table(value:DataTable):void{
            _hasTable = false;
            if(value){
                _hasTable = true;
                _table = value;
            }
        }
        
        public function set bullets(value:ArrayCollection):void{
            _hasBullets = false;
            if(value){
                _hasBullets = true;
                _bullets = value;
            }
        }
        
        public function set image(value:String):void
        {
            _hasImage = false;
            if(value)
            {
                _hasImage = true;
                _image = value;
            }
        }
        
        public function set imageRatio(value:Number):void
        {
            _imageRatio = value;
        }
        
        public function get heading():String{
            return _heading;
        }
        
        public function get paragraph():String{
            return _paragraph;
        }
        
        public function get table():DataTable{
            return _table;
        }
        
        public function get bullets():ArrayCollection{
            return _bullets;
        }
        
        public function get image():String{
            return _image;
        }
        
        public function get imageRatio():Number
        {
            return _imageRatio;
        }
        
        public function get hasHeading():Boolean{
            return _hasHeading;
        }
        
        public function get hasParagraph():Boolean{
            return _hasParagraph;
        }
        
        public function get hasTable():Boolean{
            return _hasTable;
        }
        
        public function get  hasBullets():Boolean{
            return _hasBullets;
        }
        
        public function get hasImage():Boolean{
            return _hasImage;
        }
    }
}