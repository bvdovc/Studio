package sym.objectmodel.common
{
	public class Tabasco extends DAE
	{
		public static const SIZE:Size = new Size(Size.USIZE, 2);
		
		public function Tabasco(position:Position, parentEngine:int)
		{
			super("tabasco", position, SIZE, DAE.Tabasco, parentEngine);
		}
		
		public override function get daeName():String
		{
			return TABASCO_NAME;
		}
	}
}