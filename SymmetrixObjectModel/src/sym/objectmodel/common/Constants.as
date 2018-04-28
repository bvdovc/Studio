package sym.objectmodel.common
{
    public class Constants
    {
		//Languages
		public static const LANG_ENGLISH:String = "en_US";
		public static const LANG_BRASIL:String ="pt_BR";
		public static const LANG_CHINA:String ="zh_CN";
		public static const LANG_GERMANY:String ="de_DE";
		public static const LANG_ITALA:String ="it_IT";
		public static const LANG_JAPAN:String ="ja_JP";
		public static const LANG_KOREA:String ="ko_KR";
		public static const LANG_MEXICO:String ="es_MX";
		public static const LANG_RUSSIA:String ="ru_RU";
		public static const LANG_FRANCE:String ="fr_FR";
		
        //VMAX Series
		public static const IMPORTED_CONFIGS:String = "imported_configs";
        public static const VMAX_450F:String = "VMAX-450F/FX";
        public static const VMAX_950F:String = "VMAX-950F/FX";
		public static const VMAX_250F:String = "VMAX-250F";
		public static const VMAX_AFA:String = "VMAX All Flash";
		
		//PowerMax Series
		public static const PowerMax_2000:String = "PowerMax-2000";
		public static const PowerMax_8000:String = "PowerMax-8000";
		
		//selection component dataProvider types
		public static const CONFIGURATION_TYPE:String = "CONFIGURATION_TYPE"
		public static const PORT_CONFIGURATION_TYPE:String = "PORT_CONFIGURATION_TYPE"
		public static const PDP_TYPE:String = "PDP_TYPE"
		public static const SPS_TYPE:String = "SPS_TYPE"
        public static const ENGINE_PORT_TYPE:String = "ENGINE_PORT_TYPE";
			
		public static const FRONT_VIEW_PERSPECTIVE:String = "front view";	
		public static const REAR_VIEW_PERSPECTIVE:String = "rear view";	
		public static const TOP_VIEW_PERSPECTIVE:String = "top view";	
		public static const SIDE_3D_VIEW_PERSPECTIVE:String = "side view";	
		
		// wizard tier DataGrid dataFields
		public static const WIZARD_DATA_GRID_TIER_COLUMN:String = "tier";
		public static const WIZARD_DATA_GRID_DRIVE_TYPE_COLUMN:String = "drive";
		public static const WIZARD_DATA_GRID_RAID_COLUMN:String = "raid";
		public static const WIZARD_DATA_GRID_SIZE_COLUMN:String = "size";
		public static const WIZARD_DATA_GRID_DRIVE_COUNT_COLUMN:String = "activeCount";
		public static const WIZARD_DATA_GRID_PERCENT_COLUMN:String = "cap";
		
		// wizard engine port DataGrid dataFields
		public static const WIZARD_PORT_GRID_TYPE_COLUMN:String = "Port Type";
		public static const WIZARD_PORT_GRID_SPEED:String = "Speed";
		public static const WIZARD_PORT_GRID_NO_ENGINE_COLUMN:String = "Engine";
		public static const WIZARD_PORT_GRID_TOTAL_COLUMN:String = "Total";
		
		// wizard dropdown drive type labels
		public static const WIZARD_DRIVE_TYPE_960GB:String = "960GB ";
		public static const WIZARD_DRIVE_TYPE_1920GB:String = "1.92TB ";
		public static const WIZARD_DRIVE_TYPE_3840GB:String = "3.84TB ";
		public static const WIZARD_DRIVE_TYPE_7680GB:String = "7.68TB ";
		public static const WIZARD_DRIVE_TYPE_15360:String = "15.36TB ";
		
		//wizard dropdown drive type labels for PowerMax series
		public static const WIZARD_DRIVE_TYPE_1920GB_NVM:String = "1.92 TB";
		public static const WIZARD_DRIVE_TYPE_3840GB_NVM:String = "3.84 TB";
		public static const WIZARD_DRIVE_TYPE_7680GB_NVM:String = "7.68 TB";
		
		// wizard drive selection dropDowns max row count
		public static const WIZARD_DROP_DOWN_MAX_ROWS:int = 4;
			
		//validation values
		public static const NO_ENGINE_V10KE:Array = [1, 2, 3, 4];
		public static const NO_ENGINE_V2040K:Array = [1, 2, 3, 4, 5, 6, 7, 8];
		public static const NO_ENGINE_V100K:Array = [1, 2];
		public static const NO_ENGINE_V200K:Array = [1, 2, 3, 4];
		public static const NO_ENGINE_V400K:Array = [1, 2, 3, 4, 5, 6, 7, 8];
		public static const NO_ENGINE_V450F:Array = [1, 2, 3, 4];
		public static const NO_ENGINE_V850F:Array = [1, 2, 3, 4, 5, 6, 7, 8];
		public static const NO_ENGINE_V250F:Array = [1, 2];
		public static const NO_ENGINE_PM2000:Array = [1,2];
		public static const NO_ENGINE_PM8000:Array = [1, 2, 3, 4, 5, 6, 7, 8];
		
		public static const STORAGE_BAY_V10KE:Array = [0, 1, 2];
		public static const STORAGE_BAY_V2040K:Array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
		
		public static const DISPERSED_V10KE:Array = [-1, 3];
		public static const DISPERSED_V20K:Array = [-1];
		public static const DISPERSED_V40K:Array = [-1, 3, 5, 7];
		
		public static const DAE_TYPE_VMAX10KE:Array = [DAE.D15, DAE.Vanguard, DAE.MixedD15];
		public static const DAE_TYPE_VMAX20K:Array = [DAE.D15, DAE.Vanguard, DAE.MixedD15, DAE.MixedVanguard];
		public static const DAE_TYPE_VMAX40K:Array = [DAE.D15, DAE.Vanguard, DAE.MixedD15, DAE.MixedVanguard];
		
		public static const PORT_CONFIGURATIONS_V10KE:Array = [PortConfiguration.CONFIG1, PortConfiguration.CONFIG2, PortConfiguration.CONFIG3, 
			/*PortConfiguration.CONFIG4,*/ PortConfiguration.CONFIG6,PortConfiguration.CONFIG7, PortConfiguration.CONFIG8, PortConfiguration.CONFIG13,
			PortConfiguration.CONFIG14, PortConfiguration.CONFIG15, /*PortConfiguration.CONFIG16, PortConfiguration.CONFIG17,*/ PortConfiguration.CONFIG20, 
			PortConfiguration.CONFIG21,	PortConfiguration.CONFIG22, PortConfiguration.CONFIG23];
		public static const PORT_CONFIGURATIONS_V20K:Array = [PortConfiguration.CONFIG1, PortConfiguration.CONFIG2, PortConfiguration.CONFIG3, PortConfiguration.CONFIG5, 
			PortConfiguration.CONFIG6, PortConfiguration.CONFIG7, PortConfiguration.CONFIG8, PortConfiguration.CONFIG9, PortConfiguration.CONFIG10, PortConfiguration.CONFIG11,
			PortConfiguration.CONFIG13, PortConfiguration.CONFIG14, PortConfiguration.CONFIG15, PortConfiguration.CONFIG18, PortConfiguration.CONFIG19,
			PortConfiguration.CONFIG20, PortConfiguration.CONFIG21, PortConfiguration.CONFIG22, PortConfiguration.CONFIG23];
		public static const PORT_CONFIGURATIONS_V40K:Array = [PortConfiguration.CONFIG1, PortConfiguration.CONFIG2, PortConfiguration.CONFIG3, /*PortConfiguration.CONFIG4,*/
			PortConfiguration.CONFIG5, PortConfiguration.CONFIG6, PortConfiguration.CONFIG7, PortConfiguration.CONFIG8, PortConfiguration.CONFIG9,PortConfiguration.CONFIG10,
			PortConfiguration.CONFIG11, /* PortConfiguration.CONFIG12,*/ PortConfiguration.CONFIG13, PortConfiguration.CONFIG14,PortConfiguration.CONFIG15, /*PortConfiguration.CONFIG16, PortConfiguration.CONFIG17,*/
			PortConfiguration.CONFIG18, PortConfiguration.CONFIG19, PortConfiguration.CONFIG20, PortConfiguration.CONFIG21, PortConfiguration.CONFIG22, PortConfiguration.CONFIG23];
		
		public static const SPS_POSITION_V10KE:Array = [Position.BAY_HALF_ENCLOSURE_LEFT, Position.BAY_HALF_ENCLOSURE_RIGHT];
		public static const SPS_POSITION_V2040K:Array = [Position.BAY_HALF_ENCLOSURE_LEFT, Position.BAY_HALF_ENCLOSURE_RIGHT, Position.MIDDLEBAYVERTICAL, Position.ENGINESIDE_SPS_LEFT, Position.ENGINESIDE_SPS_RIGHT];
		
		public static const DATA_MOVER_POSITION:Array = [Position.BAY_HALF_ENCLOSURE_LEFT, Position.BAY_HALF_ENCLOSURE_RIGHT];		
		
		public static const D15_POSITION_10KE:Array = [Position.BAY_ENCLOSURE];
		public static const D15_POSITION_20K:Array = [Position.BAY_ENCLOSURE, Position.UPPERHALFBAYVERTICAL, Position.LOWERHALFBAYVERTICAL];
		public static const D15_POSITION_40K:Array = [Position.UPPERHALFBAYVERTICAL, Position.LOWERHALFBAYVERTICAL];
		
		
		public static const BAY_TYPE_V10KE:Array = [Bay.TYPETITANSYSBAY, Bay.TYPETITANSTGBAY];
		public static const BAY_TYPE_V20K:Array = [Bay.TYPETITANSYSBAY, Bay.TYPEMOHAWKSTGBAY, Bay.TYPEMOHAWKSYSBAY, Bay.TYPETITANSTGBAY];
		public static const BAY_TYPE_V40K:Array = [Bay.TYPEMOHAWKSYSBAY, Bay.TYPEMOHAWKSTGBAY, Bay.TYPETITANSTGBAY];
        
        public static const DISPERSED_10K_VALUE:int = 3;
    }
}