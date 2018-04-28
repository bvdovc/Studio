package sym.configurationmodel.utils
{
    /**
     * Integer utilities 
     */
    public class IntUtil
    {
        /**
         * Returns minimum between given numbers 
         * @param value1
         * @param value2
         * @return 
         * 
         */        
        public static function min(value1:int, value2:int):int
        {
            return value1 <= value2 ? value1 : value2;
        }
        
        /**
         * Returns maximum between given numbers 
         * @param value1
         * @param value2
         * @return 
         * 
         */    
        public static function max(value1:int, value2:int):int
        {
            return value1 >= value2 ? value1 : value2;
        }
        
        /**
         * Creates sequence of integers between given numbers 
         * @param from
         * @param to
         * @return Array
         * 
         */        
        public static function sequence(from:int, to:int):Array
        {
            var values:Array = [];
            for(var i:int = from; i < to + 1; i++)
            {
                values.push(i);
            }
            return values;
        }
        
        /**
         * Finds index of minimal value 
         * @param values Array of numbers (integers)
         * @return index of minimal number
         */        
        public static function minValueIndex(values:Array):int
        {
            if(!values || values.length == 0) return -1;
            
            var index:int = 0;
            
            for(var ind:int = 1; ind < values.length; ind++)
            {
                if(values[ind] < values[index])
                {
                    index = ind;
                }
            }
            
            return index;
        }
        
        /**
         * Finds index of maximal value 
         * @param values Array of numbers (integers)
         * @return index of maximal number
         */        
        public static function maxValueIndex(values:Array):int
        {
            if(!values || values.length == 0) return -1;
            
            var index:int = 0;
            
            for(var ind:int = 1; ind < values.length; ind++)
            {
                if(values[ind] > values[index])
                {
                    index = ind;
                }
            }
            
            return index;
        }
    }
}