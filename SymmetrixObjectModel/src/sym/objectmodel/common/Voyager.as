package sym.objectmodel.common
{
	public class Voyager extends DAE
	{
		public static const SIZE:Size = new Size(Size.USIZE, 4);
		
		public function Voyager(position:Position, parentEngine:int)
		{
			super("voyager", position, SIZE, DAE.Voyager, parentEngine);
		}
		
		public override function get daeName():String
		{
			return VOYAGER_NAME;
		}
	}
}