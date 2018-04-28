package sym.controller.utils
{
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    
    import sym.controller.SymmController;
    import sym.objectmodel.common.Bay;
    import sym.objectmodel.common.ComponentBase;
    import sym.objectmodel.common.ControlStation;
    import sym.objectmodel.common.D15;
    import sym.objectmodel.common.DAE;
    import sym.objectmodel.common.Drive;
    import sym.objectmodel.common.EnginePort;
    import sym.objectmodel.common.EthernetSwitch;
    import sym.objectmodel.common.InfinibandSwitch;
    import sym.objectmodel.common.KVM;
    import sym.objectmodel.common.SPS;
    import sym.objectmodel.common.Server;
    import sym.objectmodel.common.UPS;
    import sym.objectmodel.common.Vanguard;
    import sym.objectmodel.common.Viking;
    import sym.objectmodel.common.Voyager;
    import sym.objectmodel.common.Worktray;
    
    public class DrawingRenderer implements IRenderer
    {
        public static const BORDER_COLOR:uint = 0x000000;
        private static const BAY_MASK_COLOR:uint = 0x161618;
        public static const SELECTION_BOX_COLOR:uint = 0x007DB8;
        public static const OVERLAY_COMPONENT_SELECTION_BOX_COLOR:uint = 0xFFD220;
        public static const SELECTION_BOX_WEIGHT:uint = 10;
        public static const OVERLAY_COMPONENT_SELECTION_BOX_WEIGHT:uint = 8;
        private static const DISPERSED_CONNECTION_COLOR:uint = 0x000000;
        private static const FILL_COLOR:uint = 0x00FF00;
        private static const EMPTY_FILL_COLOR:uint = 0xdddddd; 
        private static const COMPONENT_COMMON_COLOR:uint = 0xfefefe;
        private static const ENGINE_COLORS:Object = {0: EMPTY_FILL_COLOR, 8: 0xffffff, 7: 0xea3338, 6: 0x0098db, 5: 0xa9cf46, 4: 0xffcc2a, 3: 0xf58634, 2: 0x9818c7, 1: 0xfa5a9a};
		private static const HIGHLIGHTING_COLORS_AFA_PM: Object = {0: EMPTY_FILL_COLOR, 8: 0x34A2EB, 7: 0xE7713B, 6: 0x10007D, 5: 0xFF6000, 4: 0xF3F312, 3: 0xA800D9, 2: 0x009D02, 1: 0xFF0000};
        private static const DRIVE_TYPE_COLORS:Object = {0: EMPTY_FILL_COLOR, 4: 0x990000, 3: 0xCCFFCC, 2: 0xCCFFCC, 1: 0xFFCC00};
        private static const KVM_COLOR:uint = 0x880000;
        private static const UPS_COLOR:uint = 0x008800;
        private static const CONTROL_STATION_COLOR:uint = 0xBF7794;
        private static const SERVER_COLOR:uint = 0x000088;
        private static const MIBE_COLOR:uint = 0x008888;
        private static const SPS_COLOR:uint = 0x888800;
        private static const IB_COLOR:uint = 0x1E9821;
        private static const WORKTRAY_COLOR:uint = 0xFFFF99;
        private static const ETHERNET_SWITCH_COLOR:uint = 0x778899;
        private static const BACKGROUND_COLOR:uint = 0xbcbcbd;
		
        private var _renderEngineDAEConnections:Boolean = false;

        public function DrawingRenderer()
        {
        }
        
        /**
         * Renders as drawing. 
         * @param view
         * @param component
         * @param parentBitmapData
         * @param position
         * 
         */
        public function render(view:String, component:ComponentBase, parentBitmapData:BitmapData, position:Rectangle):void
        {
            var sprite:Sprite = new Sprite();
            sprite.graphics.beginFill(getComponentColor(component), 1);
            sprite.graphics.drawRect(0, 0, position.width - 1, position.height - 1);
            sprite.graphics.endFill();
            
            sprite.graphics.lineStyle(5, BORDER_COLOR);
            sprite.graphics.drawRect(0, 0, sprite.width, sprite.height);
            
            var matrix:Matrix = new Matrix();
            matrix.translate(position.x, position.y);
            parentBitmapData.draw(sprite, matrix, null, null, null, true);
        }
        
        /**
         * Put some space when drawing. 
         * @return 
         * 
         */
        public function get baySpace():int {
            return 20;
        }
        
        /**
         * Draw dispersed connecting line. 
         * @param bData
         * @param position
         * 
         */
        public function drawDispersedConnectingLine(bData:BitmapData, position:Rectangle):void {
            var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(BACKGROUND_COLOR);
			sprite.graphics.drawRect(0, 0, position.width, position.height);
			sprite.graphics.endFill();
			
            const lineThickness:Number = 30;
            sprite.graphics.lineStyle(lineThickness, DISPERSED_CONNECTION_COLOR);
            sprite.graphics.moveTo(0, 0);
            sprite.graphics.lineTo(0, position.height);
            sprite.graphics.lineTo(position.width, position.height);
            sprite.graphics.lineTo(position.width, 0);
            bData.draw(sprite, null, null, null, null, true);
        }
        
        /**
         * draws election box on sprite 
         * @param sprite
         * 
         */
        public function drawSelectionBox(sprite:Sprite, position:Rectangle):void {
            sprite.graphics.clear();
            sprite.graphics.lineStyle(SELECTION_BOX_WEIGHT, SELECTION_BOX_COLOR);
            sprite.graphics.drawRect(
                position.x + SELECTION_BOX_WEIGHT/2,
                position.y + SELECTION_BOX_WEIGHT/2,
                position.width - SELECTION_BOX_WEIGHT,
                position.height - SELECTION_BOX_WEIGHT);
        }
        
        /**
         * Draws mask on top of bay. 
         * @param bData
         * @param position
         * 
         */
        public function drawBayMask(bData:BitmapData, position:Rectangle):void {
            var sprite:Sprite = new Sprite();
            sprite.graphics.beginFill(BAY_MASK_COLOR, 1);
            sprite.graphics.drawRect(0, 0, position.width, position.height);
            sprite.graphics.endFill();
            
            var matrix:Matrix = new Matrix();
            matrix.translate(position.x, position.y);
            bData.draw(sprite, matrix, null, null, null, true);
        }
        
        public function set renderEngineDAEConnections(value:Boolean):void {
            _renderEngineDAEConnections = value;
        }

        public function set realistic(value:Boolean):void {
            // does nothing
        }

        /**
         * Color to draw with. 
         * @param component
		 * @param twoColorComponent 
         * @return 
         * 
         */
        public function getComponentColor(component:ComponentBase, twoColorComponent:Boolean = false):uint {
            
            if (component is Bay) {
                return EMPTY_FILL_COLOR;
            }
			         
            if (component.isDAE )
            {
				if(SymmController.instance.isAFA()|| SymmController.instance.isPM())
				{
					var i:int = (component as DAE).parentEngine;
					if(twoColorComponent)
						i += 1;
					return HIGHLIGHTING_COLORS_AFA_PM[i];
				}
				return ENGINE_COLORS[(component as DAE).parentEngine];
            }
			if (component is Drive)
			{ 
				var drive:Drive = component as Drive;
				return DRIVE_TYPE_COLORS[drive.isSpare ? 0 : drive.type];
			}
            
            if (component.isEngine){
				if(SymmController.instance.isAFA()|| SymmController.instance.isPM())
                	return HIGHLIGHTING_COLORS_AFA_PM[component.id];
				return ENGINE_COLORS[component.id];
            }
            if (component is KVM) {
                return KVM_COLOR;
            }
            if (component is Server) {
                return SERVER_COLOR;
            }
            if (component is UPS) {
                return UPS_COLOR;
            }
			if (component is ControlStation) {
				return CONTROL_STATION_COLOR;
			}
                
            if (component.id.indexOf("mibe") > -1) {
                return MIBE_COLOR;
            }
            if (component is SPS && (SymmController.instance.isAFA()|| SymmController.instance.isPM()))
            {
                if((component as SPS).parentEngine > -1)
                {
                     return HIGHLIGHTING_COLORS_AFA_PM[(component as SPS).parentEngine];   
                }
                else
                {
                    return IB_COLOR;
                }
            }
            if (component.id.indexOf("sps") > -1)
            {
                return SPS_COLOR;
            }
			if (component is InfinibandSwitch)
			{
				return IB_COLOR;
			}
			if (component is Worktray)
			{
				return WORKTRAY_COLOR;
			}
			if (component is EthernetSwitch)
			{
				return ETHERNET_SWITCH_COLOR;
			}
            
            return EMPTY_FILL_COLOR;
        }
    }
}