package sym.objectmodel.common
{

    public class PortConfiguration extends ComponentBase
    {
        public static const CONFIG1:int = 1;
        public static const CONFIG2:int = 2;
        public static const CONFIG3:int = 3;
        public static const CONFIG4:int = 4;
        public static const CONFIG5:int = 5;
        public static const CONFIG6:int = 6;
        public static const CONFIG7:int = 7;
        public static const CONFIG8:int = 8;
        public static const CONFIG9:int = 9;
        public static const CONFIG10:int = 10;
        public static const CONFIG11:int = 11;
        public static const CONFIG12:int = 12;
        public static const CONFIG13:int = 13;
        public static const CONFIG14:int = 14;
        public static const CONFIG15:int = 15;
        public static const CONFIG16:int = 16;
        public static const CONFIG17:int = 17;
        public static const CONFIG18:int = 18;
        public static const CONFIG19:int = 19;
        public static const CONFIG20:int = 20;
        public static const CONFIG21:int = 21;
        public static const CONFIG22:int = 22;
        public static const CONFIG23:int = 23;
		// vg3r configs
		public static const CONFIG1_VG3R:int = 24;	
		public static const CONFIG_ALL_FLASH:int = 25;	
		public static const CONFIG_ALL_FLASH_250F:int = 26;
		public static const CONFIG_ALL_FLASH_pm2000:int = 27;
		public static const CONFIG_ALL_FLASH_SINGLE_ENGINE_PM8000:int = 28;
		public static const CONFIG_ALL_FLASH_MULTI_ENGINE_PM8000:int = 29;
		
        private static const CACHE_PREFIX:String = "cache_portConfig_";

        public static const ENGINE_DIRECTOR_10K_POSITION_CACHE_KEY:String = "10kEngineDirector_Position";
        public static const ENGINE_DIRECTOR_20K_40K_POSITION_CACHE_KEY:String = "20kEngineDirector_Position";
		public static const ENGINE_DIRECTOR_VG3R_POSITION_CACHE_KEY:String = "vg3rEngineDirector_Position";
		
        public function PortConfiguration(type:int, position:Position)
        { 
            super(type.toString(), position, null);
            _type = type; 
            
            // generate children depending on type
             
            //init cache
            for(var i:int = 0; i < 4; i++){
                var posKey:String =  Position.generateCacheKey(position.type, i);
                if(!ObjectCache.instance.hasKey(posKey)){
                    ObjectCache.instance.put(posKey, new Position(position.type, i), false);
                }   
            }
			
            switch (type) 
			{	
                case CONFIG1:
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_4, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_4, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_4, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_4, position.type, 3));
                    break;
                case CONFIG2:
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_4, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_2_SRDF_1, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_4, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_2_SRDF_1, position.type, 3));
                    break;
                case CONFIG3:
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_2_SRDF_1, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_2_SRDF_1, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_2_SRDF_1, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_2_SRDF_1, position.type, 3));
                    break;
                case CONFIG4:
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_16GB_2, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_16GB_2, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_16GB_2, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_16GB_2, position.type, 3));
                    break;
                case CONFIG5:
                    addChild(EnginePort.createIfNotCached(EnginePort.FICON_2, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.FICON_2, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.FICON_2, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.FICON_2, position.type, 3));
                    break;
                case CONFIG6:
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_2, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_2, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_2, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_2, position.type, 3));
                    break;
                case CONFIG7:
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_2, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_1_GIGE_1, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_2, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_1_GIGE_1, position.type, 3));
                    break;
                case CONFIG8:
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_1_GIGE_1, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_1_GIGE_1, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_1_GIGE_1, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_1_GIGE_1, position.type, 3));
                    break;
                case CONFIG9:
                    addChild(EnginePort.createIfNotCached(EnginePort.FICON_2, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_4, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.FICON_2, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_4, position.type, 3));
                    break;
                case CONFIG10:
                    addChild(EnginePort.createIfNotCached(EnginePort.FICON_2, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_2_SRDF_1, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.FICON_2, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_2_SRDF_1, position.type, 3));
                    break;
                case CONFIG11:
                    addChild(EnginePort.createIfNotCached(EnginePort.FICON_2, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.SRDF_2, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.FICON_2, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.SRDF_2, position.type, 3));
                    break;
                case CONFIG12:
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_16GB_2, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.FICON_2, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_16GB_2, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.FICON_2, position.type, 3));
                    break;
                case CONFIG13:
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_4, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_2, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_4, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_2, position.type, 3));
                    break;
                case CONFIG14:
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_4, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_1_GIGE_1, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_4, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_1_GIGE_1, position.type, 3));
                    break;
                case CONFIG15:
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_2, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_2_SRDF_1, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_2, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_2_SRDF_1, position.type, 3));
                    break;
                case CONFIG16:
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_16GB_2, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_2, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_16GB_2, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_2, position.type, 3));
                    break;
                case CONFIG17:
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_16GB_2, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_1_GIGE_1, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_16GB_2, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_1_GIGE_1, position.type, 3));
                    break;
                case CONFIG18:
                    addChild(EnginePort.createIfNotCached(EnginePort.FICON_2, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_2, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.FICON_2, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_2, position.type, 3));
                    break;
                case CONFIG19:
                    addChild(EnginePort.createIfNotCached(EnginePort.FICON_2, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_1_GIGE_1, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.FICON_2, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.ETH_1_GIGE_1, position.type, 3));
                    break;
                case CONFIG20:
                    addChild(EnginePort.createIfNotCached(EnginePort.DX_2_FC_2, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_4, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.DX_2_FC_2, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_4, position.type, 3));
                    break;
                case CONFIG21:
                    addChild(EnginePort.createIfNotCached(EnginePort.DX_4, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_4, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.DX_4, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.FC_4, position.type, 3));
                    break;
                case CONFIG22:
                    addChild(EnginePort.createIfNotCached(EnginePort.DX_4, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.DX_2_FC_2, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.DX_4, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.DX_2_FC_2, position.type, 3));
                    break;
                case CONFIG23:
                    addChild(EnginePort.createIfNotCached(EnginePort.DX_4, position.type, 0));
                    addChild(EnginePort.createIfNotCached(EnginePort.DX_4, position.type, 1));
                    addChild(EnginePort.createIfNotCached(EnginePort.DX_4, position.type, 2));
                    addChild(EnginePort.createIfNotCached(EnginePort.DX_4, position.type, 3));
                    break;
                case CONFIG1_VG3R:
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 0));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 10));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 1));	 
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 6)); 
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 7)); 
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 11)); 	 
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 16)); 	 
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 17)); 	 
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 2)); 	 
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 8)); 	 
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 12)); 	 
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 18)); 	 
                    addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 3));	 
                    addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 9));	 
                    addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 13));	 
                    addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 19));
					break;
                case CONFIG_ALL_FLASH:
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 0));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 10));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 1));	 
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 6)); 
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 7));
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 11));	 
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 16));	 
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 17)); 	 
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 2)); 	 
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 8)); 	 
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 12)); 	 
                    addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 18)); 	 
                    addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 3));	 
                    addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 9));	 
                    addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 13));	 
                    addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 19));
                    break;
				case CONFIG_ALL_FLASH_250F:
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 0));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 1));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 4));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 6));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 7));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 8));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 10));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 11));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 14));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 16));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 17));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 18));
					addChild(EnginePort.createIfNotCached(EnginePort.COMPRESSION_ASTEROID, position.type, 2));
					addChild(EnginePort.createIfNotCached(EnginePort.COMPRESSION_ASTEROID, position.type, 12));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 3));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 9));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 13));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 19));	
					break;
				case CONFIG_ALL_FLASH_pm2000:
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 0));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 1));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 4));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 5));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 6));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 7));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 8));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 10));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 11));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 14));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 15));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 16));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 17));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 18));
					addChild(EnginePort.createIfNotCached(EnginePort.COMPRESSION_ASTEROID, position.type, 2));
					addChild(EnginePort.createIfNotCached(EnginePort.COMPRESSION_ASTEROID, position.type, 12));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 3));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 9));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 13));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 19));	
					break;
				case CONFIG_ALL_FLASH_SINGLE_ENGINE_PM8000:
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 1));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 4));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 5));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 6));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 7));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 11));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 14));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 15));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 16));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 17));
					addChild(EnginePort.createIfNotCached(EnginePort.COMPRESSION_ASTEROID, position.type, 0));
					addChild(EnginePort.createIfNotCached(EnginePort.COMPRESSION_ASTEROID, position.type, 10));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 2));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 3));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 8));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 9));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 12));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 13));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 18));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 19));	
					break;
				case CONFIG_ALL_FLASH_MULTI_ENGINE_PM8000:
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 0));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 1));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 4));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 5));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 6));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 7));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 10));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 11));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 14));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 15));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 16));
					addChild(EnginePort.createIfNotCached(EnginePort.EMPTY_SLOT, position.type, 17));
					addChild(EnginePort.createIfNotCached(EnginePort.COMPRESSION_ASTEROID, position.type, 2));
					addChild(EnginePort.createIfNotCached(EnginePort.COMPRESSION_ASTEROID, position.type, 12));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 3));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 8));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 9));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 13));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 18));
					addChild(EnginePort.createIfNotCached(EnginePort.VAULT_FLASH_WIRLWIND, position.type, 19));	
					break;
            }
            
            // Modules in 10k and vg3r are vertical
            if (position.type == Position.ENGINE_DIRECTOR_10ke ||
				position.type == Position.ENGINE_DIRECTOR_VG3R) 
			{
                for each (var child:EnginePort in _children) 
				{
                    child.position.rotation = Position.ROTATION270;
                }
            }
        }

		public override function serializeToXML():XML
		{
			var xml:XML = super.serializeToXML();
			xml.@type = _type;
			return xml;
		}
		
		public static function createFromXml(xml:XML):ComponentBase
		{
			var portConfiguration:PortConfiguration = new PortConfiguration(xml.@type, new Position(xml.@positionType, xml.@positionIndex));
			return portConfiguration;
		}
		
		public static function validateXml(xml:XML, seria:String):Boolean
		{
			return true;
		}
        
        /**
         * generates cache key for caching port config  objects with given type, position type and index
         */
        public static function generateCacheKey(type:int, positionKey:String):String{
            return CACHE_PREFIX + type + "_" + positionKey;
        }
        
        /**
         * creates PDP with given position data. Puts the instance into cache if not cached previously and return cached instance
         */
        public static function createIfNotCached(type:int, positionKey:String):PortConfiguration{
            var key:String = generateCacheKey(type, positionKey);
            if(!ObjectCache.instance.hasKey(key)){
                ObjectCache.instance.put(key, new PortConfiguration(type, ObjectCache.instance.get(positionKey) as Position)); 
            }
            return ObjectCache.instance.get(key) as PortConfiguration;
        }
        
        /**
         *  creates clone for given parent
         * @param parent reference of parent component
         * @return 
         * 
         */        
        public override function clone(parent:ComponentBase = null):ComponentBase{
            var clone:PortConfiguration = new PortConfiguration(type, position);
            clone.removeChildren();
            clone.cloneBasicData(this);
            
            clone.parent = parent;
            return clone;
        }
    }
}
