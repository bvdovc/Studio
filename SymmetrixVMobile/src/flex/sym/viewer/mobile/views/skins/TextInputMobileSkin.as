package sym.viewer.mobile.views.skins
{
	import flash.display.GradientType;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.geom.Matrix;
	
	import spark.components.TextInput;
	import spark.skins.mobile.TextInputSkin;
	
	import sym.viewer.mobile.utils.CommonUtility;
	public class TextInputMobileSkin extends TextInputSkin
	{
		private static const fillType:String = GradientType.LINEAR;
		private static const colors:Array = [0x4682B4, 0x3E95CF]; 
		private static const alphas:Array = [1, 1]; 
		private static const ratios:Array = [127, 255]; 
		
		public function TextInputMobileSkin()
		{
			super();
			layoutCornerEllipseSize = 15;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if (CommonUtility.getOS() == CommonUtility.IOS || CommonUtility.getOS() == CommonUtility.ANDROID)
			{
				hostComponent.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, onSoftKeyboardActivating);
				hostComponent.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onSoftKeyboardDeactivate);
				hostComponent.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);				
				this.stage.addEventListener(MouseEvent.CLICK, stageClickHandler);
			}
		}
		
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var borderSize:uint = (border) ? layoutBorderSize : 0;
			var borderWidth:uint = borderSize * 2;
			
			// Draw the contentBackground
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(unscaledWidth - borderWidth, unscaledHeight - borderWidth, Math.PI/2);
			graphics.beginGradientFill(fillType, colors, alphas, ratios, matrix);
			graphics.drawRoundRect(borderSize, borderSize, unscaledWidth - borderWidth, unscaledHeight - borderWidth, layoutCornerEllipseSize, layoutCornerEllipseSize);
			graphics.endFill();
		}
		
		override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.layoutContents(unscaledWidth, unscaledHeight);
			
			if (border)
			{
				border.alpha = 0;
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		protected function onSoftKeyboardActivating(event:SoftKeyboardEvent):void
		{
			textDisplay.setStyle("fontFamily", "Arial");
			textDisplay.commitStyles();
		}
		
		protected function onSoftKeyboardDeactivate(event:SoftKeyboardEvent):void
		{
			textDisplay.setStyle("fontFamily", "RobotoMobileFont");
			textDisplay.commitStyles();
		}
		
		/**
		 * Stage click handler<br/>
		 * If soft keyboard is raised textInput control loses focus and keyboard is closed  
		 * @param ev MouseEvent.CLICK
		 * 
		 */		
		private function stageClickHandler(ev:MouseEvent):void
		{
			var focus:Object = this.focusManager.getFocus();
			
			if (this.stage.softKeyboardRect && !this.stage.softKeyboardRect.isEmpty() 
				&& focus is TextInput)
			{
				this.stage.focus = null;
			}
		}
		
		/**
		 * Removes stage click handler when textInput control has been removed from the display list 
		 * @param ev
		 * 
		 */		
		private function removedFromStageHandler(ev:Event):void
		{
			if (this.stage.hasEventListener(MouseEvent.CLICK))
				this.stage.removeEventListener(MouseEvent.CLICK, stageClickHandler);
		}
	}
}