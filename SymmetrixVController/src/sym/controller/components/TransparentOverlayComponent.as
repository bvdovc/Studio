package sym.controller.components
{
	import flash.events.MouseEvent;
	
	import mx.events.ToolTipEvent;
	
	import spark.components.BorderContainer;
	
	import sym.controller.SymmController;
	import sym.controller.events.ToolTipCustomEvent;
	import sym.controller.utils.DrawingRenderer;
	import sym.objectmodel.common.ComponentBase;
	
	/**
	 * represents transparent, overlay components like led indicators, ports, etc.
	 * which overlays on components like Engines, SPS, DAE, MIBE, UPS, Server
	 * 
	 */	
	public class TransparentOverlayComponent extends BorderContainer
	{
		private var _type:int = 0;
		private var _rearView:Boolean = false;
		private var _display:String;
		private var _order:int = -1;
		private var _cb:ComponentBase;
		
		public function TransparentOverlayComponent(type:int, sortOrder:int = -1, rearView:Boolean = false, display:String = null, hasBorder:Boolean = true) {
			super();
			_type = type;
			_rearView = rearView;
			_display = display;
			_order = sortOrder;
			if(hasBorder){
				setStyle("backgroundAlpha", 0);
				setStyle("borderColor", DrawingRenderer.OVERLAY_COMPONENT_SELECTION_BOX_COLOR);
				setStyle("borderWeight", DrawingRenderer.OVERLAY_COMPONENT_SELECTION_BOX_WEIGHT);
				setStyle("borderVisible", false);
			}
			else
			{
				setStyle("backgroundAlpha", 0);
			}
			addEventListeners();
		}
		
		public function get type():int 
		{
			return _type;
		}
		
		public function get rearView():Boolean
		{
			return _rearView;
		}
		
		public function get display():String
		{
			return _display;
		}
		
		public function get order():int
		{
			return _order;
		}
		
		private function overHandler(event:MouseEvent):void {
			SymmController.instance.eventHandler.dispatchEvent(new ToolTipCustomEvent(ToolTipCustomEvent.START_TOOLTIP, event.currentTarget));
		}
		
		private function outHandler(event:MouseEvent):void {
			setStyle("borderVisible", false);
			SymmController.instance.eventHandler.dispatchEvent(new ToolTipCustomEvent(ToolTipCustomEvent.HIDE_TOOLTIP, event.currentTarget));
		}
		
		private function clickHandler(ev:MouseEvent):void{
			SymmController.instance.eventHandler.dispatchEvent(new ToolTipCustomEvent(ToolTipCustomEvent.SHOW_TOOLTIP, ev.currentTarget));
		}
		
		private function toolTipShownHandler(ev:ToolTipEvent):void{
			SymmController.instance.eventHandler.dispatchEvent(ev);
		}
		
		/**
		 * Generates overlay component's position and size
		 * @param x overlay component's horizontal position
		 * @param y overlay component's vertical position
		 * @param width overlay component's width
		 * @param height overlay component's height
		 * 
		 */		
		public function generateOverlayPosition(x:Number, y:Number, width:Number, height:Number):void {
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
		
		public function addEventListeners():void
		{
			if (!this.hasEventListener(MouseEvent.MOUSE_OVER))
			{
				this.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			}
			if (!this.hasEventListener(MouseEvent.MOUSE_OUT))
			{
				this.addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			}
			if (!this.hasEventListener(MouseEvent.CLICK))
			{
				this.addEventListener(MouseEvent.CLICK, clickHandler);
			}
			if (!this.hasEventListener(ToolTipEvent.TOOL_TIP_SHOWN))
			{
				this.addEventListener(ToolTipEvent.TOOL_TIP_SHOWN, toolTipShownHandler);
			}
		}
		
		public function removeEventListeners():void
		{
			if (this.hasEventListener(MouseEvent.MOUSE_OVER))
			{
				this.removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			}
			if (this.hasEventListener(MouseEvent.MOUSE_OUT))
			{
				this.removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
			}
			if (this.hasEventListener(MouseEvent.CLICK))
			{
				this.removeEventListener(MouseEvent.CLICK, clickHandler);
			}
		}
	}
}