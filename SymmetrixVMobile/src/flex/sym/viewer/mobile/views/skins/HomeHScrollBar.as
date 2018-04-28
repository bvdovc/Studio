package sym.viewer.mobile.views.skins
{
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import mx.events.EffectEvent;
    
    import spark.components.HScrollBar;
    import spark.effects.Animate;
    import spark.effects.animation.MotionPath;
    import spark.effects.animation.SimpleMotionPath;
    
    /**
     * A subclass of HScrollBar for use in a Scroller with interactionMode="touch"
     * where the scrollbar will be shown at startup and then fade away after a 
     * short period of time.
     */
    public class HomeHScrollBar extends HScrollBar
    {
        // force the scroll bars to stay visible
        private var keepScrollBars:Boolean;
        
        public function HomeHScrollBar() {
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
    }
}