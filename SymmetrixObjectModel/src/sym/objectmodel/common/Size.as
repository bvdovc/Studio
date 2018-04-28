package sym.objectmodel.common
{
	public class Size
	{
		public static const USIZE:int = 0;
		
		protected var _type:int;
		protected var _height:Number;
		
		public function Size(type:int, size:Number)
		{
			_type = type;
			if (type == USIZE) {
				_height = size;
			}
		}
		
		public function get type():int {
			return _type;
		}
		
		public function get height():Number {
			return _height;
		}
	}
}