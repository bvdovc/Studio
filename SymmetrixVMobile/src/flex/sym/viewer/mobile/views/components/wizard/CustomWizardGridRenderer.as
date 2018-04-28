package sym.viewer.mobile.views.components.wizard
{
	import flash.events.MouseEvent;
	
	import spark.skins.spark.DefaultGridItemRenderer;
	
	import sym.viewer.mobile.views.skins.grid.WizardDataGridSkin;
	
	
	/**
	 * 
	 * Custom Item Renderer used for standard items/rows in wizard DataGrid.</br>
	 * User should specifies which custom item renderer to use via item renderer function.
	 * 
	 */
	public class CustomWizardGridRenderer extends DefaultGridItemRenderer
	{
		public function CustomWizardGridRenderer()
		{
			super();
			
			this.addEventListener(MouseEvent.MOUSE_OVER, onItemOver);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onItemClick);
		}
		
		/**
		 * MouseEvent Over handler fot item renderer. <br/>
		 * Sets grid rollOver color to default rollOver color
		 * @param ev indicates MouseEvent.Click event type
		 * 
		 */		
		private function onItemOver(ev:MouseEvent):void
		{
			this.grid.dataGrid.setStyle("rollOverColor", WizardDataGridSkin.defaultRollOverColor);
		}

		/**
		 * MouseEvent Click handler fot item renderer. <br/>
		 * Sets grid selection color to default selection color
		 * @param ev indicates MouseEvent.Click event type
		 * 
		 */		
		private function onItemClick(ev:MouseEvent):void
		{
			this.grid.dataGrid.setStyle("selectionColor", WizardDataGridSkin.defaultSelectionColor);
		}
		
		/**
		 * @private
		 *
		 * Override this setter to respond to data changes
		 */
		override public function set data(value:Object):void
		{
			super.data = value;
			// the data has changed.  push these changes down in to the 
			// subcomponents here    		
		} 
		
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			
			this.grid.dataGrid.mouseChildren = value;
		}
		
	}
}