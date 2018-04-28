package sym.helper
{
    import assets.images.IconImages;
    
    
    import mx.core.UIComponent;
    
    import spark.components.Image;
    
    import sym.objectmodel.common.Bay;
    import sym.objectmodel.common.ComponentBase;
    import sym.objectmodel.common.Configuration;
    import sym.objectmodel.common.Configuration_VG3R;
    import sym.objectmodel.v10ke.Configuration;
    import sym.objectmodel.v20k.Configuration;
    import sym.objectmodel.v40k.Configuration;

    public class IconRenderUtility
    {
        private static var ICON_SMALL_HEIGHT:int = 400;
        private static var ICON_SMALL_WIDTH:int = 400;
        private static var ASPECT_RATIO_MEDIUM:Number = 1.2568;
        private static var ASPECT_RATIO_LARGE:Number = 1.3661;
        private static var ASPECT_RATIO_LARGE_VG3R:Number = 1.4754;
		
		private static var TITAN_BAY:String = "Titan";
        
        private static var V10KE_BAY_OFFSETS:Array = [
            [{x:0.3, y:0.15, width:0.4, height:0.7}],
            [{x:0.1, y:0.15, width:0.38, height:0.7}, {x:0.52, y:0.15, width:0.38, height:0.7}],
            [{x:0.05, y:0.25, width:0.2, height:0.5}, {x:0.28, y:0.25, width:0.2, height:0.5}, {x:0.52, y:0.25, width:0.2, height:0.5}, {x:0.75, y:0.25, width:0.2, height:0.5}],
            [{x:0.05, y:0.3, width:0.13, height:0.4}, {x:0.2, y:0.3, width:0.13, height:0.4}, {x:0.35, y:0.3, width:0.13, height:0.4}, {x:0.5, y:0.3, width:0.13, height:0.4}, {x:0.65, y:0.3, width:0.13, height:0.4}, {x:0.8, y:0.3, width:0.13, height:0.4}]
        ];
        private static var VMAX_VG3R_BAY_OFFSETS:Array = [
            [{x:0.3, y:0.15, width:0.4, height:0.7}],
            [{x:0.1, y:0.15, width:0.38, height:0.7}, {x:0.52, y:0.15, width:0.38, height:0.7}],
            [{x:0.05, y:0.25, width:0.2, height:0.5}, {x:0.28, y:0.25, width:0.2, height:0.5}, {x:0.52, y:0.25, width:0.2, height:0.5}, {x:0.75, y:0.25, width:0.2, height:0.5}],
            [{x:0.05, y:0.3, width:0.13, height:0.4}, {x:0.2, y:0.3, width:0.13, height:0.4}, {x:0.35, y:0.3, width:0.13, height:0.4}, {x:0.5, y:0.3, width:0.13, height:0.4}, {x:0.65, y:0.3, width:0.13, height:0.4}, {x:0.8, y:0.3, width:0.13, height:0.4}],
			[{x:0.04, y:0.35, width:0.09, height:0.4}, {x:0.16, y:0.35, width:0.09, height:0.4}, {x:0.28, y:0.35, width:0.09, height:0.4}, {x:0.4, y:0.35, width:0.09, height:0.4}, {x:0.52, y:0.35, width:0.09, height:0.4}, {x:0.64, y:0.35, width:0.09, height:0.4}, {x:0.76, y:0.35, width:0.09, height:0.4}, {x:0.88, y:0.35, width:0.09, height:0.4}]
        ];

        private static var SYSTEM_BAY_OFFSETS:Array = [
            {x:0.3, y:0.15, width:0.4, height:0.7},
            {x:0.52, y:0.15, width:0.38, height:0.7},
            {x:0.3, y:0.3, width:0.35, height:0.4},
            {x:0.45, y:0.35, width:0.1, height:0.3}
            ];
        
        private static var STORAGE_BAY_OFFSETS_LEFT:Array = [
            null,
            [{x:0.1, y:0.15, width:0.38, height:0.7}],
            [{x:0.1, y:0.55, width:0.15, height:0.3}, {x:0.1, y:0.15, width:0.15, height:0.3}],
            [{x:0.31, y:0.55, width:0.1, height:0.2}, {x:0.18, y:0.55, width:0.1, height:0.2}, {x:0.05, y:0.55, width:0.1, height:0.2}, {x:0.31, y:0.25, width:0.1, height:0.2}, {x:0.18, y:0.25, width:0.1, height:0.2}, {x:0.05, y:0.25, width:0.1, height:0.2}],
        ];

        private static var STORAGE_BAY_OFFSETS_RIGHT:Array = [
            null,
            null,
            [{x:0.7, y:0.55, width:0.15, height:0.3}, {x:0.7, y:0.15, width:0.15, height:0.3}],
            [{x:0.59, y:0.55, width:0.1, height:0.2}, {x:0.72, y:0.55, width:0.1, height:0.2}, {x:0.85, y:0.55, width:0.1, height:0.2}, {x:0.59, y:0.25, width:0.1, height:0.2}, {x:0.72, y:0.25, width:0.1, height:0.2}, {x:0.85, y:0.25, width:0.1, height:0.2}],
            ];

        public function IconRenderUtility()
        {
        }
        
        public function render(comp:ComponentBase):UIComponent {
            if (comp is sym.objectmodel.v10ke.Configuration) 
			{
                return render10ke(comp as sym.objectmodel.common.Configuration);
            }
            if (comp is sym.objectmodel.v20k.Configuration ||
				comp is sym.objectmodel.v40k.Configuration) 
			{
                return render20_40k(comp as sym.objectmodel.common.Configuration);
            }
			if (comp is Configuration_VG3R)
			{
				return renderVMAX_VG3R(comp as sym.objectmodel.common.Configuration);
			}
            
            return null;
        }
        
        private function render10ke(cfg:sym.objectmodel.common.Configuration):UIComponent {
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
			else 
			{
				size = 3;
				w *= ASPECT_RATIO_LARGE;
			}
            
            uicomp.width = w;
            uicomp.height = h;
            
            var img:Image = new Image();
            img.width = uicomp.width;
            img.height = uicomp.height;
            img.smooth = true;
            
            if (size == 0 || size == 1) {
                img.source = IconImages.BackgroundSmall;
            } else if (size == 2) {
                img.source = IconImages.BackgroundMedium;
            } else {
                img.source = IconImages.BackgroundLarge;
            }
            
            uicomp.addChild(img);
            
            var childImage:Image = null;
            var source:String = "";
            var count:int = 0;
            
            // add all storage bays
            for each (var bay:Bay in cfg.children) {
				
				var unified:String = bay.countDataMovers > 0 ? bay.countDataMovers + "DMs" : "";
				var daeCount:String = bay.countDAEs + "DAEs";
				var bayType:String = bay.isStorageBay ? "StorageBay" : "SystemBay"; 
				source = TITAN_BAY;
				
                childImage = new Image();
                childImage.smooth = true;
                
                childImage.x = V10KE_BAY_OFFSETS[size][count].x * img.width;
                childImage.y = V10KE_BAY_OFFSETS[size][count].y * img.height;
                childImage.width = V10KE_BAY_OFFSETS[size][count].width * img.width;
                childImage.height = V10KE_BAY_OFFSETS[size][count].height * img.height;

				source += bayType + daeCount + unified;
				
                childImage.source = IconImages[source];
                
                uicomp.addChild(childImage);
                count++;
            }
            
            return uicomp;            
        }

        private function render20_40k(cfg:sym.objectmodel.common.Configuration):UIComponent {
            var uicomp:UIComponent = new UIComponent();
            var w:Number = ICON_SMALL_WIDTH;
            var h:Number = ICON_SMALL_HEIGHT;
            var size:int = cfg.countStorageBay;
            
            if (size == 0) {
                // size = 0;
            } else if (size == 1) {
                size = 1;
            } else if (size <= 4) {
                size = 2;
            } else {
                size = 3;
            }

            var count:int = 0;
            var seenSysBay:Boolean = false;
            var sysBay:Bay = null;
            
            // if middle size, check if there are more than 2 storage bays on left/right of system bay
            for each (var bay:Bay in cfg.children) {
                if (!bay.isStorageBay) {
                    seenSysBay = true;
                    sysBay = bay;
                } else {
                    if (seenSysBay) {
                        count = 0;
                    }
                    count++;
                    if (count > 2 && size == 2) {
                        size++;
                    }
                }
            }
            
            count = 0;
            seenSysBay = false;
            
            var img:Image = new Image();

            if (size == 0 || size == 1) {
                img.source = IconImages.BackgroundSmall;
            } else if (size == 2) {
                img.source = IconImages.BackgroundMedium;
                w *= ASPECT_RATIO_MEDIUM;
            } else {
                img.source = IconImages.BackgroundLarge;
                w *= ASPECT_RATIO_LARGE;
            }

            uicomp.width = w;
            uicomp.height = h;
            
            img.width = uicomp.width;
            img.height = uicomp.height;
            img.smooth = true;
            
            uicomp.addChild(img);
            
            var childImage:Image = null;
            var source:String = "";
            
            // first add all storage bays counting to the left of system bay
            for (var i:int = cfg.children.indexOf(sysBay) - 1; i >= 0; --i) {
                bay = cfg.children[i];
                childImage = new Image();
                childImage.smooth = true;
                
                childImage.x = STORAGE_BAY_OFFSETS_LEFT[size][count].x * img.width;
                childImage.y = STORAGE_BAY_OFFSETS_LEFT[size][count].y * img.height;
                childImage.width = STORAGE_BAY_OFFSETS_LEFT[size][count].width * img.width;
                childImage.height = STORAGE_BAY_OFFSETS_LEFT[size][count].height * img.height;
                
                if (bay.countDAEs > 8) {
                    childImage.source = IconImages.MohawkStorageBayFull;
                } else {
                    if (sysBay.countDAEs == 0) {
                        childImage.source = IconImages.MohawkStorageBayHalfFull;
                    } else {
                        // special case for Extended 20k versions
                        childImage.source = IconImages.MohawkStorageBayHalfFullSeparated;
                    }
                }
                uicomp.addChild(childImage);
                count++;
            }
            
            // add system bay
            childImage = new Image();
            childImage.smooth = true;
            childImage.x = SYSTEM_BAY_OFFSETS[size].x * img.width;
            childImage.y = SYSTEM_BAY_OFFSETS[size].y * img.height;
            childImage.width = SYSTEM_BAY_OFFSETS[size].width * img.width;
            childImage.height = SYSTEM_BAY_OFFSETS[size].height * img.height;
            
            if (sysBay.countDAEs > 0) {
                source = "MohawkSystemBay" + cfg.noEngines.toString() + "Engine8DAEs";
            } else {
                source = "MohawkSystemBay" + cfg.noEngines.toString() + "Engine";
            }
            
            childImage.source = IconImages[source];
            uicomp.addChild(childImage);
            
            count = 0;
            // add to the right
            for (i = cfg.children.indexOf(sysBay) + 1; i < cfg.children.length; i++) {
                bay = cfg.children[i];
                childImage = new Image();
                childImage.smooth = true;

                childImage.x = STORAGE_BAY_OFFSETS_RIGHT[size][count].x * img.width;
                childImage.y = STORAGE_BAY_OFFSETS_RIGHT[size][count].y * img.height;
                childImage.width = STORAGE_BAY_OFFSETS_RIGHT[size][count].width * img.width;
                childImage.height = STORAGE_BAY_OFFSETS_RIGHT[size][count].height * img.height;
                
                if (bay.countDAEs > 8) {
                    childImage.source = IconImages.MohawkStorageBayFull;
                } else {
                    if (sysBay.countDAEs == 0) {
                        childImage.source = IconImages.MohawkStorageBayHalfFull;
                    } else {
                        // special case for Extended 20k versions
                        childImage.source = IconImages.MohawkStorageBayHalfFullSeparated;
                    }
                }
                uicomp.addChild(childImage);
                count++;
            }
            
            return uicomp;            
        }
		
		private function renderVMAX_VG3R(cfg:sym.objectmodel.common.Configuration):UIComponent
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
				img.source = IconImages.BackgroundSmall;	
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
			for each (var bay:Bay in cfg.children) {
				
				var vg3rPart:String = (bay.isSystemBay && bay.countDAEs != 6) ? "VG3R_" + (cfg as Configuration_VG3R).noEnginesPerBay + "E_" : "VG3R_";
				var vg3r:String = (bay.countDAEs == 5 && bay.isSystemBay) ? "VG3R_" + (cfg as Configuration_VG3R).fifthDaePosition(bay) + "_" : vg3rPart;
				var daeCount:String = bay.countDAEs + "DAEs";
				var bayType:String = bay.isStorageBay ? "StorageBay" : "SystemBay"; 
				source = TITAN_BAY;
				
				childImage = new Image();
				childImage.smooth = true;
				
				childImage.x = VMAX_VG3R_BAY_OFFSETS[size][count].x * img.width;
				childImage.y = VMAX_VG3R_BAY_OFFSETS[size][count].y * img.height;
				childImage.width = VMAX_VG3R_BAY_OFFSETS[size][count].width * img.width;
				childImage.height = VMAX_VG3R_BAY_OFFSETS[size][count].height * img.height;
				
				source += bayType + vg3r + daeCount;
				
				childImage.source = IconImages[source];
				
				uicomp.addChild(childImage);
				count++;
			}
			
			return uicomp;  
		}
    }
}