package sym.objectmodel.driveUtils
{
	import flash.utils.Dictionary;
	
	/**
	 * Store drive mix information
	 */	
	public dynamic class DictionaryExt extends Dictionary
	{
		public function DictionaryExt(weakKeys:Boolean = false)
		{
			super(weakKeys);
		}
		
		public function get keys():Array
		{
			var keyArray:Array = [];
			
			for (var key:Object in this)
			{
				keyArray.push(key);
			}
			
			return keyArray;
		}
		
		public function get values():Array
		{
			var valueArray:Array = [];
			
			for each(var key:Object in keys)
			{
				valueArray.push(this[key]);					
			}
			
			return valueArray;
		}
		
		public function containsKey(key:Object):Boolean
		{
			return keys.indexOf(key) > -1;
		}
		
		public function containsValue(value:Object):Boolean
		{
			return values.indexOf(value) > -1;
		}
	}
}