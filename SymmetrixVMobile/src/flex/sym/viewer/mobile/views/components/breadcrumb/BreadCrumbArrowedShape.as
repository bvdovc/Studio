package sym.viewer.mobile.views.components.breadcrumb
{
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import mx.core.UIComponent;
	
	import spark.components.BorderContainer;

    /**
    * draws arrow shaped breadcrumb item background
    */
	public class BreadCrumbArrowedShape extends UIComponent
	{
		private var _arrowSharpness:int=0;
        private var _colorIndex:int = 0;
		private var _isStarting:Boolean=false;
        private var _colors:Array = null;
        
        //gradient colors used for items starting from home respectivelly
        private const gradients:Array = [[0xFFFFFF, 0xFFFFFF], 
                                         [0x77CBF8, 0x49A1E0], 
                                         [0x80B7DE, 0x547C9F], 
                                         [0x46A2E1, 0x187CB7],
                                         [0x187CB7, 0x1279B3],
                                         [0x818B94, 0x565D6D], 
                                         [0x77CBF8, 0x49A1E0], 
                                         [0x80B7DE, 0x547C9F], 
                                         [0x46A2E1, 0x187CB7]];

		public function BreadCrumbArrowedShape()
		{
		}
        
        public function set colors(gradientColors:Array):void{
            _colors = gradientColors;
        }
        
        /**
        * arrow shaprness values
        */
		[Inspectable(enumeration="0,1,2,3,4")]
		public function set arrowSharpness(value:int):void
		{
			_arrowSharpness=value;
			invalidateDisplayList();
		}

		public function get arrowSharpness():int
		{
			return _arrowSharpness;
		}

        /**
        * if this is starting (home) item
        */
		public function set isStartingLink(value:Boolean):void
		{
			_isStarting=value;
			dispatchEvent(new Event("startLinkChanged"));
		}

		[Bindable("startLinkChanged")]
		public function get isStartingLink():Boolean
		{
			return _isStarting;
		}
        
        /**
        * sets index of color (order number of item in list)
        */
        public function set colorIndex(value:int):void
        {
            _colorIndex =value;
            dispatchEvent(new Event("colorIndexChanged"));
        }
        
        [Bindable("colorIndexChanged")]
        public function get colorIndex():int
        {
            return _colorIndex;
        }

		protected override function initializationComplete():void
		{
			super.initializationComplete();
			minHeight=20;
		}
        
        /**
        * draws arrow shape with gradient background
        */
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			const w:Number=unscaledWidth;
			const h:Number=unscaledHeight;
			const offset:Number=2 * _arrowSharpness;
            var matrix:Matrix = new  Matrix();
            matrix.createGradientBox(unscaledWidth, unscaledHeight, 90);
            
            graphics.clear(); 
            
            graphics.beginGradientFill(GradientType.LINEAR, _colors? _colors : gradients[colorIndex],null, null, matrix);
			graphics.moveTo(0, 0);
			graphics.lineTo(w, 0);
			graphics.lineTo(w + offset, h / 2);
			graphics.lineTo(w, h);
			graphics.lineTo(0, h);
			if (!_isStarting)
				graphics.lineTo(offset, h / 2);
			graphics.lineTo(0, 0);
			graphics.endFill();
			super.updateDisplayList(unscaledWidth, unscaledHeight);
            
		}
	}
}
