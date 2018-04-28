package sym.objectmodel.common
{
	import mx.resources.ResourceManager;
	
	import sym.objectmodel.driveUtils.enum.HostType;
	
    public class EnginePort extends ComponentBase
    {
        public static const FC_4:int = 1;  //4-Port Fibre Channel Front End I/O Module
        public static const FC_2_SRDF_1:int = 2;  //2-Port Fibre Channel Front End  I/O Module
        public static const FC_16GB_2:int = 3;    //2-Port Fibre Channel Front End  I/O Module
        public static const FICON_2:int = 4;   //2-Port FiCON Front End I/O Module
        public static const ETH_2:int = 5;    //1.  2-Port Gb Ethernet  Front End I/O Module
        public static const ETH_1_GIGE_1:int = 6;  //2.   2-Port Gb Ethernet  Front End I/O Module
        public static const DX_2_FC_2:int = 7;
        public static const DX_4:int = 8;
        public static const SRDF_2:int = 9;
        public static const FC_4_GLACIER:int = 10;  //4-Port FC FE I/O Module 2/4/8 Gb/s
        public static const FC_4_RAINFALL:int = 11;  //4-Port FC FE I/O Module 4/8/16 Gb/s
        public static const FICON_4_PORT:int = 22;  //4-Port FICON I/O Module 16 Gb/s
        public static const GIGE_2PORT_10GB_ERRUPTION:int = 12;  //Eruption - 2-Port 10Gb Ethernet Fr. I/O Module used in VG3R (check if this is same as Eth2 and Eth1
        public static const GIGE_2PORT_10GB_ELNINO:int = 13;  //El Nino - 2-Port 10Gb Ethernet Fr. I/O Module used in VG3R (check if this is same as Eth2 and Eth1
        public static const GIGE_2PORT_10GB_HEATWAVE:int = 14;  // Heat wave - 2-Port 10Gb GigE SRDF
        public static const GIGE_4PORT_10GB_RAINSTORM:int = 15; // RainstormE - 4-port 10Gb Ethernet FCoE/iSCSI I/O module
        public static const GIGE_2PORT_1GB_THUNDERBOLT:int = 16; //Thunderbolt - 2/2-port 1Gb SRDF
        public static const GIGE_4PORT_1GB_THUNDERCHILD:int = 17; // Thunderchild - 4-port 1Gb GigE
        public static const COMPRESSION_ASTEROID:int = 18;
        public static const VAULT_FLASH_WIRLWIND:int = 19;
        public static const IB_MODULE:int = 20;
        
		public static const EMPTY_SLOT:int = 21;
		
		public static const PORT_CONFIGURATION_250F_INDICATOR:String = "26"; //represents port configuration of vmax 250f series

		private static const CACHE_PREFIX:String = "cache_engine_port_";
        
		// empty slot prototype used as a clone when engine ports are removed from slot
        public static const EmptySlotPrototype:EnginePort = createPortProto(EMPTY_SLOT);
		public static const FILE_PORT_PROTOTYPE:EnginePort = createPortProto(GIGE_2PORT_10GB_ELNINO);
		public static const FC_PORT_PROTOTYPE:EnginePort = createPortProto(FC_4_RAINFALL);
		public static const FICON_PORT_PROTOTYPE:EnginePort = createPortProto(FICON_4_PORT);
		public static const ISCSI_PORT_PROTOTYPE:EnginePort = createPortProto(GIGE_4PORT_10GB_RAINSTORM);
		public static const COMPRESSION_PROTOTYPE:EnginePort = createPortProto(COMPRESSION_ASTEROID);
		public static const IB_MODULE_PROTOTYPE:EnginePort = createPortProto(IB_MODULE);
		
		public static const PORT_SPEED_16GB:int = 16;
		public static const PORT_SPEED_10GB:int = 10;
		public static const PORT_SPEED_8GB:int = 8;
		public static const PORT_SPEED_1GB:int = 1;
		
		public static const NO_PORT_COUNT:int = 0;
		public static const PORT_COUNT_2:int = 2;
		public static const PORT_COUNT_4:int = 4;
		
		public static const COMPRESSION_MODULE_DEFAULT_COUNT:int = 2;
		public static const COMPRESSION_MODULE_REQUIRED_SLOTS:int = 1;
		
        public function EnginePort(type:int, position:Position)
        {
            super("engine_port_" + type.toString(), position, null);
            _type = type;
        }

        public override function serializeToXML():XML
        {
			// if Engine Port is VG3R port
			if (this.position.type == Position.ENGINE_DIRECTOR_VG3R)
			{
				var newXML:XML = createXMLnode();
				
				newXML.@id = this.enginePortName;
				newXML.@type = this.type;
				newXML.@positionIndex = this.position.index;
				newXML.@positionType = this.position.type;
				
				return newXML;
			}
			
            var xml:XML = super.serializeToXML();
            xml.@type = _type;
            
			return xml;
        }
		
        public static function createFromXml(xml:XML):EnginePort
        {
            var ep:EnginePort = new EnginePort(xml.@type, new Position(xml.@positionType, xml.@positionIndex));
			
			if (ep.position.type == Position.ENGINE_DIRECTOR_VG3R)
			{
				// only for VG3R port
				ep.position.rotation = Position.ROTATION270;
			}
			
            return ep;
        }
        
		public static function validateXml(xml:XML, seria:String):Boolean
		{			
			return true;
		}
        
        /**
         * generates cache key for const static enginePort objects with given position type and index
         */
        public static function generateCacheKey(type:int, positionType:int, index:Number):String{
            return CACHE_PREFIX + type + "_" + positionType + "_" + index;
        }
        
        /**
        * creates engine port with given position data and engine port type. Puts the instance into cache
        */
        public static function createIfNotCached(type:int, positionType:int, index:Number):EnginePort{
            var key:String = generateCacheKey(type, positionType, index);
            if(!ObjectCache.instance.hasKey(key)){
                ObjectCache.instance.put(key, new EnginePort(type, new Position(positionType, index))); 
            }
            return ObjectCache.instance.get(key) as EnginePort;
        }
        
        /**
         * gets cached engine port by position type and index
         */
        public static function getFromCacheByType(type:int, positionType:int, index:Number):EnginePort{
            return ObjectCache.instance.get(generateCacheKey(type, positionType, index)) as EnginePort;;
        }

		/**
		 * Creates engine port prototype based on provided port type
		 * @param type indicates port type
		 * @return 
		 * 
		 */		
		public static function createPortProto(type:int):EnginePort
		{
            return new EnginePort(type, new Position(Position.ENGINE_DIRECTOR_VG3R, -1, false, Position.ROTATION270));
        }
        
        /**
         * creates clone for given parent
         * @param parent reference of parent component
         * @return 
         * 
         */        
        public override function clone(parent:ComponentBase = null):ComponentBase{
            var clone:EnginePort = new EnginePort(type, position);
            clone.cloneBasicData(this);
            
            clone.parent = parent;
            
            return clone;
        }
        
        /**
         * Validates if this engine port can be removed from engine
         * @return 
         * 
         */        
        public function get isRemovable():Boolean
        {
			if(this.parent != null && this.parent.id == PORT_CONFIGURATION_250F_INDICATOR)
			{
				if(Engine.VARIABLE_ENGINE_PORTS.indexOf(type) > -1 && [1, 2, 3, 8, 9].indexOf(Engine.getSlotNumberByPosition(position.index)) > -1)
					return true;				
			}
			else{
				if(Engine.VARIABLE_ENGINE_PORTS.indexOf(type) > -1 && [1, 2, 3, 7, 8, 9].indexOf(Engine.getSlotNumberByPosition(position.index)) > -1)
					return true;
			}
			if(this.parent == null) // this is used for ports which are not listed in default Port Configuration. currently only used in 250F
			{
				if(Engine.VARIABLE_ENGINE_PORTS.indexOf(type) > -1 && [5].indexOf(Engine.getSlotNumberByPosition(position.index)) > -1)
					return true;
			}
			return false;
        }
        
        /**
         * Validates if this engine port can be moved (if dragging can start) 
         * @return 
         * 
         */        
        public function get isDraggable():Boolean
        {
			if(type == VAULT_FLASH_WIRLWIND && [3, 13, 9, 19].indexOf(position.index) > -1)
                return false;
			else if(type == COMPRESSION_ASTEROID && [2, 12].indexOf(position.index) > -1)
				return false;
            return true;            
        }
        
        /**
         * Is this Fibre Channel module 
         * @return 
         * 
         */        
        public function get isFC():Boolean
        {
            return (type == FC_4_GLACIER || type == FC_4_RAINFALL);
        }
		
		/**
		 * Is this OS host type module 
		 * @return 
		 * 
		 */		
		public function get isOpenSystems():Boolean
		{
			return this.isOSblock || this.isSRDF;
		}
		
		/**
		 * Is this Mainframe only module 
		 * @return 
		 * 
		 */		
		public function get isMainframe():Boolean
        {
            return type == FICON_4_PORT;
        }
        
		/**
		 * Is this Open Systems block module 
		 * @return 
		 * 
		 */		
		public function get isOSblock():Boolean
		{
			return this.isFC || this.isFCOE_ISCSI;
		}
		
		/**
		 * Is this Block storage module 
		 * @return 
		 * 
		 */		
		public function get isBlock():Boolean
		{
			return this.isOSblock || this.isMainframe;
		}
		
        /**
         * Is this file storage module 
         * @return 
         * 
         */        
        public function get isFile():Boolean
        {
            return (type == GIGE_2PORT_10GB_ELNINO || 
                	type == GIGE_2PORT_10GB_ERRUPTION ||
					type == GIGE_4PORT_1GB_THUNDERCHILD);
        }
        
        /**
         * Is this SRDF module 
         * @return 
         * 
         */        
        public function get isSRDF():Boolean
        {
			return type == GIGE_2PORT_10GB_HEATWAVE || type == GIGE_2PORT_1GB_THUNDERBOLT;
        }

		/**
         * Examine if this is FCoE/iSCSI module 
         * @return True if module is FCoE/iSCSI type. Otherwise, False 
         * 
		 */        
        public function get isFCOE_ISCSI():Boolean
        {
            return type == GIGE_4PORT_10GB_RAINSTORM;
        }
        
		/**
		 * Examine if this is Ethernet module 
		 * @return 
		 * 
		 */		
		public function get isEthernet():Boolean
		{
			return this.isSRDF || this.isFCOE_ISCSI || this.isFile;
		}

		/**
		 * Examine if this is FrontEnd module 
		 * @return 
		 * 
		 */		
		public function get isFE():Boolean
		{
			return this.isFC || this.isEthernet || this.isMainframe; 
		}
		
		/**
		 * Is this mandatory engine module based on selected host type
		 * @param hostType indicates OS/MF/Mixed
		 * @return 
		 * 
		 */		
		public function isMandatoryPort(hostType:String):Boolean
		{
			if (hostType == HostType.OPEN_SYSTEMS)
			{
				// OS mandatory port is FC or FCoE/iSCSI or File (if used)
				return this.isOSblock || this.isFile;
			}
			
			if (hostType == HostType.MAINFRAME_HOST)
			{
				// MF mandatory port is FICON
				return this.isMainframe;	
			}
				
			// Mixed - FICON/OS block or File
			return this.isBlock || this.isFile;
		}
		
        /**
         * Validates if this engine port have equal connection type as the given component 
         * @param engPort
         * @return 
         * 
         */        
        public function connectionEquals(engPort:EnginePort):Boolean
        {
			// cross-protocol swap is allowed
            return (this.type == engPort.type) || (this.isFE && engPort.isFE) || (this.isFE && engPort.type == COMPRESSION_ASTEROID);
        }
        
        /**
         * Gets if population direction is left to right 
         * @return true if L2R, else R2L
         */        
        public function get isLeftToRight():Boolean
        {
//            return type != FC_4_RAINFALL;
			// all modules get populated from the left as of Hudson
			return true;
        }
		
		/**
		 * Gets engine port speed 
		 * @return speed in Gb/s
		 * 
		 */		
		public function get speed():int
		{
			switch(this.type)
			{
				case FC_4_RAINFALL:
				case FICON_4_PORT:
					return PORT_SPEED_16GB; // 16/8/4 Gb/s
				case FC_4_GLACIER:
					return PORT_SPEED_8GB; // 8/4/2 Gb/s
				case GIGE_2PORT_10GB_HEATWAVE:
				case GIGE_4PORT_10GB_RAINSTORM:
				case GIGE_2PORT_10GB_ELNINO:
				case GIGE_2PORT_10GB_ERRUPTION:
					return PORT_SPEED_10GB;
				case GIGE_2PORT_1GB_THUNDERBOLT:
				case GIGE_4PORT_1GB_THUNDERCHILD:
					return PORT_SPEED_1GB;
				default:
					return -1; // N/A speed
			}
		}

		/**
		 * Gets number of ports for current I/O module 
		 * @return port count
		 * 
		 */		
		public function get portCount():int
		{
			switch(this.type)
			{
				// 4-port modules
				case FC_4_GLACIER:
				case FC_4_RAINFALL:
				case GIGE_4PORT_10GB_RAINSTORM:
				case GIGE_4PORT_1GB_THUNDERCHILD:
				case FICON_4_PORT:
					return PORT_COUNT_4;
				// 2-port modules	
				case GIGE_2PORT_10GB_HEATWAVE:
				case GIGE_2PORT_1GB_THUNDERBOLT:
				case GIGE_2PORT_10GB_ELNINO:
				case GIGE_2PORT_10GB_ERRUPTION:
					return PORT_COUNT_2;
				default:
					return 0; // N/A ports
			}
		}
		
		/**
		 * Gets number of ports per Director for current I/O module 
		 * @return port count
		 * 
		 */		
		public function get portCountPerDirector():int
		{
			return this.portCount * 2;
		}
		
		/**
		 * Gets supported speeds for specific engine port 
		 * @param port indicates engine port
		 * @param is250f indicates if current vmax model is 250F AFA
		 * @return array of supported speeds 
		 * 
		 */		
		public static function getSupportedSpeed(port:EnginePort, is250f:Boolean):Array
		{
			if (port.isFC)
			{
				// Fibre Channel speed - 16/8 Gb
				return [0,PORT_SPEED_16GB, PORT_SPEED_8GB];
			}
			
			if (port.isMainframe)
			{
				// FICON - 16 Gb 
				return [PORT_SPEED_16GB];
			}
			
			if (port.isFCOE_ISCSI || (is250f && port.isFile))
			{
				// iSCSI/FCoE - 10 Gb
				// File Ethernet - 10Gb (only for 250f)
				return [0,PORT_SPEED_10GB];
			}
			
			if (!is250f && (port.isSRDF || port.isFile))
			{
				// GigE SRDF/File Ethernet - 1/10 Gb
				// for all VMAX that are not 250F
				return [0,PORT_SPEED_10GB, PORT_SPEED_1GB];
				
			}
			if (is250f && port.isSRDF)
			{
				// GigE SRDF - 1 Gb (only for 250f)
				return [PORT_SPEED_1GB];
			}

			return [port.speed];
		}
		
		/**
		 * Gets Engine Port name
		 * @param type indicates Engine Port type 
		 * @return 
		 * 
		 */		
		public function get enginePortName():String
		{
			switch(this.type)
			{
				case COMPRESSION_ASTEROID:
					return ResourceManager.getInstance().getString('main', 'PORT_COMPRESSION_ASTEROID');
				case FC_4_GLACIER:
					return ResourceManager.getInstance().getString('main', 'PORT_GLACIER');
				case FC_4_RAINFALL:
					return ResourceManager.getInstance().getString('main', 'PORT_RAINFALL');
				case VAULT_FLASH_WIRLWIND:
					return ResourceManager.getInstance().getString('main', 'PORT_FLASH_WIRLWIND');
				case GIGE_2PORT_10GB_ELNINO:
					return ResourceManager.getInstance().getString('main', 'PORT_EL_NINO');
				case GIGE_2PORT_10GB_ERRUPTION:
					return ResourceManager.getInstance().getString('main', 'PORT_ERRUPTION');
				case GIGE_2PORT_10GB_HEATWAVE:
					return ResourceManager.getInstance().getString('main', 'PORT_HEATWAVE');
				case GIGE_2PORT_1GB_THUNDERBOLT:
					return ResourceManager.getInstance().getString('main', 'PORT_THUNDERBOLT');
				case GIGE_4PORT_1GB_THUNDERCHILD:
					return ResourceManager.getInstance().getString('main', 'PORT_THUNDERCHILD');
				case GIGE_4PORT_10GB_RAINSTORM:
					return ResourceManager.getInstance().getString('main', 'PORT_RAINSTORM');
				case FICON_4_PORT:
					return ResourceManager.getInstance().getString('main', 'PORT_FICON');
				default:
					return ResourceManager.getInstance().getString('main', 'PORT_EMPTY_SLOT');
			}
		}
    }
}