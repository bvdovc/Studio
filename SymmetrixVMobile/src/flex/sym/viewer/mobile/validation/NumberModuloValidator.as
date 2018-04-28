package sym.viewer.mobile.validation
{
    import mx.validators.ValidationResult;
    import mx.validators.Validator;
    
    /** 
     * Drive count validator (modulo validation)
     */    
    public class NumberModuloValidator extends Validator
    {
        public static const ERROR_CODE:String = "Int_Modulo_Error";
        private var results:Array;  //validation results
        
        [Bindable]
        public var errorMessage:String;
        
        [Bindable]
        public var modulo:int;
        
        public function NumberModuloValidator() {
            super();
        }
        
        /**
         * Does validation 
         * @param value
         * @return 
         * 
         */        
        override protected function doValidation(value:Object):Array 
        {
            var inputValue:int = int(value);
            
            results = [];
            
            results = super.doValidation(value);        

            if (results.length > 0)
            {
                return results;
            }
           
            if (inputValue <= 0 || (inputValue % modulo) != 0) 
            {
                results.push(new ValidationResult(true, null, ERROR_CODE, errorMessage));
                return results;
            }
            
            return results;
        }
    }
}