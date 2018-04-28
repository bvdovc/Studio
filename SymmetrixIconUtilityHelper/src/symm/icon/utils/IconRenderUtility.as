package symm.icon.utils
{
	
	import mx.core.UIComponent;
	
	import spark.components.Image;
	
	import assets.images.IconImages;
	
	import sym.objectmodel.common.Bay;
	import sym.objectmodel.common.Configuration_VG3R;
	import sym.objectmodel.common.DAE;
	
	public class IconRenderUtility
	{
		private static var ICON_SMALL_HEIGHT:int = 400;
		private static var ICON_SMALL_WIDTH:int = 400;
		private static var ASPECT_RATIO_MEDIUM:Number = 1.2568;
		private static var ASPECT_RATIO_LARGE:Number = 1.3661;
		private static var ASPECT_RATIO_LARGE_VG3R:Number = 1.4754;
		private static var TITAN_BAY:String = "Titan";
		
		private static var VMAX_VG3R_BAY_OFFSETS:Array = [
			[{x:0.3, y:0.15, width:0.4, height:0.7}],
			[{x:0.1, y:0.15, width:0.38, height:0.7}, {x:0.52, y:0.15, width:0.38, height:0.7}],
			[{x:0.05, y:0.25, width:0.2, height:0.5}, {x:0.28, y:0.25, width:0.2, height:0.5}, {x:0.52, y:0.25, width:0.2, height:0.5}, {x:0.75, y:0.25, width:0.2, height:0.5}],
			[{x:0.05, y:0.3, width:0.13, height:0.4}, {x:0.2, y:0.3, width:0.13, height:0.4}, {x:0.35, y:0.3, width:0.13, height:0.4}, {x:0.5, y:0.3, width:0.13, height:0.4}, {x:0.65, y:0.3, width:0.13, height:0.4}, {x:0.8, y:0.3, width:0.13, height:0.4}],
			[{x:0.04, y:0.35, width:0.09, height:0.4}, {x:0.16, y:0.35, width:0.09, height:0.4}, {x:0.28, y:0.35, width:0.09, height:0.4}, {x:0.4, y:0.35, width:0.09, height:0.4}, {x:0.52, y:0.35, width:0.09, height:0.4}, {x:0.64, y:0.35, width:0.09, height:0.4}, {x:0.76, y:0.35, width:0.09, height:0.4}, {x:0.88, y:0.35, width:0.09, height:0.4}]
		];
		
		private static var _currentIcon:UIComponent;
		
		public static const CFG_REMOVE_BUTTON_WIDTH_RATIO:Number = 0.2;
		public static const CFG_REMOVE_BUTTON_HEIGHT_RATIO:Number = 0.2;
		public static const CFG_REMOVE_BUTTON_X_OFFSET_RATIO:Number = 0.8;
		public static const CFG_REMOVE_BUTTON_Y_OFFSET_RATIO:Number = 0.0;
		
		public function IconRenderUtility()
		{
		}
		
		public static function get currentIcon():UIComponent
		{
			return _currentIcon;
		}
		
		/**
		 * Generates configuration icon 
		 * @param config indicates vg3r configuration
		 * 
		 */		
		public static function generateIcon(config:Configuration_VG3R):void 
		{
			if (!config)
			{
				throw new ArgumentError("Can render icon only if configuration is supplied");
			}

			_currentIcon = render(config);
			
			if (_currentIcon)
			{
				return;
			}
			
			_currentIcon = null;
		}
		
		/**
		 * Rneders vmax vg3r config icon
		 * @param cfg indicates vg3r configuration
		 * @return rendered config icon
		 * 
		 */		
		private static function render(cfg:Configuration_VG3R):UIComponent
		{
			var uicomp:UIComponent = new UIComponent();
			var w:Number = ICON_SMALL_WIDTH;
			var h:Number = ICON_SMALL_HEIGHT;
			
			var size:int = cfg.children.length;
			
			if (size == 1)
			{
				size = 0;
			}
			else if (size == 2)
			{
				size = 1;
			}
			else if (size <= 4)
			{
				size = 2;
				w *= ASPECT_RATIO_MEDIUM;
			}
			else if (size <= 6)
			{
				size = 3;
				w *= ASPECT_RATIO_LARGE;
			}
			else if (size <= 8)
			{
				size = 4;
				w *= ASPECT_RATIO_LARGE_VG3R;
			}
			
			uicomp.width = w;
			uicomp.height = h;
			
			var img:Image = new Image();
			img.width = uicomp.width;
			img.height = uicomp.height;
			img.smooth = true;
			
			if (size == 0 || size == 1) 
			{
				img.source =  IconImages.BackgroundSmall;	
			} 
			else if (size == 2) 
			{
				img.source = IconImages.BackgroundMedium;
			} 
			else if (size == 3)
			{
				img.source = IconImages.BackgroundLarge;
			}
			else
			{
				img.source = IconImages.BackgroundLargeVG3R;
			}
			uicomp.addChild(img);
			
			var childImage:Image = null;
			var source:String = "";
			var count:int = 0;
			
			// add all storage bays
			for each (var bay:Bay in cfg.children)
			{
				var vg3rPart:String = (bay.isSystemBay && bay.countDAEs != 6) ? "VG3R_" + cfg.sysBayType + "E_" : "VG3R_";
				var vg3r:String = (bay.countDAEs == 5 && bay.isSystemBay) ? "VG3R_" + cfg.fifthDaePosition(bay) + "_" : vg3rPart;
				var daeCount:String = bay.countDAEs + "DAEs";
				var bayType:String = bay.isStorageBay ? "StorageBay" : "SystemBay";
					
				if (cfg.daeType == DAE.Tabasco)
				{
					// 250F config icons
					var afa250f:String = "250F_" + cfg.sysBayType + "E_" + daeCount;
					
					source = TITAN_BAY + bayType + afa250f;
				}
				else
					source = TITAN_BAY + bayType + vg3r + daeCount;
				
				childImage = new Image();
				childImage.smooth = true;
				childImage.x = VMAX_VG3R_BAY_OFFSETS[size][count].x * img.width;
				childImage.y = VMAX_VG3R_BAY_OFFSETS[size][count].y * img.height;
				childImage.width = VMAX_VG3R_BAY_OFFSETS[size][count].width * img.width;
				childImage.height = VMAX_VG3R_BAY_OFFSETS[size][count].height * img.height;		
				childImage.source = IconImages[source];
				
				uicomp.addChild(childImage);
				count++;
			}
			// configuration "remove" button		 
			var removeBtnImage:Image = new Image();
			removeBtnImage.width = img.width * CFG_REMOVE_BUTTON_WIDTH_RATIO;
			removeBtnImage.height = img.height * CFG_REMOVE_BUTTON_HEIGHT_RATIO;
			removeBtnImage.x = img.width * CFG_REMOVE_BUTTON_X_OFFSET_RATIO;
			removeBtnImage.y = img.height * CFG_REMOVE_BUTTON_Y_OFFSET_RATIO;
			removeBtnImage.smooth = true;
			removeBtnImage.buttonMode = true;
			removeBtnImage.source = IconImages.DeleteConfiguration;
			
			uicomp.addChild(removeBtnImage);
			
			return uicomp;
		}
	}
}