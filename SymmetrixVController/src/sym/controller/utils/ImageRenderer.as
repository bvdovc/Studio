package sym.controller.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import assets.images.diagram.ComponentImages;
	import assets.images.realistic.ComponentImages;
	
	import sym.controller.SymmController;
	import sym.objectmodel.common.Bay;
	import sym.objectmodel.common.ComponentBase;
	import sym.objectmodel.common.Constants;
	import sym.objectmodel.common.ControlStation;
	import sym.objectmodel.common.D15;
	import sym.objectmodel.common.DAE;
	import sym.objectmodel.common.DataMover;
	import sym.objectmodel.common.Drive;
	import sym.objectmodel.common.Engine;
	import sym.objectmodel.common.EnginePort;
	import sym.objectmodel.common.EthernetSwitch;
	import sym.objectmodel.common.IPowerTypeManager;
	import sym.objectmodel.common.InfinibandSwitch;
	import sym.objectmodel.common.KVM;
	import sym.objectmodel.common.MIBE;
	import sym.objectmodel.common.Nebula;
	import sym.objectmodel.common.PDP;
	import sym.objectmodel.common.PDU;
	import sym.objectmodel.common.PDU_VG3R;
	import sym.objectmodel.common.Position;
	import sym.objectmodel.common.SPS;
	import sym.objectmodel.common.Server;
	import sym.objectmodel.common.Tabasco;
	import sym.objectmodel.common.UPS;
	import sym.objectmodel.common.Vanguard;
	import sym.objectmodel.common.Viking;
	import sym.objectmodel.common.Voyager;
	import sym.objectmodel.driveUtils.DriveDef;
	import sym.objectmodel.driveUtils.DriveRegister;
	import sym.objectmodel.driveUtils.enum.DriveType;
    
    public class ImageRenderer implements IRenderer
    {
        //Small images used in drag-drop feature
        public static const WHIRLWIND_SMALL:Bitmap = new assets.images.realistic.ComponentImages.WhirlwindSmall();
        public static const ASTEROID_SMALL:Bitmap = new assets.images.realistic.ComponentImages.AsteroidSmall();
        public static const THUNDERBOLT_SMALL:Bitmap = new assets.images.realistic.ComponentImages.ThunderboltSmall();
        public static const THUNDERCHILD_SMALL:Bitmap = new assets.images.realistic.ComponentImages.ThunderchildSmall();
        public static const ELNINO_SMALL:Bitmap = new assets.images.realistic.ComponentImages.ElninoSmall();
        public static const ERRUPTION_SMALL:Bitmap = new assets.images.realistic.ComponentImages.ErruptionSmall();
        public static const HEATWAVE_SMALL:Bitmap = new assets.images.realistic.ComponentImages.HeatwaveSmall();
        public static const FC_GLACIER_SMALL_SMALL:Bitmap = new assets.images.realistic.ComponentImages.FCGlacierSmall();
        public static const FC_RAINFALL_SMALL_SMALL:Bitmap = new assets.images.realistic.ComponentImages.FCRainfallSmall();
        public static const RAINSTORM_SMALL:Bitmap = new assets.images.realistic.ComponentImages.RainstormESmall();
        public static const FICON_SMALL:Bitmap = new assets.images.realistic.ComponentImages.FiconSmall();

        // diagram pics
        private static const DIAGRAM_FRONT_MOHAWKSTGBAY:Bitmap = new assets.images.diagram.ComponentImages.FrontStorageBayMohawk();
        private static const DIAGRAM_FRONT_MOHAWKSYSBAY:Bitmap = new assets.images.diagram.ComponentImages.FrontSystemBayMohawk();
        private static const DIAGRAM_FRONT_TITANSTGBAY:Bitmap = new assets.images.diagram.ComponentImages.FrontStorageBayTitan();
        private static const DIAGRAM_FRONT_TITANSYSBAYSE:Bitmap = new assets.images.diagram.ComponentImages.FrontSystemBayTitanSE();
        private static const DIAGRAM_FRONT_TITANSYSBAY:Bitmap = new assets.images.diagram.ComponentImages.FrontSystemBayTitan();
        private static const DIAGRAM_FRONT_D15:Bitmap = new assets.images.diagram.ComponentImages.FrontD15();
        private static const DIAGRAM_FRONT_Vanguard:Bitmap = new assets.images.diagram.ComponentImages.FrontVanguard();
        private static const DIAGRAM_FRONT_Server:Bitmap = new assets.images.diagram.ComponentImages.FrontServer();
        private static const DIAGRAM_FRONT_UPS:Bitmap = new assets.images.diagram.ComponentImages.FrontUPS();
        private static const DIAGRAM_FRONT_CONTROL_STATION:Bitmap = new assets.images.diagram.ComponentImages.FrontCONTROL_STATION();
        private static const DIAGRAM_FRONT_DATA_MOVER:Bitmap = new assets.images.diagram.ComponentImages.FrontDataMover();		
        private static const DIAGRAM_FRONT_MIBE:Bitmap = new assets.images.diagram.ComponentImages.FrontMIBE();
        private static const DIAGRAM_FRONT_KVM:Bitmap = new assets.images.diagram.ComponentImages.FrontKVM();
        private static const DIAGRAM_FRONT_SPS:Bitmap = new assets.images.diagram.ComponentImages.FrontSPS();
        private static const DIAGRAM_FRONT_SPSLiOn:Bitmap = new assets.images.diagram.ComponentImages.FrontSPSLiOn();
        private static const DIAGRAM_FRONT_10kEENGINE:Bitmap = new assets.images.diagram.ComponentImages.Front10keEngine();
        private static const DIAGRAM_FRONT_2040kENGINE:Bitmap = new assets.images.diagram.ComponentImages.Front2040kEngine();		

        private static const DIAGRAM_BACK_MOHAWKSTGBAY:Bitmap = new assets.images.diagram.ComponentImages.BackStorageBayMohawk();
        private static const DIAGRAM_BACK_MOHAWKSYSBAY:Bitmap = new assets.images.diagram.ComponentImages.BackSystemBayMohawk();
        private static const DIAGRAM_BACK_TITANSTGBAY:Bitmap = new assets.images.diagram.ComponentImages.BackStorageBayTitan();
        private static const DIAGRAM_BACK_TITANSYSBAYSE:Bitmap = new assets.images.diagram.ComponentImages.BackSystemBayTitanSE();
        private static const DIAGRAM_BACK_TITANSYSBAY:Bitmap = new assets.images.diagram.ComponentImages.BackSystemBayTitan();
        private static const DIAGRAM_BACK_D15:Bitmap = new assets.images.diagram.ComponentImages.BackD15();
        private static const DIAGRAM_BACK_Vanguard:Bitmap = new assets.images.diagram.ComponentImages.BackVanguard();
        private static const DIAGRAM_BACK_UPS:Bitmap = new assets.images.diagram.ComponentImages.BackUPS();
        private static const DIAGRAM_BACK_CONTROL_STATION:Bitmap = new assets.images.diagram.ComponentImages.BackCONTROL_STATION();
        private static const DIAGRAM_BACK_DATA_MOVER:Bitmap = new assets.images.diagram.ComponentImages.BackDataMover();
        private static const DIAGRAM_BACK_MIBE:Bitmap = new assets.images.diagram.ComponentImages.BackMIBE();
        private static const DIAGRAM_BACK_PDU:Bitmap = new assets.images.diagram.ComponentImages.BackPDU();
		private static const DIAGRAM_BACK_POWERMAX_PDU:Bitmap = new assets.images.diagram.ComponentImages.PowerMaxBackPDU();
        private static const DIAGRAM_BACK_PDP1Phase:Bitmap = new assets.images.diagram.ComponentImages.BackPDP1Phase();
        private static const DIAGRAM_BACK_PDP3Phase:Bitmap = new assets.images.diagram.ComponentImages.BackPDP3Phase();
        private static const DIAGRAM_BACK_Server:Bitmap = new assets.images.diagram.ComponentImages.BackServer();
        /*
        private static const DIAGRAM_BACK_KVM:Bitmap = new assets.images.diagram.ComponentImages.BackKVM();
        */
        private static const DIAGRAM_BACK_SPS:Bitmap = new assets.images.diagram.ComponentImages.BackSPS();
        private static const DIAGRAM_BACK_10kEENGINE:Bitmap = new assets.images.diagram.ComponentImages.Back10keEngine();
        private static const DIAGRAM_BACK_20kENGINE:Bitmap = new assets.images.diagram.ComponentImages.Back20kEngine();
        private static const DIAGRAM_BACK_40kENGINE:Bitmap = new assets.images.diagram.ComponentImages.Back40kEngine();

        
        private static const DIAGRAM_BACK_PORT_FC4:Bitmap = new assets.images.diagram.ComponentImages.BackPortFC4();
        private static const DIAGRAM_BACK_PORT_FC2_SRDF1:Bitmap = new assets.images.diagram.ComponentImages.BackPortFC2_SRDF1();
        private static const DIAGRAM_BACK_PORT_FC216GB:Bitmap = new assets.images.diagram.ComponentImages.BackPortFC216GB();
        private static const DIAGRAM_BACK_PORT_FICON2:Bitmap = new assets.images.diagram.ComponentImages.BackPortFICON2();
        private static const DIAGRAM_BACK_PORT_1GBE:Bitmap = new assets.images.diagram.ComponentImages.BackPort1GBE();
        private static const DIAGRAM_BACK_PORT_10GBE:Bitmap = new assets.images.diagram.ComponentImages.BackPort10GBE();
		
    	// realistic pics
        private static const REALISTIC_FRONT_MOHAWKSTGBAY:Bitmap = new assets.images.realistic.ComponentImages.FrontStorageBayMohawk();
        private static const REALISTIC_FRONT_MOHAWKSYSBAY:Bitmap = new assets.images.realistic.ComponentImages.FrontSystemBayMohawk();
        private static const REALISTIC_FRONT_TITANSTGBAY:Bitmap = new assets.images.realistic.ComponentImages.FrontStorageBayTitan();
        private static const REALISTIC_FRONT_TITANSYSBAYSE:Bitmap = new assets.images.realistic.ComponentImages.FrontSystemBayTitanSE();
        private static const REALISTIC_FRONT_TITANSYSBAY:Bitmap = new assets.images.realistic.ComponentImages.FrontSystemBayTitan();
        private static const REALISTIC_FRONT_D15:Bitmap = new assets.images.realistic.ComponentImages.FrontD15();
        private static const REALISTIC_FRONT_Vanguard:Bitmap = new assets.images.realistic.ComponentImages.FrontVanguard();
        private static const REALISTIC_FRONT_Server:Bitmap = new assets.images.realistic.ComponentImages.FrontServer();
        private static const REALISTIC_FRONT_UPS:Bitmap = new assets.images.realistic.ComponentImages.FrontUPS();
        private static const REALISTIC_FRONT_CONTROL_STATION:Bitmap = new assets.images.realistic.ComponentImages.FrontCONTROL_STATION();
		private static const REALISTIC_FRONT_DATA_MOVER:Bitmap = new assets.images.realistic.ComponentImages.FrontDataMover();
        private static const REALISTIC_FRONT_MIBE:Bitmap = new assets.images.realistic.ComponentImages.FrontMIBE();
        private static const REALISTIC_FRONT_KVM:Bitmap = new assets.images.realistic.ComponentImages.FrontKVM();
        private static const REALISTIC_OPEN_KVM:Bitmap = new assets.images.realistic.ComponentImages.OpenedKVM();
        private static const REALISTIC_FRONT_SPS:Bitmap = new assets.images.realistic.ComponentImages.FrontSPS();
        private static const REALISTIC_FRONT_SPSLiOn:Bitmap = new assets.images.realistic.ComponentImages.FrontSPSLiOn();
        private static const REALISTIC_FRONT_10kEENGINE:Bitmap = new assets.images.realistic.ComponentImages.Front10keEngine();
        private static const REALISTIC_FRONT_2040kENGINE:Bitmap = new assets.images.realistic.ComponentImages.Front2040kEngine();

        private static const REALISTIC_BACK_MOHAWKSTGBAY:Bitmap = new assets.images.realistic.ComponentImages.BackStorageBayMohawk();
        private static const REALISTIC_BACK_MOHAWKSYSBAY:Bitmap = new assets.images.realistic.ComponentImages.BackSystemBayMohawk();
        private static const REALISTIC_BACK_TITANSTGBAY:Bitmap = new assets.images.realistic.ComponentImages.BackStorageBayTitan();
        private static const REALISTIC_BACK_TITANSYSBAYSE:Bitmap = new assets.images.realistic.ComponentImages.BackSystemBayTitanSE();
        private static const REALISTIC_BACK_TITANSYSBAY:Bitmap = new assets.images.realistic.ComponentImages.BackSystemBayTitan();
        private static const REALISTIC_BACK_D15:Bitmap = new assets.images.realistic.ComponentImages.BackD15();
        private static const REALISTIC_BACK_Vanguard:Bitmap = new assets.images.realistic.ComponentImages.BackVanguard();
        private static const REALISTIC_BACK_Server:Bitmap = new assets.images.realistic.ComponentImages.BackServer();
        private static const REALISTIC_BACK_UPS:Bitmap = new assets.images.realistic.ComponentImages.BackUPS();
        private static const REALISTIC_BACK_CONTROL_STATION:Bitmap = new assets.images.realistic.ComponentImages.BackCONTROL_STATION();
		private static const REALISTIC_BACK_DATA_MOVER:Bitmap = new assets.images.realistic.ComponentImages.BackDataMover();
        private static const REALISTIC_BACK_MIBE:Bitmap = new assets.images.realistic.ComponentImages.BackMIBE();
        private static const REALISTIC_BACK_PDU:Bitmap = new assets.images.realistic.ComponentImages.BackPDU();
        private static const REALISTIC_BACK_PDP1Phase:Bitmap = new assets.images.realistic.ComponentImages.BackPDP1Phase();
        private static const REALISTIC_BACK_PDP3Phase:Bitmap = new assets.images.realistic.ComponentImages.BackPDP3Phase();
        /*
		private static const REALISTIC_BACK_KVM:Bitmap = new assets.images.realistic.ComponentImages.BackKVM();
        */
        private static const REALISTIC_BACK_SPS:Bitmap = new assets.images.realistic.ComponentImages.BackSPS();
        private static const REALISTIC_BACK_10kEENGINE:Bitmap = new assets.images.realistic.ComponentImages.Back10keEngine();
        private static const REALISTIC_BACK_20kENGINE:Bitmap = new assets.images.realistic.ComponentImages.Back20kEngine();
        private static const REALISTIC_BACK_40kENGINE:Bitmap = new assets.images.realistic.ComponentImages.Back40kEngine();
        
        private static const REALISTIC_BACK_PORT_FC4:Bitmap = new assets.images.realistic.ComponentImages.BackPortFC4();
		public static const REALISTIC_BACK_PORT_FC4_GLACIER:Bitmap = new assets.images.realistic.ComponentImages.BackPortFC4_GLACIER;
		public static const REALISTIC_BACK_PORT_FC4_RAINFALL:Bitmap = new assets.images.realistic.ComponentImages.BackPortFC4_RAINFALL;
        public static const REALISTIC_BACK_PORT_FICON4:Bitmap = new assets.images.realistic.ComponentImages.BackPort4_FICON();
        private static const REALISTIC_BACK_PORT_FC2_SRDF1:Bitmap = new assets.images.realistic.ComponentImages.BackPortFC2_SRDF1();
        private static const REALISTIC_BACK_PORT_FC216GB:Bitmap = new assets.images.realistic.ComponentImages.BackPortFC216GB();
        private static const REALISTIC_BACK_PORT_FICON2:Bitmap = new assets.images.realistic.ComponentImages.BackPortFICON2();
        private static const REALISTIC_BACK_PORT_1GBE:Bitmap = new assets.images.realistic.ComponentImages.BackPort1GBE();
        public static const REALISTIC_BACK_PORT_10GBE:Bitmap = new assets.images.realistic.ComponentImages.BackPort10GBE();
        public static const REALISTIC_BACK_PORT_10GBE_ERRUPTION:Bitmap = new assets.images.realistic.ComponentImages.BackPort10GBE_ERRUPTION();
        public static const REALISTIC_BACK_PORT_10GBE_HEATWAVE:Bitmap = new assets.images.realistic.ComponentImages.BackPort10GBE_HEATWAVE();
        public static const REALISTIC_BACK_PORT_10GBE_RAINSTORM:Bitmap = new assets.images.realistic.ComponentImages.BackPort10GBE_RainstormE();
        public static const REALISTIC_BACK_PORT_1GBE_THUNDERBOLT:Bitmap = new assets.images.realistic.ComponentImages.BackPort1GBE_THUNDERBOLT();
        public static const REALISTIC_BACK_PORT_1GBE_THUNDERCHILD:Bitmap = new assets.images.realistic.ComponentImages.BackPort1GBE_THUNDERCHILD();
        public static const REALISTIC_BACK_COMPRESSION_ASTERIOD:Bitmap = new assets.images.realistic.ComponentImages.BackCompression_ASTEROID();
        public static const REALISTIC_BACK_FLASH_VAULT_WIRLWIND:Bitmap = new assets.images.realistic.ComponentImages.BackFlashVault_WIRLWIND();
        
        private static const REALISTIC_BACK_IB_MODULE:Bitmap = new assets.images.realistic.ComponentImages.BackIBModule();
        
		/*vg3r*/
		private static const REALISTIC_FRONT_VOYAGER:Bitmap = new assets.images.realistic.ComponentImages.FrontVoyager();
		private static const REALISTIC_FRONT_VIKING:Bitmap = new assets.images.realistic.ComponentImages.FrontViking();
		private static const REALISTIC_FRONT_TABASCO:Bitmap = new assets.images.realistic.ComponentImages.FrontTabasco();
		private static const REALISTIC_FRONT_ENGINE:Bitmap = new assets.images.realistic.ComponentImages.FrontEngine();
		private static const REALISTIC_FRONT_ETHERNET:Bitmap = new assets.images.realistic.ComponentImages.FrontEthernet();
		private static const REALISTIC_FRONT_PDU_VG3R:Bitmap = new assets.images.realistic.ComponentImages.FrontPDU_VG3R();
		private static const REALISTIC_FRONT_DINGO:Bitmap = new assets.images.realistic.ComponentImages.FrontDingo();
		private static const REALISTIC_FRONT_STINGRAY:Bitmap = new assets.images.realistic.ComponentImages.FrontStingray();
		
		//nebula
		private static const REALISTIC_FRONT_NEBULA:Bitmap = new assets.images.realistic.ComponentImages.FrontNebula();
		private static const REALISTIC_BACK_NEBULA:Bitmap = new assets.images.realistic.ComponentImages.BackNebula(); 
		private static const REALISTIC_FRONT_ETHERNET_NEBULA:Bitmap = new assets.images.realistic.ComponentImages.FrontEthernetNebula();
		private static const REALISTIC_BACK_ETHERNET_NEBULA:Bitmap = new assets.images.realistic.ComponentImages.BackEthernetNebula();
		private static const REALISTIC_DRIVE_FLASH_1920_NEBULA:Bitmap = new assets.images.realistic.ComponentImages.Drive_1920_FLASH_Nebula();
		private static const REALISTIC_DRIVE_FLASH_3840_NEBULA:Bitmap = new assets.images.realistic.ComponentImages.Drive_3840_FLASH_Nebula();
		private static const REALISTIC_DRIVE_FLASH_7680_NEBULA:Bitmap = new assets.images.realistic.ComponentImages.Drive_7680_FLASH_Nebula();
		private static const REALISTIC_BACK_POWERMAX_PDU:Bitmap = new assets.images.realistic.ComponentImages.PowerMaxBackPDU();
		private static const REALISTIC_DRILL_DOWN_POWERMAX_PDU:Bitmap = new assets.images.realistic.ComponentImages.PowerMaxDrillDownPDU();
		
		
		private static const REALISTIC_BACK_VIKING:Bitmap = new assets.images.realistic.ComponentImages.BackViking();
		private static const REALISTIC_BACK_VOYAGER:Bitmap = new assets.images.realistic.ComponentImages.BackVoyager();
		private static const REALISTIC_BACK_TABASCO:Bitmap = new assets.images.realistic.ComponentImages.BackTabasco();
		private static const REALISTIC_BACK_ENGINE:Bitmap = new assets.images.realistic.ComponentImages.BackEngine();
		private static const REALISTIC_BACK_ENGINE_250F:Bitmap = new assets.images.realistic.ComponentImages.BackEngine250F();
        private static const REALISTIC_BACK_PDU_VG3R:Bitmap = new assets.images.realistic.ComponentImages.BackPDU_VG3R();
		private static const REALISTIC_BACK_PDU_VG3R_LEFT:Bitmap = new assets.images.realistic.ComponentImages.BackPDU_VG3R_LEFT();
        private static const REALISTIC_BACK_PDU_VG3R_RIGHT:Bitmap = new assets.images.realistic.ComponentImages.BackPDU_VG3R_RIGHT();
		private static const REALISTIC_BACK_ETHERNET:Bitmap = new assets.images.realistic.ComponentImages.BackEthernet();
		private static const REALISTIC_BACK_DINGO:Bitmap = new assets.images.realistic.ComponentImages.BackDingo();
		private static const REALISTIC_BACK_STINGRAY:Bitmap = new assets.images.realistic.ComponentImages.BackStingray();
		
		private static const REALISTIC_TOP_VOYAGER:Bitmap = new assets.images.realistic.ComponentImages.TopVoyager();
		private static const REALISTIC_TOP_VIKING:Bitmap = new assets.images.realistic.ComponentImages.TopViking();
		private static const REALISTIC_SIDE3D_VOYAGER:Bitmap = new assets.images.realistic.ComponentImages.Side3DVoyager();
		private static const REALISTIC_SIDE3D_VIKING:Bitmap = new assets.images.realistic.ComponentImages.Side3DViking();
        
        private static const REALISTIC_TOP_DRIVE_FLASH_200:Bitmap = new assets.images.realistic.ComponentImages.TopDrive_200_FLASH();
        private static const REALISTIC_TOP_DRIVE_FLASH_400:Bitmap = new assets.images.realistic.ComponentImages.TopDrive_400_FLASH();
        private static const REALISTIC_TOP_DRIVE_FLASH_800:Bitmap = new assets.images.realistic.ComponentImages.TopDrive_800_FLASH();
        private static const REALISTIC_TOP_DRIVE_FLASH_1600:Bitmap = new assets.images.realistic.ComponentImages.TopDrive_1600_FLASH();
        private static const REALISTIC_TOP_DRIVE_FLASH_960:Bitmap = new assets.images.realistic.ComponentImages.TopDrive_960_FLASH();
        private static const REALISTIC_TOP_DRIVE_FLASH_1920:Bitmap = new assets.images.realistic.ComponentImages.TopDrive_1920_FLASH();
        private static const REALISTIC_TOP_DRIVE_FLASH_3840:Bitmap = new assets.images.realistic.ComponentImages.TopDrive_3840_FLASH();
        private static const REALISTIC_TOP_DRIVE_300GB_10K:Bitmap = new assets.images.realistic.ComponentImages.TopDrive_300GB_10K();
        private static const REALISTIC_TOP_DRIVE_600GB_10K:Bitmap = new assets.images.realistic.ComponentImages.TopDrive_600GB_10K();
        private static const REALISTIC_TOP_DRIVE_1TB_10K:Bitmap = new assets.images.realistic.ComponentImages.TopDrive_1TB_10K();
        private static const REALISTIC_TOP_DRIVE_300GB_15K:Bitmap = new assets.images.realistic.ComponentImages.TopDrive_300GB_15K();
		private static const REALISTIC_TOP_DRIVE_VOYAGER_FLASH_200:Bitmap = new assets.images.realistic.ComponentImages.TopDriveVoyager_200GB_FLASH();
		private static const REALISTIC_TOP_DRIVE_VOYAGER_FLASH_400:Bitmap = new assets.images.realistic.ComponentImages.TopDriveVoyager_400GB_FLASH();
		private static const REALISTIC_TOP_DRIVE_VOYAGER_FLASH_800:Bitmap = new assets.images.realistic.ComponentImages.TopDriveVoyager_800GB_FLASH();
		private static const REALISTIC_TOP_DRIVE_VOYAGER_FLASH_1600:Bitmap = new assets.images.realistic.ComponentImages.TopDriveVoyager_1600GB_FLASH();
		private static const REALISTIC_TOP_DRIVE_VOYAGER_FLASH_960:Bitmap = new assets.images.realistic.ComponentImages.TopDriveVoyager_960GB_FLASH();
		private static const REALISTIC_TOP_DRIVE_VOYAGER_FLASH_1920:Bitmap = new assets.images.realistic.ComponentImages.TopDriveVoyager_1920GB_FLASH();
		private static const REALISTIC_TOP_DRIVE_VOYAGER_FLASH_3840:Bitmap = new assets.images.realistic.ComponentImages.TopDriveVoyager_3840GB_FLASH();
		private static const REALISTIC_DRIVE_FLASH_7680:Bitmap = new assets.images.realistic.ComponentImages.Drive_7680_FLASH();
		private static const REALISTIC_DRIVE_FLASH_15360:Bitmap = new assets.images.realistic.ComponentImages.Drive_15360_FLASH();
		private static const REALISTIC_TOP_DRIVE_VOYAGER_300GB_10K:Bitmap = new assets.images.realistic.ComponentImages.TopDriveVoyager_300GB_10K();
		private static const REALISTIC_TOP_DRIVE_VOYAGER_600GB_10K:Bitmap = new assets.images.realistic.ComponentImages.TopDriveVoyager_600GB_10K();
		private static const REALISTIC_TOP_DRIVE_VOYAGER_1TB_10K:Bitmap = new assets.images.realistic.ComponentImages.TopDriveVoyager_1TB_10K();
		private static const REALISTIC_TOP_DRIVE_VOYAGER_300GB_15K:Bitmap = new assets.images.realistic.ComponentImages.TopDriveVoyager_300GB_15K();
		private static const REALISTIC_TOP_DRIVE_VOYAGER_2TB_7K:Bitmap = new assets.images.realistic.ComponentImages.TopDriveVoyager_2TB_7K();
        private static const REALISTIC_TOP_DRIVE_VOYAGER_4TB_7K:Bitmap = new assets.images.realistic.ComponentImages.TopDriveVoyager_4TB_7K();
		
        private static const IB_REAR_CONNECTION_X:Number = 0.72;
        
        private static const SPSCONNECTION_X:Number = 0.58;
        private static const ENGINECONNECTION_X:Number = 0.8;
        private static const ENGINECONNECTION_Y:Number = 0.32;
        private static const ENGINECONNECTION_WIDTH:Number = 65;
        private static const ENGINECONNECTION_HEIGHT:Number = 35;

        private var _drawingRenderer:DrawingRenderer = null;
        private var _renderEngineDAEConnections:Boolean = false;
        private var _realisticImages:Boolean = true;
		private var _engineDAEConnection:ComponentBase = null;
		private var _engineDAEConnectionRect:Rectangle = null;
		
		private var renderDriveFlag:Boolean = false; //flags if Drive render is already done
		private var counter:int = 0; //used for drive count in highlighting rendering
		private var resetDriveCounter:Boolean = true; // flag if we need to reset drive counter for highlight render 
		private var numOfDrives:int; // determines number of drived per DAE for rendering
		private var daeCounter:int = 0; // determines which dae will be highlighted with two colors, for PM 8000 only
		private var bayIndicator:int = 0; // determines which bay is in focus
        
        public function ImageRenderer()
        {
            _drawingRenderer = new DrawingRenderer();
        }
        
        /**
         * Renders as drawing. 
         * @param viewSide
         * @param component
         * @param parentBitmapData
         * @param position
         * 
         */
        public function render(viewSide:String, component:ComponentBase, parentBitmapData:BitmapData, position:Rectangle):void
        {
			
            if (component.position.flip) {
				if (viewSide == Constants.FRONT_VIEW_PERSPECTIVE)
				{
					viewSide = Constants.REAR_VIEW_PERSPECTIVE;
				}
				if (viewSide == Constants.REAR_VIEW_PERSPECTIVE)
				{
					if (component is Voyager || component is Viking)
					{
						viewSide = Constants.TOP_VIEW_PERSPECTIVE;
					}
					else
					{
						viewSide = Constants.FRONT_VIEW_PERSPECTIVE;
					}
				}
				if (viewSide == Constants.TOP_VIEW_PERSPECTIVE)
				{
					viewSide = Constants.FRONT_VIEW_PERSPECTIVE;	
				}
            }
			
			if(component is PDU && position.height == 750)
				var bitmap:Bitmap = getComponentBitmapData(component, viewSide, true);
			else
            	var bitmap:Bitmap = getComponentBitmapData(component, viewSide);
            var drawComponents:Boolean = true;
            
			// if we have empty slot without any I/O module do not draw any component
			if (component.type == EnginePort.EMPTY_SLOT)
				return;
            // if we cannot get bitmap, fallback to simple drawing
            if (!bitmap || (!(component is Bay) && !drawComponents)) {
                _drawingRenderer.render(viewSide, component, parentBitmapData, position);
                return;
            }
            var scaleX:Number = new Number(position.width)/bitmap.width;
            var scaleY:Number = new Number(position.height)/bitmap.height;
            var matrix:Matrix = new Matrix();
            var extraTranslateX:Number = 0;
            var extraTranslateY:Number = 0;
            
            if (!isNaN(component.position.rotation)) {
                matrix.rotate(component.position.rotation);
                // re-calc scaling
                scaleX = new Number(position.width)/bitmap.height;
                scaleY = new Number(position.height)/bitmap.width;
                if (component.position.mirrorY) {
                    scaleX = -scaleX;
                    extraTranslateX += position.width;
                }
                if (component.position.mirrorX) {
                    scaleY = -scaleY;
                    extraTranslateY += position.height;
                }
                matrix.scale(scaleX, scaleY);
                if (component.position.rotation == Position.ROTATION90) {
                    // when rotated, add width
                    matrix.translate(extraTranslateX + position.x + position.width, extraTranslateY + position.y);
                } else if (component.position.rotation == Position.ROTATION270) {
                    // when rotated, add width
                    matrix.translate(extraTranslateX + position.x, extraTranslateY + position.y + position.height);
                } else {
                    // do not know how to render other rotations
                    _drawingRenderer.render(viewSide, component, parentBitmapData, position);
                    return;
                }
            } else {
                if (component.position.mirrorY) {
                    scaleX = -scaleX;
                    extraTranslateX = position.width;
                } if (component.position.mirrorX) {
                    scaleY = -scaleY;
                    extraTranslateY = position.height;
                }
                matrix.scale(scaleX, scaleY);
                matrix.translate(extraTranslateX + position.x, extraTranslateY + position.y);
            }
            
            parentBitmapData.draw(bitmap, matrix, null, null, null, true);
			
			// flag if DAE rectangle (connection to Engine) should be render in front of all other components
			var renderInFront:Boolean = (component is EnginePort || component is Drive) && _engineDAEConnection;
			
			// numOfDrives and counter are used for drive count, only last drive will be highlighted  
			if(component is DAE)
			{
				numOfDrives = component.children.length;
				resetDriveCounter = true;
			}
			if(resetDriveCounter)
			{
				resetDriveCounter = false;
				counter = 0;
			}
			if(component is Drive)
				counter++;
            
			if(SymmController.instance.isAFA() || SymmController.instance.isPM())
			{
				
				if (_renderEngineDAEConnections && (component.isEngine || component is DAE || component is SPS))	
					renderEngineDAEConnection_AFA_PM(component, parentBitmapData, position, viewSide);	
				else if(_renderEngineDAEConnections && (component is Drive)&& counter == numOfDrives)
					renderEngineDAEConnection_AFA_PM(_engineDAEConnection, parentBitmapData, _engineDAEConnectionRect, viewSide);
			}
			else
			{
				if (_renderEngineDAEConnections && (
					component.isEngine || component is DAE || renderInFront ||
					(SymmController.instance.isAFA() && (component is SPS || component is InfinibandSwitch))))
				{
					renderInFront ? renderEngineDAEConnection(_engineDAEConnection, parentBitmapData, _engineDAEConnectionRect) : 
						renderEngineDAEConnection(component, parentBitmapData, position);
				}
			}
        }

        public function set realistic(value:Boolean):void {
            _realisticImages = value;
        }
        
        private function renderEngineDAEConnection(component:ComponentBase, parentBitmapData:BitmapData, parentPosition:Rectangle):void {
            var engineId:int = -1;
            
            if (component is DAE) {
                engineId = (component as DAE).parentEngine;
            } else if (component.isEngine) {
                engineId = int(component.id);
            }
            else if(component is SPS){
                engineId = (component as SPS).parentEngine;
            }
            
            var mFamilySPSOrIB:Boolean = (SymmController.instance.isAFA() && (component is SPS || component is InfinibandSwitch));
            
            if (engineId == -1 && !mFamilySPSOrIB) {
                return;
            }
            
			if (component is sym.objectmodel.common.Engine ||component is Tabasco) {
				_engineDAEConnection = component;
				_engineDAEConnectionRect = parentPosition;
			}
			
            var position:Rectangle = new Rectangle();
            
            if (isNaN(component.position.rotation)) {
				position.width = ENGINECONNECTION_WIDTH;
				position.height = ENGINECONNECTION_HEIGHT;
                position.y = parentPosition.y +   (parentPosition.height - position.height)/2;
                
                if(component is SPS)
                    position.x = parentPosition.x + parentPosition.width * SPSCONNECTION_X;
                else if(component is InfinibandSwitch && component.type == InfinibandSwitch.TYPE_STINGRAY && SymmController.instance.viewPerspective == Constants.REAR_VIEW_PERSPECTIVE)
                    position.x = parentPosition.x + parentPosition.width * IB_REAR_CONNECTION_X; 
                else
                    position.x = parentPosition.x + parentPosition.width * ENGINECONNECTION_X;
            } else {
				position.width = ENGINECONNECTION_WIDTH;
				position.height = ENGINECONNECTION_HEIGHT;
                position.x = parentPosition.x + ( parentPosition.width - position.width)/2;
                position.y = parentPosition.y + ENGINECONNECTION_X * parentPosition.height;
            }
            
            var sprite:Sprite = new Sprite();
            if(mFamilySPSOrIB)
            {
                sprite.graphics.beginFill(_drawingRenderer.getComponentColor(component), 1);
                sprite.graphics.drawEllipse(0, 0, position.width - 1, position.height - 1);
                sprite.graphics.endFill();
                
                sprite.graphics.lineStyle(5, DrawingRenderer.BORDER_COLOR);
                sprite.graphics.drawEllipse(0,0, position.width, position.height);
            }
            else
            {
                sprite.graphics.beginFill(_drawingRenderer.getComponentColor(component), 1);
                sprite.graphics.drawRect(0, 0, position.width - 1, position.height - 1);
                sprite.graphics.endFill();
                
                sprite.graphics.lineStyle(5, DrawingRenderer.BORDER_COLOR);
                sprite.graphics.drawRect(0, 0, sprite.width, sprite.height);
            }
            
            var matrix:Matrix = new Matrix();
            matrix.translate(position.x, position.y);
            parentBitmapData.draw(sprite, matrix, null, null, null, true);
            
            if(component is sym.objectmodel.common.Engine) //m family engine connection with SPS
            {
                sprite = new Sprite();
                position = new Rectangle();
                 
                position.width = ENGINECONNECTION_WIDTH;
                position.height = ENGINECONNECTION_HEIGHT;
                position.x = parentPosition.x + parentPosition.width - parentPosition.width * ENGINECONNECTION_X - position.width;
                position.y = parentPosition.y +   (parentPosition.height - position.height)/2;
                
                sprite.graphics.beginFill(_drawingRenderer.getComponentColor(component), 1);
                sprite.graphics.drawEllipse(0, 0, position.width - 1, position.height - 1);
                sprite.graphics.endFill();
                sprite.graphics.lineStyle(5, DrawingRenderer.BORDER_COLOR);
                sprite.graphics.drawEllipse(0, 0, sprite.width, sprite.height);
                
                matrix = new Matrix();
                matrix.translate(position.x, position.y);
                parentBitmapData.draw(sprite, matrix, null, null, null, true);
            }
        }
        
		private function renderEngineDAEConnection_AFA_PM(component:ComponentBase, parentBitmapData:BitmapData, parentPosition:Rectangle, viewSide:String):void
		{
			var engineId:int = -1;
			var daeIndicator:Boolean = false;
			
			if(component is DAE) // used for DAEs that need to be highlighted with two colors
			{
				if(((component as DAE).parent as Bay).countDAEs == 3 || ((component as DAE).parent as Bay).countDAEs == 6 )
					daeIndicator = true;
				
			 	if(((component as DAE).parentEngine == 1 && ((component as DAE).parent as Bay).countDAEs == 2) ||
					((component as DAE).parentEngine == 3 && ((component as DAE).parent as Bay).countDAEs == 5) ||
					((component as DAE).parentEngine == 5 && ((component as DAE).parent as Bay).countDAEs == 2) ||
					((component as DAE).parentEngine == 7 && ((component as DAE).parent as Bay).countDAEs == 5))
					daeIndicator = false;
				else
					daeIndicator = true;
				
				if(((component as DAE).parent as Bay).positionIndex != bayIndicator) // resets daeCounter after first bay is finished
				{
					daeCounter = 0;
					bayIndicator = ((component as DAE).parent as Bay).positionIndex;
				}
					
			}
			if(component is Engine && SymmController.instance.vmaxConfiguration == Constants.PowerMax_8000) // used for reseting daeCounter, when highlighting recursion starts
				daeCounter = 0;
			
			if (component is DAE) 
			{
				engineId = (component as DAE).parentEngine;
				daeCounter++
			}
			else if (component.isEngine) 
			{
				engineId = int(component.id);
			}
			else if(component is SPS)
			{
				engineId = (component as SPS).parentEngine;
			}
			
			if (component is sym.objectmodel.common.Engine || component is Tabasco || component is Nebula) {
				_engineDAEConnection = component;
				_engineDAEConnectionRect = parentPosition;
			}
			
			var sprite:Sprite = new Sprite();
			
			if(renderDriveFlag && (component is DAE))
			{					
				sprite.graphics.beginFill(_drawingRenderer.getComponentColor(component, true), 0.5);
				sprite.graphics.drawRect(0, 0, parentPosition.width / 2, parentPosition.height);
				sprite.graphics.endFill();
				sprite.graphics.beginFill(_drawingRenderer.getComponentColor(component), 0.5);
				sprite.graphics.drawRect(parentPosition.width / 2, 0, parentPosition.width / 2, parentPosition.height);
				sprite.graphics.endFill();
				
				resetDriveCounter = true;
				renderDriveFlag = false;
			}
			else
			{
				sprite.graphics.beginFill(_drawingRenderer.getComponentColor(component), 0.5);
				sprite.graphics.drawRect(0, 0, parentPosition.width, parentPosition.height);
				sprite.graphics.endFill();	
				
				
				
				if(component is DAE && (component as DAE).parentEngine % 2 != 0 && SymmController.instance.vmaxConfiguration == Constants.PowerMax_8000 && daeIndicator) // flags when two colors DAE is next for highlight render
				{
					if((viewSide == Constants.FRONT_VIEW_PERSPECTIVE && (daeCounter == 3 || daeCounter == 9)) || (viewSide == Constants.REAR_VIEW_PERSPECTIVE && (daeCounter == 1 || daeCounter == 4)))
						renderDriveFlag = true;
				}
			}

			sprite.graphics.lineStyle(5, DrawingRenderer.BORDER_COLOR);
			sprite.graphics.drawRect(0, 0, sprite.width, sprite.height);
			
			var matrix:Matrix = new Matrix();
			matrix.translate(parentPosition.x, parentPosition.y);
			parentBitmapData.draw(sprite, matrix, null, null, null, true);
			
		}
        
        /**
         * When rendering images, there is no space between bays. 
         * @return 
         * 
         */
        public function get baySpace():int {
            return 0;
        }
        
        /**
         * Render dispersed connecting line.  
         * @param bData
         * @param position
         * 
         */
        public function drawDispersedConnectingLine(bData:BitmapData, position:Rectangle):void {
            _drawingRenderer.drawDispersedConnectingLine(bData, position);
        }

        public function drawBayMask(bData:BitmapData, position:Rectangle):void {
            if (_drawingRenderer) {
                _drawingRenderer.drawBayMask(bData, position);
            }
        }
        
        public function set renderEngineDAEConnections(value:Boolean):void {
            _renderEngineDAEConnections = value;
            if (_drawingRenderer) {
                _drawingRenderer.renderEngineDAEConnections = value;
            }
        }
        
        public function drawSelectionBox(sprite:Sprite, position:Rectangle):void {
            _drawingRenderer.drawSelectionBox(sprite, position);
        }
        
        /**
         * Returns bitmap data, if not found return null and fallback to drawing. 
         * @param component
         * @param viewSide
         * @return 
         * 
         */
        private function getComponentBitmapData(component:ComponentBase, viewSide:String, isDrillDownImage:Boolean = false):Bitmap {
            var prefix:String = "DIAGRAM_";

            if (_realisticImages) {
                prefix = "REALISTIC_";
            }
            
			var drillDown_PDU: String;
			
			if(isDrillDownImage)
				drillDown_PDU = prefix + "DRILL_DOWN_POWERMAX_PDU";
			else
				drillDown_PDU = prefix + "BACK_POWERMAX_PDU";
            if (viewSide == Constants.FRONT_VIEW_PERSPECTIVE) {
                // front pics
                
                if (component is Bay) {
                    var bay:Bay = component as Bay;
                    switch (bay.type) {
                        case Bay.TYPEMOHAWKSTGBAY:
                            return ImageRenderer[prefix+"FRONT_MOHAWKSTGBAY"];
                        case Bay.TYPEMOHAWKSYSBAY:
                            return ImageRenderer[prefix+"FRONT_MOHAWKSYSBAY"];
                        case Bay.TYPETITANSTGBAY:
                            return ImageRenderer[prefix+"FRONT_TITANSTGBAY"];
                        case Bay.TYPETITANSYSBAY:
                            return ImageRenderer[prefix+"FRONT_TITANSYSBAY"];
                    }
                }
                
                
				if (component is sym.objectmodel.common.Engine) {
					return ImageRenderer[prefix+"FRONT_ENGINE"];
				}

                if (component is sym.objectmodel.common.D15) {
                    return ImageRenderer[prefix+"FRONT_D15"] 
                }
                
				if (component is Tabasco) {
					return ImageRenderer[prefix+"FRONT_TABASCO"] 
				}
				
				if (component is Nebula) {
					return ImageRenderer[prefix+"FRONT_NEBULA"] 
				}

				if (component is sym.objectmodel.common.Viking) {
					return ImageRenderer[prefix+"FRONT_VIKING"] 
				}
				
				if (component is sym.objectmodel.common.Voyager) {
					return ImageRenderer[prefix+"FRONT_VOYAGER"] 
				}
				
                if (component is sym.objectmodel.common.Vanguard) {
                    return ImageRenderer[prefix+"FRONT_Vanguard"] 
                }
    
                if (component is sym.objectmodel.common.UPS) {
                    return ImageRenderer[prefix+"FRONT_UPS"];
                }
				
				if (component is sym.objectmodel.common.ControlStation) {
					return ImageRenderer[prefix+"FRONT_CONTROL_STATION"];
				}
                
                if (component is sym.objectmodel.common.Server) {
                    return ImageRenderer[prefix+"FRONT_Server"];
                }
    
                if (component is sym.objectmodel.common.SPS) {
                    var pwm:sym.objectmodel.common.IPowerTypeManager = component.parentConfiguration.factory as IPowerTypeManager;
                    if (pwm.getCurrentSPSType() == SPS.TYPE_LION) {
                        return ImageRenderer[prefix+"FRONT_SPSLiOn"];
                    }
                    return ImageRenderer[prefix+"FRONT_SPS"];
                }
    
                if (component is sym.objectmodel.common.MIBE) {
                    return ImageRenderer[prefix+"FRONT_MIBE"];
                }

				if (component is sym.objectmodel.common.EthernetSwitch) {
					if(isPM8000())
						return ImageRenderer[prefix+"FRONT_ETHERNET_NEBULA"];
					
					return ImageRenderer[prefix+"FRONT_ETHERNET"];
				}
                
                if(SymmController.instance.currentComponent is sym.objectmodel.common.KVM)
                {
                    return ImageRenderer[prefix+"OPEN_KVM"];
                }
                else if (component is sym.objectmodel.common.KVM) 
                {
                    return ImageRenderer[prefix+"FRONT_KVM"];
                }
				
				if (component is InfinibandSwitch)
				{
					if (component.type == InfinibandSwitch.TYPE_DINGO)
					{
						return ImageRenderer[prefix+"FRONT_DINGO"];
					}
					if (component.type == InfinibandSwitch.TYPE_STINGRAY)
					{
						return ImageRenderer[prefix+"FRONT_STINGRAY"];
					}
				}
                
                if (component is sym.objectmodel.common.PDU) {
					return ImageRenderer[prefix+"BACK_PDU"];  
                }
				
                if (component is sym.objectmodel.common.PDU_VG3R) {
                    if(SymmController.instance.currentComponent is PDU_VG3R)  //drill down
                    {
                        return ImageRenderer[prefix+"BACK_PDU_VG3R"];
                    }
                    else if(component.position.type == Position.BAY_HALF_ENCLOSURE_RIGHT)
					{
						var bitmap:Bitmap = ImageRenderer[prefix+"FRONT_PDU_VG3R"];
						var tempBitmap:BitmapData = new BitmapData(bitmap.width, bitmap.height);
						var rotationMatrix:Matrix = new Matrix();
						rotationMatrix.rotate(Math.PI);
						rotationMatrix.translate(bitmap.width, bitmap.height);
						tempBitmap.draw(bitmap, rotationMatrix);
						return new Bitmap(tempBitmap);
					} 
                    else
					{
						return ImageRenderer[prefix+"FRONT_PDU_VG3R"];
					}
                }
                
                if (component is sym.objectmodel.common.PDP) {
                    var onePhase:Boolean = true;
					var renderPDP3Phase:Boolean = !component.visible && SymmController.instance.currentComponent is PDP;
                    if(component.parentConfiguration != null){
                        onePhase = (component.parentConfiguration.factory as IPowerTypeManager).getCurrentPowerType() == PDU.TYPE1PHASE;
                    }
                    return onePhase? (renderPDP3Phase ? ImageRenderer[prefix+"BACK_PDP3Phase"] : ImageRenderer[prefix+"BACK_PDP1Phase"]) : 
									ImageRenderer[prefix+"BACK_PDP3Phase"];
                }
                if (component is EnginePort) {
                    switch (component.type) {
                        case EnginePort.FC_4:
                        case EnginePort.DX_2_FC_2:
                        case EnginePort.DX_4:
                            return ImageRenderer[prefix+"BACK_PORT_FC4"];
                        case EnginePort.FICON_2:
                            return ImageRenderer[prefix+"BACK_PORT_FICON2"];
                        case EnginePort.FC_16GB_2:
                            return ImageRenderer[prefix+"BACK_PORT_FC216GB"];
                        case EnginePort.FC_2_SRDF_1:
                            return ImageRenderer[prefix+"BACK_PORT_FC2_SRDF1"];
                        case EnginePort.ETH_1_GIGE_1:
                        case EnginePort.ETH_2:
                        case EnginePort.SRDF_2:
                        case EnginePort.GIGE_2PORT_10GB_ELNINO:
                            return ImageRenderer[prefix+"BACK_PORT_10GBE"];
                        case EnginePort.IB_MODULE:
                            return ImageRenderer[prefix+"BACK_IB_MODULE"];
                        case EnginePort.GIGE_2PORT_10GB_ERRUPTION:
                            return ImageRenderer[prefix+"BACK_PORT_10GBE_ERRUPTION"];
                        case EnginePort.GIGE_2PORT_1GB_THUNDERBOLT:
                            return ImageRenderer[prefix+"BACK_PORT_1GBE_THUNDERBOLT"];
                        case EnginePort.GIGE_4PORT_1GB_THUNDERCHILD:
                            return ImageRenderer[prefix+"BACK_PORT_1GBE_THUNDERCHILD"];
                        case EnginePort.COMPRESSION_ASTEROID:
                            return ImageRenderer[prefix+"BACK_COMPRESSION_ASTERIOD"];
                        case EnginePort.VAULT_FLASH_WIRLWIND:
                            return ImageRenderer[prefix+"BACK_FLASH_VAULT_WIRLWIND"];
						case EnginePort.GIGE_4PORT_10GB_RAINSTORM:
                            return ImageRenderer[prefix+"BACK_PORT_10GBE_RAINSTORM"];
						case EnginePort.FICON_4_PORT:
                            return ImageRenderer[prefix+"BACK_PORT_FICON4"];
                    }
                }
				if (component is DataMover) {
					return ImageRenderer[prefix+"FRONT_DATA_MOVER"];
				}
				if (component is Drive)
				{
					return getDriveImage(component as Drive, prefix);
				}
            } else if (viewSide == Constants.REAR_VIEW_PERSPECTIVE)
			{
                // back pics
                if (component is Bay) {
                    bay = component as Bay;
                    switch (bay.type) {
                        case Bay.TYPEMOHAWKSTGBAY:
                            return ImageRenderer[prefix+"BACK_MOHAWKSTGBAY"];
                        case Bay.TYPEMOHAWKSYSBAY:
                            return ImageRenderer[prefix+"BACK_MOHAWKSYSBAY"];
                        case Bay.TYPETITANSTGBAY:
                            return ImageRenderer[prefix+"BACK_TITANSTGBAY"];
                        case Bay.TYPETITANSYSBAY:
                            return ImageRenderer[prefix+"BACK_TITANSYSBAY"];
                    }
                }
                
				if (component is sym.objectmodel.common.Engine) {
					if(!is250F() || !isPM2000())
					{
						return ImageRenderer[prefix+"BACK_ENGINE"];
					}
					return ImageRenderer[prefix+"BACK_ENGINE_250F"];
				}
				
                if (component is sym.objectmodel.common.D15) {
                    return ImageRenderer[prefix+"BACK_D15"];
                }
                
				if (component is sym.objectmodel.common.Viking) {
					return ImageRenderer[prefix+"BACK_VIKING"];
				}

				if (component is sym.objectmodel.common.Voyager) {
					return ImageRenderer[prefix+"BACK_VOYAGER"];
				}

				if (component is Tabasco) {
					return ImageRenderer[prefix+"BACK_TABASCO"];
				}
				
				if (component is Nebula) {
					return ImageRenderer[prefix+"BACK_NEBULA"];
				}
				
                if (component is sym.objectmodel.common.Vanguard) {
                    return ImageRenderer[prefix+"BACK_Vanguard"];
                }
                
                if (component is sym.objectmodel.common.UPS) {
                    return ImageRenderer[prefix+"BACK_UPS"];
                }

				if (component is sym.objectmodel.common.ControlStation) {
                    return ImageRenderer[prefix+"BACK_CONTROL_STATION"];
                }
                
                if (component is sym.objectmodel.common.Server) {
                    return ImageRenderer[prefix+"BACK_Server"];
                }
                
                if (component is sym.objectmodel.common.SPS) {
                    return ImageRenderer[prefix+"BACK_SPS"];
                }
                
                if (component is sym.objectmodel.common.MIBE) {
                    return ImageRenderer[prefix+"BACK_MIBE"];
                }

				if (component is sym.objectmodel.common.EthernetSwitch) {
					if(isPM8000())
						return ImageRenderer[prefix+"BACK_ETHERNET_NEBULA"];
					
					return ImageRenderer[prefix+"BACK_ETHERNET"];
				}

                if (component is sym.objectmodel.common.PDU) {
					if(SymmController.instance.isAFA())
					{
						return ImageRenderer[prefix+"BACK_PDU"];
					} else
						return ImageRenderer[drillDown_PDU];
                }
				
				if (component is sym.objectmodel.common.PDU_VG3R) {
                    if(SymmController.instance.currentComponent is PDU_VG3R)
                    {
                        return ImageRenderer[prefix+"BACK_PDU_VG3R"];
                    }
                    if(component.position.type == Position.BAY_HALF_ENCLOSURE_RIGHT)
                    {
					    return ImageRenderer[prefix+"BACK_PDU_VG3R_LEFT"];
                    }
                    else
                    {
                        return ImageRenderer[prefix+"BACK_PDU_VG3R_RIGHT"];
                    }
				}
				
				if (component is InfinibandSwitch)
				{
					if (component.type == InfinibandSwitch.TYPE_DINGO)
					{
						return ImageRenderer[prefix+"BACK_DINGO"];
					}
					if (component.type == InfinibandSwitch.TYPE_STINGRAY)
					{
						return ImageRenderer[prefix+"BACK_STINGRAY"];
					}
				}

                if (component is sym.objectmodel.common.PDP) {
                    var onePhase1:Boolean = true;
					var renderPDP3Phase1:Boolean = !component.visible && SymmController.instance.currentComponent is PDP;
                    if(component.parentConfiguration != null){
                        onePhase1 = (component.parentConfiguration.factory as IPowerTypeManager).getCurrentPowerType() == PDU.TYPE1PHASE;
                    }
                    return onePhase1? (renderPDP3Phase1 ? ImageRenderer[prefix+"BACK_PDP3Phase"] : ImageRenderer[prefix+"BACK_PDP1Phase"]) : 
										ImageRenderer[prefix+"BACK_PDP3Phase"];
                }
                
                if(SymmController.instance.currentComponent is sym.objectmodel.common.KVM)
                {
                    return ImageRenderer[prefix+"OPEN_KVM"];
                }
                else if(component is sym.objectmodel.common.KVM){
                    return ImageRenderer[prefix+"FRONT_KVM"];
                }
                
                if (component is EnginePort) {
                    switch (component.type) {
                        case EnginePort.FC_4:
                        case EnginePort.DX_2_FC_2:
                        case EnginePort.DX_4:
                            return ImageRenderer[prefix+"BACK_PORT_FC4"];
                        case EnginePort.FICON_2:
                            return ImageRenderer[prefix+"BACK_PORT_FICON2"];
                        case EnginePort.FC_16GB_2:
                            return ImageRenderer[prefix+"BACK_PORT_FC216GB"];
                        case EnginePort.FC_2_SRDF_1:
                            return ImageRenderer[prefix+"BACK_PORT_FC2_SRDF1"];
                        case EnginePort.ETH_1_GIGE_1:
                        case EnginePort.ETH_2:
                        case EnginePort.SRDF_2:
                        case EnginePort.GIGE_2PORT_10GB_ELNINO:
                            return ImageRenderer[prefix+"BACK_PORT_10GBE"];
						case EnginePort.FC_4_GLACIER:
							return ImageRenderer[prefix+"BACK_PORT_FC4_GLACIER"];
						case EnginePort.FC_4_RAINFALL:
							return ImageRenderer[prefix+"BACK_PORT_FC4_RAINFALL"];
                        case EnginePort.IB_MODULE:
                            return ImageRenderer[prefix+"BACK_IB_MODULE"];
                        case EnginePort.GIGE_2PORT_10GB_ERRUPTION:
                            return ImageRenderer[prefix+"BACK_PORT_10GBE_ERRUPTION"];
                        case EnginePort.GIGE_2PORT_10GB_HEATWAVE:
                            return ImageRenderer[prefix+"BACK_PORT_10GBE_HEATWAVE"];
                        case EnginePort.GIGE_2PORT_1GB_THUNDERBOLT:
                            return ImageRenderer[prefix+"BACK_PORT_1GBE_THUNDERBOLT"];
                        case EnginePort.GIGE_4PORT_1GB_THUNDERCHILD:
                            return ImageRenderer[prefix+"BACK_PORT_1GBE_THUNDERCHILD"];
                        case EnginePort.COMPRESSION_ASTEROID:
                            return ImageRenderer[prefix+"BACK_COMPRESSION_ASTERIOD"];
                        case EnginePort.VAULT_FLASH_WIRLWIND:
                            return ImageRenderer[prefix+"BACK_FLASH_VAULT_WIRLWIND"];
						case EnginePort.GIGE_4PORT_10GB_RAINSTORM:
							return ImageRenderer[prefix+"BACK_PORT_10GBE_RAINSTORM"];
						case EnginePort.FICON_4_PORT:
							return ImageRenderer[prefix+"BACK_PORT_FICON4"];
                    }
                }
				if (component is DataMover) {
					return ImageRenderer[prefix+"BACK_DATA_MOVER"];
				}
            }
			else if (viewSide == Constants.TOP_VIEW_PERSPECTIVE)
			{
				if (component is Viking)
				{
					return ImageRenderer[prefix+"TOP_VIKING"];
				}
				if (component is Voyager)
				{
					return ImageRenderer[prefix+"TOP_VOYAGER"];
				}
                if(component is Drive)
                {
					return getDriveImage(component as Drive, prefix);
                }
			}
			else if (viewSide == Constants.SIDE_3D_VIEW_PERSPECTIVE)
			{
				if (component is Viking)
				{
					return ImageRenderer[prefix+"SIDE3D_VIKING"];
				}
				if (component is Voyager)
				{
					return ImageRenderer[prefix+"SIDE3D_VOYAGER"];
				}
			}

            return null;
        }
        
		public static function getDriveImage(drive:Drive, prefix:String):Bitmap
		{
			var bitmapImage:Bitmap;
			var dd:DriveDef = DriveRegister.getById(drive.type - 1);
			
			switch(dd.type)
			{
				case DriveType.FC_SAS_10K_1TB:
					bitmapImage = ImageRenderer[dd.size == DAE.Voyager ? prefix + "TOP_DRIVE_VOYAGER_1TB_10K" : prefix + "TOP_DRIVE_1TB_10K"];
					break;
				case DriveType.FC_SAS_10K_300GB:
					bitmapImage = ImageRenderer[dd.size == DAE.Voyager ? prefix + "TOP_DRIVE_VOYAGER_300GB_10K" : prefix + "TOP_DRIVE_300GB_10K"];
					break;
				case DriveType.FC_SAS_10K_600GB:
					bitmapImage = ImageRenderer[dd.size == DAE.Voyager ? prefix + "TOP_DRIVE_VOYAGER_600GB_10K" : prefix + "TOP_DRIVE_600GB_10K"];
					break;
				case DriveType.FC_SAS_15K_300GB:
					bitmapImage = ImageRenderer[dd.size == DAE.Voyager ? prefix + "TOP_DRIVE_VOYAGER_300GB_15K" : prefix + "TOP_DRIVE_300GB_15K"];
					break;
				case DriveType.FLASH_SAS_200GB:
					bitmapImage = ImageRenderer[dd.size == DAE.Voyager ? prefix + "TOP_DRIVE_VOYAGER_FLASH_200" : prefix + "TOP_DRIVE_FLASH_200"];
					break;
				case DriveType.FLASH_SAS_400GB:
					bitmapImage = ImageRenderer[dd.size == DAE.Voyager ? prefix + "TOP_DRIVE_VOYAGER_FLASH_400" : prefix + "TOP_DRIVE_FLASH_400"];
					break;
				case DriveType.FLASH_SAS_800GB:
					bitmapImage = ImageRenderer[dd.size == DAE.Voyager ? prefix + "TOP_DRIVE_VOYAGER_FLASH_800" : prefix + "TOP_DRIVE_FLASH_800"];
					break;
				case DriveType.FLASH_SAS_1600GB:
					bitmapImage = ImageRenderer[dd.size == DAE.Voyager ? prefix + "TOP_DRIVE_VOYAGER_FLASH_1600" : prefix + "TOP_DRIVE_FLASH_1600"];
					break;
				case DriveType.FLASH_SAS_960GB:
					bitmapImage = ImageRenderer[dd.size == DAE.Voyager ? prefix + "TOP_DRIVE_VOYAGER_FLASH_960" : prefix + "TOP_DRIVE_FLASH_960"];
					break;
				case DriveType.FLASH_SAS_1920GB:
					bitmapImage = ImageRenderer[dd.size == DAE.Voyager ? prefix + "TOP_DRIVE_VOYAGER_FLASH_1920" : prefix + "TOP_DRIVE_FLASH_1920"];
					break;
				case DriveType.FLASH_SAS_3840GB:
					bitmapImage = ImageRenderer[dd.size == DAE.Voyager ? prefix + "TOP_DRIVE_VOYAGER_FLASH_3840"  : prefix + "TOP_DRIVE_FLASH_3840"];
					break;
				case DriveType.FLASH_SAS_7680GB:
					bitmapImage = ImageRenderer[prefix + "DRIVE_FLASH_7680"];
					break;
				case DriveType.FLASH_SAS_15360GB:
					bitmapImage = ImageRenderer[prefix + "DRIVE_FLASH_15360"];
					break;
				case DriveType.SATA_SAS_7K_2TB:
					bitmapImage = ImageRenderer[prefix + "TOP_DRIVE_VOYAGER_2TB_7K"];
					break;
				case DriveType.SATA_SAS_7K_4TB:
					bitmapImage = ImageRenderer[prefix + "TOP_DRIVE_VOYAGER_4TB_7K"];
					break;
				case DriveType.FLASH_NVM_1920GB:
					bitmapImage = ImageRenderer[prefix + "DRIVE_FLASH_1920_NEBULA"];
					break;
				case DriveType.FLASH_NVM_3840GB:
					bitmapImage = ImageRenderer[prefix + "DRIVE_FLASH_3840_NEBULA"];
					break;
				case DriveType.FLASH_NVM_7680GB:
					bitmapImage = ImageRenderer[prefix + "DRIVE_FLASH_7680_NEBULA"];
					break;
			}
			
			return bitmapImage;
		}
		
        /**
         * Gets small images for the component with the given type 
         * @param componentType
         * @return 
         * 
         */        
        public static function getComponentSmallImage(componentType:int):Bitmap
        {
            var bitmapImage:Bitmap = new Bitmap();
            
            switch(componentType)
            {
                case EnginePort.FC_4_GLACIER:
                    bitmapImage = ImageRenderer.FC_GLACIER_SMALL_SMALL;
                    break;
                case EnginePort.FC_4_RAINFALL:
                    bitmapImage = ImageRenderer.FC_RAINFALL_SMALL_SMALL;
                    break;
                case EnginePort.VAULT_FLASH_WIRLWIND:
                    bitmapImage = ImageRenderer.WHIRLWIND_SMALL;
                    break;
                case EnginePort.COMPRESSION_ASTEROID:
                    bitmapImage = ImageRenderer.ASTEROID_SMALL;
                    break;
                case EnginePort.GIGE_2PORT_10GB_ELNINO:
                    bitmapImage = ImageRenderer.ELNINO_SMALL;
                    break;
                case EnginePort.GIGE_2PORT_10GB_HEATWAVE:
                    bitmapImage = ImageRenderer.HEATWAVE_SMALL;
                    break;
                case EnginePort.GIGE_2PORT_10GB_ERRUPTION:
                    bitmapImage = ImageRenderer.ERRUPTION_SMALL;
                    break;
                case EnginePort.GIGE_2PORT_1GB_THUNDERBOLT:
                    bitmapImage = ImageRenderer.THUNDERBOLT_SMALL;
                    break;
                case EnginePort.GIGE_4PORT_1GB_THUNDERCHILD:
                    bitmapImage = ImageRenderer.THUNDERCHILD_SMALL;
                    break;
				case EnginePort.GIGE_4PORT_10GB_RAINSTORM:
                    bitmapImage = RAINSTORM_SMALL;
                    break;
				case EnginePort.FICON_4_PORT:
                    bitmapImage = FICON_SMALL;
                    break;
            }
            return bitmapImage;
        }
    }
}