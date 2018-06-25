package sym.objectmodel.common
{ 
    import mx.collections.ArrayCollection;
    import mx.core.IFactory;
    import mx.preloaders.DownloadProgressBar;
    import mx.utils.StringUtil;
    
    import spark.collections.Sort;
    
	public class Configuration_VG3R extends sym.objectmodel.common.Configuration
	{
		private static const FIFTH_DAE_LOCATION:Array = [5, 27];
		private static const DAE_NUMBER_COUNT:Array = [5, 8];
		public static const SINGLE_ENGINE_BAY:int = 1;
		public static const DUAL_ENGINE_BAY:int = 2;
		
		public static const CONFIG_XML_TAG_NAME:String = "Configuration";
		public static const MODEL_XML_NAME:String = "model";
		public static const NO_ENGINES_XML_NAME:String = "num_system_nodes";
		public static const DUAL_ENGINE_XML_NAME:String = "Dual_Engine";
		public static const DRIVE_MIX_XML_NAME:String = "Drive_mix";
		
		private var _sysBayType:int = SINGLE_ENGINE_BAY;
        private var _engineDriveMap:Array;
        private var _driveGroups:Array;
        private var _driveGroupStructure:String = "";
		private var _enginePortsStructure:String = "";
		private var _isSizerImported:Boolean = false;
		
		private var _fileName:String;
		
		// OS/MF/Mixed
		public var hostType:String;
		// is File capacity selected
		public var fileCapacity:Boolean;
		
		[Bindable]
		public var saved:Boolean = false;
		
		public function Configuration_VG3R(id:String = null)
		{
			super(id);
		}
		
        public function get isSizerImported():Boolean
		{
			return _isSizerImported;
		}
		
		public function set isSizerImported(value:Boolean):void
		{
			_isSizerImported = value;
		}
		
		public override function get totalDaeNumber():int
		{
			if(noNebula == 0)
			{
				if(noViking == 0 && noVoyager == 0)
					return noTabasco;
				return noViking + noVoyager;
			}else return noNebula;
		}
		
		public override function get maxDrivesNumber():int
		{
			if(noNebula == 0)
			{
				if (noTabasco > 0)
					return noTabasco * Drive.TABASCO_DRIVES_NUMBER;
			
			return noVoyager * Drive.VOYAGER_DRIVES_NUMBER + noViking * Drive.VIKING_DRIVES_NUMBER;
			}else return noNebula * Drive.NEBULA_DRIVES_NUMBER;
				
		}
		
		public override function get calculatedId():String
		{
			var calcId:String = "";
			// only for configs with 2 bays, 4 DAEs per bay and 2 engines
			
			//for every bay stores its baysId
			var markedBays:Array = [];
						
			var matchedConfigID:String = "";
			for each (var bay:Bay in children) 
			{
				//if there is dispersion find partial baysIds which will later be concatenated
				if(this.dispersed_m[0] != -1)
				{
					var baysId:String = "";
					
					if (fifthDaePosition(bay) != -1)
						baysId = bay.countDAEs + "_" + fifthDaePosition(bay) + "_";	
					else	
						baysId += bay.countDAEs + "_";
					
					markedBays.push({bay:bay, bayId:baysId}); 
				}
				else{
					if (fifthDaePosition(bay) != -1)
						calcId += bay.countDAEs + "_" + fifthDaePosition(bay) + "_";	
					else	
						calcId += bay.countDAEs + "_";
				}
			}
			
			if(this.dispersed_m[0] != -1)
			{
				//default model for positioning bays (first goes storage bay, then 2 system bays followed by 2 storage bays, then 2 system bays and finally last storage bay)
				// system bays with positionIndex (from 4 to 7) are placed at positions from 8 to 11 (last 4 indexes)
				var orderedItems:Array = ["", "", "", "", "", "", "", "", "", "", "", ""];
				
				//positions of system bays
				var sysBayIndexPositionMap:Object = {0 : 1, 1 : 2, 2 : 5, 3 : 6, 4 : 8, 5 : 9, 6 : 10, 7 : 11};
				//positions of storage bays
				var strgBayIndexPositionMap:Object = {0 : 0, 1 : 3, 2 : 4, 3 : 7};
				
				for each(var obj:Object in markedBays)
				{
					var sbay:Bay = obj.bay as Bay;
					
					if(sbay.isSystemBay)
					{
						orderedItems[sysBayIndexPositionMap[sbay.positionIndex]] = obj.bayId;
					}
					else
					{
						orderedItems[strgBayIndexPositionMap[sbay.attachedToSystemBayWithIndex]] = obj.bayId;
					}
				}

				//creates calcId by concatinating all baysIds (if there is an empty position (no such bay in configuration) only empty string will be passed (default in orderedItems))
				for (var j:int = 0; j < orderedItems.length; j++)
				{
					calcId += orderedItems[j].toString();
				}
				
				if (this.noEngines == DUAL_ENGINE_BAY && this.totalDaeNumber == DAE_NUMBER_COUNT[1])
					matchedConfigID = singleEngine ? "_" + SINGLE_ENGINE_BAY : "_" + DUAL_ENGINE_BAY;
				
				calcId += noEngines + matchedConfigID + "_" + this.daeType;
				
				return calcId;
			}
			
			if (this.noEngines == DUAL_ENGINE_BAY && this.totalDaeNumber == DAE_NUMBER_COUNT[1])
				matchedConfigID = singleEngine ? "_" + SINGLE_ENGINE_BAY : "_" + DUAL_ENGINE_BAY;
			
			// added daeType to the ID to distunguish the configs if they have the same HW structure but different DAE type
			// for example, 250F (only Tabasco) series differ from rest - AFA and VMAX3 arrays (Viking/Voyager)
			calcId += noEngines + matchedConfigID + "_" + this.daeType;
			
			return calcId;
		}
		
		/**
		 * For case when we have two configs with 5 DAEs number 
		 * but 5th DAEs are on different places within sys bay
		 * @param bay
		 * @return fifth dae position in bay<br/>
		 * -1 if not found
		 * 
		 */				
		public function fifthDaePosition(bay:Bay):Number
		{
			if (bay.isSystemBay && bay.countDAEs == DAE_NUMBER_COUNT[0])
			{
				for each (var comp:ComponentBase in bay.children) 
				{
					if (comp is DAE && (comp.position.index == FIFTH_DAE_LOCATION[0] || 
										comp.position.index == FIFTH_DAE_LOCATION[1]))
					return comp.position.index;
				}
			}
			return -1;
		} 
		
		/**
		 * Determines system bay type - single/dual engine bay
		 * @return number of engines per bay
		 * 
		 */		
		public function get sysBayType():int
		{
			return _sysBayType;
		}
        
        /**
         * System bay type setter 
         * @param value SINGLE_ENGINE_BAY/DUAL_ENGINE_BAY
         */        
        public function set sysBayType(value:int):void
        {
            _sysBayType = value;
        }
          
       
		
		/**
		 * Does DAE contains Drives 
		 * @return true if Drives exist in config, otherwise is false
		 * 
		 */		
		public function get containsDrives():Boolean
		{
			for each (var bay:Bay in this.children)
			{
				for each (var comp:ComponentBase in bay.children)
				{
					if (comp is DAE && comp.children.length > 0)
					{
						return true;
					}
				}
			}
			
			return false;
		}
		
		public override function get structureId():String
		{
			return calculatedId + "_" + noVoyager + "_" + noViking + "_" + noTabasco + "_" + noNebula + "_" + countSystemBay + "_" + sysBayType + "_" + 
				dispersed_m + "_" + tierSolution + "_" + _driveGroupStructure + "_" + enginePortsStructure + "_" + this.hostType;
		}
        
        /**  
         * helper getter
         */        
        public function get singleEngine():Boolean
        {
            return _sysBayType == SINGLE_ENGINE_BAY;
        }
        
        /**  
         * helper getter
         */  
        public function get dualEngine():Boolean
        {
            return _sysBayType == DUAL_ENGINE_BAY;
        }
		
        /**
         * Getter of drive count maps for each engine (value => [driveDef.id] = {active:int, spare:int})
         * @return arrays 
         * <p>Note that engine indices starts from 0 even though index of first Engine is 1</p>
         */        
        public function get driveCountMap():Array
        {
            return _engineDriveMap;
        }
        
        /**
         * Sets drive count 
         * @param map  
         */        
        public function set driveCountMap(map:Array):void
        {
            _engineDriveMap = map;
        }
        
        /**
         * Drive group array 
         * @param value
         * 
         */        
        public function set driveGroups(value:Array):void
        {
            _driveGroups = value;
            if(_driveGroups && _driveGroups.length > 0)
            {
                var dgs:ArrayCollection = new ArrayCollection(value);
                dgs.sort = new Sort();
                dgs.sort.compareFunction = sortDriveGroupsFunction;
                dgs.refresh();
                
                for(var dgid:int = 0; dgid < dgs.length; dgid++)
                {
                    var driveGroup:DriveGroup = dgs[dgid] as DriveGroup;
                    _driveGroupStructure += StringUtil.substitute("[{0}]{1}", driveGroup.driveDef.id, driveGroup.activeCount);
                }
            }
        }
        
        public function get driveGroups():Array
        {
            return _driveGroups;
        }

		public override function get activesAndSpares():int
		{
			if (_activesAndSpares > 0)
				return _activesAndSpares;
			
			for each (var obj:Object in _engineDriveMap)
			{
				for each(var obj2:Object in obj)
				{
					_activesAndSpares += obj2.active + obj2.spare;
				}
			}
			
			return _activesAndSpares;
		}
		
		public override function get enginePorts():int
		{
			if (!_noPortsModulesChanged)
				return _enginePorts;
			
			initPorts();
			_noPortsModulesChanged = false;
			return _enginePorts;
		}

		public override function get engineModules():int
		{
			if (!_noPortsModulesChanged)
				return _engineModules;
			
			initPorts();
			_noPortsModulesChanged = false;
			return _engineModules;
		}
		
		/**
		 * Calculates total FE ports/modules and port types.<br/>
		 * Sets _enginePorts, _engineModules, _enginePortsStructure properties.
		 * 
		 */		
		private function initPorts():void
		{
			var epTypes:Array = [];
			_enginePorts = 0;
			_engineModules = 0;
			
			var engineIndexCounter:int;
			
			if(this.factory.seriesName == "pm_8000" && this.noEngines > 4)
				engineIndexCounter = 4;
			else
				engineIndexCounter = this.noEngines;
			for (var i:int = 1; i <= engineIndexCounter ; i++)
			{
				var engine:Engine = this.getEngineByIndex(i) as Engine;
				
				for each (var ep:EnginePort in engine.children)
				{
					// count ports
					_enginePorts += ep.portCount;
					
					// check only FE ports
					if (ep.portCount > 0)
					{
						// count modules
						_engineModules++;
						
						if (epTypes.indexOf(ep.type) == -1)
						{
							// add port types
							epTypes.push(ep.type);
						}
					}
				}
				if(this.factory.seriesName == "pm_8000" && this.noEngines > 4 && i == 5)
					i = 1;
			}			
			_enginePortsStructure = StringUtil.substitute("[{0},{1}][{2}]", _enginePorts, _engineModules, epTypes);
		}
		
		/**
		 * Set engine port structure specific for current config.
		 * Consists of number of total FE ports, total modules and selected port types
		 * @return 
		 * 
		 */		
		public function get enginePortsStructure():String
		{
			if (_enginePortsStructure.length > 0)
				return _enginePortsStructure;
			
			initPorts();
			
			return _enginePortsStructure;
		}
		
		/**
		 * File name used when config is saved
		 * @return name of saved xml file
		 * 
		 */		
		public function get fileName():String
        {
			if (!_fileName || _fileName.length == 0)	
				this.fileName = this.factory.seriesName + this.structureId + ".xml";
			
			return _fileName;
        }

		public function set fileName(val:String):void
        {
			_fileName = val;
        }
        
        /**
         * Drive group array sort function
         * @param dg1
         * @param dg2
         * @param param
         * @return 
         * Drive group sort function is used in generation of unique drivegroup structure ID used in config.structureId.
         */        
        private static function sortDriveGroupsFunction(dg1:DriveGroup, dg2:DriveGroup, param:Object = null):int
		{
            if(dg1.driveDef.id == dg2.driveDef.id) return 0;
            else if(dg1.driveDef.id < dg2.driveDef.id) return -1;
            else return 1;
        }
		
		public override function serializeToXML():XML
		{
			var configXML:XML = initXMLnode();
			
			configXML.@capacity = this.totCapacity;
			configXML.@dispersed = this.dispersed_m;
			configXML.@hostType = this.hostType;
			configXML.@fileCapacity = this.fileCapacity;
			configXML.@osCapacity = this.osUsableCapacity;
			configXML.@mfCapacity = this.mfUsableCapacity;
			configXML.@activesAndSpares = this.activesAndSpares;
			configXML.@engineModules = this.engineModules;
			configXML.@enginePorts = this.enginePorts;
			
			configXML.child(MODEL_XML_NAME).setChildren(this.factory.modelName);
			configXML.child(NO_ENGINES_XML_NAME).setChildren(this.noEngines);
			configXML.child(DUAL_ENGINE_XML_NAME).setChildren(dualEngine ? "Yes" : "No");
			configXML.child(DRIVE_MIX_XML_NAME).setChildren(this.tierSolution);

			for each (var dg:DriveGroup in driveGroups)
			{
				configXML.appendChild(dg.serializeToXML());
			}
			
			for (var i:int = 0; i < this.children.length; i++)
			{
				for each (var cb:ComponentBase in this.children[i].children)
				{
					if (cb.isEngine)
					{
						configXML.appendChild(cb.serializeToXML());
					}
				}
			}
			
			return configXML;
		}
		
		private static function initXMLnode():XML
		{
			return new XML(<{CONFIG_XML_TAG_NAME}> 
							<{MODEL_XML_NAME}/> 
							<{NO_ENGINES_XML_NAME} />
							<{DUAL_ENGINE_XML_NAME} />
							<{DRIVE_MIX_XML_NAME} />
						</{CONFIG_XML_TAG_NAME}>);
		}
		
		/**
		 * validate sizer xml
		 * 
		 */	
		public static function validateSizerXML(xml:XML):Boolean
		{
			var seriaName:String = xml.config.make;
			var model:Number = xml.config.model;
			var raidType:String = xml.config.raidType;
			var systemType:String = xml.config.systemType;
			var driveTypes:Array = new Array();
			var noEngines:Number = xml.config.vBricks.vBrick.engineNumber.length();
			var capacity:Number = xml.config.capacity.capacity_val.tb_usable;
			var allDriveTypes:Array = [960, 1920, 3840, 7680, 15360];
			var noDriveType:Number;
			
			if (seriaName != "VMAX" && seriaName != "POWERMAX")
			{
				return false;
			}
			if (model != 250 && model != 950 && model != 2000 && model != 8000)
			{
				return false;
			}
			if (raidType != "RAID5-3+1" && raidType != "RAID5-7+1" && raidType != "RAID6-6+2" && raidType != "RAID6-14+2")
			{
				return false;
			}
			if(systemType != "OS" && systemType != "MF" && systemType != "MIXED")
			{
				return false;
			}
			if(noEngines == 0 || xml.config.capacityBricks.capacityBrick.driveType.length() == 0 || capacity == 0)
			{
				return false;
			}
			
			//check every driveType from xml if matches with default driveTypes
			for(var j:int = 0; j < xml.config.capacityBricks.capacityBrick.driveType.length(); j++)
			{
				var match:Number = 0;
				noDriveType = xml.config.capacityBricks.capacityBrick[j].driveType;
				driveTypes.push(noDriveType);
				
				for(var i:int = 0; i < allDriveTypes.length; i++)
				{
					if(noDriveType == allDriveTypes[i])
					{
						match++;
						break;
					}
					
				}
				
				if(match == 1)
					continue;
				else
					return false;
			}
			
			var isValid:Boolean = false;
			
			isValid = validateEachSeriaParts(seriaName, model, raidType, systemType, driveTypes);
			
			if(!isValid)
			{
				return false;
			}
			
			return true;
		}
		
		public static function validateEachSeriaParts(seriaName, model, raidType, systemType, driveTypes):Boolean
		{
			if(seriaName == "VMAX")
			{
				if(model == 2000 || model == 8000)
					return false;
			}
			if(seriaName == "POWERMAX")
			{
				if(model == 250 || model == 950)
					return false;
			}
			if(model == 250 || model == 2000 || model == 8000)
			{
				if(raidType == "RAID6-14+2")
					return false;
			}
			if(model == 950)
			{
				if(raidType == "RAID5-3+1" || raidType == "RAID6-6+2")
					return false;
			}
			if(model == 250 || model == 2000)
			{
				if(systemType == "MF" || systemType == "MIXED")
					return false;
			}
			if(seriaName == "POWERMAX")
			{
				for(var i:int = 0; i < driveTypes.length; i++)
				{
					if(driveTypes[i] == 15360 || driveTypes[i] == 960)
						return false;
				}
			}
			
			return true;
		}
		
		public static function validateXML(xml:XML):Boolean
		{
			var vmaxModel:String = xml.child(MODEL_XML_NAME).toString();
			
			if (vmaxModel != Constants.VMAX_450F && vmaxModel != Constants.VMAX_950F 
				&& vmaxModel != Constants.VMAX_250F && vmaxModel != Constants.PowerMax_2000 && vmaxModel != Constants.PowerMax_8000)
			{
				return false;
			}
			if (vmaxModel == Constants.VMAX_450F)
			{
				if (Constants.NO_ENGINE_V450F.indexOf(parseInt(xml.child(NO_ENGINES_XML_NAME))) == -1)
				{
					return false;
				}
			}
			if (vmaxModel == Constants.VMAX_950F)
			{
				if (Constants.NO_ENGINE_V850F.indexOf(parseInt(xml.child(NO_ENGINES_XML_NAME))) == -1)
				{
					return false;
				}
			}
			if(vmaxModel == Constants.VMAX_250F)
			{
				if(Constants.NO_ENGINE_V250F.indexOf(parseInt(xml.child(NO_ENGINES_XML_NAME))) == -1)
				{
					return false;
				}
			}
			if(vmaxModel == Constants.PowerMax_2000)
			{
				if(Constants.NO_ENGINE_PM2000.indexOf(parseInt(xml.child(NO_ENGINES_XML_NAME))) == -1)
				{
					return false;
				}
			}
			if(vmaxModel == Constants.PowerMax_8000)
			{
				if(Constants.NO_ENGINE_PM8000.indexOf(parseInt(xml.child(NO_ENGINES_XML_NAME))) == -1)
				{
					return false;
				}
			}
			
			if(vmaxModel == Constants.PowerMax_2000)
			{
				if(Constants.NO_ENGINE_PM2000.indexOf(parseInt(xml.child(NO_ENGINES_XML_NAME))) == -1)
				{
					return false;
				}
			}
			
			if (xml.contains(DriveGroup.XML_TAG_NAME) && xml.child(DriveGroup.XML_TAG_NAME).length() == 0)
			{
				return false;
			}
			
			return true;
		}
		
		/**
		 * Deserialize Engine components from xml
		 * @param xml indicates VG3R configuration xml
		 * 
		 */		
		public function deserializeParts(xml:XML):void
		{
			for each (var childXML:XML in xml.children())
			{
				if (childXML.localName() == "Engine")
				{
					var engineFound:Boolean = false;
					
					for (var i:int = 0; i < this.children.length || !engineFound; i++)
					{
						for each (var cb:ComponentBase in this.children[i].children)
						{
							if (cb.isEngine && cb.id == childXML.@id)
							{
								// deserialize only if engine xml ID matches with the Engine cmp ID
								(cb as Engine).deserializeParts(childXML);
								
								engineFound = true;
								break;
							}
						}
					}
				}
			}
		}
	}
}