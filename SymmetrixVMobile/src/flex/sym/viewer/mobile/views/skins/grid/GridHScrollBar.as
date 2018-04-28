package sym.viewer.mobile.views.skins.grid
{
	import spark.components.HScrollBar;
	
	public class GridHScrollBar extends HScrollBar
	{
		// force the scroll bars to stay visible
		private var keepScrollBars:Boolean;
		
		public function GridHScrollBar() {
			// show the scrollbar at initial startup
			keepScrollBars = true;
		}
		
		
		override public function set alpha(value:Number):void {
			if (!keepScrollBars) 
				super.alpha = value;
		}
		
		override public function set visible(value:Boolean):void {
			if (!keepScrollBars)
				super.visible = value;
		}
		
		override public function set includeInLayout(value:Boolean):void {
			if (!keepScrollBars)
				super.includeInLayout = value;
		}
		
		override public function set scaleX(value:Number):void {
			if (!keepScrollBars)
				super.scaleX = value;
		}
		
		override public function set scaleY(value:Number):void {
			if (!keepScrollBars)
				super.scaleY = value;
		} 
		
		override protected function childrenCreated():void{
			setStyle("skinClass", GridHScrollBarSkin);
			super.childrenCreated(); 
		}
	}
}