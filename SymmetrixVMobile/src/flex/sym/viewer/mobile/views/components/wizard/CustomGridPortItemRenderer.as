package sym.viewer.mobile.views.components.wizard
{
	import flash.events.MouseEvent;
	
	import spark.skins.spark.DefaultGridItemRenderer;
	
	import sym.viewer.mobile.views.skins.grid.WizardDataGridSkin;
	
	
	/**
	 * 
	 * Custom Grid Item Renderer used to disable specific rows in DataGrid.</br>
	 * User should specifies which custom item renderer to use via item renderer function.
	 * 
	 */
	public class CustomGridPortItemRenderer extends DefaultGridItemRenderer
	{
		public function CustomGridPortItemRenderer()
		{
			super();
			
			this.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
		}
		
		/**
		 * MouseEvent Click handler fot item renderer. <br/>
		 * Sets grid selection color to gray/disabled color
		 * @param ev indicates MouseEvent.Click event type
		 * 
		 */			
		private function onClick(ev:MouseEvent):void
		{
//			ev.preventDefault();
//			ev.stopImmediatePropagation();
			
			this.grid.dataGrid.setStyle("selectionColor", WizardDataGridSkin.disabledSelectionColor);
		}
		
		/**
		 * MouseEvent Over handler fot item renderer. <br/>
		 * Sets grid rollOver color to gray/disabled color 
		 * @param ev indicates MouseEvent.Click event type
		 * 
		 */		
		private function onOver(ev:MouseEvent):void
		{
			this.grid.dataGrid.setStyle("rollOverColor", WizardDataGridSkin.disabledSelectionColor);
		}

		/**
		 * @private
		 *
		 * Sets row text color to disabled color - grayed out
		 * 
		 */
		override public function set data(value:Object):void
		{
			super.data = value;
			// the data has changed.  push these changes down in to the 
			// subcomponents here  
			
			if (this.data)
			{
				this.setStyle("color", this.getStyle("disabledColor"));
			}
		}
		
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			
			this.grid.dataGrid.mouseChildren = value;
		}
		
	}
}