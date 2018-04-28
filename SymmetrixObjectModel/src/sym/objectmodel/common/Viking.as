package sym.objectmodel.common
{
	public class Viking extends DAE
	{
		public static const SIZE:Size = new Size(Size.USIZE, 3);
		
		public function Viking(position:Position, parentEngine:int)
		{
			super("viking", position, SIZE, DAE.Viking, parentEngine);
		}
		
		public override function get daeName():String
		{
			return VIKING_NAME;
		}
	}
}