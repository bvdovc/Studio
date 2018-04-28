package sym.objectmodel.common
{
	import sym.objectmodel.common.EnginePort;
	import sym.objectmodel.driveUtils.enum.HostType;

	/**
	 * Represents one Engine Port line for the wizard port grid
	 * Depending of host type selection we will have different port groups in the grid 
	 * @author nmilic
	 * 
	 */	
	public class EnginePortGroup
	{
		// engine port in one port group
		public var port:EnginePort;
		
		// engine port speed for port group
		public var speed:int;
		
		// represents engine port count map
		public var engineCountMap:Array;
		
		// OS/MF/Mixed
		public var hostType:String;
		
		public var hostProtocol:Boolean;
		
		public function EnginePortGroup()
		{
		}
		
		/**
		 * Calculates total port count for all engines
		 * @return number of ports
		 * 
		 */		
		public function get totalPortCount():int
		{
			var totalPorts:int = 0;
			
			for each (var enginePorts:int in this.engineCountMap)
			{
				totalPorts += enginePorts;
			}
			
			return totalPorts;
		}

		/**
		 * Calculates total module count for all engines 
		 * @return number of modules
		 * 
		 */		
		public function get totalModuleCount():int
		{
			var totalModules:int = 0;
			
			for (var i:int = 0; i < this.engineCountMap.length; i++)
			{
				totalModules += convertPortsToModules(this, this.engineCountMap[i]);
			}
			
			return totalModules;
		}
		
		/**
		 * Calculates required slots for this port group for specific engine 
		 * @return number of slots
		 * 
		 */		
		public function getRequiredSlots(engineInd:int):int
		{
			if (this.port.type == EnginePort.COMPRESSION_ASTEROID)
				return EnginePort.COMPRESSION_MODULE_REQUIRED_SLOTS;
			
			return this.engineCountMap[engineInd] / this.port.portCountPerDirector;
		}
		
		/**
		 * Creates EnginePortGroup for specific engine port
		 * @param port indicates engine port for current group
		 * @param noEngines indicates number of engines
		 * @return new instance of EnginePortGroup
		 * 
		 */		
		public static function create(port:EnginePort, noEngines:int, hostType:String, hostProtocol:Boolean = false):EnginePortGroup
		{
			var pg:EnginePortGroup = new EnginePortGroup();
			
			pg.port = port;
			pg.speed = port.speed;
			pg.hostType = hostType;
			pg.hostProtocol = hostProtocol;
			
			pg.engineCountMap = new Array(noEngines);
			
			// don't set any values for port types that are not default for current host selection
			if (!pg.isDefaultPort())
				return pg;
			
			// set engineCount values
			for (var ind:int = 0; ind < noEngines; ind++)
			{
				pg.engineCountMap[ind] = port.portCountPerDirector;
				
				// add ports only to engine1 by default for File type
				if (port.isFile && ind == 0)
					break;
			}
			
			return pg;
		}
		
		/**
		 * Checks if current port type is default port for selected OS/MF/Mixed host type
		 * which means that minimum port count value i.e 2 modules port count is set for this port group
		 * @return <code> True </code> if current port is default port, otherwise is <code> False </code>
		 * 
		 */		
		private function isDefaultPort():Boolean
		{
			if (this.port.isMainframe || this.port.isFile || this.hostProtocol)
			{
				// FICON is default for Mixed and MF only
				// File will be used as default when File storage is used
				// or if host protocol selected - AFA only
				return true;
			}
			
			if (this.port.isFC && this.hostType != HostType.MAINFRAME_HOST)
			{
				// FC is default for Mixed and OS only
				return true;
			}
			
			return false;
		}
		
		/**
		 * Calculates total port count per specific engine
		 * @param portGroups indicates array of port groups
		 * @param engineInd indicates engine for which we do calculaction
		 * @param rowIndex indicates row in DataGrid which cell value is not included in calculation 
		 * @return number of ports
		 * 
		 */		
		public static function getTotalPortsPerEngine(portGroups:Array, engineInd:int, rowIndex:int = -1):int
		{
			var totalCount:int = 0;
			
			for (var row:int = 0; row < portGroups.length; row++)
			{
				if (row == rowIndex)
					continue;
				
				var enginePorts:int = portGroups[row].engineCountMap[engineInd];
				totalCount += enginePorts;
			}
			
			return totalCount;
		}
		
		/**
		 * Calculates total module count per specific engine
		 * @param portGroups indicates array of port groups
		 * @param engineInd indicates engine for which we do calculaction
		 * @param rowIndex indicates row in DataGrid which cell value is not included in calculation
		 * @return 
		 * 
		 */		
		public static function getTotalModulesPerEngine(portGroups:Array, engineInd:int, rowIndex:int = -1):int
		{
			var totalModules:int = 0;
			
			for (var row:int = 0; row < portGroups.length; row++)
			{
				if (row == rowIndex)
					continue;
				
				var modules:int = convertPortsToModules(portGroups[row], portGroups[row].engineCountMap[engineInd]); 
				
				totalModules += modules;
			}
			
			return totalModules;
		}
		
		/**
		 * Gets supported port count for specific port group per specific engine
		 * @param portGroups indicates array of port groups
		 * @param pg indicates specific EnginePortGroup
		 * @param engineInd indicates engine index in port group
		 * @param rowIndex indicates row in DataGrid which cell value is not included in calculation 
		 * @return port count array
		 * 
		 */		
		public static function getSupportedPortCount(portGroups:Array, pg:EnginePortGroup, engineInd:int, rowIndex:int = -1):Array
		{
			var ports:Array = [];
			
			var maxAvailablePorts:int = Engine.ALLOWED_PORTS_PER_ENGINE[1] - getTotalPortsPerEngine(portGroups, engineInd, rowIndex);
				
			for (var portCount:int = pg.port.portCountPerDirector; portCount <= maxAvailablePorts; portCount += pg.port.portCountPerDirector)
			{
				var currentTotalModules:int = getTotalModulesPerEngine(portGroups, engineInd, rowIndex) + portCount / pg.port.portCount;
				
				if (currentTotalModules > Engine.ALLOWED_MODULES_PER_ENGINE[1])
					break;
				
				ports.push(portCount);
			}
			
			// add "0" as value for data Provider
			if (ports.length == 0 || !pg.isDefaultPort())
			{
				ports.splice(0, 0, EnginePort.NO_PORT_COUNT);
			}
			
			return ports;
		}
		
		/**
		 * Checks if there are available(empty) slots or all slots are populated. </br> 
		 * @param portGroups indicates array of port groups
		 * @param engineInd indicates engine for which we do calculaction
		 * @return True if there are no empty slots, otherwise is False
		 * 
		 */		
		public static function allSlotsPopulated(portGroups:Array, engineInd:int):Boolean
		{
			if (getTotalPortsPerEngine(portGroups, engineInd) < Engine.ALLOWED_PORTS_PER_ENGINE[1] && 
				getTotalModulesPerEngine(portGroups, engineInd) < Engine.ALLOWED_MODULES_PER_ENGINE[1])
			{
				return false;
			}
			
			return false;
		}
		
		/**
		 * Checks if specified port is appropriate for specific port speed.
		 * <br/> if not, create new appropriate EnginePort. Otherwise return old port
		 * @param portindicates EnginePort
		 * @param speed indicates port speed
		 * @return EnginePort
		 * 
		 */		
		public static function checkAppropriatePort(port:EnginePort, speed:int):EnginePort
		{
			// if port's speed doesn't match with specified speed then this is not apporiate port type
			// So, we'll create appropriate EnginePort instance
			if (port.speed != speed)
			{
				var portType:int;
				
				if (port.isFC)
				{
					portType = speed == EnginePort.PORT_SPEED_16GB ? EnginePort.FC_4_RAINFALL: EnginePort.FC_4_GLACIER;
				}
				
				if (port.isSRDF)
				{
					portType = speed == EnginePort.PORT_SPEED_10GB ? EnginePort.GIGE_2PORT_10GB_HEATWAVE : EnginePort.GIGE_2PORT_1GB_THUNDERBOLT;	
				}
				
				if (port.isFile)
				{
					portType = speed == EnginePort.PORT_SPEED_10GB ? EnginePort.GIGE_2PORT_10GB_ELNINO : EnginePort.GIGE_4PORT_1GB_THUNDERCHILD;
				}
				
				return EnginePort.createPortProto(portType);
			}
			
			return port;
		}
		
		/** Examines if every engine port count in File port group is valid for current port type.
		 * <p> Validation is needed since File 1Gb module is 4- port and 10Gb is 2-port module</p>
		 * @param filePortGroup indicates File EnginePortGroup
		 * @param portGroups indicates array of port groups
		 * @return array of engines for which we need to set new port count values
		 * 
		 */		
		public static function validateFilePortCount(filePortGroup:EnginePortGroup, portGroups:Array):Array
		{
			var engineNewPorts:Array = [];
			
			// check if this is File module only
			if (filePortGroup.port.isFile) {
				for (var i:int; i < filePortGroup.engineCountMap.length; i++) 
				{
					// 1Gb File module validation
					// examine if current 10Gb port count value can be kept as 1Gb port count
					// otherwise it will be chaged to default 1Gb port count value (8)
					if (filePortGroup.port.type == EnginePort.GIGE_4PORT_1GB_THUNDERCHILD && 
						(filePortGroup.engineCountMap[i] % filePortGroup.port.portCountPerDirector == 0 || filePortGroup.engineCountMap[i] == null))
					{
						continue;
					}
					
					// 10Gb File module validation 
					// in case when total module value per specific Engine has reached maximum of 8 modules
					// All current 1Gb port count values will be changed to default 10Gb port count (4)
					if (filePortGroup.port.type == EnginePort.GIGE_2PORT_10GB_ELNINO && !allSlotsPopulated(portGroups, i))
					{
						continue;
					}
					
					engineNewPorts.push(i);
				}
			}
			
			return engineNewPorts;
		}
		
		/**
		 * Calculates module count for specific FE port group based on provided port count for specific engine.
		 * @param portCount indicates number of ports
		 * @param epg indicates EnginePortGroup instance
		 * @return number of modules
		 * 
		 */		
		public static function convertPortsToModules(epg:EnginePortGroup, selectedPortCount:int):int
		{
			if (epg.port.type == EnginePort.COMPRESSION_ASTEROID)
			{
				// 2 Compressions added by default for AFA only
				return EnginePort.COMPRESSION_MODULE_DEFAULT_COUNT;
			}
			
			return selectedPortCount / epg.port.portCount;
		}
		
	}
}