package sym.objectmodel.utils
{
	import spark.formatters.NumberFormatter;
	
	/**
	 * Usable capacity custom number formatter
	 * @author nmilic
	 * 
	 */	
	public class CapacityNumberFormatter extends NumberFormatter
	{
		public function CapacityNumberFormatter()
		{
			super();
			
			this.decimalSeparator = ".";
			this.fractionalDigits = 1;
			this.leadingZero = true;
			this.trailingZeros = false;
			this.useGrouping = true;
		}
		
	}
}