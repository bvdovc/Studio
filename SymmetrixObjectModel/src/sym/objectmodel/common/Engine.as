package sym.objectmodel.common
{
	import flash.net.getClassByAlias;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	
	import sym.objectmodel.driveUtils.enum.DriveType;
	import sym.objectmodel.driveUtils.enum.HostType;

    public class Engine extends ComponentBase
    {
        private var _portConfigurationManager:IPortConfigurationManager = null;
		private var _overlayPorts:ArrayCollection = null;
		
		// Every Engine has its own port configuration
		private var _portConfig:PortConfiguration = null;
		
		public static const IB_MODULE_UPPER_POSITION:int = 40;
		
		public static const MAX_NUMBER_VG3R_ENGINE_MODULES:int = 22;
		
        private static const ENGINE_SIZE:Size = new Size(Size.USIZE, 3.9);
		
		// port population order within Engine
		public static const ENGINE_PORT_POPULATION_ORDER:Array = [7, 6, 1, 0];

		//allowed variable engine ports for VG3R engine, used for creating selectioncomponent dataprovider
		public const ALLOWED_ENGINE_PORTS:Array = createAllowedEnginePorts();
		
		// min and max ports/modules per engine
		public static const ALLOWED_PORTS_PER_ENGINE:Array = [4, 32];
		public static const ALLOWED_MODULES_PER_ENGINE:Array = [2, 8];
		
        //allowed variable engine ports - array index is slot number
        private static const ENGINE_SLOT_ALLOWED_PORTS:Array = [
				
                [EnginePort.VAULT_FLASH_WIRLWIND],  //slot 0
                [EnginePort.VAULT_FLASH_WIRLWIND],  //slot 1
                //slot 2
                [EnginePort.COMPRESSION_ASTEROID, 
                    EnginePort.FC_4_GLACIER,
					EnginePort.FC_4_RAINFALL,
					EnginePort.FICON_4_PORT,
                    EnginePort.GIGE_2PORT_10GB_ELNINO, 
                    EnginePort.GIGE_2PORT_10GB_ERRUPTION, 
                    EnginePort.GIGE_2PORT_10GB_HEATWAVE, 
                    EnginePort.GIGE_2PORT_1GB_THUNDERBOLT, 
                    EnginePort.GIGE_4PORT_1GB_THUNDERCHILD,
					EnginePort.GIGE_4PORT_10GB_RAINSTORM],
                //slot 3
                [EnginePort.COMPRESSION_ASTEROID, 
					EnginePort.FC_4_GLACIER,
					EnginePort.FC_4_RAINFALL,
					EnginePort.FICON_4_PORT,
					EnginePort.GIGE_2PORT_10GB_ELNINO, 
					EnginePort.GIGE_2PORT_10GB_ERRUPTION, 
					EnginePort.GIGE_2PORT_10GB_HEATWAVE, 
					EnginePort.GIGE_2PORT_1GB_THUNDERBOLT, 
					EnginePort.GIGE_4PORT_1GB_THUNDERCHILD, 
					EnginePort.GIGE_4PORT_10GB_RAINSTORM],
                [],  //slot 4 backend ports
                [],  //slot 5 backend ports
                [EnginePort.VAULT_FLASH_WIRLWIND],  //slot 6
                [EnginePort.VAULT_FLASH_WIRLWIND],  //slot 7
                //slot 8
                [EnginePort.COMPRESSION_ASTEROID, 
					EnginePort.FC_4_GLACIER,
					EnginePort.FC_4_RAINFALL,
					EnginePort.FICON_4_PORT,
					EnginePort.GIGE_2PORT_10GB_ELNINO, 
					EnginePort.GIGE_2PORT_10GB_ERRUPTION, 
					EnginePort.GIGE_2PORT_10GB_HEATWAVE, 
					EnginePort.GIGE_2PORT_1GB_THUNDERBOLT, 
					EnginePort.GIGE_4PORT_1GB_THUNDERCHILD,
					EnginePort.GIGE_4PORT_10GB_RAINSTORM],
                //slot 9
                [EnginePort.COMPRESSION_ASTEROID, 
					EnginePort.FC_4_GLACIER,
					EnginePort.FC_4_RAINFALL,
					EnginePort.FICON_4_PORT,
					EnginePort.GIGE_2PORT_10GB_ELNINO, 
					EnginePort.GIGE_2PORT_10GB_ERRUPTION, 
					EnginePort.GIGE_2PORT_10GB_HEATWAVE, 
					EnginePort.GIGE_2PORT_1GB_THUNDERBOLT, 
					EnginePort.GIGE_4PORT_1GB_THUNDERCHILD,
					EnginePort.GIGE_4PORT_10GB_RAINSTORM],
            ];
		
		public static const ENGINE_SLOT_ALLOWED_PORTS_250F:Array = [
			
			[EnginePort.VAULT_FLASH_WIRLWIND], //slot 0
			[EnginePort.VAULT_FLASH_WIRLWIND],           // slot 1
			//slot 2
			[EnginePort.COMPRESSION_ASTEROID, 
				EnginePort.FC_4_GLACIER,
				EnginePort.FC_4_RAINFALL,
				EnginePort.FICON_4_PORT,
				EnginePort.GIGE_2PORT_10GB_ELNINO, 
				EnginePort.GIGE_2PORT_10GB_ERRUPTION, 
				EnginePort.GIGE_2PORT_1GB_THUNDERBOLT, 
				EnginePort.GIGE_4PORT_10GB_RAINSTORM],
			//slot 3
			[EnginePort.COMPRESSION_ASTEROID, 
				EnginePort.FC_4_GLACIER,
				EnginePort.FC_4_RAINFALL,
				EnginePort.FICON_4_PORT,
				EnginePort.GIGE_2PORT_10GB_ELNINO, 
				EnginePort.GIGE_2PORT_10GB_ERRUPTION,  
				EnginePort.GIGE_2PORT_1GB_THUNDERBOLT, 
				EnginePort.GIGE_4PORT_10GB_RAINSTORM],
			[], // back-end ports
			[EnginePort.VAULT_FLASH_WIRLWIND], // slot5
			[EnginePort.VAULT_FLASH_WIRLWIND], //slot 6
			[EnginePort.COMPRESSION_ASTEROID], //slot 7
			//slot 8
			[EnginePort.COMPRESSION_ASTEROID, 
				EnginePort.FC_4_GLACIER,
				EnginePort.FC_4_RAINFALL,
				EnginePort.FICON_4_PORT,
				EnginePort.GIGE_2PORT_10GB_ELNINO, 
				EnginePort.GIGE_2PORT_10GB_ERRUPTION, 
				EnginePort.GIGE_2PORT_1GB_THUNDERBOLT, 
				EnginePort.GIGE_4PORT_10GB_RAINSTORM],
			//slot 9
			[EnginePort.COMPRESSION_ASTEROID, 
				EnginePort.FC_4_GLACIER,
				EnginePort.FC_4_RAINFALL,
				EnginePort.FICON_4_PORT,
				EnginePort.GIGE_2PORT_10GB_ELNINO, 
				EnginePort.GIGE_2PORT_10GB_ERRUPTION, 
				EnginePort.GIGE_2PORT_1GB_THUNDERBOLT, 
				EnginePort.GIGE_4PORT_10GB_RAINSTORM],
			];
			
        
        public static const VARIABLE_ENGINE_PORTS:Array = [
            EnginePort.FC_4_RAINFALL,
            EnginePort.FICON_4_PORT,
			EnginePort.GIGE_4PORT_10GB_RAINSTORM,
            EnginePort.FC_4_GLACIER,
            EnginePort.GIGE_2PORT_10GB_HEATWAVE,
            EnginePort.GIGE_2PORT_1GB_THUNDERBOLT,
            EnginePort.GIGE_2PORT_10GB_ELNINO,
            EnginePort.GIGE_2PORT_10GB_ERRUPTION,
            EnginePort.GIGE_4PORT_1GB_THUNDERCHILD,
            EnginePort.COMPRESSION_ASTEROID,
            EnginePort.VAULT_FLASH_WIRLWIND];
        
        public function Engine(id:String, position:Position)
        {
            super(id, position, ENGINE_SIZE);

            if (position.type != Position.BAY_ENCLOSURE)
            {
                throw new ArgumentError("vg3r engine can only be positioned directly in bay");
            }
             
            var modulePosition:Position = ObjectCache.instance.get(PortConfiguration.ENGINE_DIRECTOR_VG3R_POSITION_CACHE_KEY) as Position;
            for(var ind:int = IB_MODULE_UPPER_POSITION; ind <= (IB_MODULE_UPPER_POSITION + 1); ind++)
            {
                var ep:EnginePort = EnginePort.createIfNotCached(EnginePort.IB_MODULE, modulePosition.type, ind);
                ep.position.rotation = Position.ROTATION270;
                addChild(ep);
            }
        } 

  	 	public override function get children():Array
        {
			if (portConfig)
			{
				return portConfig.children;
			}
			
			return super.children;
        }
		
		/**
		 * Gets current engine port configuration
		 * @return
		 * 
		 */    
		private function get portConfig():PortConfiguration
		{
			if (!_portConfig && portConfigurationManager)
			{
				_portConfig = portConfigurationManager.getCurrentPortConfiguration().clone() as PortConfiguration;	
			}
			return _portConfig;
		}
		
        private function get portConfigurationManager():IPortConfigurationManager
        {
            if (!parentConfiguration)
                return null;
            return parentConfiguration.factory as IPortConfigurationManager;
        }
	
		/**
		 * List of all overlay engine ports
		 * @return 
		 * 
		 */		
		public function get overlayPorts():ArrayCollection
		{
			return _overlayPorts;
		}
		
		public function set overlayPorts(overlayList:ArrayCollection):void
		{
			var portExist:Boolean = false;
			
			if (!_overlayPorts)
			{
				_overlayPorts = new ArrayCollection();
			}
			
			if (_overlayPorts.length > 0)
			{
				_overlayPorts.removeAll();
			}
			
			_overlayPorts.addAll(overlayList);
			
		}
		
        /**
        *  creates clone for given parent
        * @param parent reference of parent component
        * @return 
        * 
        */        
        public override function clone(parent:ComponentBase = null):ComponentBase{
            var clone:Engine = new Engine(id, position);
            clone.cloneBasicData(this);
            
            clone.parent = parent;
			
            return clone;
        }
        
		/**
		 * Initializes port groups for wizard
		 * @param noEngines indicates number of engines
		 * @param hostProtocol indicates if host protocol selected
		 * @return Array of EnginePortGroup objects
		 * 
		 */		
		public static function initPortGroupMap(noEngines:int, is250f:Boolean):Object
		{
			var ports:Array = new Array(3);
			var supportedEnginePortSRDF:int = is250f ? EnginePort.GIGE_2PORT_1GB_THUNDERBOLT : EnginePort.GIGE_2PORT_10GB_HEATWAVE;
			// OS type model
			ports[HostType.OPEN_SYSTEMS] = [
				EnginePortGroup.create(EnginePort.FC_PORT_PROTOTYPE, noEngines, HostType.OPEN_SYSTEMS, true),
				EnginePortGroup.create(EnginePort.ISCSI_PORT_PROTOTYPE, noEngines, HostType.OPEN_SYSTEMS),
				EnginePortGroup.create(EnginePort.createPortProto(supportedEnginePortSRDF), noEngines, HostType.OPEN_SYSTEMS)
			];
			
			// MF type model
			ports[HostType.MAINFRAME_HOST] = [
				EnginePortGroup.create(EnginePort.FC_PORT_PROTOTYPE, noEngines, HostType.MAINFRAME_HOST),
				EnginePortGroup.create(EnginePort.FICON_PORT_PROTOTYPE, noEngines, HostType.MAINFRAME_HOST, true),
				EnginePortGroup.create(EnginePort.createPortProto(supportedEnginePortSRDF), noEngines, HostType.MAINFRAME_HOST)
			];
			
			// Mixed (MF+OS) type model
			ports[HostType.MIXED] = [
				EnginePortGroup.create(EnginePort.FC_PORT_PROTOTYPE, noEngines, HostType.MIXED, true),
				EnginePortGroup.create(EnginePort.FICON_PORT_PROTOTYPE, noEngines, HostType.MIXED, true),
				EnginePortGroup.create(EnginePort.ISCSI_PORT_PROTOTYPE, noEngines, HostType.MIXED),
				EnginePortGroup.create(EnginePort.createPortProto(supportedEnginePortSRDF), noEngines, HostType.MIXED)
			];
			
			return ports;	
		}
		
		/**
		 * Gets engine ports selection list data provider by filtering wizard selected Engine port groups provider
		 * @return  array of EnginePort instances 
		 * 
		 */		
		public function getPortsSelectionDP():ArrayCollection
		{
			var portsProvider:ArrayCollection = new ArrayCollection();
			var config:Configuration_VG3R = this.parentConfiguration as Configuration_VG3R;
			
			for each (var ep:EnginePort in ALLOWED_ENGINE_PORTS)
			{
				if (ep.type == EnginePort.VAULT_FLASH_WIRLWIND || ep.type == EnginePort.COMPRESSION_ASTEROID)
				{
					// Compression and Flash types are always in the selection list provider
					portsProvider.addItem(ep);
					continue;
				}
				if((ep.type == EnginePort.GIGE_4PORT_1GB_THUNDERCHILD || ep.type == EnginePort.GIGE_2PORT_10GB_HEATWAVE) && config.factory.modelName == Constants.VMAX_250F){
					continue;
				}
				
				if (config.hostType == HostType.OPEN_SYSTEMS)
				{
					// OS host - FC, FCoE/iSCSI, SRDF
					if (ep.isOpenSystems)
					{
						portsProvider.addItem(ep);
					}
				}
				else if (config.hostType == HostType.MAINFRAME_HOST)
				{
					// MF host - FC, FICON, SRDF
					if 	(ep.isFC || ep.isMainframe || ep.isSRDF)
					{
						portsProvider.addItem(ep);
					}
				}
				else if (config.hostType == HostType.MIXED)
				{
					// Mixed - FC, FICON, FCoE/iSCSI, SRDF
					if (ep.isOpenSystems || ep.isMainframe)
					{
						portsProvider.addItem(ep);
					}
				}
				
				if (config.fileCapacity)
				{
					// File capacity - Ethernet File modules
					if (ep.isFile)
					{
						portsProvider.addItem(ep);
					}
				}
			}
			return portsProvider;			
		}
		
		
		
		/**
		 * Places given engine port inside given slot (paired slots)
		 * @param enginePort indicates port to be placed
		 * @param slot indicates slot for engine port
		 * @param isConfigSaved indicates if configuration is saved as xml
		 * 
		 */        
		public function placeEnginePort(enginePort:EnginePort, slot:int, isConfigSaved:Boolean = false):void
		{
			var engPortClone:EnginePort;
			
			for(var epIndex:int = 0; epIndex < portConfig.children.length; epIndex++)
			{
				var port:EnginePort = portConfig.children[epIndex] as EnginePort;
				
				if(enginePort.type == EnginePort.IB_MODULE && portConfig.children.length <= MAX_NUMBER_VG3R_ENGINE_MODULES) 
				{
					engPortClone = enginePort.clone() as EnginePort; // first IB module
					engPortClone.position.index = IB_MODULE_UPPER_POSITION;
					portConfig.children[portConfig.children.length] = engPortClone;	
					engPortClone = enginePort.clone() as EnginePort; // second IB module
					engPortClone.position.index = IB_MODULE_UPPER_POSITION + 1;
					portConfig.children[portConfig.children.length] = engPortClone;	
				}
				if(slot == getSlotNumberByPosition(port.position.index))
				{
					// enable Save btn on every change in engine ports placement
					(this.parentConfiguration as Configuration_VG3R).saved = isConfigSaved;
					
					engPortClone = enginePort.clone() as EnginePort;
					engPortClone.position = port.position;
					portConfig.children[epIndex] = engPortClone;
					
					var secondFlashSlot:int;
					if((this.parentConfiguration as Configuration_VG3R).factory.modelName == Constants.VMAX_250F) // flash pair is added in slot 5 for 250F and 7 for 450F/850F
						secondFlashSlot = 5;
					else
						secondFlashSlot = 7;
					
					if(enginePort.type == EnginePort.VAULT_FLASH_WIRLWIND && (slot == 1 || slot == secondFlashSlot)) //optional Flash modules are added in pairs 
					{
						if(secondFlashSlot == 7)
							var port2:int = 2;
						else
							var port2:int = 4;
						if(port.position.index == 2 || port.position.index == 12 || port.position.index == 4 || port.position.index == 14)
						{
							port2 = 8;
						}
						
						engPortClone = enginePort.clone() as EnginePort;
						engPortClone.position.index = port2;
						var childIndex:int = getEnginePortIndex(port.type, port2);			
						if(childIndex > -1)
							portConfig.children[childIndex] = engPortClone; 
						port2 += 10;
						engPortClone = enginePort.clone() as EnginePort;
						engPortClone.position.index = port2;
						childIndex = getEnginePortIndex(port.type, port2);
						if(childIndex > -1)
							portConfig.children[childIndex] = engPortClone; 
					}
				}
			}
		}
		
		/**
		 * Removes component from current port configuration
		 * @param engPort
		 * 
		 */        
		public function removeEnginePort(engPort:EnginePort):void
		{
			if(engPort.type == EnginePort.VAULT_FLASH_WIRLWIND)
			{
				removeFlashModule(engPort);
			}
			else
			{
				removeFEModule(engPort);
			}
		}
		
		/**
		 * Gets slots where given component can be placed 
		 * @param engPort
		 * @param isMoving indicates that the given port drag started from engine slot (not from selection component)
		 * @return 
		 * <p>Validation includes both, populated and empty slots</p>
		 */    
		public function getAvailableSlots(engPort:EnginePort, isMoving:Boolean = false):Array
		{
			if(isMoving) return [getSlotNumberByPosition(engPort.position.index)];
			var allowedSlots:ArrayCollection = new ArrayCollection(getAllowedSlotsForEnginePort(engPort.type, portConfig));
			
			var validEmptySlots:Array = getValidDropEmptySlot(engPort);
			
			var mandatoryModuleCount:int = 0;
			
			var config:Configuration_VG3R = this.parentConfiguration as Configuration_VG3R;
			
			for each(var epp:EnginePort in portConfig.children)
			{
				if(epp.isMandatoryPort(config.hostType))
				{
					mandatoryModuleCount++;
				}
			}
			
			//for 950f mixed configuration, Ficon can be added to slot 9
			if(config.hostType == HostType.MIXED)
			{
				validEmptySlots.push(9);
			}
			
			//remove invalid
			for each(var ep:EnginePort in portConfig.children)
			{
				var epSlot:int = getSlotNumberByPosition(ep.position.index);
				var epSlotIndex:int = allowedSlots.getItemIndex(epSlot);
				if(epSlotIndex > -1)
				{
					if (engPort.type == EnginePort.VAULT_FLASH_WIRLWIND)  //allowed Slots already contain every valid slot for this one
					{
						continue;
					}
					if (engPort.type == EnginePort.COMPRESSION_ASTEROID)
					{
						// do not allow this slot if it is only Block or File module
						if (ep.isMandatoryPort(config.hostType) && (mandatoryModuleCount/2 < 2))
						{
							allowedSlots.removeItemAt(epSlotIndex);
						}
						continue;
					}
					// do not allow slots for different port set or empty slot in incorrect slot
					if ((!engPort.connectionEquals(ep) && ep.type != EnginePort.EMPTY_SLOT) ||
						(ep.isMandatoryPort(config.hostType) && (mandatoryModuleCount/2 < 2) && (!engPort.isMandatoryPort(config.hostType))) ||
						(ep.type == EnginePort.EMPTY_SLOT && validEmptySlots.length > 0 && validEmptySlots.indexOf(epSlot) == -1))
					{
						allowedSlots.removeItemAt(epSlotIndex);
					}
				}
			}
			
			return allowedSlots.toArray(); 
		}
		
		
		/**
		 * Gets valid empty slot that the given engine port can be dropped to 
		 * @param engPort
		 * @return slot index
		 */    
		private function getValidDropEmptySlot(engPort:EnginePort):Array
		{
			var result:ArrayCollection = new ArrayCollection();
			var minEmptySlot:int = -1;
			var maxEmptySlot:int = -1;
			var allValidSlots:Array =  getAllowedSlotsForEnginePort(engPort.type, _portConfig);
			for each(var port:EnginePort in portConfig.children)
			{
				if(port.type == EnginePort.EMPTY_SLOT)
				{
					var emptySlot:int = getSlotNumberByPosition(port.position.index);
					
					if (allValidSlots.indexOf(emptySlot) == -1 || result.contains(emptySlot)) continue; //add just allowed empty slots
					
					result.addItem(emptySlot);
					
					if(minEmptySlot == -1 || emptySlot < minEmptySlot)
						minEmptySlot = emptySlot;
					if(maxEmptySlot == -1 || emptySlot > maxEmptySlot)
						maxEmptySlot = emptySlot;
				}
			}
			
			// allValidSlots collection contains all valid slots for these types of ports, result is anyway filtered with empty ports
			if(engPort.type == EnginePort.COMPRESSION_ASTEROID || engPort.type == EnginePort.VAULT_FLASH_WIRLWIND)
			{
				return result.toArray();
			}
			
			// FE components goes only in the rightmost or the leftmost empty slot, depending on population direction
			if(engPort.isLeftToRight) 
			{
				return minEmptySlot != -1 ? [minEmptySlot] : [];
			}
			else
			{
				return maxEmptySlot != -1 ? [maxEmptySlot] : [];
			}
		}
		/**
		 * Validates if engine port with the given type is allowed in the given slot
		 * @param enginePortType
		 * @param slot
		 * @param isMoving indicates if moving is started from port slot (not the selection component)
		 * @return 
		 * 
		 */        
		public function validateEnginePortSlot(engPort:EnginePort, slot:int, isMoving:Boolean = false):Boolean
		{
			if(slot < 0 || slot > 9) return false;
			
			return getAvailableSlots(engPort, isMoving).indexOf(slot) > -1;
		}
		
		/**
		 * removes flash modules from slots 1 and 7 for 450F/850F
		 * removes flash modules from slots 1 and 5 for 250F
		 * @param module
		 * 
		 */        
		private function removeFlashModule(module:EnginePort):void
		{
			if(!module.isRemovable)
				return;
			
			placeEnginePort(EnginePort.EmptySlotPrototype, 1);
			if((this.parentConfiguration as Configuration_VG3R).factory.modelName != Constants.VMAX_250F)
			{
				placeEnginePort(EnginePort.EmptySlotPrototype, 7);
			}
			else
			{
				placeEnginePort(EnginePort.EmptySlotPrototype, 5);
			}
		}
		
		/**
		 * Removes FE module 
		 * @param module
		 * 
		 */        
		private function removeFEModule(module:EnginePort):void
		{
			if(!module.isRemovable)
				return;
			
			//validate if there is at least one FC or File port beside one given for deletion
			for each(var port:EnginePort in portConfig.children)
			{
				if((port.isMandatoryPort((this.parentConfiguration as Configuration_VG3R).hostType)) && 
					getSlotNumberByPosition(port.position.index) != getSlotNumberByPosition(module.position.index))
				{
					placeEnginePort(EnginePort.EmptySlotPrototype, getSlotNumberByPosition(module.position.index));
					break;
				}
			}
			
		}
		
		/**
		 * Gets index of engine port in port configuration collection 
		 */        
		private function getEnginePortIndex(portType:int, positionIndex:int):int
		{
			for(var ind:int = 0; ind < portConfig.children.length; ind++)
			{
				var engPort:EnginePort = portConfig.children[ind] as EnginePort;
				if(engPort.type == portType && positionIndex == engPort.position.index)
				{
					return ind;
				}
			}
			return -1;
		}
		
		/**
		 * Creates allowed engine ports</br>
		 * position index is set to -1, it will be rewriten when used drops engine port on engine slot
		 */
		private static function createAllowedEnginePorts():Array
		{
			var result:Array = [];
			var modulePosition:Position = ObjectCache.instance.get(PortConfiguration.ENGINE_DIRECTOR_VG3R_POSITION_CACHE_KEY) as Position;
			var ep:EnginePort = null;
			for each(var epType:int in VARIABLE_ENGINE_PORTS)
			{
				
				ep = EnginePort.createIfNotCached(epType, modulePosition.type, -1);
				ep.position.rotation = Position.ROTATION270;
				result.push(ep);
			}
			
			return result;
		}
		
        /**
         * Returns slot number for the given engine port position index 
         * @param positionIndex
         * @return 
         * 
         */        
        public static function getSlotNumberByPosition(positionIndex:int):int
        {
            return 9 - (positionIndex <= 9 ? positionIndex : (positionIndex - 10));
        }
        
        /**
         * Gets lower position index for the given slot 
         * @param slot
         * @param higher if true, higher position index will be returned (example: lower 8, higher 18)
         * @return 
         * <p>We can get upper</p>
         */        
        public static function getPositionIndexBySlot(slot:int, higher:Boolean = false):int
        {
            if(slot < 0) return -1;
            
            return 9 - slot + (higher ? 10 : 0);
        }
        
        /**
         * Gets allowed slots for the given port type
         * @param portType
         * @return 
         */        
        public static function getAllowedSlotsForEnginePort(portType:int, portConfig:PortConfiguration = null):Array
        {
            var result:Array = [];
			var allowedPorts:Array = ENGINE_SLOT_ALLOWED_PORTS;
			
			if(portConfig.id == PortConfiguration.CONFIG_ALL_FLASH_250F.toString())
			{
				allowedPorts = ENGINE_SLOT_ALLOWED_PORTS_250F;
			}
			
            for(var slotIndex:int = 0; slotIndex < allowedPorts.length; slotIndex++)
            {
                if((allowedPorts[slotIndex] as Array).indexOf(portType) > -1)
                {
                    result.push(slotIndex);
                }
            }
            return result;
        }
        
        /**
         * Gets variable engine port (Flash or FE/SRDF) on the given position index
         * @param index
         * @return Engine port on the given position, null if not populated
         */        
        public function getIOModuleByPosition(index:int):EnginePort
        {
            if(index != -1)
            {
                for each (var ep:EnginePort in children)
                {
                    if(ep.position.index == index && VARIABLE_ENGINE_PORTS.indexOf(ep.type) > -1)
                    {
                        return ep;
                    }
                }
            }
            return null;
        }
		
		public override function serializeToXML():XML
		{
			var newXML:XML = createXMLnode();
			
			for each (var ep:EnginePort in this.children)
			{
				newXML.appendChild(ep.serializeToXML());
			}
			
			return newXML;
		}
		
		/**
		 * Adds deserialized Engine Ports to the Engine component
		 * @param xml indicate VG3R Engine xml
		 * 
		 */		
		public function deserializeParts(xml:XML):void
		{
			for each (var portXml:XML in xml.children())
			{
				var ep:EnginePort = EnginePort.createFromXml(portXml);
				
				placeEnginePort(ep, getSlotNumberByPosition(ep.position.index), true);
			}
		}
    }
}
