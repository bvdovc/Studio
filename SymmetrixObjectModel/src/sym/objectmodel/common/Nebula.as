package sym.objectmodel.common
{
	public class Nebula extends DAE
	{
		public static const SIZE:Size = new Size(Size.USIZE, 2);
		
		public function Nebula(position:Position, parentEngine:int)
		{
			super("nebula", position, SIZE, DAE.Nebula, parentEngine);
		}
		
		public override function get daeName():String
		{
			return NEBULA_NAME;
		}
	}
}