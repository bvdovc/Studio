package sym.controller.utils
{
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.ui.Keyboard;
    
    import mx.collections.ArrayCollection;
    import mx.core.UIComponent;
    import mx.effects.easing.Back;
    import mx.events.ToolTipEvent;
    import mx.resources.ResourceManager;
    import mx.utils.StringUtil;
    
    import spark.components.Image;
    
    import sym.controller.SymmController;
    import sym.controller.components.TransparentOverlayComponent;
    import sym.controller.components.UIComponentBase;
    import sym.objectmodel.common.Bay;
    import sym.objectmodel.common.ComponentBase;
    import sym.objectmodel.common.Configuration;
    import sym.objectmodel.common.Configuration_VG3R;
    import sym.objectmodel.common.Constants;
    import sym.objectmodel.common.ControlStation;
    import sym.objectmodel.common.D15;
    import sym.objectmodel.common.DAE;
    import sym.objectmodel.common.DataMover;
    import sym.objectmodel.common.Drive;
    import sym.objectmodel.common.Engine;
    import sym.objectmodel.common.EnginePort;
    import sym.objectmodel.common.InfinibandSwitch;
    import sym.objectmodel.common.KVM;
    import sym.objectmodel.common.MIBE;
    import sym.objectmodel.common.Nebula;
    import sym.objectmodel.common.PDP;
    import sym.objectmodel.common.PDU;
    import sym.objectmodel.common.PDU_VG3R;
    import sym.objectmodel.common.Position;
    import sym.objectmodel.common.SPS;
    import sym.objectmodel.common.Tabasco;
    import sym.objectmodel.common.TransparentOverlayConstants;
    import sym.objectmodel.common.UPS;
    import sym.objectmodel.common.Vanguard;
    import sym.objectmodel.common.Viking;
    import sym.objectmodel.common.Voyager;

    public class RenderUtility
    {
        private static const DEFAULT_STAGE_HEIGHT:int = 1500;
        private static const DEFAULT_COMPONENT_UHEIGHT:int = 150;
        private static const DEFAULT_COMPONENT_UWIDTH:int = 1550;
        private static const DISPERSED_CONNECTING_LINE_HEIGHT:int = 0.05 * DEFAULT_STAGE_HEIGHT;
        private static const DISPERSED_CONNECTING_LINE_START:int = 0.1 * DISPERSED_CONNECTING_LINE_HEIGHT;
        private static const SPS_HEIGHT:int = DEFAULT_STAGE_HEIGHT; 
        private static const SPS_WIDTH:int = 0.437 * SPS_HEIGHT; 
        private static const MOHAWK_HEIGHT:Number = DEFAULT_STAGE_HEIGHT;
        private static const MOHAWK_WIDTH:Number = 0.41 * MOHAWK_HEIGHT;
        private static const MOHAWK_ENCLOSURE_FRONT_RECT:Rectangle = new Rectangle(0.2 * MOHAWK_WIDTH, 0.040 * MOHAWK_HEIGHT, 0.605 * MOHAWK_WIDTH, 0.97 * MOHAWK_HEIGHT);
        private static const MOHAWK_ENCLOSURE_BACK_RECT:Rectangle = new Rectangle(0.2401 * MOHAWK_WIDTH, 0.0446 * MOHAWK_HEIGHT, 0.5479 * MOHAWK_WIDTH, 0.97 * MOHAWK_HEIGHT);
        private static const MOHAWK_ENCLOSURE_COUNT:int = 41;
        private static const TITAN_HEIGHT:Number = MOHAWK_HEIGHT;
        private static const TITAN_WIDTH:Number = 0.34 * TITAN_HEIGHT;
        private static const TITAN_ENCLOSURE_RECT:Rectangle = new Rectangle(0.133 * TITAN_WIDTH, 0.01866 * TITAN_HEIGHT, 0.743 * TITAN_WIDTH, 0.956 * TITAN_HEIGHT);
        private static const TITAN_ENCLOSURE_COUNT:int = 40;
        private static const BAY_SPACE:int = 20;
        private static const BAY_DISPERSED_SPACE:Number = TITAN_WIDTH;
        private static const LOWERHALFBAYVERTICAL_FRONT_OFFSET:Number = 0.487 * MOHAWK_HEIGHT;
		private static const DAE_ENCLOSURE_M_FAMILY_HEIGHT:Number = DEFAULT_COMPONENT_UHEIGHT * 1.5;
		private static const DAE_ENCLOSURE_M_FAMILY_WIDTH_PERCENT:Number = 0.8;
		private static const DAE_SIDE_VIEW_ENCLOSURE_WIDTH:Number = DEFAULT_COMPONENT_UWIDTH * 0.6;
		private static const VOYAGER_DRIVE_PERCENT_WIDTH:Number = 0.064;
		private static const VOYAGER_DRIVE_PERCENT_HEIGHT:Number = 0.1726;
		private static const VIKING_DRIVE_PERCENT_WIDTH:Number = 0.034;
		private static const VIKING_DRIVE_PERCENT_HEIGHT:Number = 0.1272;
		private static const DRIVE_HEIGHT:Number = DEFAULT_STAGE_HEIGHT;
		private static const DRIVE_WIDTH:Number = 0.2 * DRIVE_HEIGHT;
        
        private static const VOYAGER_TOP_OFFSET_PERCENT:Number = 0.018;
        private static const VOYAGER_LEFT_OFFSET_PERCENT:Number = 0.0446;
        private static const VOYAGER_DRIVE_GAP_PERCENT:Number = 0.00776;
        private static const VOYAGER_DRIVE_V_GAP_PERCENT:Number = 0.0039;

		private static const TABASCO_DRIVE_PERCENT_WIDTH:Number = 0.032;
		private static const TABASCO_DRIVE_PERCENT_HEIGHT:Number = 0.955;
		private static const TABASCO_LEFT_OFFSET_PERCENT:Number = 0.0392;
		private static const TABASCO_DRIVE_GAP_PERCENT:Number = 0.137;
		private static const TABASCO_DRIVE_Y_POS_PERCENT:Number = 0.029;
		private static const TABASCO_DRIVE_LEFT_SPLIT_PERCENT:Number = 0.122;
		private static const TABASCO_DRIVE_RIGHT_SPLIT_PERCENT:Number = 0.23;
        
        private static const VIKING_TOP_OFFSET_PERCENT:Number = 0.102;
        private static const VIKING_LEFT_OFFSET_PERCENT:Number = 0.04572;
        private static const VIKING_DRIVE_GAP_PERCENT:Number = 0.011;
        private static const VIKING_DRIVE_V_GAP_PERCENT:Number = 0.00711;
        private static const VIKING_VLINE_SPLIT_PERCENT:Number = 0.0117;
        
        private static const MOHAWK_VERTICAL_FRONT_DAEX:Number = 0.0765 * MOHAWK_WIDTH;
        private static const MOHAWK_VERTICAL_FRONT_DAEY:Number = 0.0133 * MOHAWK_HEIGHT;
        private static const MOHAWK_VERTICAL_FRONT_DAEWIDTH:Number = 0.166 * MOHAWK_WIDTH;
        private static const MOHAWK_VERTICAL_FRONT_DAEHEIGHT:Number = (DEFAULT_COMPONENT_UWIDTH/(3*DEFAULT_COMPONENT_UHEIGHT)) * MOHAWK_VERTICAL_FRONT_DAEWIDTH;
        private static const MOHAWK_VERTICAL_FRONT_DAEHSPACE:Number = 0.011 * MOHAWK_WIDTH;
        private static const MOHAWK_VERTICAL_FRONT_DEAVSPACE:Number = 0.007 * MOHAWK_HEIGHT;
        private static const MOHAWK_VERTICAL_FRONT_SPSSPACE:Number = 2*MOHAWK_VERTICAL_FRONT_DAEHSPACE + MOHAWK_VERTICAL_FRONT_SPS_WIDTH;
        
        private static const MOHAWK_VERTICAL_FRONT_DAE_ENCLOSURES:Array = [
            new Rectangle(MOHAWK_VERTICAL_FRONT_DAEX, MOHAWK_VERTICAL_FRONT_DAEY, MOHAWK_VERTICAL_FRONT_DAEWIDTH, MOHAWK_VERTICAL_FRONT_DAEHEIGHT),
            new Rectangle(MOHAWK_VERTICAL_FRONT_DAEX + MOHAWK_VERTICAL_FRONT_DAEWIDTH + MOHAWK_VERTICAL_FRONT_DAEHSPACE, MOHAWK_VERTICAL_FRONT_DAEY, MOHAWK_VERTICAL_FRONT_DAEWIDTH, MOHAWK_VERTICAL_FRONT_DAEHEIGHT),
            new Rectangle(MOHAWK_VERTICAL_FRONT_DAEX + 2*(MOHAWK_VERTICAL_FRONT_DAEWIDTH + MOHAWK_VERTICAL_FRONT_DAEHSPACE) + MOHAWK_VERTICAL_FRONT_SPSSPACE, MOHAWK_VERTICAL_FRONT_DAEY, MOHAWK_VERTICAL_FRONT_DAEWIDTH, MOHAWK_VERTICAL_FRONT_DAEHEIGHT),
            new Rectangle(MOHAWK_VERTICAL_FRONT_DAEX + 3*(MOHAWK_VERTICAL_FRONT_DAEWIDTH + MOHAWK_VERTICAL_FRONT_DAEHSPACE) + MOHAWK_VERTICAL_FRONT_SPSSPACE, MOHAWK_VERTICAL_FRONT_DAEY, MOHAWK_VERTICAL_FRONT_DAEWIDTH, MOHAWK_VERTICAL_FRONT_DAEHEIGHT),
            new Rectangle(MOHAWK_VERTICAL_FRONT_DAEX, MOHAWK_VERTICAL_FRONT_DAEY + MOHAWK_VERTICAL_FRONT_DEAVSPACE + MOHAWK_VERTICAL_FRONT_DAEHEIGHT, MOHAWK_VERTICAL_FRONT_DAEWIDTH, MOHAWK_VERTICAL_FRONT_DAEHEIGHT),
            new Rectangle(MOHAWK_VERTICAL_FRONT_DAEX + MOHAWK_VERTICAL_FRONT_DAEWIDTH + MOHAWK_VERTICAL_FRONT_DAEHSPACE, MOHAWK_VERTICAL_FRONT_DAEY + MOHAWK_VERTICAL_FRONT_DEAVSPACE + MOHAWK_VERTICAL_FRONT_DAEHEIGHT, MOHAWK_VERTICAL_FRONT_DAEWIDTH, MOHAWK_VERTICAL_FRONT_DAEHEIGHT),
            new Rectangle(MOHAWK_VERTICAL_FRONT_DAEX + 2*(MOHAWK_VERTICAL_FRONT_DAEWIDTH + MOHAWK_VERTICAL_FRONT_DAEHSPACE) + MOHAWK_VERTICAL_FRONT_SPSSPACE, MOHAWK_VERTICAL_FRONT_DAEY + MOHAWK_VERTICAL_FRONT_DEAVSPACE + MOHAWK_VERTICAL_FRONT_DAEHEIGHT, MOHAWK_VERTICAL_FRONT_DAEWIDTH, MOHAWK_VERTICAL_FRONT_DAEHEIGHT),
            new Rectangle(MOHAWK_VERTICAL_FRONT_DAEX + 3*(MOHAWK_VERTICAL_FRONT_DAEWIDTH + MOHAWK_VERTICAL_FRONT_DAEHSPACE) + MOHAWK_VERTICAL_FRONT_SPSSPACE, MOHAWK_VERTICAL_FRONT_DAEY + MOHAWK_VERTICAL_FRONT_DEAVSPACE + MOHAWK_VERTICAL_FRONT_DAEHEIGHT, MOHAWK_VERTICAL_FRONT_DAEWIDTH, MOHAWK_VERTICAL_FRONT_DAEHEIGHT),
        ];
        
        private static const MOHAWK_VERTICAL_FRONT_SPS_WIDTH:Number = 2/3 * MOHAWK_VERTICAL_FRONT_DAEWIDTH;
        private static const MOHAWK_VERTICAL_FRONT_SPS_HEIGHT:Number = MOHAWK_VERTICAL_FRONT_SPS_WIDTH/0.4;
        private static const MOHAWK_VERTICAL_FRONT_SPS_X:Number = MOHAWK_VERTICAL_FRONT_DAEX + 2*(MOHAWK_VERTICAL_FRONT_DAEWIDTH + MOHAWK_VERTICAL_FRONT_DAEHSPACE);
        private static const MOHAWK_VERTICAL_FRONT_SPS_Y:Number = MOHAWK_VERTICAL_FRONT_DAEY;
        private static const MOHAWK_VERTICAL_FRONT_SPS_VSPACE:Number = 0.008 * MOHAWK_HEIGHT;
        
        private static const MOHAWK_VERTICAL_FRONT_SPS_ENCLOSURES:Array = [
            new Rectangle(MOHAWK_VERTICAL_FRONT_SPS_X, MOHAWK_VERTICAL_FRONT_SPS_Y + 7*(MOHAWK_VERTICAL_FRONT_SPS_VSPACE + MOHAWK_VERTICAL_FRONT_SPS_HEIGHT), MOHAWK_VERTICAL_FRONT_SPS_WIDTH, MOHAWK_VERTICAL_FRONT_SPS_HEIGHT),
            new Rectangle(MOHAWK_VERTICAL_FRONT_SPS_X, MOHAWK_VERTICAL_FRONT_SPS_Y + 6*(MOHAWK_VERTICAL_FRONT_SPS_VSPACE + MOHAWK_VERTICAL_FRONT_SPS_HEIGHT), MOHAWK_VERTICAL_FRONT_SPS_WIDTH, MOHAWK_VERTICAL_FRONT_SPS_HEIGHT),
            new Rectangle(MOHAWK_VERTICAL_FRONT_SPS_X, MOHAWK_VERTICAL_FRONT_SPS_Y + 5*(MOHAWK_VERTICAL_FRONT_SPS_VSPACE + MOHAWK_VERTICAL_FRONT_SPS_HEIGHT), MOHAWK_VERTICAL_FRONT_SPS_WIDTH, MOHAWK_VERTICAL_FRONT_SPS_HEIGHT),
            new Rectangle(MOHAWK_VERTICAL_FRONT_SPS_X, MOHAWK_VERTICAL_FRONT_SPS_Y + 4*(MOHAWK_VERTICAL_FRONT_SPS_VSPACE + MOHAWK_VERTICAL_FRONT_SPS_HEIGHT), MOHAWK_VERTICAL_FRONT_SPS_WIDTH, MOHAWK_VERTICAL_FRONT_SPS_HEIGHT),
            new Rectangle(MOHAWK_VERTICAL_FRONT_SPS_X, MOHAWK_VERTICAL_FRONT_SPS_Y + 3*(MOHAWK_VERTICAL_FRONT_SPS_VSPACE + MOHAWK_VERTICAL_FRONT_SPS_HEIGHT), MOHAWK_VERTICAL_FRONT_SPS_WIDTH, MOHAWK_VERTICAL_FRONT_SPS_HEIGHT),
            new Rectangle(MOHAWK_VERTICAL_FRONT_SPS_X, MOHAWK_VERTICAL_FRONT_SPS_Y + 2*(MOHAWK_VERTICAL_FRONT_SPS_VSPACE + MOHAWK_VERTICAL_FRONT_SPS_HEIGHT), MOHAWK_VERTICAL_FRONT_SPS_WIDTH, MOHAWK_VERTICAL_FRONT_SPS_HEIGHT),
            new Rectangle(MOHAWK_VERTICAL_FRONT_SPS_X, MOHAWK_VERTICAL_FRONT_SPS_Y + MOHAWK_VERTICAL_FRONT_SPS_VSPACE + MOHAWK_VERTICAL_FRONT_SPS_HEIGHT, MOHAWK_VERTICAL_FRONT_SPS_WIDTH, MOHAWK_VERTICAL_FRONT_SPS_HEIGHT),
            new Rectangle(MOHAWK_VERTICAL_FRONT_SPS_X, MOHAWK_VERTICAL_FRONT_SPS_Y, MOHAWK_VERTICAL_FRONT_SPS_WIDTH, MOHAWK_VERTICAL_FRONT_SPS_HEIGHT),
        ];

        private static const LOWERHALFBAYVERTICAL_BACK_OFFSET:Number = 0.435 * MOHAWK_HEIGHT;
        private static const MOHAWK_VERTICAL_BACK_DAEX:Number = 0.13 * MOHAWK_WIDTH;
        private static const MOHAWK_VERTICAL_BACK_DAEY:Number = 0.06 * MOHAWK_HEIGHT;
        private static const MOHAWK_VERTICAL_BACK_DAEWIDTH:Number = 0.15 * MOHAWK_WIDTH;
        private static const MOHAWK_VERTICAL_BACK_DAEHEIGHT:Number = (DEFAULT_COMPONENT_UWIDTH/(3*DEFAULT_COMPONENT_UHEIGHT)) * MOHAWK_VERTICAL_BACK_DAEWIDTH;
        private static const MOHAWK_VERTICAL_BACK_DAEHSPACE:Number = 0.01 * MOHAWK_WIDTH;
        private static const MOHAWK_VERTICAL_BACK_DEAVSPACE:Number = 0.0065 * MOHAWK_HEIGHT;
        private static const MOHAWK_VERTICAL_BACK_SPSSPACE:Number = 2*MOHAWK_VERTICAL_BACK_DAEHSPACE + MOHAWK_VERTICAL_BACK_SPS_WIDTH;
        
        private static const MOHAWK_VERTICAL_BACK_DAE_ENCLOSURES:Array = [
            new Rectangle(MOHAWK_VERTICAL_BACK_DAEX, MOHAWK_VERTICAL_BACK_DAEY, MOHAWK_VERTICAL_BACK_DAEWIDTH, MOHAWK_VERTICAL_BACK_DAEHEIGHT),
            new Rectangle(MOHAWK_VERTICAL_BACK_DAEX + MOHAWK_VERTICAL_BACK_DAEWIDTH + MOHAWK_VERTICAL_BACK_DAEHSPACE, MOHAWK_VERTICAL_BACK_DAEY, MOHAWK_VERTICAL_BACK_DAEWIDTH, MOHAWK_VERTICAL_BACK_DAEHEIGHT),
            new Rectangle(MOHAWK_VERTICAL_BACK_DAEX + 2*(MOHAWK_VERTICAL_BACK_DAEWIDTH + MOHAWK_VERTICAL_BACK_DAEHSPACE) + MOHAWK_VERTICAL_BACK_SPSSPACE, MOHAWK_VERTICAL_BACK_DAEY, MOHAWK_VERTICAL_BACK_DAEWIDTH, MOHAWK_VERTICAL_BACK_DAEHEIGHT),
            new Rectangle(MOHAWK_VERTICAL_BACK_DAEX + 3*(MOHAWK_VERTICAL_BACK_DAEWIDTH + MOHAWK_VERTICAL_BACK_DAEHSPACE) + MOHAWK_VERTICAL_BACK_SPSSPACE, MOHAWK_VERTICAL_BACK_DAEY, MOHAWK_VERTICAL_BACK_DAEWIDTH, MOHAWK_VERTICAL_BACK_DAEHEIGHT),
            new Rectangle(MOHAWK_VERTICAL_BACK_DAEX, MOHAWK_VERTICAL_BACK_DAEY + MOHAWK_VERTICAL_BACK_DEAVSPACE + MOHAWK_VERTICAL_BACK_DAEHEIGHT, MOHAWK_VERTICAL_BACK_DAEWIDTH, MOHAWK_VERTICAL_BACK_DAEHEIGHT),
            new Rectangle(MOHAWK_VERTICAL_BACK_DAEX + MOHAWK_VERTICAL_BACK_DAEWIDTH + MOHAWK_VERTICAL_BACK_DAEHSPACE, MOHAWK_VERTICAL_BACK_DAEY + MOHAWK_VERTICAL_BACK_DEAVSPACE + MOHAWK_VERTICAL_BACK_DAEHEIGHT, MOHAWK_VERTICAL_BACK_DAEWIDTH, MOHAWK_VERTICAL_BACK_DAEHEIGHT),
            new Rectangle(MOHAWK_VERTICAL_BACK_DAEX + 2*(MOHAWK_VERTICAL_BACK_DAEWIDTH + MOHAWK_VERTICAL_BACK_DAEHSPACE) + MOHAWK_VERTICAL_BACK_SPSSPACE, MOHAWK_VERTICAL_BACK_DAEY + MOHAWK_VERTICAL_BACK_DEAVSPACE + MOHAWK_VERTICAL_BACK_DAEHEIGHT, MOHAWK_VERTICAL_BACK_DAEWIDTH, MOHAWK_VERTICAL_BACK_DAEHEIGHT),
            new Rectangle(MOHAWK_VERTICAL_BACK_DAEX + 3*(MOHAWK_VERTICAL_BACK_DAEWIDTH + MOHAWK_VERTICAL_BACK_DAEHSPACE) + MOHAWK_VERTICAL_BACK_SPSSPACE, MOHAWK_VERTICAL_BACK_DAEY + MOHAWK_VERTICAL_BACK_DEAVSPACE + MOHAWK_VERTICAL_BACK_DAEHEIGHT, MOHAWK_VERTICAL_BACK_DAEWIDTH, MOHAWK_VERTICAL_BACK_DAEHEIGHT),
        ];
        
        private static const MOHAWK_VERTICAL_BACK_SPS_WIDTH:Number = 2/3 * MOHAWK_VERTICAL_BACK_DAEWIDTH;
        private static const MOHAWK_VERTICAL_BACK_SPS_HEIGHT:Number = MOHAWK_VERTICAL_BACK_SPS_WIDTH/0.4;
        private static const MOHAWK_VERTICAL_BACK_SPS_X:Number = MOHAWK_VERTICAL_BACK_DAEX + 2*(MOHAWK_VERTICAL_BACK_DAEWIDTH + MOHAWK_VERTICAL_BACK_DAEHSPACE);
        private static const MOHAWK_VERTICAL_BACK_SPS_Y:Number = MOHAWK_VERTICAL_BACK_DAEY;
        private static const MOHAWK_VERTICAL_BACK_SPS_VSPACE:Number = 0.006 * MOHAWK_HEIGHT;
        
        private static const MOHAWK_VERTICAL_BACK_SPS_ENCLOSURES:Array = [
            new Rectangle(MOHAWK_VERTICAL_BACK_SPS_X, MOHAWK_VERTICAL_BACK_SPS_Y + 7*(MOHAWK_VERTICAL_BACK_SPS_VSPACE + MOHAWK_VERTICAL_BACK_SPS_HEIGHT), MOHAWK_VERTICAL_BACK_SPS_WIDTH, MOHAWK_VERTICAL_BACK_SPS_HEIGHT),
            new Rectangle(MOHAWK_VERTICAL_BACK_SPS_X, MOHAWK_VERTICAL_BACK_SPS_Y + 6*(MOHAWK_VERTICAL_BACK_SPS_VSPACE + MOHAWK_VERTICAL_BACK_SPS_HEIGHT), MOHAWK_VERTICAL_BACK_SPS_WIDTH, MOHAWK_VERTICAL_BACK_SPS_HEIGHT),
            new Rectangle(MOHAWK_VERTICAL_BACK_SPS_X, MOHAWK_VERTICAL_BACK_SPS_Y + 5*(MOHAWK_VERTICAL_BACK_SPS_VSPACE + MOHAWK_VERTICAL_BACK_SPS_HEIGHT), MOHAWK_VERTICAL_BACK_SPS_WIDTH, MOHAWK_VERTICAL_BACK_SPS_HEIGHT),
            new Rectangle(MOHAWK_VERTICAL_BACK_SPS_X, MOHAWK_VERTICAL_BACK_SPS_Y + 4*(MOHAWK_VERTICAL_BACK_SPS_VSPACE + MOHAWK_VERTICAL_BACK_SPS_HEIGHT), MOHAWK_VERTICAL_BACK_SPS_WIDTH, MOHAWK_VERTICAL_BACK_SPS_HEIGHT),
            new Rectangle(MOHAWK_VERTICAL_BACK_SPS_X, MOHAWK_VERTICAL_BACK_SPS_Y + 3*(MOHAWK_VERTICAL_BACK_SPS_VSPACE + MOHAWK_VERTICAL_BACK_SPS_HEIGHT), MOHAWK_VERTICAL_BACK_SPS_WIDTH, MOHAWK_VERTICAL_BACK_SPS_HEIGHT),
            new Rectangle(MOHAWK_VERTICAL_BACK_SPS_X, MOHAWK_VERTICAL_BACK_SPS_Y + 2*(MOHAWK_VERTICAL_BACK_SPS_VSPACE + MOHAWK_VERTICAL_BACK_SPS_HEIGHT), MOHAWK_VERTICAL_BACK_SPS_WIDTH, MOHAWK_VERTICAL_BACK_SPS_HEIGHT),
            new Rectangle(MOHAWK_VERTICAL_BACK_SPS_X, MOHAWK_VERTICAL_BACK_SPS_Y + MOHAWK_VERTICAL_BACK_SPS_VSPACE + MOHAWK_VERTICAL_BACK_SPS_HEIGHT, MOHAWK_VERTICAL_BACK_SPS_WIDTH, MOHAWK_VERTICAL_BACK_SPS_HEIGHT),
            new Rectangle(MOHAWK_VERTICAL_BACK_SPS_X, MOHAWK_VERTICAL_BACK_SPS_Y, MOHAWK_VERTICAL_BACK_SPS_WIDTH, MOHAWK_VERTICAL_BACK_SPS_HEIGHT),
        ];

        private static const MOHAWK_ENGINESIDE_SPS_FRONT_RECT:Rectangle = new Rectangle(0, 0, 0.1127 * MOHAWK_WIDTH, 0.4593 * MOHAWK_HEIGHT);
        private static const MOHAWK_ENGINESIDE_SPS_FRONT_OFFSETS:Array = [
            {x:0.078 * MOHAWK_WIDTH, y:0.028 * MOHAWK_HEIGHT},
            {x:0.078 * MOHAWK_WIDTH, y:0.514 * MOHAWK_HEIGHT},
            {x:0.8076 * MOHAWK_WIDTH, y:0.028 * MOHAWK_HEIGHT},
            {x:0.8076 * MOHAWK_WIDTH, y:0.514 * MOHAWK_HEIGHT}            
            ];
        private static const MOHAWK_ENGINESIDE_SPS_FRONT_SPACE:Number = 0.004 * MOHAWK_HEIGHT;
        
        private static const MOHAWK_ENGINESIDE_SPS_BACK_RECT:Rectangle = new Rectangle(0, 0, 0.099 * MOHAWK_WIDTH, 0.4194 * MOHAWK_HEIGHT);
        private static const MOHAWK_ENGINESIDE_SPS_BACK_OFFSETS:Array = [
            {x:0.1379 * MOHAWK_WIDTH, y:0.0546 * MOHAWK_HEIGHT},
            {x:0.1379 * MOHAWK_WIDTH, y:0.4945 * MOHAWK_HEIGHT},
            {x:0.7927 * MOHAWK_WIDTH, y:0.0546 * MOHAWK_HEIGHT},
            {x:0.7927 * MOHAWK_WIDTH, y:0.4945 * MOHAWK_HEIGHT}            
        ];
        private static const MOHAWK_ENGINESIDE_SPS_BACK_SPACE:Number = 0.0038 * MOHAWK_HEIGHT;

        private static const MOHAWK_ENGINESIDE_SPS_MAP:Array = [-1, 7, 6, 5, 4, 3, 2, 1, 0];

        private static const MOHAWK_PDU_HEIGHT:Number = 0.3139 * MOHAWK_HEIGHT;
        private static const MOHAWK_PDU_WIDTH:Number = 0.0554 * MOHAWK_WIDTH;
        private static const MOHAWK_PDU_X:Number = 0.0382 * MOHAWK_WIDTH;
        private static const MOHAWK_PDU_Y:Number = 0.0642 * MOHAWK_HEIGHT;
        private static const MOHAWK_PDU_XOFFSET:Number = 0.8613 * MOHAWK_WIDTH;
        private static const MOHAWK_PDU_YOFFSET:Number = 0.4531 * MOHAWK_HEIGHT;
        private static const MOHAWK_PDU_POSITION:Array = [
            new Rectangle(MOHAWK_PDU_X, MOHAWK_PDU_Y, MOHAWK_PDU_WIDTH, MOHAWK_PDU_HEIGHT),
            new Rectangle(MOHAWK_PDU_X + MOHAWK_PDU_XOFFSET, MOHAWK_PDU_Y, MOHAWK_PDU_WIDTH, MOHAWK_PDU_HEIGHT),
            new Rectangle(MOHAWK_PDU_X, MOHAWK_PDU_Y + MOHAWK_PDU_YOFFSET, MOHAWK_PDU_WIDTH, MOHAWK_PDU_HEIGHT),
            new Rectangle(MOHAWK_PDU_X + MOHAWK_PDU_XOFFSET, MOHAWK_PDU_Y + MOHAWK_PDU_YOFFSET, MOHAWK_PDU_WIDTH, MOHAWK_PDU_HEIGHT),
            ];
        
        private static const MOHAWK_PDP_HEIGHT:Number = 0.2975 * MOHAWK_HEIGHT;
        private static const MOHAWK_PDP_WIDTH:Number = 0.1061 * MOHAWK_WIDTH;
        private static const MOHAWK_PDP_X:Number = 0.0188 * MOHAWK_WIDTH;
        private static const MOHAWK_PDP_Y:Number = 0.1097 * MOHAWK_HEIGHT;
        private static const MOHAWK_PDP_XOFFSET:Number = 0.8571 * MOHAWK_WIDTH;
        private static const MOHAWK_PDP_YOFFSET:Number = 0.4897 * MOHAWK_HEIGHT;
        private static const MOHAWK_PDP_POSITION:Array = [
            new Rectangle(MOHAWK_PDP_X, MOHAWK_PDP_Y, MOHAWK_PDP_WIDTH, MOHAWK_PDP_HEIGHT),
            new Rectangle(MOHAWK_PDP_X + MOHAWK_PDP_XOFFSET, MOHAWK_PDP_Y, MOHAWK_PDP_WIDTH, MOHAWK_PDP_HEIGHT),
            new Rectangle(MOHAWK_PDP_X, MOHAWK_PDP_Y + MOHAWK_PDP_YOFFSET, MOHAWK_PDP_WIDTH, MOHAWK_PDP_HEIGHT),
            new Rectangle(MOHAWK_PDP_X + MOHAWK_PDP_XOFFSET, MOHAWK_PDP_Y + MOHAWK_PDP_YOFFSET, MOHAWK_PDP_WIDTH, MOHAWK_PDP_HEIGHT)
        ];
        
        private static const TITAN_PDU_HEIGHT:Number = 0.3663 * TITAN_HEIGHT;
        private static const TITAN_PDU_WIDTH:Number = 0.0628 * TITAN_WIDTH;
        private static const TITAN_PDU_X:Number = 0.0427 * TITAN_WIDTH;
        private static const TITAN_PDU_Y:Number = 0.0655 * TITAN_HEIGHT;
        private static const TITAN_PDU_XOFFSET:Number = 0.8505 * TITAN_WIDTH;
        private static const TITAN_PDU_YOFFSET:Number = 0.4531 * TITAN_HEIGHT;
        private static const TITAN_VNX_PDU_YOFFSET:Number = 0.4626 * TITAN_HEIGHT;
        private static const TITAN_PDU_POSITION:Array = [
            new Rectangle(TITAN_PDU_X, TITAN_PDU_Y, TITAN_PDU_WIDTH, TITAN_PDU_HEIGHT),
            new Rectangle(TITAN_PDU_X + TITAN_PDU_XOFFSET, TITAN_PDU_Y, TITAN_PDU_WIDTH, TITAN_PDU_HEIGHT),
            new Rectangle(TITAN_PDU_X, TITAN_PDU_Y + TITAN_PDU_YOFFSET, TITAN_PDU_WIDTH, TITAN_PDU_HEIGHT),
            new Rectangle(TITAN_PDU_X + TITAN_PDU_XOFFSET, TITAN_PDU_Y + TITAN_PDU_YOFFSET, TITAN_PDU_WIDTH, TITAN_PDU_HEIGHT),
			// VNX PDUs
            new Rectangle(TITAN_PDU_X, TITAN_PDP_Y + TITAN_VNX_PDU_YOFFSET, TITAN_PDU_WIDTH, TITAN_PDU_HEIGHT),
            new Rectangle(TITAN_PDU_X + TITAN_PDU_XOFFSET, TITAN_PDP_Y + TITAN_VNX_PDU_YOFFSET, TITAN_PDU_WIDTH, TITAN_PDU_HEIGHT),
			// 250F PDUs
			new Rectangle(TITAN_PDU_X - 20, TITAN_PDU_Y + TITAN_PDU_YOFFSET, TITAN_PDU_WIDTH, TITAN_PDU_HEIGHT),
			new Rectangle(TITAN_PDU_X + TITAN_PDU_XOFFSET + 20, TITAN_PDU_Y + TITAN_PDU_YOFFSET, TITAN_PDU_WIDTH, TITAN_PDU_HEIGHT),
			// PowerMax PDUs x/y/width/height
			new Rectangle(TITAN_PDU_X + 3, 25, TITAN_PDU_WIDTH, 1445),
			new Rectangle(TITAN_PDU_X + TITAN_PDU_XOFFSET, 25, TITAN_PDU_WIDTH, 1445)
            ];
        
        private static const TITAN_PDP_HEIGHT:Number = 0.3098 * TITAN_HEIGHT;
        private static const TITAN_PDP_WIDTH:Number = 0.1005 * TITAN_WIDTH;
        private static const TITAN_PDP_X:Number = 0.0352 * TITAN_WIDTH;
        private static const TITAN_PDP_Y:Number = 0.11 * TITAN_HEIGHT;
        private static const TITAN_PDP_XOFFSET:Number = 0.8266 * TITAN_WIDTH;
        private static const TITAN_PDP_YOFFSET:Number = 0.4897 * TITAN_HEIGHT;
        private static const TITAN_VNX_PDP_YOFFSET:Number = 0.11001 * TITAN_HEIGHT;
        private static const TITAN_PDP_POSITION:Array = [
            new Rectangle(TITAN_PDP_X, TITAN_PDP_Y, TITAN_PDP_WIDTH, TITAN_PDP_HEIGHT),
            new Rectangle(TITAN_PDP_X + TITAN_PDP_XOFFSET, TITAN_PDP_Y, TITAN_PDP_WIDTH, TITAN_PDP_HEIGHT),
            new Rectangle(TITAN_PDP_X, TITAN_PDP_Y + TITAN_PDP_YOFFSET, TITAN_PDP_WIDTH, TITAN_PDP_HEIGHT),
            new Rectangle(TITAN_PDP_X + TITAN_PDP_XOFFSET, TITAN_PDP_Y + TITAN_PDP_YOFFSET, TITAN_PDP_WIDTH, TITAN_PDP_HEIGHT),
			// VNX PDPs
            new Rectangle(TITAN_PDP_X, TITAN_PDU_Y + TITAN_VNX_PDP_YOFFSET, TITAN_PDP_WIDTH, TITAN_PDP_HEIGHT),
            new Rectangle(TITAN_PDP_X + TITAN_PDP_XOFFSET, TITAN_PDU_Y + TITAN_VNX_PDP_YOFFSET, TITAN_PDP_WIDTH, TITAN_PDP_HEIGHT),
			// 250 PDPs
			new Rectangle(TITAN_PDP_X - 10, TITAN_PDP_Y + TITAN_PDP_YOFFSET, TITAN_PDP_WIDTH, TITAN_PDP_HEIGHT),
			new Rectangle(TITAN_PDP_X + TITAN_PDP_XOFFSET + 10, TITAN_PDP_Y + TITAN_PDP_YOFFSET, TITAN_PDP_WIDTH, TITAN_PDP_HEIGHT)
        ];

        private static const ENGINE_2040K_PORT_ENCLOSURE:Rectangle = new Rectangle(0.1252, 0.77, 0.749, 0.2066);
        private static const ENGINE_10K_PORT_ENCLOSURE_DIR1:Rectangle = new Rectangle(0.036, 0.0407, 0.135, 0.8389);
        private static const ENGINE_10K_PORT_ENCLOSURE_DIR2_OFFSET:Number = 0.472;
        private static const ENGINE_VG3R_PORT_ENCLOSURE_DIR:Rectangle = new Rectangle(0.126, 0.018, 0.064, 0.442);
        private static const ENGINE_VG3R_PORT_ENCLOSURE_DIR_OFFSET_Y:Number = 0.497;
        private static const ENGINE_VG3R_IB_MODULE_ENCLOSURE:Rectangle = new Rectangle(0.027, 0.0157, 0.0947, 0.446);
        private static const ENGINE_VG3R_INNER_PORT_OFFSET:Number = 0.0075;
		
		private static const MIBE_POWER_SUPPLY_PERCENT_WIDTH:Number = 0.25;
		private static const MIBE_ASSEMBLY_PERCENT_WIDTH:Number = 0.5;
		private static const D15_BAY_ENCLOSURE_POWER_SUPPLY_PERCENT_HEIGHT:Number = 0.33;
		private static const D15_BAY_ENCLOSURE_LCC_PERCENT_HEIGHT:Number = 0.17;
		private static const D15_HALFBAYVERTICAL_POWER_SUPPLY_PERCENT_WIDTH:Number = 0.33;
		private static const D15_HALFBAYVERTICAL_LCC_PERCENT_WIDTH:Number = 0.17;
		private static const VANGUARD_POWER_SUPPLY_PERCENT_WIDTH:Number = 0.32;
		private static const VANGUARD_LCC_PERCENT_WIDTH:Number = 0.36;
		private static const VANGUARD_LCC_PERCENT_HEIGHT:Number = 0.5;
		private static const VIKING_FAN_ENCLOSURE:Rectangle = new Rectangle(0.013, 0.15, 0.2, 0.73);
		private static const VIKING_TOP_FAN_ENCLOSURE:Rectangle = new Rectangle(0.02, 0.01, 0.195, 0.09);
		private static const VIKING_POWER_SUPPLY_ENCLOSURE:Rectangle = new Rectangle(0, 0, 0.25, 0.45);
		private static const VIKING_LCC_ENCLOSURE:Rectangle = new Rectangle(0, 0.44, 0.5, 0.56);
		private static const VOYAGER_FAN_ENCLOSURE:Rectangle = new Rectangle(0.012, 0.12, 0.3, 0.74);
		private static const VOYAGER_LCC_ENCLOSURE:Rectangle = new Rectangle(0, 0, 0.093, 1);
		private static const VOYAGER_POWER_SUPPLY_ENCLOSURE:Rectangle = new Rectangle(0.09, 0, 0.205, 1);
		private static const VOYAGER_TOP_FAN_ENCLOSURE:Rectangle = new Rectangle(0.02, 0.915, 0.34, 0.08);
		private static const VOYAGER_TOP_LCC_ENCLOSURE:Rectangle = new Rectangle(0.47, 0.02, 0.07, 0.44);
        private static const VIKING_SSC_RECTANGLE:Rectangle = new Rectangle(0.25, 0.8188, 0.532, 0.174);
		
		private static const SPS_ENGINELEFT_LED_INDICATOR_PERCENT_WIDTH:Number = 0.077;
		private static const SPS_ENGINELEFT_LED_INDICATOR_PERCENT_HEIGHT:Number = 0.25;
		private static const SPS_ENGINELEFT_LED_INDICATOR_X_PERCENT_WIDTH:Number = 2 * SPS_ENGINELEFT_LED_INDICATOR_PERCENT_WIDTH;
		private static const SPS_ENGINELEFT_LED_INDICATOR_Y_PERCENT_WIDTH:Number = 0.33 * SPS_ENGINELEFT_LED_INDICATOR_PERCENT_WIDTH;
		private static const SPS_ENGINERIGHT_LED_INDICATOR_PERCENT_WIDTH:Number = 0.0714;
		private static const SPS_ENGINERIGHT_LED_INDICATOR_PERCENT_HEIGHT:Number = 0.606;
		private static const SPS_BAY_ENCLOSURE_LED_INDICATOR_X_PERCENT_WIDTH:Number = 0.613;
		private static const SPS_BAY_ENCLOSURE_LED_INDICATOR_Y_PERCENT_HEIGHT:Number = 0.849;
		private static const SPS_BAY_ENCLOSURE_LED_INDICATOR_PERCENT_HEIGHT:Number = 0.07;
		private static const SPS_BAY_ENCLOSURE_LED_INDICATOR_PERCENT:Number = 0.206;
		private static const ENGINE_DIRECTOR_POWER_SUPPLY_PERCENT_WIDTH:Number = 0.25;
		private static const ENGINE_20K40K_POWER_SUPPLY_PERCENT_WIDTH:Number = 0.2;
		private static const ENGINE_COOLING_FANS_PERCENT_WIDTH:Number = 0.15;
		private static const ENGINE_COOLING_FANS_PERCENT_HEIGHT:Number = 0.8;
		private static const ENGINE_POWER_CONNECTOR_PERCENT_HEIGHT:Number = 0.54;
		private static const ENGINE_POWER_CONNECTOR_PERCENT_WIDTH:Number = 0.13;
		private static const ENGINE_POWER_CONNECTOR_X_PERCENT_WIDTH:Number = 0.87;
		private static const ENGINE_UPPER_BACK_END_MODULE_Y_PERCENT_HEIGHT:Number = 0.13;
		private static const ENGINE_LOWER_BACK_END_MODULE_Y_PERCENT_HEIGHT:Number = 0.48;
		private static const ENGINE_UPPER_BACK_END_MODULE_PERCENT_HEIGHT:Number = 0.23;
		private static const ENGINE_LOWER_BACK_END_MODULE_PERCENT_HEIGHT:Number = 0.21;
		private static const ENGINE_FRONT_END_MODULE_Y_PERCENT_HEIGHT:Number = 0.78;
		private static const ENGINE_FRONT_END_MODUL_PERCENT_WIDTH:Number = 0.185;
		private static const ENGINE_SLOT0_BACK_END_MODULE_PERCENT_WIDTH:Number = 0.18;
		private static const ENGINE_SLOT1_BACK_END_MODULE_PERCENT_WIDTH:Number = 0.19;
		private static const ENGINE20k_SIB_PERCENT_WIDTH:Number = 0.37;	
		private static const ENGINE10K_LEFT_MANAGEMENT_MODULE_X_PERCENT_WIDTH:Number = 0.038;	
		private static const ENGINE10K_RIGHT_MANAGEMENT_MODULE_X_PERCENT_WIDTH:Number = 0.52;	
		private static const ENGINE10K_MANAGEMENT_MODULE_Y_PERCENT_HEIGHT:Number = 0.03;	
		private static const ENGINE10K_LEFT_MANAGEMENT_MODULE_PERCENT_WIDTH:Number = 0.09;	
		private static const ENGINE10K_RIGHT_MANAGEMENT_MODULE_PERCENT_WIDTH:Number = 0.089;	
		private static const ENGINE10K_MANAGEMENT_MODULE_PERCENT_HEIGHT:Number = 0.88;	
		private static const ENGINE10K_SIB_X_PERCENT_WIDTH:Number = 0.134;	
		private static const ENGINE10K_SIB_PERCENT_WIDTH:Number = 0.078;	
		private static const ENGINE10K_BACK_END_MODULE_PERCENT_WIDTH:Number = 0.073;	
		private static const ENGINE10K_FRONT_END_MODULE_PERCENT_WIDTH:Number = 0.067;	
		private static const UPS_MAIN_BATTERY_LED_X_PERCENT_WIDTH:Number = 0.734;	
		private static const UPS_MAIN_BATTERY_LED_Y_PERCENT_HEIGHT:Number = 0.1;	
		private static const UPS_AUX_BATTERY_LED_X_PERCENT_WIDTH:Number = 0.866;	
		private static const UPS_PERCENT_HEIGHT:Number = 0.416;	
		private static const UPS_PERCENT_WIDTH:Number = 0.075;	
		private static const UPS_BACK_MAIN_BATTERY_LED_X_PERCENT_WIDTH:Number = 0.396;	
		private static const UPS_BACK_MAIN_BATTERY_LED_Y_PERCENT_HEIGHT:Number = 0.627;	
		private static const UPS_BACK_PERCENT_HEIGHT:Number = 0.146;	
		private static const ENGINE_VG3R_MANAGEMENT_MODULE_RECT:Rectangle = new Rectangle(0.06, 0.013, 0.092, 0.45);	
		private static const ENGINE_VG3R_DIR_OFFSET:Number = 0.5;
		private static const ENGINE_VG3R_FRONTEND_RECT:Rectangle = new Rectangle(0.159, 0.0122, 0.073, 0.451);
		private static const ENGINE_VG3R_BACKEND_RECT:Rectangle = new Rectangle(0.444, 0.013, 0.078, 0.45);	
		private static const ENGINE_VG3R_FABRIC_RECT:Rectangle = new Rectangle(0.88, 0.013, 0.09, 0.45);	

		private static const KVM_OPENED_HEIGHT:Number = 8; 		
		private static const ENGINE_VG3R_FAN_RECT:Rectangle = new Rectangle(0.03, 0.12, 0.15, 0.37);	
		private static const ENGINE_VG3R_POWER_SUPPLY_RECT:Rectangle = new Rectangle(0.79, 0, 0.21, 0.25);	
		private static const ENGINE_VG3R_POWER_CONNECTOR_RECT:Rectangle = new Rectangle(0, 0, 0.06, 0.22);	
        private static const ENGINE_VG3R_FLASH_DRIVE_DIR_A_RECT:Rectangle = new Rectangle(0.031, 0.022, 0.182, 0.092);
        private static const ENGINE_VG3R_FLASH_DRIVE_DIR_B_RECT:Rectangle = new Rectangle(0.031, 0.515, 0.182, 0.092);
		
        private static const STINGRAY_ENCLOSURE_RECT:Rectangle = new Rectangle(0, 0.01866 * TITAN_HEIGHT, TITAN_WIDTH, 0.956 * TITAN_HEIGHT);
		
		
		// arrow directions
		public static const UP_ARROW:uint = 0x00000001;
		public static const DOWN_ARROW:uint = 0x00000002;
		public static const LEFT_ARROW:uint = 0x00000004;
		public static const RIGHT_ARROW:uint = 0x0000000010;
		public static const HORIZONTAL_DIRECTION:uint = LEFT_ARROW | RIGHT_ARROW;
		public static const VERTICAL_DIRECTION:uint = UP_ARROW | DOWN_ARROW;
		
		private const INNER_FRAME_OFF_WIDTH:Number = 0.12;
		private const INNER_FRAME_OFF_HEIGHT:Number= 0.0555;

		private const WHEEL_RECT_PERC_WIDTH:Number=0.0623;
		private const WHEEL_RECT_PERC_HEIGHT:Number=0.0605;

		private const WHEEL_RECT_PERC_X:Number=0.06;
		private const WHEEL_RECT_PERC_Y:Number=0.0958;
		private const WHEEL_RECT_PERC_LOWER_Y:Number=0.86;
		private const WHEEL_ALPHA:Number=0.3;
		
		private const BAY_OFFSET_PERC:Number = 0.018;
		private const DRAWING_WIDTH_OFFSET:Number = 1.5;
		private const DRAWING_HEIGHT_OFFSET:Number = 0.2866;
		
		private const TILE_HEIGHT_PERC:Number = 1.9508;   //Tile height ratio comparing to width
		private const TILE_WIDTH_PERC:Number = 0.5126;    //Tile width ratio comparing to height
		
		private const FRAME_HEIGHT_PERC_NON_DISPERSED:Number = 0.568;
		private const FRAME_HEIGHT_PERC_DISPERSED:Number = 0.35;

		private const LINE_SIZE:Number = 4;
        
        private var _renderer:IRenderer = null;
        private var _toolTipProvider:IToolTipProvider = null;

        private var _renderEnclosure:Boolean = false;
        private var _renderEngineDAEConnections:Boolean = false;
        private var _renderRealistic:Boolean = false;
        /**
         * Initializes  
         * @param renderer
         * 
         */
        public function RenderUtility(renderer:IRenderer, toolTipProvider:IToolTipProvider)
        {
            _renderer = renderer;
            _toolTipProvider = toolTipProvider;
        }
        
        public function set renderer(rend:IRenderer):void {
            _renderer = rend;
        }
        
        public function set renderEngineDAEConnections(value:Boolean):void {
            _renderEngineDAEConnections = value;
        }
        
        public function set realistic(value:Boolean):void {
            _renderRealistic = value;
            _renderer.realistic = value;
        }
		
        /**
         * Renders main stage. 
         * @param component component to render
         * @param back true if rendering backside
         * @return parent UIComponentBase
         * 
         */
        public function renderStage(component:ComponentBase, viewSide:String = Constants.FRONT_VIEW_PERSPECTIVE):UIComponentBase {
            var uicomp:UIComponentBase = new UIComponentBase(component);
            var mainRect:Rectangle = new Rectangle();
            
            var dispersed:int = -1;
			var dispersed_m:Array = [-1];
            
            _renderer.renderEngineDAEConnections = false;
			
			var renderFloorView:Boolean = viewSide == Constants.TOP_VIEW_PERSPECTIVE && 
				(component.isConfiguration || component.isBay);
            
            if (component is sym.objectmodel.common.Configuration) {
				if(component is sym.objectmodel.common.Configuration_VG3R)
				{
					var config:sym.objectmodel.common.Configuration_VG3R = component as sym.objectmodel.common.Configuration_VG3R;
					dispersed_m = config.dispersed_m;
				}
				else
				{
	                var cfg:sym.objectmodel.common.Configuration = component as sym.objectmodel.common.Configuration;
	                dispersed = cfg.dispersed;
				}
            }
            
            if ((component is sym.objectmodel.common.Configuration || component is Bay) && _renderEngineDAEConnections) {
                _renderer.renderEngineDAEConnections = _renderEngineDAEConnections;
            }
            
            var zoomScale:Number = getZoomScale(component);
			
			if(component is sym.objectmodel.common.Configuration_VG3R && dispersed_m[0] != -1)
			{
				var count:int;
				var dispersedBays:Array = [];
				var notDispBays:Array = [];
				
				for each(var bay:Bay in component.children)
				{
					if((bay.isSystemBay &&  dispersed_m.indexOf(bay.positionIndex + 1) > -1 ) || 
					   (bay.isStorageBay && dispersed_m.indexOf(bay.attachedToSystemBayWithIndex + 1) > -1))
					{
						dispersedBays.push(bay);
						count++;
					} 
					else
					{
						notDispBays.push(bay);
					}
				}
				
				var maxNumberOfBays:int = Math.max(notDispBays.length, dispersedBays.length);
				
				uicomp.height = mainRect.height = getComponentHeight(component) * zoomScale * 2 + TITAN_WIDTH;
				uicomp.width = mainRect.width = maxNumberOfBays * getComponentWidth(component.children[0] as Bay) * zoomScale + (dispersedBays.length -1) * TITAN_WIDTH/2;
	
				if (renderFloorView)
				{
					drawFloorView(uicomp, notDispBays, dispersedBays); 
					// disable button mode
					uicomp.useHandCursor = false;
					uicomp.buttonMode = false;
				}
				else
				{
					renderDispersed(viewSide, uicomp, dispersedBays, notDispBays, null, mainRect, component, true);
					
					// configuration is dispersed, draw connecting lines
					renderStarConnectingLine(viewSide, uicomp, component, dispersedBays);                
				}
			}
			else
			{
				uicomp.height = getComponentHeight(component) * zoomScale;
				uicomp.width = getComponentWidth(component) * zoomScale;
				uicomp.useHandCursor = true;
				uicomp.buttonMode = true;
				uicomp.toolTip = _toolTipProvider.getToolTip(viewSide, component);
				
				mainRect.height = uicomp.height;
				mainRect.width = uicomp.width;
			
	            if (dispersed != -1) {
	                // configuration is dispersed, draw connecting lines
	                // add space for line
	                uicomp.height += 2*DISPERSED_CONNECTING_LINE_HEIGHT;
	            }
				
				if (renderFloorView)
				{
					drawFloorView(uicomp);
					// disable button mode
					uicomp.useHandCursor = false;
					uicomp.buttonMode = false;
				}
				else
				{
		            render(viewSide, uicomp, null, mainRect, component, true);
		
		            if (dispersed != -1) {
		                // configuration is dispersed, draw connecting lines
		                renderConnectingLine(viewSide, uicomp, component);                
		            }
				}
			}
			
			if (!renderFloorView)
				renderOverlayComponent(uicomp, viewSide, mainRect);
			
            return uicomp;
        }
		
		
		
		/**
		 * Draws component floor view 
		 * @param compBase UIComponentBase containing ComponentBase object 
		 * <p></p>
		 */       
		public function drawFloorView(compBase:UIComponentBase, notDispersedBays:Array = null, dispersedBays:Array = null, drawDisperseLines:Boolean = false):void
		{
			const nonDispersedSystemYOffset:Number = dispersedBays && dispersedBays.length > 0 ? 0.56 : 0.280;
			const dispersedBaysYOffset:Number = 0.073;
			
			var tileWidth:Number = 0;
			var tileHeight:Number = 0; 
			var bay:Bay = null; 
			var baysOffset:uint = 0;
			var bays:Array = [];
			var disperseCollection:ArrayCollection = new ArrayCollection(dispersedBays == null ? [] : dispersedBays);
			var nonDisperseCollection:ArrayCollection = new ArrayCollection(notDispersedBays == null ? [] : notDispersedBays);
			
			//Calculate Bay Frame width/height
			if(compBase.componentBase.isBay || disperseCollection.length == 0)  //single bay, or non dispersed configuration
			{
				tileHeight = FRAME_HEIGHT_PERC_NON_DISPERSED * compBase.height;
			}
			else
			{
				tileHeight = FRAME_HEIGHT_PERC_DISPERSED * compBase.height;
			}
			
			tileWidth  = tileHeight * TILE_WIDTH_PERC;
			
			
			if(compBase.componentBase.isBay)
			{
				nonDisperseCollection.addItem(compBase.componentBase);
			}
			else if(nonDisperseCollection.length == 0)
			{
				nonDisperseCollection = new ArrayCollection(compBase.componentBase.children);
			}
			
			baysOffset = tileWidth * BAY_OFFSET_PERC;
			
			//Calculate ui container width 
			var disperseBaysWidth:Number = disperseCollection.length * tileWidth + (disperseCollection.length - 1) * tileWidth / 2;  //let disperse inner-bay offset be tilewidth/2 
			var nonDisperseBaysWidth:Number = nonDisperseCollection.length * tileWidth + (nonDisperseCollection.length - 1) * baysOffset;
			var drawingWidthPadding:Number = DRAWING_WIDTH_OFFSET * tileWidth;
			var sysBay1Position:Point = new Point();
			
			compBase.width = (disperseBaysWidth > nonDisperseBaysWidth ? disperseBaysWidth : nonDisperseBaysWidth) + drawingWidthPadding;
			
			//Draw dispersed bays
			if(disperseCollection.length > 0)
			{
				for(var i:int = 0; i < disperseCollection.length; i++)
				{
                    var bayX:Number = (compBase.width - disperseBaysWidth)/2 + tileWidth * i + tileWidth / 2 * i;
                    var bayY:Number = dispersedBaysYOffset * compBase.height;
                    
                    if(drawDisperseLines)
                    {
                        compBase.graphics.lineStyle(2, 0, 0.1);
                        compBase.graphics.moveTo(sysBay1Position.x + tileWidth/2, sysBay1Position.y);
                        compBase.graphics.lineTo(bayX + tileWidth/2, bayY + tileHeight);
                    }
                    
                    drawBay(compBase.graphics, bayX, bayY, tileWidth,  tileHeight);
				}
			}
			
			//Draw not dispersed bays
			//Generaly, this collection should always contain at least  
			if(nonDisperseCollection.length > 0) 
			{
				for(var i:int = 0; i < nonDisperseCollection.length; i++)
				{
					var xPos:Number =  (compBase.width - nonDisperseBaysWidth) / 2 + tileWidth * i + tileWidth * BAY_OFFSET_PERC * i;
					var yPos:Number = nonDispersedSystemYOffset * compBase.height;
					
					if(i == 0)
					{
						sysBay1Position.x = xPos;
						sysBay1Position.y = yPos;
					}
					drawBay(compBase.graphics, xPos, yPos, tileWidth,  tileHeight);
					
					if (compBase.componentBase.isConfiguration)
					{
						// draw Bay labels
						var bayLabel:String = String.fromCharCode(Keyboard.R); // R ascii code
						var bayLabelRect:Rectangle = new Rectangle();
						
						bayLabelRect.x = xPos + tileWidth / 2;
						bayLabelRect.y = yPos + tileHeight / 2 - 15;
						bayLabelRect.width = 0.17 * tileWidth;
						bayLabelRect.height = 0.1 * tileHeight; 
						
						if (i == 0)
						{
							// "00" for System bay 1 only
							bayLabel = String.fromCharCode(Keyboard.NUMBER_0) + String.fromCharCode(Keyboard.NUMBER_0);
						}
						else 
						{
							if ((nonDisperseCollection[i].parent as Configuration_VG3R).sysBayType == Configuration_VG3R.SINGLE_ENGINE_BAY)
							{
								// single engine bay label	
								bayLabel += i;
							}
							else
							{
								// dual engine bay label
								bayLabel += i == 1 ? i : i + Configuration_VG3R.DUAL_ENGINE_BAY;
							}
						}
						// actual label draw
						drawText(bayLabelRect, compBase, bayLabel, 52, -1, 0, true, TextFormatAlign.LEFT);
					}
				}
			}
			
			var horizontalDimensionHeight:Number = 0.133 * tileHeight; //Horizontal dimensions height
			
			// draw first bay's dimensions - horizontal
			drawBaysDimension(new Rectangle(sysBay1Position.x - baysOffset, 
				sysBay1Position.y - horizontalDimensionHeight - 2*baysOffset,
				tileWidth + 2 * baysOffset,
				horizontalDimensionHeight),
				compBase, HORIZONTAL_DIRECTION, -1, baysOffset, true, 
				ResourceManager.getInstance().getString("main", "BAYS_WIDTH_DIMENSION"), 3, -6);
			
			var systemVertDimensionRectangle:Rectangle = new Rectangle();
			var verticalDimensionWidth:Number = 0.77 * tileWidth;
			systemVertDimensionRectangle.x = sysBay1Position.x - verticalDimensionWidth - 2 * baysOffset;
			systemVertDimensionRectangle.y = sysBay1Position.y - baysOffset;
			systemVertDimensionRectangle.width = verticalDimensionWidth;
			systemVertDimensionRectangle.height = tileHeight + 2 * baysOffset;
			
			// draw second bay's dimension - vertical
			drawBaysDimension(systemVertDimensionRectangle,
				compBase, VERTICAL_DIRECTION, -1, baysOffset, true, 
				ResourceManager.getInstance().getString("main", "BAYS_HEIGHT_DIMENSION"), 3);			
			
			if(compBase.componentBase.isConfiguration && nonDisperseCollection.length > 1)
			{
				//Drawing complete configuration's dimension
				var systemDimensionRectangle:Rectangle = new Rectangle();
				systemDimensionRectangle.x = sysBay1Position.x - baysOffset;
				systemDimensionRectangle.y = sysBay1Position.y + tileHeight + 4 * baysOffset; //a bit further from bay than bay's dimension
				systemDimensionRectangle.height = horizontalDimensionHeight;
				systemDimensionRectangle.width = nonDisperseBaysWidth + baysOffset * 2;
				
				const bayWidth_Inch:Number = 24;
				const bayOffset_Inch:Number = 0.25;
				var cfgWidth_Inch:Number = nonDisperseCollection.length * bayWidth_Inch + (nonDisperseCollection.length - 1) * bayOffset_Inch;
				var cfgWidth_Centimeter:Number = cfgWidth_Inch * 2.54;
				
				var dimensionText:String = StringUtil.substitute(ResourceManager.getInstance().getString("main", "CONFIG_WIDTH_DIMENSION"), 
					Math.round(cfgWidth_Inch * 100) / 100, Math.round(cfgWidth_Centimeter * 100) / 100);
				
				//Actual draw
				drawBaysDimension(systemDimensionRectangle, compBase, HORIZONTAL_DIRECTION, -1, baysOffset, true, dimensionText , 3); 
			}
			
			//Drawing inner-bay offset dimensions
			var offsetDimensionRectangle:Rectangle = new Rectangle();
			offsetDimensionRectangle.width = tileWidth * 0.9 * 2;
			offsetDimensionRectangle.height = tileHeight * 0.2;
			offsetDimensionRectangle.y = sysBay1Position.y - tileHeight * 0.174 - offsetDimensionRectangle.height;
			offsetDimensionRectangle.x = sysBay1Position.x + tileWidth - offsetDimensionRectangle.width / 2 + baysOffset / 2;
			
			//actual draw
			drawBaysDimension(offsetDimensionRectangle, compBase, DOWN_ARROW, -1, -1, false, 
				ResourceManager.getInstance().getString("main", "BAYS_GAP_DIMENSION"), 3);
			
			// Draw Front/Rear labels
			var rearTextRect:Rectangle = new Rectangle(compBase.width / 2, 0, tileWidth, horizontalDimensionHeight);
			var frontTextRect:Rectangle = new Rectangle(rearTextRect.x, compBase.height - rearTextRect.height * 0.6 , rearTextRect.width, rearTextRect.height);
			
			// actual text drawing
			drawText(rearTextRect, compBase, ResourceManager.getInstance().getString("main", "FlOOR_VIEW_REAR"), 52, -1, 0, true, TextFormatAlign.LEFT);
			drawText(frontTextRect, compBase, ResourceManager.getInstance().getString("main", "FlOOR_VIEW_FRONT"), 52, -1, 0, true, TextFormatAlign.LEFT);
			
		}
		
		/**
		 * Draws Bay floor perspective  
		 * @param graphic on this graphics
		 * @param x on this position
		 * @param y on this position
		 * @param w Width
		 * @param h Height
		 * 
		 */        
		private function drawBay(graphic:Graphics, x:Number, y:Number, w:Number, h:Number):void
		{
			const INNER_W_OFFSET:Number = INNER_FRAME_OFF_WIDTH * w;
			const INNER_H_OFFSET:Number = INNER_FRAME_OFF_HEIGHT * h;
			
			drawFrame(graphic, x, y, w, h);
			drawFrame(graphic, x + INNER_W_OFFSET, y + INNER_H_OFFSET, w - 2 * INNER_W_OFFSET, h - 2 * INNER_H_OFFSET);
			
			drawWheel(graphic, x + w * WHEEL_RECT_PERC_X, y + h * WHEEL_RECT_PERC_Y,  w * WHEEL_RECT_PERC_WIDTH, h * WHEEL_RECT_PERC_HEIGHT); 
			drawWheel(graphic, x + w - INNER_W_OFFSET, y + h * WHEEL_RECT_PERC_Y,  w * WHEEL_RECT_PERC_WIDTH, h * WHEEL_RECT_PERC_HEIGHT); 
			drawWheel(graphic, x + w * WHEEL_RECT_PERC_X, y + h * WHEEL_RECT_PERC_LOWER_Y,  w * WHEEL_RECT_PERC_WIDTH, h * WHEEL_RECT_PERC_HEIGHT); 
			drawWheel(graphic, x + w - INNER_W_OFFSET, y + h * WHEEL_RECT_PERC_LOWER_Y,  w * WHEEL_RECT_PERC_WIDTH, h * WHEEL_RECT_PERC_HEIGHT); 
		} 
		
		/**
		 * Draws bay frame
		 * @param graphics Grpahics object to be drawn to
		 * @param x Position of an outer rectangle
		 * @param y Position of an outer rectangle
		 * @param w Width of an outer rectangle
		 * @param h Height of an outer rectangle
		 * Draws rectangle on the given position
		 */        
		private function drawFrame(graphics:Graphics, x:Number, y:Number, w:Number, h:Number):void
		{ 
			graphics.lineStyle(LINE_SIZE);
			graphics.drawRect(x, y, w, h);
		}
		
		
		/**
		 * Draws bay wheel on a graphical floor view of a bay/configuration 
		 * @param graphics Graphics to be drawn to
		 * @param x Position of a wheel rectangle
		 * @param y Position of a wheel rectangle
		 * @param w Width of a wheel rectangle
		 * @param h Height of a wheel rectangle
		 * <p>Wheel radius is same as a size of a rectangle diagonal</p>
		 */        
		private function drawWheel(graphics:Graphics, x:Number, y:Number, w:Number, h:Number):void
		{
			graphics.lineStyle(LINE_SIZE);
			graphics.drawRect(x, y, w, h);
			
			graphics.lineStyle(LINE_SIZE - 1, 0, WHEEL_ALPHA);
			graphics.drawCircle(x + w / 2, y + h / 2, Math.sqrt(w * w + h * h) / 2);
		}
		
		
		/**
		 * Draws arrow for bay/configuration floor top view
		 * @param position indicates position where arrow will be drawn
		 * @param length indicates arrow's length
		 * @param graphics indicates Graphics to be drawn to
		 * @param direction indicates direction in which arror will be drawn. Default Left-horizontal direction
		 * @param thickness indicates the thickness of the arrow. Default value is <code> 5</code> 
		 * @param color indicates arrow line color. Default is <code> 0x000000 </code> - black color 
		 * 
		 */
		private function drawArrow(position:Point, 
								   length:uint, 
								   graphics:Graphics, 
								   direction:uint = LEFT_ARROW, 
								   thickness:Number = 5,
								   color:uint = 0x000000):void
		{
			graphics.beginFill(color);
			graphics.lineStyle(0, color);
			graphics.moveTo(position.x, position.y);
			
			switch(direction)
			{
				case LEFT_ARROW:
				{
					graphics.lineTo(position.x + 38, position.y - 15);
					graphics.lineTo(position.x + 30, position.y);
					graphics.lineTo(position.x + 38, position.y + 15);
					graphics.lineTo(position.x, position.y);
					graphics.endFill();
					
					graphics.beginFill(color);
					graphics.lineStyle(thickness, color);
					graphics.moveTo(position.x + 30, position.y);
					graphics.lineTo(position.x + length, position.y);
					graphics.endFill();
					
					break;
				}
				case RIGHT_ARROW:
				{
					graphics.lineTo(position.x - 38, position.y - 15);
					graphics.lineTo(position.x - 30, position.y);
					graphics.lineTo(position.x - 38, position.y + 15);
					graphics.lineTo(position.x, position.y);
					graphics.endFill();
					
					graphics.beginFill(color);
					graphics.lineStyle(thickness, color);
					graphics.moveTo(position.x - 30, position.y);
					graphics.lineTo(position.x - length, position.y);
					graphics.endFill();
					
					break;
				}
				case UP_ARROW:
				{
					graphics.lineTo(position.x - 15, position.y + 38);
					graphics.lineTo(position.x, position.y + 30);
					graphics.lineTo(position.x + 15, position.y + 38);
					graphics.lineTo(position.x, position.y);
					graphics.endFill();
					
					graphics.beginFill(color);
					graphics.lineStyle(thickness, color);
					graphics.moveTo(position.x, position.y + 30);
					graphics.lineTo(position.x, position.y + length);
					graphics.endFill();
					
					break;
				}
				case DOWN_ARROW:
				{
					graphics.lineTo(position.x - 15, position.y - 38);
					graphics.lineTo(position.x, position.y - 30);
					graphics.lineTo(position.x + 15, position.y - 38);
					graphics.lineTo(position.x, position.y);
					graphics.endFill();
					
					graphics.beginFill(color);
					graphics.lineStyle(thickness, color);
					graphics.moveTo(position.x, position.y - 30);
					graphics.lineTo(position.x, position.y - length);
					graphics.endFill();
					
					break;
				}
			}
			
		}
		
		/**
		 * Draws borders for bay/configuration floor top view
		 * @param position indicates position where borders will be drawn
		 * @param length indicates border length
		 * @param graphics indicates Graphics to be drawn to
		 * @param isVertical indicates if borders are vertically displayed 
		 * @param gap indicates gap between borders
		 * @param color indicates border line color. Default value is <code> 0x000000 </code> - black color 
		 * @param thickness indicates the thickness of the border. Default value is <code> 5</code>  
		 * 
		 */
		private function drawBorders(position:Point,
									 length:uint,
									 graphics:Graphics,
									 gap:uint,
									 isVertical:Boolean = true,
									 color:uint = 0x000000, 
									 thickness:Number = 5):void
		{
			graphics.lineStyle(thickness, color);
			graphics.moveTo(position.x, position.y);
			
			if (isVertical)
			{
				graphics.lineTo(position.x, position.y + length);
				graphics.moveTo(position.x + gap, position.y);
				graphics.lineTo(position.x + gap, position.y + length);
			}
			else
			{
				graphics.lineTo(position.x + length, position.y);
				graphics.moveTo(position.x, position.y + gap);
				graphics.lineTo(position.x + length, position.y + gap);
			}
		}
		
		/**
		 * Draw text into specific rectangle
		 * @param rect indicates rectangle where text will be positioned
		 * @param comp indicates parent component
		 * @param text indicates text message
		 * @param fontSize indicates size in pixels
		 * @param arrowDirection indicates arrow direction if text will be placed along with arrow. 
		 * If set to <code>-1</code> this text is displayed as ordinary label
		
		 * @param leading indicates vertical space between lines.Default value is <code> 0 </code>.
		 * @param bold indicates whether the text is bold or normal. Default is <code> true</code>
  		 * @param textAlign indicates the alignment of the text inside its rectangle as a <code>TextFormatAlign</code> value.
		 * Default value is <code> CENTER </code> alignment
		
		 * @param color indicates text color. Default value is <code> 0x000000 </code> - black
		 * 
		 */		
		public function drawText(rect:Rectangle, 
								 comp:UIComponent,
								 text:String,
								 fontSize:int,
								 arrowDirection:int = -1,
								 leading:int = 0,
								 bold:Boolean = true,
								 textAlign:String = TextFormatAlign.CENTER,
								 color:uint = 0x000000):TextField
		{
			var textField:TextField = new TextField();
			var format:TextFormat = new TextFormat("RobotoMobileFont", fontSize, color, bold);
			
			textField.mouseEnabled = false; // disable mouse events
			
			format.align = textAlign;
			format.leading = leading;

			textField.defaultTextFormat = format;
			textField.text = text;
			
			
			// set text width
			textField.width = rect.width;
			textField.height = rect.height;
			
			// set text position
			if (arrowDirection > 0)
			{
				// text will be placed along with arrow
				if (arrowDirection == HORIZONTAL_DIRECTION ||
					arrowDirection == VERTICAL_DIRECTION)
				{
					textField.x = rect.x;
					textField.y = rect.y + (rect.height - textField.textHeight) / 2;
				}
				else if (arrowDirection == VERTICAL_DIRECTION)
				{
					textField.x = rect.x;
					textField.y = rect.y + (rect.height - textField.textHeight) / 2;
				}
				else if (arrowDirection & LEFT_ARROW)
				{
					textField.x = rect.x + rect.width - textField.textWidth; 
					textField.y = rect.y + (rect.height - textField.textHeight) / 2;
				}
				else if (arrowDirection & RIGHT_ARROW)
				{
					textField.x = rect.x; 
					textField.y = rect.y + (rect.height - textField.textHeight) / 2;
				}
				else if (arrowDirection & DOWN_ARROW)
				{
					textField.x = rect.x;
					textField.y = rect.y;
				}
				else if (arrowDirection & UP_ARROW)
				{
					textField.x = rect.x; 
					textField.y = rect.y + rect.height - textField.height;
				}
			}
			else
			{
				// display text as ordinary label
				textField.x = rect.x - textField.textWidth / 2;
				textField.y = rect.y;
			}
			
			// add text
			comp.addChild(textField);
				
			return textField;
		}
		
		/**
		 * Draws bays dimension part of floor top view drawing
		 * @param mainRect indicates rectangle where drawing will be applied
		 * @param component indicates uiComponet containing ComponentBase object
		 * @param direction indicates direction of object drawing
		 * @param arrowLength indicates length for arrow.
		 * If arrow length has default value <code>-1</code>, calculate arrow length based on the text width/height 
		 * 
		 * @param bordersGap indicates gap between borders
		 * @param includeBorders indicates if drawing borders is enabled
		 * @param textDesc indicates text description related to bay/config dimensions
		 * @param thickness indicates the thickness of the drawing lines. Default value is <code> 5</code> 
		 * @param textLineGap indicates vertical space between lines. Default value is <code>0</code> 
		 * @param color indicates drawing line color. Default is <code> 0x000000 </code> - black color 
		 * 
		 */
		private function drawBaysDimension(mainRect:Rectangle,
										   component:UIComponentBase,
										   direction:uint,
										   arrowLength:int = -1,
										   bordersGap:int = -1,					  
										   includeBorders:Boolean = false,
										   textDesc:String = null,
										   thickness:Number = 5,
										   textLineGap:int = 0,
										   color:uint = 0x000000):void
		{
			var arrowPos:Point = new Point();
			
			if (textDesc && textDesc.length > 0)
			{
				// display text
				var textDisplay:TextField = drawText(mainRect, component, textDesc, 45, direction, textLineGap);
				
				// if arrow length hasn't been set 
				// calculate arrow length based on the text width/height 
				if (arrowLength == -1)
				{
					// gap between text and arrow
					var arrowTextGap:uint;
					
					if (direction == HORIZONTAL_DIRECTION)
					{
						arrowTextGap = mainRect.width * 0.13;
						arrowLength = (mainRect.width - textDisplay.textWidth - 2 * arrowTextGap) / 2;
					}
					else if (direction == VERTICAL_DIRECTION)
					{
						arrowTextGap = mainRect.height * 0.04;
						arrowLength = (mainRect.height - textDisplay.textHeight - 2 * arrowTextGap) / 2;
					}
					else if (direction & LEFT_ARROW ||
							 direction & RIGHT_ARROW)
					{
						arrowTextGap = mainRect.width * 0.1;
						arrowLength = mainRect.height - textDisplay.textWidth - arrowTextGap;
					}
					else if (direction & DOWN_ARROW ||
							 direction & UP_ARROW)
					{
						arrowTextGap = mainRect.width * 0.02;
						arrowLength = mainRect.height - textDisplay.textHeight - arrowTextGap;
					}
				}
			}
				
			if (includeBorders)
			{
				if (direction == HORIZONTAL_DIRECTION)
				{
					// draw vertical borders
					drawBorders(new Point(mainRect.x, mainRect.y), mainRect.height, component.graphics, bordersGap, true, color, thickness);
					drawBorders(new Point(mainRect.x + mainRect.width - bordersGap, mainRect.y), mainRect.height, component.graphics, bordersGap, true, color, thickness);
					
					// draw arrows
					arrowPos.x = mainRect.x + bordersGap;
					arrowPos.y = mainRect.y + mainRect.height / 2;
					drawArrow(arrowPos, arrowLength, component.graphics, LEFT_ARROW, thickness, color);
					
					arrowPos.x = mainRect.x + mainRect.width - bordersGap;
					drawArrow(arrowPos, arrowLength, component.graphics, RIGHT_ARROW, thickness, color);
				}
				else if (direction == VERTICAL_DIRECTION)
				{
					// draw horizontal borders
					drawBorders(new Point(mainRect.x, mainRect.y), mainRect.width, component.graphics, bordersGap, false, color, thickness);
					drawBorders(new Point(mainRect.x, mainRect.y + mainRect.height - bordersGap), mainRect.width, component.graphics, bordersGap, false, color, thickness);
					
					// draw arrows
					arrowPos.x = mainRect.x + mainRect.width / 2;
					arrowPos.y = mainRect.y + bordersGap;
					drawArrow(arrowPos, arrowLength, component.graphics, UP_ARROW, thickness, color);
					
					arrowPos.y = mainRect.y + mainRect.height - bordersGap;
					drawArrow(arrowPos, arrowLength, component.graphics, DOWN_ARROW, thickness, color);
				}
			}
			else
			{
				// draw only arrows
				if (Boolean(direction & LEFT_ARROW))
				{
					// left horizontal arrow
					arrowPos.x = mainRect.x;
					arrowPos.y = mainRect.y + mainRect.height / 2;
					
					drawArrow(arrowPos, arrowLength, component.graphics, LEFT_ARROW, thickness, color);		
				}
				
				if (Boolean(direction & RIGHT_ARROW))
				{
					// right horizontal arrow
					arrowPos.x = mainRect.x + mainRect.width;
					arrowPos.y = mainRect.y + mainRect.height / 2;
					
					drawArrow(arrowPos, arrowLength, component.graphics, RIGHT_ARROW, thickness, color);
				}
				
				if (Boolean(direction & UP_ARROW))
				{
					// up vertical arrow
					arrowPos.x = mainRect.x + mainRect.width / 2;
					arrowPos.y = mainRect.y;
					
					drawArrow(arrowPos, arrowLength, component.graphics, UP_ARROW, thickness, color);
				}
				
				if (Boolean(direction & DOWN_ARROW))
				{
					// down vertical arrow
					arrowPos.x = mainRect.x + mainRect.width / 2;
					arrowPos.y = mainRect.y + mainRect.height;
					
					drawArrow(arrowPos, arrowLength, component.graphics, DOWN_ARROW, thickness, color);
					
				}
			}
			
		}
 
        /**
        * get some scaling for better quality drilled component
        */
        private function getZoomScale(cb:ComponentBase):Number{
            if(cb is PDP || cb is PDU || cb is EnginePort || cb is PDU_VG3R) 
                return 5;
            if( cb is MIBE || cb.isEngine || cb is DAE || cb is InfinibandSwitch)
			{
                return 1.5;
			}
            if(cb is SPS || cb is DataMover){
                return 2;
            }
			if (cb is UPS || cb is ControlStation)
				return 3;
         
            return 1;
        }
		/**
		 * Renders transparent overlay component 
		 * @param component indicates main component
		 * @param viewSide indicates <code> true </code> if rendering backside
		 */
		private function renderOverlayComponent(uiComp:UIComponentBase, viewSide:String, parentRect:Rectangle):void {
			var component:ComponentBase = uiComp.componentBase;
			if(component is Bay && is250F() && viewSide == Constants.REAR_VIEW_PERSPECTIVE)
			{
				var pdpOverlayComponent_right:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.PDU_250F,-1,true,null,false);
				var pdpOverlayComponent_left:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.PDU_250F,-1,true,null,false);
				
				pdpOverlayComponent_right.generateOverlayPosition(uiComp.width*0.9 + 5,uiComp.height*0.6 + 20,20,235);
				pdpOverlayComponent_right.toolTip = "PDP A";
				
				pdpOverlayComponent_left.generateOverlayPosition(uiComp.width*0.1 - 22, uiComp.height*0.6 + 20 ,20,235);
				pdpOverlayComponent_left.toolTip = "PDP B";
				
				uiComp.addChild(pdpOverlayComponent_right);
				uiComp.addChild(pdpOverlayComponent_left);
				
				
				
			}
			
			if (component is MIBE) {
				if (viewSide == Constants.FRONT_VIEW_PERSPECTIVE) {
					var mibePowerSupply1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.MIBE_POWER_SUPPLY, 0);
					var mibePowerSupply2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.MIBE_POWER_SUPPLY, 1);
					var mibePowerSupply3:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.MIBE_POWER_SUPPLY, 2);
					var mibePowerSupply4:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.MIBE_POWER_SUPPLY, 3);

					mibePowerSupply1.generateOverlayPosition(0, 0, uiComp.width * MIBE_POWER_SUPPLY_PERCENT_WIDTH, uiComp.height);
					mibePowerSupply1.toolTip = _toolTipProvider.getToolTip(viewSide, component, mibePowerSupply1);
					
					mibePowerSupply2.generateOverlayPosition(mibePowerSupply1.width, 0, mibePowerSupply1.width, uiComp.height);
					mibePowerSupply2.toolTip = _toolTipProvider.getToolTip(viewSide, component, mibePowerSupply2);
					
					mibePowerSupply3.generateOverlayPosition(mibePowerSupply2.x + mibePowerSupply2.width, 0, mibePowerSupply2.width, uiComp.height);
					mibePowerSupply3.toolTip = _toolTipProvider.getToolTip(viewSide, component, mibePowerSupply3);
					
					mibePowerSupply4.generateOverlayPosition(mibePowerSupply3.x + mibePowerSupply3.width, 0, mibePowerSupply3.width, uiComp.height);
					mibePowerSupply4.toolTip = _toolTipProvider.getToolTip(viewSide, component, mibePowerSupply4);
					
					// add overlay components to MIBE
					uiComp.addChild(mibePowerSupply1);
					uiComp.addChild(mibePowerSupply2);
					uiComp.addChild(mibePowerSupply3);
					uiComp.addChild(mibePowerSupply4);
				}
				else {
					var mibeAssembly1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.MIBE_ASSEMBLY, 0, true);
					var mibeAssembly2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.MIBE_ASSEMBLY, 1, true);

					mibeAssembly1.generateOverlayPosition(0, 0, uiComp.width * MIBE_ASSEMBLY_PERCENT_WIDTH, uiComp.height);
					mibeAssembly1.toolTip = _toolTipProvider.getToolTip(viewSide, component, mibeAssembly1);
					
					mibeAssembly2.generateOverlayPosition(mibeAssembly1.width, 0, mibeAssembly1.width, uiComp.height);
					mibeAssembly2.toolTip = _toolTipProvider.getToolTip(viewSide, component, mibeAssembly2);
					
					// add overlay components to MIBE
					uiComp.addChild(mibeAssembly1);
					uiComp.addChild(mibeAssembly2);
				}
			}
			if (component is D15 && component.position.type == Position.BAY_ENCLOSURE) {
				if (viewSide == Constants.REAR_VIEW_PERSPECTIVE) {
					var daePS1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_POWER_SUPPLY, 0, true, TransparentOverlayConstants.POSITION_HORIZONTAL);
					var daeLCC1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_LCC, 1, true, TransparentOverlayConstants.POSITION_HORIZONTAL);
					var daeLCC2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_LCC, 2, true, TransparentOverlayConstants.POSITION_HORIZONTAL);
					var daePS2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_POWER_SUPPLY, 3, true, TransparentOverlayConstants.POSITION_HORIZONTAL);

					daePS1.generateOverlayPosition(0, 0, uiComp.width, uiComp.height * D15_BAY_ENCLOSURE_POWER_SUPPLY_PERCENT_HEIGHT);
					daePS1.toolTip = _toolTipProvider.getToolTip(viewSide, component, daePS1);
					
					daeLCC1.generateOverlayPosition(0, daePS1.height, uiComp.width, uiComp.height * D15_BAY_ENCLOSURE_LCC_PERCENT_HEIGHT);
					daeLCC1.toolTip = _toolTipProvider.getToolTip(viewSide, component, daeLCC1);
					
					daeLCC2.generateOverlayPosition(0, daeLCC1.y + daeLCC1.height, uiComp.width, daeLCC1.height);
					daeLCC2.toolTip = _toolTipProvider.getToolTip(viewSide, component, daeLCC2);
					
					daePS2.generateOverlayPosition(0, daeLCC2.y + daeLCC2.height, uiComp.width, daePS1.height);
					daePS2.toolTip = _toolTipProvider.getToolTip(viewSide, component, daePS2); 
					
					// add overlay components to D15
					uiComp.addChild(daePS1);
					uiComp.addChild(daePS2);
					uiComp.addChild(daeLCC1);
					uiComp.addChild(daeLCC2);
				}
			}
			if (component is D15 && (component.position.type == Position.UPPERHALFBAYVERTICAL || component.position.type == Position.LOWERHALFBAYVERTICAL)) {
				if (viewSide == Constants.REAR_VIEW_PERSPECTIVE) {
					var daePS3:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_POWER_SUPPLY, 0, true, TransparentOverlayConstants.POSITION_VERTICAL);
					var daeLCC3:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_LCC, 1, true, TransparentOverlayConstants.POSITION_VERTICAL);
					var daeLCC4:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_LCC, 2, true, TransparentOverlayConstants.POSITION_VERTICAL);
					var daePS4:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_POWER_SUPPLY, 3, true, TransparentOverlayConstants.POSITION_VERTICAL);

					daePS3.generateOverlayPosition(0, 0, uiComp.width * D15_HALFBAYVERTICAL_POWER_SUPPLY_PERCENT_WIDTH, uiComp.height);
					daePS3.toolTip = _toolTipProvider.getToolTip(viewSide, component, daePS3);
					
					daeLCC3.generateOverlayPosition(daePS3.width, 0, uiComp.width * D15_HALFBAYVERTICAL_LCC_PERCENT_WIDTH, uiComp.height);
					daeLCC3.toolTip = _toolTipProvider.getToolTip(viewSide, component, daeLCC3);
					
					daeLCC4.generateOverlayPosition(daeLCC3.x + daeLCC3.width, 0, daeLCC3.width, uiComp.height);
					daeLCC4.toolTip = _toolTipProvider.getToolTip(viewSide, component, daeLCC4);
					
					daePS4.generateOverlayPosition(daeLCC4.x + daeLCC4.width, 0, daePS3.width, uiComp.height);
					daePS4.toolTip = _toolTipProvider.getToolTip(viewSide, component, daePS4);
					
					// add overlay components to D15
					uiComp.addChild(daePS3);
					uiComp.addChild(daePS4);
					uiComp.addChild(daeLCC3);
					uiComp.addChild(daeLCC4);					
				}
			}
			if (component is Vanguard) {
				if (viewSide == Constants.REAR_VIEW_PERSPECTIVE) {
					var daePS5:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_POWER_SUPPLY, 0, true, TransparentOverlayConstants.POSITION_VERTICAL);
					var daeLCC5:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_LCC, 1, true, TransparentOverlayConstants.POSITION_VERTICAL);
					var daeLCC6:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_LCC, 2, true, TransparentOverlayConstants.POSITION_VERTICAL);
					var daePS6:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_POWER_SUPPLY, 3, true, TransparentOverlayConstants.POSITION_VERTICAL);

					daePS5.generateOverlayPosition(0, 0, uiComp.width * VANGUARD_POWER_SUPPLY_PERCENT_WIDTH, uiComp.height);
					daePS5.toolTip = _toolTipProvider.getToolTip(viewSide, component, daePS5);
					
					daeLCC5.generateOverlayPosition(daePS5.width, 0, uiComp.width * VANGUARD_LCC_PERCENT_WIDTH, uiComp.height * VANGUARD_LCC_PERCENT_HEIGHT);
					daeLCC5.toolTip = _toolTipProvider.getToolTip(viewSide, component, daeLCC5);
					
					daeLCC6.generateOverlayPosition(daeLCC5.x, daeLCC5.height, daeLCC5.width, daeLCC5.height);
					daeLCC6.toolTip = _toolTipProvider.getToolTip(viewSide, component, daeLCC6);
					
					daePS6.generateOverlayPosition(daeLCC6.x + daeLCC6.width, 0, daePS5.width, uiComp.height);
					daePS6.toolTip = _toolTipProvider.getToolTip(viewSide, component, daePS6);
					
					// add overlay components to Vanguard
					uiComp.addChild(daePS5);
					uiComp.addChild(daePS6);
					uiComp.addChild(daeLCC5);
					uiComp.addChild(daeLCC6);			
				}
			}
			if (component is Viking)
			{
				if (viewSide == Constants.FRONT_VIEW_PERSPECTIVE)
				{
					var cf1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 0);
					var cf2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 1);
					var cf3:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 2);
					var cf4:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 3);
					var cf5:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 4);
                    var ssc:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.VIKING_SSC, 5);
					
					cf1.generateOverlayPosition(uiComp.width * VIKING_FAN_ENCLOSURE.x, uiComp.height * VIKING_FAN_ENCLOSURE.y, uiComp.width * VIKING_FAN_ENCLOSURE.width, uiComp.height * VIKING_FAN_ENCLOSURE.height);
					cf1.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf1);
					
					cf2.generateOverlayPosition(cf1.x + cf1.width, cf1.y, cf1.width, cf1.height);
					cf2.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf2);
					
					cf3.generateOverlayPosition(cf2.x + cf2.width, cf1.y, cf1.width, cf1.height);
					cf3.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf3);
					
					cf4.generateOverlayPosition(cf3.x + cf3.width, cf1.y, cf1.width, cf1.height);
					cf4.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf4);

					cf5.generateOverlayPosition(cf4.x + cf4.width, cf1.y, cf1.width * 0.9, cf1.height);
					cf5.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf5);
                    
                    ssc.generateOverlayPosition(uiComp.width * VIKING_SSC_RECTANGLE.x, uiComp.height * VIKING_SSC_RECTANGLE.y, uiComp.width * VIKING_SSC_RECTANGLE.width, uiComp.height * VIKING_SSC_RECTANGLE.height);
                    ssc.toolTip = _toolTipProvider.getToolTip(viewSide, component, ssc);
					// add cmps to Viking
					uiComp.addChild(cf1);
					uiComp.addChild(cf2);
					uiComp.addChild(cf3);
					uiComp.addChild(cf4);
					uiComp.addChild(cf5);
                    uiComp.addChild(ssc);
				}
				if (viewSide == Constants.REAR_VIEW_PERSPECTIVE)
				{
					var psu1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_POWER_SUPPLY, 0, true);
					var psu2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_POWER_SUPPLY, 1, true);
					var psu3:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_POWER_SUPPLY, 2, true);
					var psu4:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_POWER_SUPPLY, 3, true);
					var lcc1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_LCC, 4, true);
					var lcc2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_LCC, 5, true);
					
					psu1.generateOverlayPosition(VIKING_POWER_SUPPLY_ENCLOSURE.x, VIKING_POWER_SUPPLY_ENCLOSURE.y, uiComp.width * VIKING_POWER_SUPPLY_ENCLOSURE.width, uiComp.height * VIKING_POWER_SUPPLY_ENCLOSURE.height);
					psu1.toolTip = _toolTipProvider.getToolTip(viewSide, component, psu1);
					
					psu2.generateOverlayPosition(psu1.x + psu1.width, psu1.y, psu1.width, psu1.height);
					psu2.toolTip = _toolTipProvider.getToolTip(viewSide, component, psu2);
					
					psu3.generateOverlayPosition(psu2.x + psu2.width, psu2.y, psu2.width, psu2.height);
					psu3.toolTip = _toolTipProvider.getToolTip(viewSide, component, psu3);
					
					psu4.generateOverlayPosition(psu3.x + psu3.width, psu2.y, psu3.width, psu3.height);
					psu4.toolTip = _toolTipProvider.getToolTip(viewSide, component, psu4); 
					
					lcc1.generateOverlayPosition(VIKING_LCC_ENCLOSURE.x, uiComp.height * VIKING_LCC_ENCLOSURE.y, uiComp.width * VIKING_LCC_ENCLOSURE.width, uiComp.height * VIKING_LCC_ENCLOSURE.height);
					lcc1.toolTip = _toolTipProvider.getToolTip(viewSide, component, lcc1);
					
					lcc2.generateOverlayPosition(lcc1.x + lcc1.width, lcc1.y, lcc1.width, lcc1.height);
					lcc2.toolTip = _toolTipProvider.getToolTip(viewSide, component, lcc2);
					
					// add overlay components to Viking
					uiComp.addChild(psu1);
					uiComp.addChild(psu2);
					uiComp.addChild(psu3);
					uiComp.addChild(psu4);
					uiComp.addChild(lcc1);
					uiComp.addChild(lcc2);
				}
				if (viewSide == Constants.TOP_VIEW_PERSPECTIVE)
				{
					var cf1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 0, true);
					var cf2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 1, true);
					var cf3:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 2, true);
					var cf4:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 3, true);
					var cf5:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 4, true);
					var cf6:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 5);
					var cf7:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 6);
					var cf8:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 7);
					var cf9:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 8);
					var cf10:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 9);
					
					cf1.generateOverlayPosition(uiComp.width * VIKING_TOP_FAN_ENCLOSURE.x, uiComp.height * VIKING_TOP_FAN_ENCLOSURE.y, uiComp.width * VIKING_TOP_FAN_ENCLOSURE.width, uiComp.height * VIKING_TOP_FAN_ENCLOSURE.height);
					cf1.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf1);
					
					cf2.generateOverlayPosition(cf1.x + cf1.width, cf1.y, cf1.width, cf1.height);
					cf2.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf2);
					
					cf3.generateOverlayPosition(cf2.x + cf2.width, cf1.y, cf1.width, cf1.height);
					cf3.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf3);
					
					cf4.generateOverlayPosition(cf3.x + cf3.width, cf1.y, cf1.width, cf1.height);
					cf4.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf4);
					
					cf5.generateOverlayPosition(cf4.x + cf4.width - cf1.y, cf1.y, cf1.width, cf1.height);
					cf5.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf5);
					
					cf6.generateOverlayPosition(cf1.x, uiComp.height - cf1.height, cf1.width, cf1.height);
					cf6.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf6);
					
					cf7.generateOverlayPosition(cf2.x, cf6.y, cf6.width, cf6.height);
					cf7.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf7);
					
					cf8.generateOverlayPosition(cf3.x - cf1.y, cf7.y, cf7.width, cf7.height);
					cf8.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf8);
					
					cf9.generateOverlayPosition(cf4.x - cf1.y, cf8.y, cf8.width, cf8.height);
					cf9.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf9);

					cf10.generateOverlayPosition(cf5.x, cf9.y, cf9.width, cf9.height);
					cf10.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf10);
					
					// add cmps to Viking
					uiComp.addChild(cf1);
					uiComp.addChild(cf2);
					uiComp.addChild(cf3);
					uiComp.addChild(cf4);
					uiComp.addChild(cf5);
					uiComp.addChild(cf6);
					uiComp.addChild(cf7);
					uiComp.addChild(cf8);
					uiComp.addChild(cf9);
					uiComp.addChild(cf10);
				}
				
			}
			if (component is Voyager)
			{
				if (viewSide == Constants.FRONT_VIEW_PERSPECTIVE)
				{
					var f1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 0);
					var f2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 1);
					var f3:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 2);
					
					f1.generateOverlayPosition(uiComp.width * VOYAGER_FAN_ENCLOSURE.x, uiComp.height * VOYAGER_FAN_ENCLOSURE.y, uiComp.width * VOYAGER_FAN_ENCLOSURE.width, uiComp.height * VOYAGER_FAN_ENCLOSURE.height);
					f1.toolTip = _toolTipProvider.getToolTip(viewSide, component, f1);
					
					f2.generateOverlayPosition(f1.width + f1.y, f1.y, f1.width, f1.height);
					f2.toolTip = _toolTipProvider.getToolTip(viewSide, component, f2);
					
					f3.generateOverlayPosition(f2.x + f2.width + f1.y, f1.y, f1.width, f1.height);
					f3.toolTip = _toolTipProvider.getToolTip(viewSide, component, f3);
					
					// add cmps to Voyager
					uiComp.addChild(f1);
					uiComp.addChild(f2);
					uiComp.addChild(f3);
				}
				if (viewSide == Constants.REAR_VIEW_PERSPECTIVE)
				{
					var lcc1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_LCC, 0, true);
					var lcc2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_LCC, 5, true);
					var psu1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_POWER_SUPPLY, 1, true);
					var psu2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_POWER_SUPPLY, 2, true);
					var psu3:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_POWER_SUPPLY, 3, true);
					var psu4:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_POWER_SUPPLY, 4, true);
					
					lcc1.generateOverlayPosition(VOYAGER_LCC_ENCLOSURE.x, VOYAGER_LCC_ENCLOSURE.y, uiComp.width * VOYAGER_LCC_ENCLOSURE.width, uiComp.height * VOYAGER_LCC_ENCLOSURE.height);
					lcc1.toolTip = _toolTipProvider.getToolTip(viewSide, component, lcc1);

					psu1.generateOverlayPosition(lcc1.width, VOYAGER_POWER_SUPPLY_ENCLOSURE.y, uiComp.width * VOYAGER_POWER_SUPPLY_ENCLOSURE.width, uiComp.height * VOYAGER_POWER_SUPPLY_ENCLOSURE.height);
					psu1.toolTip = _toolTipProvider.getToolTip(viewSide, component, psu1);
					
					psu2.generateOverlayPosition(psu1.x + psu1.width, psu1.y, psu1.width, psu1.height);
					psu2.toolTip = _toolTipProvider.getToolTip(viewSide, component, psu2);
					
					psu3.generateOverlayPosition(psu2.x + psu2.width, psu2.y, psu2.width, psu2.height);
					psu3.toolTip = _toolTipProvider.getToolTip(viewSide, component, psu3);
					
					psu4.generateOverlayPosition(psu3.x + psu3.width, psu2.y, psu3.width, psu3.height);
					psu4.toolTip = _toolTipProvider.getToolTip(viewSide, component, psu4);
					
					lcc2.generateOverlayPosition(psu4.x + psu4.width, lcc1.y, lcc1.width, lcc1.height);
					lcc2.toolTip = _toolTipProvider.getToolTip(viewSide, component, lcc2);
					
					// add overlay components to Voyager
					uiComp.addChild(lcc1);
					uiComp.addChild(psu1);
					uiComp.addChild(psu2);
					uiComp.addChild(psu3);
					uiComp.addChild(psu4);
					uiComp.addChild(lcc2);
				}
				if (viewSide == Constants.TOP_VIEW_PERSPECTIVE)
				{
					var cf1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 0);
					var cf2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 1);
					var cf3:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_COOLING_FAN, 2);
					var lcc1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_LCC, 3);
					var lcc2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_LCC, 4);
					
					cf1.generateOverlayPosition(uiComp.width * VOYAGER_TOP_FAN_ENCLOSURE.x, uiComp.height * VOYAGER_TOP_FAN_ENCLOSURE.y, uiComp.width * VOYAGER_TOP_FAN_ENCLOSURE.width, uiComp.height * VOYAGER_TOP_FAN_ENCLOSURE.height);
					cf1.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf1);
					
					cf2.generateOverlayPosition(cf1.x + cf1.width, cf1.y, cf1.width - cf1.x, cf1.height);
					cf2.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf2);
					
					cf3.generateOverlayPosition(cf2.x + cf2.width - cf1.x, cf1.y, cf1.width - cf1.x, cf1.height);
					cf3.toolTip = _toolTipProvider.getToolTip(viewSide, component, cf3);
					
					lcc1.generateOverlayPosition(uiComp.width * VOYAGER_TOP_LCC_ENCLOSURE.x, uiComp.height * VOYAGER_TOP_LCC_ENCLOSURE.y, uiComp.width * VOYAGER_TOP_LCC_ENCLOSURE.width, uiComp.height * VOYAGER_TOP_LCC_ENCLOSURE.height);
					lcc1.toolTip = _toolTipProvider.getToolTip(viewSide, component, lcc1);

					lcc2.generateOverlayPosition(lcc1.x, lcc1.y + lcc1.height, lcc1.width, lcc1.height);
					lcc2.toolTip = _toolTipProvider.getToolTip(viewSide, component, lcc2);
					
					// add cmps to Voyager
					uiComp.addChild(cf1);
					uiComp.addChild(cf2);
					uiComp.addChild(cf3);
					uiComp.addChild(lcc1);
					uiComp.addChild(lcc2);
				}
			}
			
			if (component is SPS && component.position.type == Position.MIDDLEBAYVERTICAL)
				if (viewSide == Constants.REAR_VIEW_PERSPECTIVE) {
					var spsLED1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.SPS_ON_LINE_ENABLED_CHARGING_LED, 0, true, TransparentOverlayConstants.POSITION_VERTICAL);
					var spsLED2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.SPS_ON_BATTERY_LED, 1, true, TransparentOverlayConstants.POSITION_VERTICAL);
					var spsLED3:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.SPS_REPLACE_BATTERIES_LED, 2, true, TransparentOverlayConstants.POSITION_VERTICAL);
					var spsLED4:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.SPS_INTERNAL_CHECK_LED, 3, true, TransparentOverlayConstants.POSITION_VERTICAL);
					
					var xPos:Number = uiComp.width - uiComp.width * SPS_ENGINELEFT_LED_INDICATOR_X_PERCENT_WIDTH;
					var yPos:Number = uiComp.height * SPS_ENGINELEFT_LED_INDICATOR_PERCENT_HEIGHT + uiComp.width * SPS_ENGINELEFT_LED_INDICATOR_Y_PERCENT_WIDTH;
					var ledWidth:Number = uiComp.width * SPS_ENGINELEFT_LED_INDICATOR_PERCENT_WIDTH;
					
					spsLED1.generateOverlayPosition(xPos, yPos, ledWidth, ledWidth);
					spsLED1.toolTip = _toolTipProvider.getToolTip(viewSide, component, spsLED1);
						
					spsLED2.generateOverlayPosition(spsLED1.x, spsLED1.y + spsLED1.height, ledWidth, ledWidth);
					spsLED2.toolTip = _toolTipProvider.getToolTip(viewSide, component, spsLED2);
					
					spsLED3.generateOverlayPosition(spsLED1.x, spsLED2.y + spsLED2.height, ledWidth, ledWidth);
					spsLED3.toolTip = _toolTipProvider.getToolTip(viewSide, component, spsLED3);
					
					spsLED4.generateOverlayPosition(spsLED1.x, spsLED3.y + spsLED3.height, ledWidth, ledWidth);
					spsLED4.toolTip = _toolTipProvider.getToolTip(viewSide, component, spsLED4);
					
					// add overlay components to SPS
					uiComp.addChild(spsLED1); 
					uiComp.addChild(spsLED2); 
					uiComp.addChild(spsLED3); 
					uiComp.addChild(spsLED4); 
				}
			if (component is SPS && component.position.type == Position.ENGINESIDE_SPS_LEFT) {
				if (viewSide == Constants.FRONT_VIEW_PERSPECTIVE)
				{
					var spsLED5:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.SPS_ON_LINE_ENABLED_CHARGING_LED, 0, false, TransparentOverlayConstants.POSITION_VERTICAL);
					var spsLED6:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.SPS_ON_BATTERY_LED, 1, false, TransparentOverlayConstants.POSITION_VERTICAL);
					var spsLED7:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.SPS_REPLACE_BATTERIES_LED, 2, false, TransparentOverlayConstants.POSITION_VERTICAL);
					var spsLED8:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.SPS_INTERNAL_CHECK_LED, 3, false, TransparentOverlayConstants.POSITION_VERTICAL);

					var xPos1:Number = uiComp.width - uiComp.width * SPS_ENGINELEFT_LED_INDICATOR_X_PERCENT_WIDTH;
					var yPos1:Number = uiComp.height * SPS_ENGINELEFT_LED_INDICATOR_PERCENT_HEIGHT + uiComp.width * SPS_ENGINELEFT_LED_INDICATOR_Y_PERCENT_WIDTH;
					var ledWidth1:Number = uiComp.width * SPS_ENGINELEFT_LED_INDICATOR_PERCENT_WIDTH;
					
					spsLED5.generateOverlayPosition(xPos1, yPos1, ledWidth1, ledWidth1);
					spsLED5.toolTip = _toolTipProvider.getToolTip(viewSide, component, spsLED5);
					
					spsLED6.generateOverlayPosition(spsLED5.x, spsLED5.y + spsLED5.height, spsLED5.width, spsLED5.height);
					spsLED6.toolTip = _toolTipProvider.getToolTip(viewSide, component, spsLED6);
					
					spsLED7.generateOverlayPosition(spsLED5.x, spsLED6.y + spsLED6.height, spsLED5.width, spsLED5.height);
					spsLED7.toolTip = _toolTipProvider.getToolTip(viewSide, component, spsLED7);
					
					spsLED8.generateOverlayPosition(spsLED5.x, spsLED7.y + spsLED7.height, spsLED5.width, spsLED5.height);
					spsLED8.toolTip = _toolTipProvider.getToolTip(viewSide, component, spsLED8);
					
					// add overlay components to SPS
					uiComp.addChild(spsLED5); 
					uiComp.addChild(spsLED6); 
					uiComp.addChild(spsLED7); 
					uiComp.addChild(spsLED8); 
				}
			}
				
			if (component is SPS && component.position.type == Position.ENGINESIDE_SPS_RIGHT) {
				if (viewSide == Constants.FRONT_VIEW_PERSPECTIVE) {
					var spsLED9:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.SPS_INTERNAL_CHECK_LED, 0, false, TransparentOverlayConstants.POSITION_VERTICAL);
					var spsLED10:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.SPS_REPLACE_BATTERIES_LED, 1, false, TransparentOverlayConstants.POSITION_VERTICAL);
					var spsLED11:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.SPS_ON_BATTERY_LED, 2, false, TransparentOverlayConstants.POSITION_VERTICAL);
					var spsLED12:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.SPS_ON_LINE_ENABLED_CHARGING_LED, 3, false, TransparentOverlayConstants.POSITION_VERTICAL);

					var xPos2:Number = uiComp.width * SPS_ENGINERIGHT_LED_INDICATOR_PERCENT_WIDTH;
					var yPos2:Number = uiComp.height * SPS_ENGINERIGHT_LED_INDICATOR_PERCENT_HEIGHT;
					var ledWidth2:Number = uiComp.width * SPS_ENGINELEFT_LED_INDICATOR_PERCENT_WIDTH;
					
					spsLED9.generateOverlayPosition(xPos2, yPos2, ledWidth2, ledWidth2);
					spsLED9.toolTip = _toolTipProvider.getToolTip(viewSide, component, spsLED9);
					
					spsLED10.generateOverlayPosition(spsLED9.x, spsLED9.y + spsLED9.height, spsLED9.width, spsLED9.height);
					spsLED10.toolTip = _toolTipProvider.getToolTip(viewSide, component, spsLED10);
					
					spsLED11.generateOverlayPosition(spsLED9.x, spsLED10.y + spsLED10.height, spsLED9.width, spsLED9.height);
					spsLED11.toolTip = _toolTipProvider.getToolTip(viewSide, component, spsLED11);
					
					spsLED12.generateOverlayPosition(spsLED9.x, spsLED11.y + spsLED11.height, spsLED9.width, spsLED9.height);
					spsLED12.toolTip = _toolTipProvider.getToolTip(viewSide, component, spsLED12);
					
					// add overlay components to SPS
					uiComp.addChild(spsLED9); 
					uiComp.addChild(spsLED10); 
					uiComp.addChild(spsLED11); 
					uiComp.addChild(spsLED12); 
				}
			}
				
			if (component is SPS && (component.position.type == Position.BAY_HALF_ENCLOSURE_LEFT || component.position.type == Position.BAY_HALF_ENCLOSURE_RIGHT)) {
				if (viewSide == Constants.REAR_VIEW_PERSPECTIVE) {
					var spsLED13:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.SPS_INTERNAL_CHECK_LED, 0, false, TransparentOverlayConstants.POSITION_VERTICAL);
					var spsLED14:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.SPS_REPLACE_BATTERIES_LED, 1, false, TransparentOverlayConstants.POSITION_VERTICAL);
					var spsLED15:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.SPS_ON_BATTERY_LED, 2, false, TransparentOverlayConstants.POSITION_VERTICAL);
					var spsLED16:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.SPS_ON_LINE_ENABLED_CHARGING_LED, 3, false, TransparentOverlayConstants.POSITION_VERTICAL);
					
					var xPos3:Number = uiComp.width * SPS_BAY_ENCLOSURE_LED_INDICATOR_X_PERCENT_WIDTH;
					var yPos3:Number = uiComp.height * SPS_BAY_ENCLOSURE_LED_INDICATOR_Y_PERCENT_HEIGHT;
					var ledWidth3:Number = uiComp.height * SPS_BAY_ENCLOSURE_LED_INDICATOR_PERCENT_HEIGHT;
					
					spsLED13.generateOverlayPosition(xPos3, yPos3, ledWidth3, ledWidth3);
					spsLED13.toolTip = _toolTipProvider.getToolTip(viewSide, component, spsLED13);
					
					spsLED14.generateOverlayPosition(spsLED13.x + spsLED13.width, spsLED13.y, spsLED13.width, spsLED13.height);
					spsLED14.toolTip = _toolTipProvider.getToolTip(viewSide, component, spsLED14);
					
					spsLED15.generateOverlayPosition(spsLED14.x + spsLED13.width + spsLED13.width * SPS_BAY_ENCLOSURE_LED_INDICATOR_PERCENT, spsLED13.y, spsLED13.width, spsLED13.height);
					spsLED15.toolTip = _toolTipProvider.getToolTip(viewSide, component, spsLED15);
					
					spsLED16.generateOverlayPosition(spsLED15.x + spsLED13.width, spsLED13.y, spsLED13.width, spsLED13.height);
					spsLED16.toolTip = _toolTipProvider.getToolTip(viewSide, component, spsLED16);
					
					// add overlay components to SPS
					uiComp.addChild(spsLED13); 
					uiComp.addChild(spsLED14); 
					uiComp.addChild(spsLED15); 
					uiComp.addChild(spsLED16); 
				}
			}
			
			if (component.isEngine && viewSide == Constants.FRONT_VIEW_PERSPECTIVE) {
				if (component is sym.objectmodel.common.Engine)
				{
					var f1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_VG3R_COOLING_FAN, 0);					
					var f2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_VG3R_COOLING_FAN, 1);					
					var f3:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_VG3R_COOLING_FAN, 2);					
					var f4:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_VG3R_COOLING_FAN, 3);					
					var f5:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_VG3R_COOLING_FAN, 4);					
					var f6:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_VG3R_COOLING_FAN, 5);					
					var f7:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_VG3R_COOLING_FAN, 6);					
					var f8:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_VG3R_COOLING_FAN, 7);					
					var f9:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_VG3R_COOLING_FAN, 8);					
					var f10:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_VG3R_COOLING_FAN, 9);					
					var ps1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_VG3R_POWER_SUPPLY, 10);					
					var ps2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_VG3R_POWER_SUPPLY, 11);					
					var ps3:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_VG3R_POWER_SUPPLY, 12);					
					var ps4:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_VG3R_POWER_SUPPLY, 13);
                    var fd1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_VG3R_FLASH_DRIVE, 15);
                    var fd2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_VG3R_FLASH_DRIVE, 14);
					
					f1.generateOverlayPosition(uiComp.width * ENGINE_VG3R_FAN_RECT.x, uiComp.height * ENGINE_VG3R_FAN_RECT.y, uiComp.width * ENGINE_VG3R_FAN_RECT.width, uiComp.height * ENGINE_VG3R_FAN_RECT.height);
					f1.toolTip = _toolTipProvider.getToolTip(viewSide, component, f1);
					
					f2.generateOverlayPosition(f1.x + f1.width, f1.y, f1.width, f1.height);
					f2.toolTip = _toolTipProvider.getToolTip(viewSide, component, f2);
					
					f3.generateOverlayPosition(f2.x + f2.width, f2.y, f2.width, f2.height);
					f3.toolTip = _toolTipProvider.getToolTip(viewSide, component, f3);
					
					f4.generateOverlayPosition(f3.x + f3.width, f3.y, f3.width, f3.height);
					f4.toolTip = _toolTipProvider.getToolTip(viewSide, component, f4);

					f5.generateOverlayPosition(f4.x + f4.width, f4.y, f4.width, f4.height);
					f5.toolTip = _toolTipProvider.getToolTip(viewSide, component, f5);
					
					f6.generateOverlayPosition(f1.x, 2*f1.y + f1.height, f1.width, f1.height);
					f6.toolTip = _toolTipProvider.getToolTip(viewSide, component, f6);
					
					f7.generateOverlayPosition(f6.x + f6.width, f6.y, f6.width, f6.height);
					f7.toolTip = _toolTipProvider.getToolTip(viewSide, component, f7);
					
					f8.generateOverlayPosition(f7.x + f7.width, f7.y, f7.width, f7.height);
					f8.toolTip = _toolTipProvider.getToolTip(viewSide, component, f8);
					
					f9.generateOverlayPosition(f8.x + f8.width, f8.y, f8.width, f8.height);
					f9.toolTip = _toolTipProvider.getToolTip(viewSide, component, f9);

					f10.generateOverlayPosition(f9.x + f9.width, f9.y, f9.width, f9.height);
					f10.toolTip = _toolTipProvider.getToolTip(viewSide, component, f10);

					ps1.generateOverlayPosition(uiComp.width * ENGINE_VG3R_POWER_SUPPLY_RECT.x, ENGINE_VG3R_POWER_SUPPLY_RECT.y, uiComp.width * ENGINE_VG3R_POWER_SUPPLY_RECT.width, uiComp.height * ENGINE_VG3R_POWER_SUPPLY_RECT.height);
					ps1.toolTip = _toolTipProvider.getToolTip(viewSide, component, ps1);
		
					ps2.generateOverlayPosition(ps1.x, ps1.y + ps1.height, ps1.width, ps1.height);
					ps2.toolTip = _toolTipProvider.getToolTip(viewSide, component, ps2);

					ps3.generateOverlayPosition(ps2.x, ps2.y + ps2.height, ps1.width, ps1.height);
					ps3.toolTip = _toolTipProvider.getToolTip(viewSide, component, ps3);
				
					ps4.generateOverlayPosition(ps1.x, ps3.y + ps3.height, ps1.width, ps1.height);
					ps4.toolTip = _toolTipProvider.getToolTip(viewSide, component, ps4);
                    
                    fd1.generateOverlayPosition(uiComp.width * ENGINE_VG3R_FLASH_DRIVE_DIR_A_RECT.x, uiComp.height * ENGINE_VG3R_FLASH_DRIVE_DIR_A_RECT.y, uiComp.width * ENGINE_VG3R_FLASH_DRIVE_DIR_A_RECT.width, uiComp.height * ENGINE_VG3R_FLASH_DRIVE_DIR_A_RECT.height);
                    fd1.toolTip = _toolTipProvider.getToolTip(viewSide, component, fd1);
                    
                    fd2.generateOverlayPosition(fd1.x, uiComp.height * ENGINE_VG3R_FLASH_DRIVE_DIR_B_RECT.y, fd1.width, fd1.height);
                    fd2.toolTip = _toolTipProvider.getToolTip(viewSide, component, fd2);
					
					
					// add overlay components to Engine
					uiComp.addChild(f1);
					uiComp.addChild(f2);
					uiComp.addChild(f3);
					uiComp.addChild(f4);
					uiComp.addChild(f5);
					uiComp.addChild(f6);
					uiComp.addChild(f7);
					uiComp.addChild(f8);
					uiComp.addChild(f9);
					uiComp.addChild(f10);
					uiComp.addChild(ps1);
					uiComp.addChild(ps2);
					uiComp.addChild(ps3);
					uiComp.addChild(ps4);
                    uiComp.addChild(fd1);;
                    uiComp.addChild(fd2);
				}
			}			
			if (component.isEngine && viewSide == Constants.REAR_VIEW_PERSPECTIVE) {
				if (component is sym.objectmodel.common.Engine)
				{
					var mngModule1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_MANAGEMENT_MODULE, 4, true);
					var mngModule2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_MANAGEMENT_MODULE, 5, true);
					var be1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_BACK_END_MODULE, 8, true);
					var be2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_BACK_END_MODULE, 9, true);
					var be3:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_BACK_END_MODULE, 10, true);
					var be4:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_BACK_END_MODULE, 11, true)
					var ac1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_POWER_CONNECTOR, 16, true);
					var ac2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_POWER_CONNECTOR, 17, true);
					var ac3:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_POWER_CONNECTOR, 18, true);
					var ac4:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.ENGINE_POWER_CONNECTOR, 19, true);
					
                    var fabric1:TransparentOverlayComponent = new TransparentOverlayComponent(component.parentConfiguration.noEngines > 1 ? TransparentOverlayConstants.ENGINE_VG3R_FABRIC : TransparentOverlayConstants.UNKNOWN_TYPE, 14, true);
                    var fabric2:TransparentOverlayComponent = new TransparentOverlayComponent(component.parentConfiguration.noEngines > 1 ? TransparentOverlayConstants.ENGINE_VG3R_FABRIC : TransparentOverlayConstants.UNKNOWN_TYPE, 15, true);
                    
                    fabric1.generateOverlayPosition(ENGINE_VG3R_FABRIC_RECT.x * uiComp.width, 
                        ENGINE_VG3R_FABRIC_RECT.y * uiComp.height, 
                        ENGINE_VG3R_FABRIC_RECT.width * uiComp.width, 
                        ENGINE_VG3R_FABRIC_RECT.height * uiComp.height);
                    fabric1.toolTip = _toolTipProvider.getToolTip(viewSide, component, fabric1);
                    
                    fabric2.generateOverlayPosition(fabric1.x, fabric1.y + ENGINE_VG3R_DIR_OFFSET * uiComp.height, fabric1.width, fabric1.height);
                    fabric2.toolTip = _toolTipProvider.getToolTip(viewSide, component, fabric2);
                    
                    uiComp.addChild(fabric1);
                    uiComp.addChild(fabric2);
					
					var overlayList:ArrayCollection = new ArrayCollection();
					overlayList.addItem(fabric1);
					overlayList.addItem(fabric2);
                    
					mngModule1.generateOverlayPosition(ENGINE_VG3R_MANAGEMENT_MODULE_RECT.x * uiComp.width,
						ENGINE_VG3R_MANAGEMENT_MODULE_RECT.y * uiComp.height, 
						ENGINE_VG3R_MANAGEMENT_MODULE_RECT.width * uiComp.width, 
						ENGINE_VG3R_MANAGEMENT_MODULE_RECT.height * uiComp.height);
					mngModule1.toolTip = _toolTipProvider.getToolTip(viewSide, component, mngModule1);
					
					mngModule2.generateOverlayPosition(mngModule1.x, mngModule1.y + ENGINE_VG3R_DIR_OFFSET * uiComp.height, mngModule1.width, mngModule1.height);
					mngModule2.toolTip = _toolTipProvider.getToolTip(viewSide, component, mngModule2);

                    //create tooltip overlays for variable components
                    for each (var ep:EnginePort in component.children)
                    {
                        if(sym.objectmodel.common.Engine.VARIABLE_ENGINE_PORTS.indexOf(ep.type) > -1 ||
							ep.type == EnginePort.EMPTY_SLOT)
                        {
                            var tocType:int = TransparentOverlayConstants.ENGINE_FRONT_END_MODULE;
                            var compRect:Rectangle = createVg3rEngineComponentRect(uiComp, ep.position.index);
                            if(compRect == null) return;
                            
                            var toc:TransparentOverlayComponent = new TransparentOverlayComponent(tocType, ep.position.index, true);
                            toc.generateOverlayPosition(compRect.x, compRect.y, compRect.width, compRect.height);
                            toc.toolTip = _toolTipProvider.getToolTip(viewSide, component, toc);
                            
                            uiComp.addChild(toc);						
							overlayList.addItem(toc);
                        }
                    }
                    
					be1.generateOverlayPosition(ENGINE_VG3R_BACKEND_RECT.x * uiComp.width, 
						ENGINE_VG3R_BACKEND_RECT.y * uiComp.height, 
						ENGINE_VG3R_BACKEND_RECT.width * uiComp.width, 
						ENGINE_VG3R_BACKEND_RECT.height * uiComp.height);
					be1.toolTip = _toolTipProvider.getToolTip(viewSide, component, be1);
					
					be2.generateOverlayPosition(be1.x, be1.y + ENGINE_VG3R_DIR_OFFSET * uiComp.height, be1.width, be1.height);
					be2.toolTip = _toolTipProvider.getToolTip(viewSide, component, be2);
					
					be3.generateOverlayPosition(be1.x + be1.width, be1.y, be1.width, be1.height);
					be3.toolTip = _toolTipProvider.getToolTip(viewSide, component, be3);
					
					be4.generateOverlayPosition(be3.x, be2.y, be2.width, be2.height);
					be4.toolTip = _toolTipProvider.getToolTip(viewSide, component, be4);
					
					ac1.generateOverlayPosition(ENGINE_VG3R_POWER_CONNECTOR_RECT.x, ENGINE_VG3R_POWER_CONNECTOR_RECT.y, uiComp.width * ENGINE_VG3R_POWER_CONNECTOR_RECT.width, uiComp.height * ENGINE_VG3R_POWER_CONNECTOR_RECT.height);
					ac1.toolTip = _toolTipProvider.getToolTip(viewSide, component, ac1);
					
					ac2.generateOverlayPosition(ac1.x, ac1.y + ac1.height, ac1.width, ac1.height);
					ac2.toolTip = _toolTipProvider.getToolTip(viewSide, component, ac2);

					ac3.generateOverlayPosition(ac1.x, uiComp.height * 0.57, ac1.width, ac1.height * 0.8);
					ac3.toolTip = _toolTipProvider.getToolTip(viewSide, component, ac3);
					
					ac4.generateOverlayPosition(ac3.x, ac3.y + ac3.height, ac1.width, ac1.height);
					ac4.toolTip = _toolTipProvider.getToolTip(viewSide, component, ac4);
					
					// add overlay components to Engine
					uiComp.addChild(mngModule1);
					uiComp.addChild(mngModule2);
					uiComp.addChild(be1);
					uiComp.addChild(be2);
					uiComp.addChild(be3);
					uiComp.addChild(be4);
					
					uiComp.addChild(ac1);
					uiComp.addChild(ac2);
					uiComp.addChild(ac3);
					uiComp.addChild(ac4);
					
					overlayList.addItem(be1);
					overlayList.addItem(be2);
					overlayList.addItem(be3);
					overlayList.addItem(be4);
					
					(component as sym.objectmodel.common.Engine).overlayPorts = overlayList;
				}
			}
			if (component is UPS) {
				if (viewSide == Constants.FRONT_VIEW_PERSPECTIVE) {
					var led1:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.UPS_MAIN_INPUT_LED, 0, false);
					var led2:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.UPS_ON_BATTERY_LED, 1, false);
					var led3:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.UPS_AUX_INPUT_LED, 2, false);
					var led4:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.UPS_REPLACE_BATTERY_LED, 3, false);
					
					var ledWidthUPS:Number = uiComp.width * UPS_PERCENT_WIDTH;
					var ledHeight:Number = uiComp.height * UPS_PERCENT_HEIGHT;
					
					led1.generateOverlayPosition(uiComp.width * UPS_MAIN_BATTERY_LED_X_PERCENT_WIDTH, uiComp.height * UPS_MAIN_BATTERY_LED_Y_PERCENT_HEIGHT, ledWidthUPS, ledHeight);
					led1.toolTip = _toolTipProvider.getToolTip(viewSide, component, led1);
					
					led2.generateOverlayPosition(led1.x, led1.y + ledHeight, ledWidthUPS, ledHeight);
					led2.toolTip = _toolTipProvider.getToolTip(viewSide, component, led2);
					
					led3.generateOverlayPosition(uiComp.width * UPS_AUX_BATTERY_LED_X_PERCENT_WIDTH, led1.y, ledWidthUPS, ledHeight);
					led3.toolTip = _toolTipProvider.getToolTip(viewSide, component, led1);
					
					led4.generateOverlayPosition(led3.x, led3.y + ledHeight, ledWidthUPS, ledHeight);
					led4.toolTip = _toolTipProvider.getToolTip(viewSide, component, led4);
					
					// add overlay components to UPS
					uiComp.addChild(led1);
					uiComp.addChild(led2);
					uiComp.addChild(led3);
					uiComp.addChild(led4);
				} else {
					var led5:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.UPS_MAIN_INPUT_LED, 0, true);
					var led6:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.UPS_AUX_INPUT_LED, 1, true);
					var ledXpos:Number = uiComp.width * UPS_BACK_MAIN_BATTERY_LED_X_PERCENT_WIDTH;
					var ledYpos:Number =  uiComp.height * UPS_BACK_MAIN_BATTERY_LED_Y_PERCENT_HEIGHT;
					var ledSize:Number = uiComp.height * UPS_BACK_PERCENT_HEIGHT;
					
					led5.generateOverlayPosition(ledXpos, ledYpos, ledSize, ledSize);
					led5.toolTip = _toolTipProvider.getToolTip(viewSide, component, led5);

					led6.generateOverlayPosition(ledXpos, led5.y + ledSize, ledSize, ledSize);
					led6.toolTip = _toolTipProvider.getToolTip(viewSide, component, led6);

					// add overlay components to UPS
					uiComp.addChild(led5);
					uiComp.addChild(led6);
				}
			}
			if ((viewSide == Constants.TOP_VIEW_PERSPECTIVE || viewSide == Constants.FRONT_VIEW_PERSPECTIVE) && component is DAE)
			{
				for each (var drive:Drive in component.children)
				{
					var driveRect:Rectangle = getComponentRect(viewSide, drive, parentRect, null, null);
					
					var driveOverlay:TransparentOverlayComponent = new TransparentOverlayComponent(TransparentOverlayConstants.DAE_VG3R_DRIVE, drive.position.index, true);
					driveOverlay.generateOverlayPosition(driveRect.x, driveRect.y, driveRect.width, driveRect.height);
					driveOverlay.toolTip = _toolTipProvider.getToolTip(viewSide, drive);
					
					// add overlay to DAE
					uiComp.addChild(driveOverlay);
				}
			}
		}
		
        public function renderSelectionBox(uicomp:UIComponent):void {
            var sprite:Sprite = new Sprite();
            var rect:Rectangle = new Rectangle();
            rect.width = uicomp.width;
            rect.height = uicomp.height;
            
            _renderer.drawSelectionBox(sprite, rect);
            
            uicomp.addChild(sprite);
        }
        
		private function renderStarConnectingLine(viewSide:String, uicomp:UIComponentBase, component:ComponentBase, dispersedBays:Array):void {
			if (!(component is sym.objectmodel.common.Configuration)) {
				throw new ArgumentError("can render connecting line only if configuration is supplied");
			}
			
			var rootBay:UIComponentBase = null;
			var baysToConnect:Array = [];
			
			for (var i:int = 0; i < uicomp.numChildren; i++)
			{
				var child:UIComponentBase = null;
				
				if (uicomp.getChildAt(i) is UIComponentBase)
				{
					child = uicomp.getChildAt(i) as UIComponentBase;
				}
				else 
				{
					continue;
				}
				
				if (child.componentBase is Bay) 
				{
					var bay:Bay = child.componentBase as Bay;
					if(bay.positionIndex == 0)
					{
						rootBay = child;
						continue;
					}
					for(var j:int = 0; j < dispersedBays.length; j++)
					{
						if(dispersedBays[j] == bay && !bay.isStorageBay)
						{
							baysToConnect.push(child);
						}
					}
				}
			}
			
			for(var k:int = 0; k < baysToConnect.length; k++)
			{
				var shape:Shape = new Shape(); 
				shape.graphics.lineStyle(15);
				shape.graphics.moveTo(rootBay.x + rootBay.width/2, rootBay.y);
				shape.graphics.lineTo(baysToConnect[k].x + baysToConnect[k].width/2, baysToConnect[k].y + baysToConnect[k].height);
				
				uicomp.addChild(shape);
			}
		}
		
		
        /**
         * Renders connecting line
         * @param uicomp parent UIComponentBase
         * @param component configuration which is being rendered
         * 
         */
        private function renderConnectingLine(viewSide:String, uicomp:UIComponentBase, component:ComponentBase):void {
            if (!(component is sym.objectmodel.common.Configuration)) {
                throw new ArgumentError("can render connecting line only if configuration is supplied");
            }
            
            // we have to draw a connecting line from one system bay to another
            // first, find system bay components
            var sysB1:UIComponentBase = null;
            var sysB2:UIComponentBase = null;
            var sysB3:UIComponentBase = null;
            
            for (var i:int = 0; i < uicomp.numChildren; i++) {
                var child:UIComponentBase = null;
                
                if (uicomp.getChildAt(i) is UIComponentBase) {
                    child = uicomp.getChildAt(i) as UIComponentBase;
                } else {
                    continue;
                }
                
                if (child.componentBase is Bay) {
                    if(sysB1 && sysB2){
                        break;
                    }
                    var bay:Bay = child.componentBase as Bay;
                    
                    if (bay.id != Bay.ID_SYSTEM_BAY && bay.id != Bay.ID_SYSTEM_BAY_D15 && bay.id != Bay.ID_SYSTEM_BAY_VANGUARD) {
                        // not system bay, skip
                        continue;
                    }
                    
                    
                    if (bay.dispersed != -1) { 
                        sysB2 = child;
                        continue;
                    }
                    
                    sysB1 = child;
                }
            }

            if (viewSide == Constants.REAR_VIEW_PERSPECTIVE) {
                var tmp:UIComponentBase = null;
             
                tmp = sysB1;
                sysB1 = sysB2;
                sysB2 = tmp;
                
            }

            if (!sysB3)
                uicomp.addChild(createConnectinLine(sysB1, sysB2));
            else
            {
                uicomp.addChild(createConnectinLine(sysB1, sysB2));
                uicomp.addChild(createConnectinLine(sysB2, sysB3));
            }
        }
        
        /**
        *  create rectangle with connecting line dimensions
        */
        private function createConnectinLine(b1:UIComponentBase, b2:UIComponentBase):UIComponent{
           
            var rect:Rectangle = new Rectangle();
            rect.x = b1.x + b1.width/2;
            rect.y = b1.y + b1.height + DISPERSED_CONNECTING_LINE_HEIGHT;
            
            rect.width = b2.x + b2.width/2 - rect.x;
            rect.height = DISPERSED_CONNECTING_LINE_HEIGHT - DISPERSED_CONNECTING_LINE_START;
            
            var childUIComp:UIComponent = new UIComponent();
            childUIComp.x = rect.x;
            childUIComp.y = rect.y;
            childUIComp.width = rect.width;
            childUIComp.height = rect.height;
            
            childUIComp.mouseChildren = false;
            childUIComp.mouseEnabled = false;
            childUIComp.useHandCursor = false;
            childUIComp.buttonMode = false;
            
            var img:Image = new Image();
            img.width = rect.width;
            img.height = rect.height;
            var bData:BitmapData = new BitmapData(img.width, img.height);
            var pRect:Rectangle = new Rectangle(0, 0, img.width, img.height);
            _renderer.drawDispersedConnectingLine(bData, pRect);
            
            img.source = bData;
            childUIComp.addChild(img)
            return childUIComp;
        }
        
		private function renderDispersed(viewSide:String, uicomp:UIComponentBase, dispersedBays:Array, notDispersedBays:Array, parentBitmapData:BitmapData, parentRect:Rectangle, component:ComponentBase, renderChildrenAsUI:Boolean):void
		{
			if (renderChildrenAsUI && (uicomp == null)) {
				throw new ArgumentError("if rendering children as ui, supply parent ui component");
			} else if (!renderChildrenAsUI && ((parentBitmapData == null && uicomp == null))) {
				throw new ArgumentError("if NOT rendering children as ui, supply parent bitmap data");
			}
			
			var bData:BitmapData = parentBitmapData;

			renderBays(viewSide, uicomp, dispersedBays, true, bData, parentRect, component, renderChildrenAsUI);
			renderBays(viewSide, uicomp, notDispersedBays, false, bData, parentRect, component, renderChildrenAsUI);
		}
		
		private function renderBays(viewSide:String, uicomp:UIComponentBase, bays:Array, isDispersed:Boolean, parentBitmapData:BitmapData, parentRect:Rectangle, component:ComponentBase, renderChildrenAsUI:Boolean):void
		{
			var bData:BitmapData = parentBitmapData;
			var countSystemBays:int = 0; 
			var countStorageBays:int = 0; 
			
			var cfg:Configuration_VG3R = component as Configuration_VG3R;
			
			if(isDispersed)
			{
				for each(var comp:Bay in bays)
				{
					if(comp.isSystemBay)
					{
						countSystemBays++;
					}
					else
					{
						countStorageBays++;
					}
				}
			}
			
			var dispersedSpace:int = (isDispersed) ? (countSystemBays - 1) * TITAN_WIDTH / 2 : 0;
			var pos:int = bays.length * TITAN_WIDTH + dispersedSpace;

			var firstStorageBayOccupied:Boolean = false;
			var firstSystemBayOccupied:Boolean = false;
			
			for(var i:int = 0; i < bays.length; i++)
			{
				var childUIComp:UIComponentBase = null;
				
				var siblingBayDispersed:Boolean = false;
				var childRect:Rectangle = null;
				var previousSibling:ComponentBase = null;
				
				previousSibling = bays[i];
				
				var rect:Rectangle = new Rectangle();
				
				rect.x = uicomp.x + (uicomp.width/2 - pos/2);
				rect.x += i * TITAN_WIDTH;
				
				if(isDispersed)
				{
					var bay:Bay = (bays[i] as Bay);
				
					if(cfg.sysBayType == Configuration_VG3R.SINGLE_ENGINE_BAY)
					{
						rect.x += i * TITAN_WIDTH/2; 
					}
					else
					{
						rect.x = uicomp.x + (uicomp.width/2 - pos/2);
						if(bay.isStorageBay)
						{
							switch(bay.attachedToSystemBayWithIndex)
							{
								case 1:
								{
									rect.x += TITAN_WIDTH;
									firstStorageBayOccupied = true;
									break;
								}
								case 2:
								{
									if((countStorageBays == 1 && countSystemBays == 2 && firstStorageBayOccupied) || (countStorageBays > 1 && firstStorageBayOccupied))
									{
										rect.x += TITAN_WIDTH * 2 + TITAN_WIDTH/2;
									}
									break;
								}
								case 3:
								{
									if(countStorageBays == 1)
									{
										rect.x += TITAN_WIDTH;
									}
									else if(countStorageBays == 2)
									{
										rect.x += TITAN_WIDTH * 3 + TITAN_WIDTH/2;
									}
									else if(countStorageBays == 3)
									{
										rect.x += TITAN_WIDTH * 5 + TITAN_WIDTH/2 * 2;
									}
									break;
								}
							}
						}
						else if(bay.isSystemBay)
						{
							switch(bay.positionIndex)
							{
								case 1:
								{
									firstSystemBayOccupied = true;
									break;
								}
								case 2:
								{
									if(countStorageBays == 0 && countSystemBays > 1 && firstSystemBayOccupied)
									{ 
										rect.x += TITAN_WIDTH + TITAN_WIDTH/2;
									}
									else if(countStorageBays == 1)
									{
										if(firstSystemBayOccupied)
										{
											rect.x += TITAN_WIDTH * 2 + TITAN_WIDTH/2;
										}
										else
										{
											rect.x += TITAN_WIDTH;
										}
									}
									else if(countStorageBays == 2)
									{
										if(firstSystemBayOccupied)
										{
											rect.x += TITAN_WIDTH * 3 + TITAN_WIDTH/2;
										}
										else
										{
											rect.x += TITAN_WIDTH;
										}
									}
									else if(countStorageBays > 2)
									{
										rect.x += TITAN_WIDTH * 3 + TITAN_WIDTH/2
									}
									break;
								}
								case 3:
								{
									if(countSystemBays == 3)
									{
										if(countStorageBays == 0)
										{
											rect.x += TITAN_WIDTH * 2 + TITAN_WIDTH/2 * 2;
										}
										else if(countStorageBays == 1)
										{
											rect.x += TITAN_WIDTH * 3 + TITAN_WIDTH/2 * 2;
										}
										else
										{
											rect.x += TITAN_WIDTH * 4 + TITAN_WIDTH/2 * 2
										}
									}
									else if(countSystemBays == 2)
									{
										if(countStorageBays == 0)
										{
											rect.x += TITAN_WIDTH  + TITAN_WIDTH/2;
										}
										else
										{
											rect.x += TITAN_WIDTH * 2  + TITAN_WIDTH/2;
										}
									}
									break;
								}
							}
						}
					}
				}
				
				if(!isDispersed)
				{
					rect.y = uicomp.height / 2 + TITAN_WIDTH / 2;
				}
				
				childRect = getComponentRect(viewSide, bays[i], rect, childRect, previousSibling);
				
				if (renderChildrenAsUI) {
					childUIComp = new UIComponentBase(bays[i]);
					childUIComp.x = rect.x;
					childUIComp.y = rect.y;
					childUIComp.width = childRect.width;
					childUIComp.height = childRect.height;
					
					childUIComp.mouseChildren = false;
					childUIComp.mouseEnabled = true;
					childUIComp.useHandCursor = true;
					childUIComp.buttonMode = true;
					childUIComp.toolTip = _toolTipProvider.getToolTip(viewSide, bays[i]);
					
					uicomp.addChild(childUIComp);
				}
				
				render(viewSide, childUIComp, bData, childRect, bays[i], false);
			}
		}
		
        /**
         * Render single component. 
         * @param viewSide front/rear/top
         * @param uicomp container, if exists
         * @param parentBitmapData, target bitmap data 
         * @param parentRect target area
         * @param component component to render
         * @param renderChildrenAsUI should children be rendered as UIComponents (clickable)?
         * 
         */
        private function render(viewSide:String, uicomp:UIComponentBase, parentBitmapData:BitmapData, parentRect:Rectangle, component:ComponentBase, renderChildrenAsUI:Boolean):void {
            if (renderChildrenAsUI && (uicomp == null)) {
                throw new ArgumentError("if rendering children as ui, supply parent ui component");
            } else if (!renderChildrenAsUI && ((parentBitmapData == null && uicomp == null))) {
                throw new ArgumentError("if NOT rendering children as ui, supply parent bitmap data");
            }
           
            if (!component.visible && !(SymmController.instance.currentComponent is PDP))
			{
                return;
            }
            
            var bData:BitmapData = parentBitmapData;
            var img:Image = null;
            var pRect:Rectangle = null;
            
            // render component itself
            if (!(component is sym.objectmodel.common.Configuration)) {
                if (uicomp) {
                    if (component.position.type == Position.FLOOR && parentRect.y > 0) {
                        var maskComp:UIComponent = new UIComponent();
                        maskComp.x = uicomp.x;
                        maskComp.y = 0;
                        maskComp.width = uicomp.width;
                        maskComp.height = uicomp.y;
                        
                        img = new Image();
                        img.width = maskComp.width;
                        img.height = maskComp.height;
                        img.smooth = true;
                        
                        bData = new BitmapData(img.width, img.height, true, 0x00FFFFFF); // transparent
                        pRect = new Rectangle(0, 0, img.width, img.height);
                        _renderer.drawBayMask(bData, pRect);
                        img.source = bData;
                        maskComp.addChild(img);
                        uicomp.parent.addChild(maskComp);
                    }
                    
                    // supplied component for rendering, render directly as image
                    img = new Image();
                    img.width = uicomp.width;
                    img.height = uicomp.height;
                    img.smooth = true;
					
					if(component is PDU && uicomp.explicitHeight == 750)
					{
						img.width = 900;
						img.x = -500;
						img.y= 0;
					}
                    
                    bData = new BitmapData(img.width, img.height, true, 0x00FFFFFF); // transparent
                    parentRect = new Rectangle(0, 0, img.width, img.height);
                    _renderer.render(viewSide, component, bData, parentRect);
                    img.source = bData;
                    
                    uicomp.addChild(img);
                    
                } else if (parentBitmapData) {
                    // supplied bitmap data, render over it
                    _renderer.render(viewSide, component, parentBitmapData, parentRect);
                }
            }
            
            var childUIComp:UIComponentBase = null;
            
            var siblingBayDispersed:Boolean = false;
            var childRect:Rectangle = null;
            var previousSibling:ComponentBase = null;
			
            // render children
            for each (var child:ComponentBase in component.children) {
				
				childRect = getComponentRect(viewSide, child, parentRect, childRect, previousSibling);
				
                previousSibling = child;
                
                if (childRect.width == 0 || childRect.height == 0) {
                    continue;
                }
                
                // if we are drawing directly on bitmap data, take into consideration previous offset
                if (parentBitmapData) {
                    childRect.x += parentRect.x;
                    childRect.y += parentRect.y;
                }
				
                if (renderChildrenAsUI) {
                    childUIComp = new UIComponentBase(child);
                    childUIComp.x = childRect.x;
                    childUIComp.y = childRect.y;
                    childUIComp.width = childRect.width;
                    childUIComp.height = childRect.height;
                    
                    childUIComp.mouseChildren = false;
                    childUIComp.mouseEnabled = true;
                    childUIComp.useHandCursor = true;
                    childUIComp.buttonMode = true;
                    childUIComp.toolTip = _toolTipProvider.getToolTip(viewSide, child);
					
					childUIComp.addEventListener(ToolTipEvent.TOOL_TIP_SHOWN, hideCurrentTip);

                    uicomp.addChild(childUIComp);
                }
                
                render(viewSide, childUIComp, bData, childRect, child, false);
            }
        }

		private function hideCurrentTip(ev:ToolTipEvent):void
		{
			SymmController.instance.eventHandler.dispatchEvent(ev);
		}
		
         /**
          * Return bounding box around component. 
          * @param component
          * @param siblingRect
          * @param sibling
          * @return 
          * 
          */
         private function getComponentRect(viewSide:String, component:ComponentBase, parentRect:Rectangle, siblingRect:Rectangle, sibling:ComponentBase):Rectangle {
            var rect:Rectangle = new Rectangle();
            var bay:Bay = null;
            var enclosureRect:Rectangle = null;
            var uCount:int = 0;
            var uHeight:Number = 0;
            var scale:Number = 0;

            rect.width = getComponentWidth(component);
            rect.height = getComponentHeight(component);

			           
            // calculate rect depending on position type/index
            switch (component.position.type) {
                case Position.FLOOR:
                    // if component is positioned on the floor, it is definatelly a bay
                    // bays should be evenly spaced, there is extra space if dispersed
                    bay = component as Bay;
                    
                    // if sibling rect is provided, offset x/y according to it
                    if (siblingRect) {
                        if (viewSide == Constants.REAR_VIEW_PERSPECTIVE) {
                            flipOnParentYAxis(siblingRect, parentRect);
                        }
                        rect.x = siblingRect.x + siblingRect.width;
                    }
                    
                    // add offset sequentially
                    // space for bays
                    rect.x += _renderer.baySpace;
                    if (bay.dispersed != -1) {
                        var siblingBay:Bay = sibling as Bay;
                        if (siblingBay.dispersed == -1) {
                            rect.x += (BAY_DISPERSED_SPACE - _renderer.baySpace);
                        }
                    }
                    break;
                case Position.BAY_ENCLOSURE:
                    // component is positioned in enclosures
                    // location of enclosure depends on rack type
                    if(component is InfinibandSwitch && component.type == InfinibandSwitch.TYPE_STINGRAY && viewSide == Constants.REAR_VIEW_PERSPECTIVE)
                    {
                        enclosureRect = STINGRAY_ENCLOSURE_RECT;
                    }
                    else
                    {
                        enclosureRect = getEnclosureRect(viewSide, component.parent);
                    }
                    uCount = getEnclosureCount(component.parent);
                    uHeight = enclosureRect.height / uCount;
                    
					if (component is KVM && !SymmController.instance.configFactory.isKVMvisible(component as KVM, viewSide))
					{
						rect.x = 0;
						rect.y = 0;
						rect.width = 0;
						rect.height = 0;
						
						break;
					}
					
                    if (!_renderEnclosure) {
                        rect.width = enclosureRect.width;
                        rect.height = uHeight * component.size.height;
                        rect.x = enclosureRect.x;
                        rect.y = enclosureRect.y + (uCount - (component.position.index + 1)) * uHeight;
                    } else {
                        rect.width = enclosureRect.width;
                        rect.height = enclosureRect.height;
                        rect.x = enclosureRect.x;
                        rect.y = enclosureRect.y;
                    }
                    
                    break;
                case Position.BAY_HALF_ENCLOSURE_LEFT:
                case Position.BAY_HALF_ENCLOSURE_RIGHT:
                    // component is positioned in enclosure, but only takes half of width (or less)
                    // used for SPSes
                    enclosureRect = getEnclosureRect(viewSide, component.parent);
                    uCount = getEnclosureCount(component.parent);
                    uHeight = enclosureRect.height / uCount;
                    
                    // scale
                    scale = (component.size.height * uHeight) / rect.height;
                    rect.height *= scale;
                    rect.width *= scale;
                    rect.x = enclosureRect.x;
                    rect.y = enclosureRect.y + (uCount - (component.position.index + 1)) * uHeight;
                    
                    if (component.position.type == Position.BAY_HALF_ENCLOSURE_RIGHT) {
                        // move it to the right side
                        rect.x = enclosureRect.x + enclosureRect.width - rect.width;
                    }
                    
                    break;    
                case Position.LOWERHALFBAYVERTICAL:
                case Position.UPPERHALFBAYVERTICAL:
                    // vertical positioning of DAEs
                    rect = getDAEVerticalRect(viewSide, component);
                    if (component.position.type == Position.LOWERHALFBAYVERTICAL) {
                        // add offset for lower bay
                        if (viewSide == Constants.REAR_VIEW_PERSPECTIVE) {
                            rect.y += LOWERHALFBAYVERTICAL_BACK_OFFSET;
                        } else {
                            rect.y += LOWERHALFBAYVERTICAL_FRONT_OFFSET;
                        }
                    }
                    break;
                case Position.MIDDLEBAYVERTICAL:
                    // middle of bay vertical, positioning for SPS
                    rect = getSPSVerticalRect(viewSide, component);
                    break;
                case Position.ENGINESIDE_SPS_LEFT:
                    rect = getEngineSideSPSRect(true, viewSide, component);
                    break;
                case Position.ENGINESIDE_SPS_RIGHT:
                    rect = getEngineSideSPSRect(false, viewSide, component);
                    break;
                case Position.BACKPANEL_PDU:
                    rect = getPDURect(viewSide, component);
                    break;
                case Position.BACKPANEL_PDP:
                    rect = getPDPRect(viewSide, component);
                    break;
                case Position.ENGINE_DIRECTOR_2040k:
                    if (viewSide == Constants.REAR_VIEW_PERSPECTIVE) {
                        rect.y = ENGINE_2040K_PORT_ENCLOSURE.y * parentRect.height;
                        rect.height = ENGINE_2040K_PORT_ENCLOSURE.height * parentRect.height;
                        rect.width = (ENGINE_2040K_PORT_ENCLOSURE.width/4) * parentRect.width;
                        rect.x = ENGINE_2040K_PORT_ENCLOSURE.x * parentRect.width + ((3 - component.position.index) * rect.width);
                    } else {
                        rect.x = 0;
                        rect.y = 0;
                        rect.width = 0;
                        rect.height = 0;
                    }
                    break;
                case Position.ENGINE_DIRECTOR_10ke:
                    if (viewSide == Constants.REAR_VIEW_PERSPECTIVE) {
                        var offset:int = component.position.index;
                        if (offset > 1) {
                            offset -= 2;
                        }
                        
                        rect.y = ENGINE_10K_PORT_ENCLOSURE_DIR1.y * parentRect.height;
                        rect.height = ENGINE_10K_PORT_ENCLOSURE_DIR1.height * parentRect.height;
                        rect.width = (ENGINE_10K_PORT_ENCLOSURE_DIR1.width/2) * parentRect.width;
                        rect.x = ENGINE_10K_PORT_ENCLOSURE_DIR1.x * parentRect.width + ((1 - offset) * rect.width);
                        if (component.position.index > 1) {
                            rect.x += ENGINE_10K_PORT_ENCLOSURE_DIR2_OFFSET * parentRect.width;
                        }
                    } else {
                        rect.x = 0;
                        rect.y = 0;
                        rect.width = 0;
                        rect.height = 0;
                    }
                    break;
				case Position.ENGINE_DIRECTOR_VG3R:
					if (viewSide == Constants.REAR_VIEW_PERSPECTIVE)
					{
						var ind:int = component.position.index;
                        
                        if(component.type == EnginePort.IB_MODULE)
                        {
                            rect.x = ENGINE_VG3R_IB_MODULE_ENCLOSURE.x * parentRect.width;
                            rect.y = ENGINE_VG3R_IB_MODULE_ENCLOSURE.y * parentRect.height + (component.position.index == sym.objectmodel.common.Engine.IB_MODULE_UPPER_POSITION ? 0 : ENGINE_VG3R_PORT_ENCLOSURE_DIR_OFFSET_Y * parentRect.height);
                            rect.width = ENGINE_VG3R_IB_MODULE_ENCLOSURE.width * parentRect.width;
                            rect.height = ENGINE_VG3R_IB_MODULE_ENCLOSURE.height * parentRect.height;
                             
                        }
                        else
                        {
                            var ind:int =  component.position.index % 10;
						    rect.width = ENGINE_VG3R_PORT_ENCLOSURE_DIR.width * parentRect.width;
						    rect.height = ENGINE_VG3R_PORT_ENCLOSURE_DIR.height * parentRect.height;
                            rect.x = ENGINE_VG3R_PORT_ENCLOSURE_DIR.x * parentRect.width + 
                                ind * (rect.width + ENGINE_VG3R_INNER_PORT_OFFSET * parentRect.width); 
                            rect.y = ENGINE_VG3R_PORT_ENCLOSURE_DIR.y * parentRect.height;
                           
                            if (component.position.index >= 10)
                            {
                                rect.y += ENGINE_VG3R_PORT_ENCLOSURE_DIR_OFFSET_Y * parentRect.height;
                            }
                        }
						
					}
					else
					{
						rect.x = 0;
						rect.y = 0;
						rect.width = 0;
						rect.height = 0;
					}
					break;
				case Position.VOYAGER_ENCLOSURE:
				case Position.VIKING_ENCLOSURE:
				case Position.DAE_TABASCO_ENCLOSURE:
				case Position.DAE_NEBULA_ENCLOSURE:
					rect = getDriveRect(viewSide, component, parentRect);
					break;
            }
			

            
            if (viewSide == Constants.REAR_VIEW_PERSPECTIVE) {
                // mirror the rectangle relative to parent Y axis
                flipOnParentYAxis(rect, parentRect);
            }
            
            return rect;
        }
        
        /**
         * Flips rect on parent rect Y axis (mirror/reflection). 
         * 
         */
        private function flipOnParentYAxis(rect:Rectangle, parentRect:Rectangle):void {
            rect.x = parentRect.width - rect.x - rect.width;
        }
		
		private function getDriveRect(viewSide:String, component:ComponentBase, parentRect:Rectangle):Rectangle
		{
			var rect:Rectangle = new Rectangle();
			
			var rectWidth:Number;
			var rectHeight:Number;	
			var offset:int;
			var xPosIndex:int;
			var yPosIndex:int;
			
			if (viewSide == Constants.TOP_VIEW_PERSPECTIVE)
			{
				// Viking/Voyager drives
				var drivesPerQueue:int = component.position.type == Position.VOYAGER_ENCLOSURE ? 12 : 20;
                
                var driveVerticalGap:Number = component.position.type == Position.VOYAGER_ENCLOSURE ? parentRect.height * VOYAGER_DRIVE_V_GAP_PERCENT :
                    parentRect.height * VIKING_DRIVE_V_GAP_PERCENT;
                var driveHorizontalGap:Number = component.position.type == Position.VOYAGER_ENCLOSURE ? parentRect.width * VOYAGER_DRIVE_GAP_PERCENT : 
                    parentRect.width * VIKING_DRIVE_GAP_PERCENT;
                var daeTopOffset:Number = component.position.type == Position.VOYAGER_ENCLOSURE ? parentRect.height * VOYAGER_TOP_OFFSET_PERCENT : 
                    parentRect.height * VIKING_TOP_OFFSET_PERCENT;
                var daeLeftOffset:Number = component.position.type == Position.VOYAGER_ENCLOSURE ? parentRect.width * VOYAGER_LEFT_OFFSET_PERCENT : 
                    parentRect.width * VIKING_LEFT_OFFSET_PERCENT;

				rectWidth = component.position.type == Position.VOYAGER_ENCLOSURE ? parentRect.width * VOYAGER_DRIVE_PERCENT_WIDTH : 
					parentRect.width * VIKING_DRIVE_PERCENT_WIDTH;
				rectHeight = component.position.type == Position.VOYAGER_ENCLOSURE ? parentRect.height * VOYAGER_DRIVE_PERCENT_HEIGHT : 
					parentRect.height * VIKING_DRIVE_PERCENT_HEIGHT;
				
				xPosIndex = component.position.index % drivesPerQueue;
				yPosIndex = component.position.index / drivesPerQueue;
				
				if (component.position.type == Position.VOYAGER_ENCLOSURE && xPosIndex >= 6 && xPosIndex <= 11)
				{
					offset = rectWidth;
				}
				if(component.position.type == Position.VIKING_ENCLOSURE)
                { 
                     if(xPosIndex > 6 && xPosIndex < 13)
                     {
                         offset += parentRect.width * VIKING_VLINE_SPLIT_PERCENT;
                     }
                     else if(xPosIndex >= 13)
                     {
                         offset += parentRect.width * VIKING_VLINE_SPLIT_PERCENT * 2;
                     }
                }
				
				rect.x = xPosIndex * rectWidth + offset + daeLeftOffset + xPosIndex * driveHorizontalGap;
				rect.y = yPosIndex * rectHeight + daeTopOffset + yPosIndex * driveVerticalGap;
				rect.width = rectWidth;
				rect.height = rectHeight;
			}
			else if (viewSide == Constants.FRONT_VIEW_PERSPECTIVE && component.parent is Tabasco)
			{
				// Tabasco drives
				rectWidth = parentRect.width * TABASCO_DRIVE_PERCENT_WIDTH;
				rectHeight = parentRect.height * TABASCO_DRIVE_PERCENT_HEIGHT;
				
				xPosIndex = component.position.index;
				yPosIndex = parentRect.height * TABASCO_DRIVE_Y_POS_PERCENT;
				// strating offset from the left side of DAE
				var daeLeftOffset:Number = parentRect.width * TABASCO_LEFT_OFFSET_PERCENT;
				// gap between drives
				var driveGap:Number = rectWidth * TABASCO_DRIVE_GAP_PERCENT;
				
				offset = xPosIndex * driveGap + (xPosIndex - 1) * rectWidth;
				
				if (xPosIndex >= 9 && xPosIndex < 18)
				{
					offset += rectWidth * TABASCO_DRIVE_LEFT_SPLIT_PERCENT;
				}
				else if (xPosIndex >= 18)
				{
					offset += rectWidth * TABASCO_DRIVE_RIGHT_SPLIT_PERCENT;
				}
				
				rect.x = daeLeftOffset + offset;
				rect.y = yPosIndex;
				rect.width = rectWidth;
				rect.height = rectHeight;
			}
			else if (viewSide == Constants.FRONT_VIEW_PERSPECTIVE && component.parent is Nebula)
			{
				// Nebula drives - use same constants for tabasco
				rectWidth = parentRect.width * TABASCO_DRIVE_PERCENT_WIDTH;
				rectHeight = parentRect.height * TABASCO_DRIVE_PERCENT_HEIGHT;
				
				xPosIndex = component.position.index;
				yPosIndex = parentRect.height * TABASCO_DRIVE_Y_POS_PERCENT;
				// strating offset from the left side of DAE
				var daeLeftOffset:Number = parentRect.width * TABASCO_LEFT_OFFSET_PERCENT;
				// gap between drives
				var driveGap:Number = rectWidth * TABASCO_DRIVE_GAP_PERCENT;
				
				offset = xPosIndex * driveGap + (xPosIndex - 1) * rectWidth;
				
				if (xPosIndex >= 9 && xPosIndex < 18)
				{
					offset += rectWidth * TABASCO_DRIVE_LEFT_SPLIT_PERCENT;
				}
				else if (xPosIndex >= 18)
				{
					offset += rectWidth * TABASCO_DRIVE_RIGHT_SPLIT_PERCENT;
				}
				
				rect.x = daeLeftOffset + offset;
				rect.y = yPosIndex;
				rect.width = rectWidth;
				rect.height = rectHeight;
			}
			else
			{
				rect.x = 0;
				rect.y = 0;
				rect.width = 0;
				rect.height = 0;
			}
				
			return rect;
		}
		
        private function getPDPRect(viewSide:String, component:ComponentBase):Rectangle {
            // PDP positioning
            var rect:Rectangle = new Rectangle();
            
            if (viewSide == Constants.FRONT_VIEW_PERSPECTIVE) {
                // skip drawing PDP if front
                return rect;
            }
            
            if (!(component.parent is Bay)) {
                return rect;
            }
            
            var bay:Bay = component.parent as Bay;
            
            switch (bay.type) {
                case Bay.TYPEMOHAWKSTGBAY:
                case Bay.TYPEMOHAWKSYSBAY:
                    
                    rect.x = MOHAWK_PDP_POSITION[component.position.index].x;
                    rect.y = MOHAWK_PDP_POSITION[component.position.index].y;
                    rect.width = MOHAWK_PDP_POSITION[component.position.index].width;
                    rect.height = MOHAWK_PDP_POSITION[component.position.index].height;
                    
                    break;
                case Bay.TYPETITANSTGBAY:
                case Bay.TYPETITANSYSBAY:

                    rect.x = TITAN_PDP_POSITION[component.position.index].x;
                    rect.y = TITAN_PDP_POSITION[component.position.index].y;
                    rect.width = TITAN_PDP_POSITION[component.position.index].width;
                    rect.height = TITAN_PDP_POSITION[component.position.index].height;

                    break;
            }
            
            return rect;
        }
        
        private function getPDURect(viewSide:String, component:ComponentBase):Rectangle {
            // PDU positioning
            var rect:Rectangle = new Rectangle();
            
            if (viewSide == Constants.FRONT_VIEW_PERSPECTIVE) {
                // skip drawing PDU if front
                return rect;
            }
            
            if (!(component.parent is Bay)) {
                return rect;
            }
            
            var bay:Bay = component.parent as Bay; 
            
            switch (bay.type) {
                case Bay.TYPEMOHAWKSTGBAY:
                case Bay.TYPEMOHAWKSYSBAY:
                    
                    rect.x = MOHAWK_PDU_POSITION[component.position.index].x;
                    rect.y = MOHAWK_PDU_POSITION[component.position.index].y;
                    rect.width = MOHAWK_PDU_POSITION[component.position.index].width;
                    rect.height = MOHAWK_PDU_POSITION[component.position.index].height;
                    
                    break;
                case Bay.TYPETITANSTGBAY:
                case Bay.TYPETITANSYSBAY:
                    
					if(isPM2000() || isPM8000())
					{
						if(component.position.index == 6)
							rect.x = TITAN_PDU_POSITION[component.position.index+2].x;
						else
							rect.x = TITAN_PDU_POSITION[component.position.index+2].x;
					
						rect.y = TITAN_PDU_POSITION[component.position.index+2].y;
						rect.width = TITAN_PDU_POSITION[component.position.index+2].width;
						rect.height = TITAN_PDU_POSITION[component.position.index+2].height;
					}else
					{	
                    	rect.x = TITAN_PDU_POSITION[component.position.index].x;
                    	rect.y = TITAN_PDU_POSITION[component.position.index].y;
                    	rect.width = TITAN_PDU_POSITION[component.position.index].width;
                    	rect.height = TITAN_PDU_POSITION[component.position.index].height;
					}
					
                    break;
            }
            
            return rect;
        }

        private function getEngineSideSPSRect(left:Boolean, viewSide:String, component:ComponentBase):Rectangle {
            // DAE vertical positioning is only in Mohawk rack
            var rect:Rectangle = new Rectangle();
            var idx:int = MOHAWK_ENGINESIDE_SPS_MAP[component.position.index];
            var offset:int = 0;
            var parentRect:Rectangle = null;
            var space:Number = 0;
            
            if (idx >= 4) {
                idx -= 4;
                offset++;
            }
            
            if (!left) {
                offset += 2;                
            }
            
            if (viewSide == Constants.REAR_VIEW_PERSPECTIVE) {
                rect.x = MOHAWK_ENGINESIDE_SPS_BACK_OFFSETS[offset].x;
                rect.y = MOHAWK_ENGINESIDE_SPS_BACK_OFFSETS[offset].y;
                parentRect = MOHAWK_ENGINESIDE_SPS_BACK_RECT;
                space = MOHAWK_ENGINESIDE_SPS_BACK_SPACE;
            } else {
                rect.x = MOHAWK_ENGINESIDE_SPS_FRONT_OFFSETS[offset].x;
                rect.y = MOHAWK_ENGINESIDE_SPS_FRONT_OFFSETS[offset].y;
                parentRect = MOHAWK_ENGINESIDE_SPS_FRONT_RECT;
                space = MOHAWK_ENGINESIDE_SPS_FRONT_SPACE;
            }
            
            rect.width = parentRect.width;
            rect.height = (parentRect.height - 3*space) / 4;
            rect.y += idx*(rect.height + space);
            
            return rect;
        }

        private function getSPSVerticalRect(viewSide:String, component:ComponentBase):Rectangle {
            // DAE vertical positioning is only in Mohawk rack
            var rect:Rectangle = new Rectangle();
            if (viewSide == Constants.REAR_VIEW_PERSPECTIVE) {
                rect.x = MOHAWK_VERTICAL_BACK_SPS_ENCLOSURES[component.position.index].x;
                rect.y = MOHAWK_VERTICAL_BACK_SPS_ENCLOSURES[component.position.index].y;
                rect.width = MOHAWK_VERTICAL_BACK_SPS_ENCLOSURES[component.position.index].width;
                rect.height = MOHAWK_VERTICAL_BACK_SPS_ENCLOSURES[component.position.index].height;
            } else {
                rect.x = MOHAWK_VERTICAL_FRONT_SPS_ENCLOSURES[component.position.index].x;
                rect.y = MOHAWK_VERTICAL_FRONT_SPS_ENCLOSURES[component.position.index].y;
                rect.width = MOHAWK_VERTICAL_FRONT_SPS_ENCLOSURES[component.position.index].width;
                rect.height = MOHAWK_VERTICAL_FRONT_SPS_ENCLOSURES[component.position.index].height;
            }
            return rect;
        }
        
        private function getDAEVerticalRect(viewSide:String, component:ComponentBase):Rectangle {
            // DAE vertical positioning is only in Mohawk rack
            var rect:Rectangle = new Rectangle();

            if (viewSide == Constants.REAR_VIEW_PERSPECTIVE) {
                rect.x = MOHAWK_VERTICAL_BACK_DAE_ENCLOSURES[component.position.index].x;
                rect.y = MOHAWK_VERTICAL_BACK_DAE_ENCLOSURES[component.position.index].y;
                rect.width = MOHAWK_VERTICAL_BACK_DAE_ENCLOSURES[component.position.index].width;
                rect.height = MOHAWK_VERTICAL_BACK_DAE_ENCLOSURES[component.position.index].height;
            } else {
                rect.x = MOHAWK_VERTICAL_FRONT_DAE_ENCLOSURES[component.position.index].x;
                rect.y = MOHAWK_VERTICAL_FRONT_DAE_ENCLOSURES[component.position.index].y;
                rect.width = MOHAWK_VERTICAL_FRONT_DAE_ENCLOSURES[component.position.index].width;
                rect.height = MOHAWK_VERTICAL_FRONT_DAE_ENCLOSURES[component.position.index].height;
            }
            return rect;            
        }
        
        private function getEnclosureRect(viewSide:String, component:ComponentBase):Rectangle {
            var bay:Bay = component as Bay;
            
            switch (bay.type) {
                case Bay.TYPEMOHAWKSTGBAY:
                case Bay.TYPEMOHAWKSYSBAY:
                    if (viewSide == Constants.REAR_VIEW_PERSPECTIVE) {
                        return MOHAWK_ENCLOSURE_BACK_RECT;
                    }
                    return MOHAWK_ENCLOSURE_FRONT_RECT;             
                    break;
                case Bay.TYPETITANSTGBAY:
                case Bay.TYPETITANSYSBAY:
                    return TITAN_ENCLOSURE_RECT;
                    break;
            }
            
            return null;
        }
        
        private function getEnclosureCount(component:ComponentBase):int {
            var bay:Bay = component as Bay;
            
            switch (bay.type) {
                case Bay.TYPEMOHAWKSTGBAY:
                case Bay.TYPEMOHAWKSYSBAY:
                    return MOHAWK_ENCLOSURE_COUNT;             
                    break;
                case Bay.TYPETITANSTGBAY:
                case Bay.TYPETITANSYSBAY:
                    return TITAN_ENCLOSURE_COUNT;
                    break;
            }
            
            return -1;
        }

        private function getComponentHeight(component:ComponentBase):int {
            if (component is sym.objectmodel.common.Configuration) {
                return DEFAULT_STAGE_HEIGHT;
            }
            
            if (component is Bay) {
                var bay:Bay = component as Bay;
                switch (bay.type) {
                    case Bay.TYPEMOHAWKSTGBAY:
                    case Bay.TYPEMOHAWKSYSBAY:
                        return MOHAWK_HEIGHT;                        
                        break;
                    case Bay.TYPETITANSTGBAY:
                    case Bay.TYPETITANSYSBAY:
                        return TITAN_HEIGHT;
                        break;
                }
            }
            
            if (component.position.type == Position.BAY_ENCLOSURE ||
                component.position.type == Position.BAY_HALF_ENCLOSURE_LEFT ||
                component.position.type == Position.BAY_HALF_ENCLOSURE_RIGHT) {
				if (component is DAE && (SymmController.instance.viewPerspective == Constants.TOP_VIEW_PERSPECTIVE ||
					SymmController.instance.viewPerspective == Constants.SIDE_3D_VIEW_PERSPECTIVE))
				{
					return component.size.height * DAE_ENCLOSURE_M_FAMILY_HEIGHT;
				}

                if(component is sym.objectmodel.common.KVM && SymmController.instance.currentComponent is sym.objectmodel.common.KVM)
                {  
                    return KVM_OPENED_HEIGHT * DEFAULT_COMPONENT_UHEIGHT;
                }
				
                return component.size.height * DEFAULT_COMPONENT_UHEIGHT;
            }

            if (component.position.type == Position.LOWERHALFBAYVERTICAL ||
                component.position.type == Position.UPPERHALFBAYVERTICAL) {
                return DEFAULT_COMPONENT_UWIDTH;
            }
            
            // these are positions for SPS, thus same size
            if (component.position.type == Position.ENGINESIDE_SPS_LEFT ||
                component.position.type == Position.ENGINESIDE_SPS_RIGHT ||
                component.position.type == Position.MIDDLEBAYVERTICAL) {
                return SPS_HEIGHT;
            }

            if (component.position.type == Position.BACKPANEL_PDU) {
                return DEFAULT_COMPONENT_UHEIGHT;
            }

            if (component.position.type == Position.BACKPANEL_PDP) {
                return DEFAULT_COMPONENT_UHEIGHT;
            }
            
            if (component.position.type == Position.ENGINE_DIRECTOR_2040k) {
                return DEFAULT_COMPONENT_UHEIGHT;
            }
            
            if (component.position.type == Position.ENGINE_DIRECTOR_10ke) {
                return DEFAULT_COMPONENT_UWIDTH/4;
            }
			
            if (component.position.type == Position.ENGINE_DIRECTOR_VG3R) {
                return DEFAULT_COMPONENT_UWIDTH/4;
            }

			if (component is Drive)
			{
				return DRIVE_HEIGHT;
			}
				
            return 0;
        }
 
        private function getComponentWidth(component:ComponentBase):int {
            var width:int = 0;
            var bay:Bay = null;
            
            if (component is sym.objectmodel.common.Configuration) {
                var cfg:sym.objectmodel.common.Configuration = component as sym.objectmodel.common.Configuration;
                
                // add 2 spaces on each side
                width += 2 * _renderer.baySpace;
                
                // add space between each bay
                width += (cfg.children.length - 1) * _renderer.baySpace;
                
                // replace space for dispersion
                if (cfg.dispersed != -1) {
                    width += (BAY_DISPERSED_SPACE - _renderer.baySpace);
                }
                
                // add widths of bays
                for each (bay in component.children) {
                    width += getComponentWidth(bay);
                }
                return width;
            }
            
            if (component is Bay) {
                bay = component as Bay;
                switch (bay.type) {
                    case Bay.TYPEMOHAWKSTGBAY:
                    case Bay.TYPEMOHAWKSYSBAY:
                        return MOHAWK_WIDTH;
                        break;
                    case Bay.TYPETITANSTGBAY:
                    case Bay.TYPETITANSYSBAY:
                        return TITAN_WIDTH;
                        break;
                }
            }
            if (component.position.type == Position.BAY_ENCLOSURE) {
				if (component is DAE && (SymmController.instance.viewPerspective == Constants.TOP_VIEW_PERSPECTIVE || 
					SymmController.instance.viewPerspective == Constants.SIDE_3D_VIEW_PERSPECTIVE))
				{
					return SymmController.instance.viewPerspective == Constants.SIDE_3D_VIEW_PERSPECTIVE ? DAE_SIDE_VIEW_ENCLOSURE_WIDTH :
						getComponentHeight(component) * DAE_ENCLOSURE_M_FAMILY_WIDTH_PERCENT;
				}
				
                return DEFAULT_COMPONENT_UWIDTH;
            }
            
            if (component.position.type == Position.BAY_HALF_ENCLOSURE_LEFT ||
                component.position.type == Position.BAY_HALF_ENCLOSURE_RIGHT) {
            
                if (component is SPS) {
                    return getComponentHeight(component) * (MOHAWK_VERTICAL_FRONT_SPS_HEIGHT/MOHAWK_VERTICAL_FRONT_SPS_WIDTH);                    
                }
                
                return DEFAULT_COMPONENT_UWIDTH/2;
            }

            if (component.position.type == Position.LOWERHALFBAYVERTICAL ||
                component.position.type == Position.UPPERHALFBAYVERTICAL) {
                return component.size.height * DEFAULT_COMPONENT_UHEIGHT;
            }

            // these are positions for SPS, thus same size
            if (component.position.type == Position.ENGINESIDE_SPS_LEFT ||
                component.position.type == Position.ENGINESIDE_SPS_RIGHT ||
                component.position.type == Position.MIDDLEBAYVERTICAL) {
                return SPS_WIDTH;
            }

            if (component.position.type == Position.BACKPANEL_PDU) {
                return getComponentHeight(component) * (MOHAWK_PDU_WIDTH/MOHAWK_PDU_HEIGHT);
            }

            if (component.position.type == Position.BACKPANEL_PDP) {
                return getComponentHeight(component) * (MOHAWK_PDP_WIDTH/MOHAWK_PDP_HEIGHT);
            }

            if (component.position.type == Position.ENGINE_DIRECTOR_2040k) {
                return DEFAULT_COMPONENT_UWIDTH/4;
            }
            
            if (component.position.type == Position.ENGINE_DIRECTOR_10ke ||
				component.position.type == Position.ENGINE_DIRECTOR_VG3R) {
                return DEFAULT_COMPONENT_UHEIGHT;
            }
            
			if (component is Drive)
			{
				return DRIVE_WIDTH;
			}
			
            return width;
        }
        
        /**
         * Creates rectangle that represents slot for the given vgr3 engine port position index 
         * @param uiComp  engine uicomponent
         * @param positionIndex engine port position index
         * @return Rectangle
         */        
        public static function createVg3rEngineComponentRect(uiComp:UIComponent, positionIndex:int):Rectangle
        {
            if(positionIndex < 0 || positionIndex > 19 || uiComp == null || uiComp.width == 0 || uiComp.height == 0) return null;
            
            const portGap:Number = - 0.001 * uiComp.width; 
            const compW:Number = ENGINE_VG3R_FRONTEND_RECT.width * uiComp.width;
            const slot:int = sym.objectmodel.common.Engine.getSlotNumberByPosition(positionIndex);
            
            var rect:Rectangle = new Rectangle( 
                ENGINE_VG3R_FRONTEND_RECT.x * uiComp.width + slot * (compW + portGap), 
                ENGINE_VG3R_FRONTEND_RECT.y * uiComp.height + (positionIndex >=10  ?  ENGINE_VG3R_DIR_OFFSET * uiComp.height : 0), 
                compW, 
                ENGINE_VG3R_FRONTEND_RECT.height * uiComp.height);
            
            return rect;
        }
        
        /**
         * Gets slot number for the given point 
         * @param x
         * @param y
         * @param uiComponent
         * @return slot number (0-9) or -1 if given point is outside the slot limits
         */        
        public static function getVg3rEngineSlotByPoint(x:Number, y:Number, uiComponent:UIComponent):int
        {
            var slotNumber:int = -1;
            
            for(var posIndex:int = 0 ; posIndex < 20; posIndex++)
            {
                var componentRectangle:Rectangle = createVg3rEngineComponentRect(uiComponent, posIndex);
                
                if(componentRectangle == null) continue;
                
                if(componentRectangle.contains(x, y))
                {
                    slotNumber = sym.objectmodel.common.Engine.getSlotNumberByPosition(posIndex);
                    break;
                }
            }
            
            return slotNumber;
        }
		
    }
}