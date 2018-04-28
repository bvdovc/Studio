	package sym.objectmodel.common
{
    import flash.utils.Dictionary;
    import flash.utils.flash_proxy;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    
    import mx.collections.ArrayCollection;
    import mx.collections.ArrayList;
    import mx.collections.Sort;
    import mx.olap.aggregators.MaxAggregator;
    
    import sym.objectmodel.driveUtils.DriveDef;
    import sym.objectmodel.driveUtils.DriveRegister;
    import sym.objectmodel.driveUtils.enum.DriveRaidLevel;
    import sym.objectmodel.driveUtils.enum.DriveType;
    import sym.objectmodel.driveUtils.enum.HostType;
    import sym.objectmodel.utils.AllFlashArray;

    [Bindable]
    public class ComponentBase implements IXmlSerializable, ICloneableComponent
    {
        protected var _id:String;
        protected var _position:Position = null;
        protected var _size:Size = null;
        protected var _children:Array = [];
        protected var _parent:ComponentBase = null;
        protected var _type:int;
		
		// flag to know when to skip some validation for 950F ceate conf.
		public static var importConf950SizerXML:Boolean = false; 
				
        public function ComponentBase(id:String, position:Position, size:Size)
        {
            _id = id;
            _position = position;
            _size = size;
        }

        public function get parent():ComponentBase
        {
            return _parent;
        }
        
        public function get parentConfiguration():sym.objectmodel.common.Configuration {
            var comp:ComponentBase = this;
            while (!(comp is sym.objectmodel.common.Configuration)) {
                comp = comp.parent;
            }
            
            return comp as sym.objectmodel.common.Configuration;
        }

        protected function set parent(parent:ComponentBase):void
        {
            _parent = parent;
        }

        public function get id():String
        {
            return _id;
        }

        public function set id(id:String):void
        {
            _id = id;
        }

        public function get position():Position
        {
            return _position;
        }

        public function set position(position:Position):void
        {
            _position = position;

        }

        public function get size():Size
        {
            return _size;
        }

        protected function set size(size:Size):void
        {
            _size = size;
        }

        public function get visible():Boolean {
            return true;
        }
        
        public function get type():int{
            return _type;
		}
		
        public function get visibleInFrontView():Boolean{
            return position && 
                !(position.type == Position.BACKPANEL_PDP || 
                  position.type == Position.BACKPANEL_PDU ||
                  position.type == Position.ENGINE_DIRECTOR_10ke ||
                  position.type == Position.ENGINE_DIRECTOR_2040k ||
				  position.type == Position.ENGINE_DIRECTOR_VG3R);
        }
		
		public function get visibleInRearView():Boolean 
		{
			return true;
		}
		
		public function get propertiesEnabled():Boolean{
			return true;
		}
        
        /**
         * add a child component
         */
        public function addChild(child:ComponentBase):void
        {
            child.parent = this;
            _children.push(child);
        }
        
        /**
         * Removes child from private children collection 
         * @param child
         * 
         */        
        public function removeChild(child:ComponentBase):Boolean
        {
            var ci:int = _children.indexOf(child); 
            if(ci > -1)
            {
                delete _children[ci];
                return true;
            }
            
            return false;
        }

        public function get children():Array
        {
            return _children;
        }
		
		public function set children(children:Array):void
		{
			_children = children;
		}
        
        public function removeChildren():void
        {
            _children = [];
        }

        public function serializeToXML():XML
        {
            var xml:XML;

            xml = new XML(<{(this.id as String).toLowerCase()} id={this.id}/>);

            if (this._position)
            {
                xml.@positionType = this._position.type;
                xml.@positionIndex = this._position.index;
				xml.@flip = this._position.flip;
				xml.@rotation = this._position.rotation;
            }

            if (this._size)
            {
                xml.@sizeType = this._size.type;
                xml.@sizeHeight = this._size.height;
            }

            appendChildrenXML(this, xml);
            return xml;
        }
		
		public static function validateXml(xml:XML):Boolean
		{
			var valid:Boolean = false;
			
			if(xml.children().length() == 2)
			{		
				if(xml.config == null && xml.headers == null ){
					return false;
				}
				
				if(xml.config.make == null || xml.config.model == null)
					return false;
				
				valid = Configuration_VG3R.validateSizerXML(xml);
				
				if(!valid)
				{
					return false;
				}
				
				return true;
				
			}	
			
			if(xml.@series.toString() == null){
				return false;
			}
			
			valid = Configuration_VG3R.validateXML(xml);
			
			if(!valid)
			{
				return false;
			}
			
			if(!validateParts(xml))
			{
				return false;
			}
			
			//comments this to skip old validatePars function
			//since we dont have xml.@series and xml.@classType attribute in xml
			
			/*var children:XMLList = xml.children();
			
			for each (var child:XML in children)
				{
					if(!validateParts(child, xml.@series.toString()))
					{
						return false;
					}
				}*/
			
			return true;
		}
		
		//change what parts to validate, because now we dont have xml.@classType attribute in xml
		//keep before validation under comments
		public static function validateParts(xml:XML):Boolean
		{
			var raidGroups:Array = ["RAID 5(3+1)", "RAID 5(7+1)", "RAID 6(6+2)", "RAID 6(14+2)"];              
			var driveSizeGroup:Array = [960, 1920, 3840, 7680, 15360];
			var raidGroupFromXML:String = xml.Volume_request.protection;
			var driveSizeFromXML:int = xml.Volume_request.drive_size;
			var hostType:String = xml.@hostType;
			var matchesCorrect:Number = 0;
			
			for(var i:int = 0; i < raidGroups.length; i++)
			{
				if(raidGroupFromXML == raidGroups[i])
				{
					matchesCorrect++;
					break;
				}
			}
			
			for each(var drSize:int in driveSizeGroup)
			{
				if(drSize == driveSizeFromXML)
				{					
					matchesCorrect++; 
					break;
				}
			}
			
			if(matchesCorrect != 2)
			{
				return false;
			}
			
			if(hostType != "OS" && hostType != "MF" && hostType != "Mixed")
				return false;
			
			return true;
			
			/*try{
				 clazz = getDefinitionByName(xml.@classType) as Class;
			}catch(e:Error){
				return false;
			}
			if(!clazz)
			{
				return false;
			}
			
			var children:XMLList = xml.children();
			for (var i:int = 0; i < children.length(); i++)
			{
                var valid:Boolean = clazz["validateXml"](children[i], seria);
                if (!valid)
                {
                    return false;
                }

                for each (var child:XML in children[i].children())
                {
                    if (!ComponentBase.validateParts(child, seria))
                    {
                        trace("not valid xml");
                        return false;
                    }
                }
            }*/
			
		}

		/**
		 * Creates Configuration from xml
		 * @param xml indicates xml for which deserialization is made
		 * @param cfgFactory indicates factory for VG3R configuration only
		 * @return deserialized Configuration instance
		 * 
		 */		
        public static function deserializeFromXML(xml:XML, cfgFactory:Object=null):ComponentBase
        {
			var configuration:sym.objectmodel.common.Configuration;

			if((xml.model).toString() == Constants.VMAX_250F || (xml.model).toString() == Constants.VMAX_950F
				|| (xml.model).toString() == Constants.PowerMax_2000 || (xml.model).toString() == Constants.PowerMax_8000)
			{
				var noEngines:int = parseInt(xml.child(Configuration_VG3R.NO_ENGINES_XML_NAME).toString());
				var noEnginesPerBay:int = xml.child(Configuration_VG3R.DUAL_ENGINE_XML_NAME).toString() == "Yes" ? 2 : 1;
				var xmlChildren:XMLList = xml.children();
				var driveGroups:ArrayCollection = new ArrayCollection();
				var dispersion:Array = new Array();
				var tier:int = parseInt(xml.child(Configuration_VG3R.DRIVE_MIX_XML_NAME).toString());
				var usableCapacity:Number = Number(xml.@capacity);
				var is250Fmodel:Boolean = xml.child(Configuration_VG3R.MODEL_XML_NAME).toString() == Constants.VMAX_250F;
				var is950Fmodel:Boolean = xml.child(Configuration_VG3R.MODEL_XML_NAME).toString() == Constants.VMAX_950F;
				var raidType:String = (xml.Volume_request.protection).toString();
				var driveRaid:DriveRaidLevel;
				var actAndSpares:Number = xml.@activesAndSpares;
				var systemBays:int;
				
				if (usableCapacity == 0)
				{
					throw new Error("\nCapacity value is invalid!");
				}
				
				// determine appropriate parameters for creating DriveGroup
				if(is250Fmodel == true || is950Fmodel == true)
				{
					if(raidType == "RAID 5(3+1)")
						driveRaid = DriveRaidLevel.R53;
					else if(raidType == "RAID 5(7+1)")
						driveRaid = is250Fmodel == true ? DriveRaidLevel.R57_forTabasco : DriveRaidLevel.R57;
					else if(raidType == "RAID 6(6+2)")
						driveRaid = DriveRaidLevel.R66;
					else
						driveRaid = DriveRaidLevel.R614;
				}else
				{
					if(raidType == "RAID 5(3+1)")
						driveRaid = DriveRaidLevel.R53_Nebula;
					else if(raidType == "RAID 5(7+1)")
						driveRaid = DriveRaidLevel.R57_Nebula;
					else
						driveRaid = DriveRaidLevel.R66_Nebula;
				}
				
				for each (var childXml:XML in xmlChildren)
				{
					if (childXml.localName() == DriveGroup.XML_TAG_NAME)
					{
						var driveCap:int;
						var driveSpeed:Number;
						var size:Object;
						var noDrives:int;
						var driveType:DriveType;
						var dg:DriveGroup;
						
						noDrives = parseInt(childXml.child(DriveGroup.DRIVE_COUNT_XML_NAME).toString());
					
						if(is250Fmodel == true || is950Fmodel == true)
						{
							size = childXml.child(DriveGroup.DRIVE_SIZE_XML_NAME).toString() == "Yes" && is250Fmodel ? DAE.Tabasco : 
								childXml.child(DriveGroup.DRIVE_SIZE_XML_NAME).toString() == "No" ? DAE.Voyager : DAE.Viking;
							
							//set sysBayType
							if(noEngines < 2)
								systemBays = 1;
							else
								systemBays = 2;
							
						}else
						{
							size = DAE.Nebula;
							
							//set sysBayType
							if(noEngines <= 4)
								systemBays = 1;
							else
								systemBays = 2;
						}
						
						driveCap = parseInt(childXml.child(DriveType.DRIVE_CAPACITY_XML_NAME).toString());
	
						driveSpeed = Number(childXml.child(DriveType.DRIVE_SPEED_XML_NAME).toString());
						
						// determine drive type based on drive capacity and drive speed
						if(is250Fmodel == true || is950Fmodel == true)
							driveType = DriveDef.getDriveType(driveCap, driveSpeed);
						else
						{
							var drCap:String = driveCap/1000 + "TB NVMe";
							
							if(drCap == DriveType.FLASH_NVM_1920GB.name)
								driveType = DriveType.FLASH_NVM_1920GB;
							else if(drCap == DriveType.FLASH_NVM_3840GB.name)
								driveType = DriveType.FLASH_NVM_3840GB;
							else 
								driveType = DriveType.FLASH_NVM_7680GB;
						}
						
						// create drive group
						dg = DriveGroup.create(DriveRegister.register(driveType, driveRaid, size), NaN, noDrives);
						
						driveGroups.addItem(dg);
					}
				}
				
				// create configuration
				
				for each (var i:Object in xml.@dispersed.split(","))
				{	// deserialize dispersed values from xml 
					dispersion.push(parseInt(i.toString()));
				}				
				//configuration = cfgFactory.createConfiguration(noEngines, noEnginesPerBay, dispersion, driveGroups.toArray());
				configuration = cfgFactory.createConfiguration(noEngines, systemBays, driveType.name, actAndSpares, dispersion, driveGroups.toArray(), tier, xml.@osCapacity, xml.@mfCapacity, false );
				configuration.tierSolution = tier;
				configuration.totCapacity = usableCapacity;
				
				(configuration as Configuration_VG3R).hostType = xml.@hostType;
				(configuration as Configuration_VG3R).fileCapacity = xml.@fileCapacity == "true" ? true : false;
				configuration.activesAndSpares = xml.@activesAndSpares;
				configuration.osUsableCapacity = xml.@osCapacity;
				configuration.mfUsableCapacity = xml.@mfCapacity;
				configuration.engineModules = xml.@engineModules;
				configuration.enginePorts = xml.@enginePorts;
				configuration.driveType = driveType.name;
				if(is950Fmodel == true)
					configuration.numberOfDrives = actAndSpares;
				
				// set as saved
				(configuration as Configuration_VG3R).saved = true;
				
				(configuration as Configuration_VG3R).deserializeParts(xml);
				
				return configuration;
			}
			// create configuration from sizerXML
			else if(xml.config)
			{
				//values from xml
				var noEngines:int = xml.config.vBricks.vBrick.engineNumber.length();
				var usableCapacity:Number = xml.config.capacity.capacity_val.tb_usable;
				var drRaid:String = xml.config.raidType;
				var hostType:String = xml.config.systemType;
				var model:Number = xml.config.model;
				var driveTypes:Array = new Array();
				var noDriveType:int;
				var spare:Number;
				
				//if we have more values of driveTypes we use max value
				for(var j:int = 0; j < xml.config.capacityBricks.capacityBrick.driveType.length(); j++)
				{
					noDriveType = xml.config.capacityBricks.capacityBrick[j].driveType;
					driveTypes.push(noDriveType);
				}
				driveTypes.sort(Array.NUMERIC);
				
				noDriveType = driveTypes[driveTypes.length - 1];
				
				var cfg:Configuration_VG3R = new Configuration_VG3R();
				var driveGroups:ArrayCollection = new ArrayCollection();
				var dispersion:Array = [-1]; //default
				var driveGroup:DriveGroup;
				var drTypeFromSizerXml:String;
				var drRaidLevel:DriveRaidLevel;
				var drType:DriveType;
				var osCapacity:Number;
				var mfCapacity:Number;
				var sizeNumber:int;
				var sysBayType:int;
				var numberOfDrives:Number;
				var drivesAndSpares:Number;
				var tier:int = -1; //default
				
				if(model == 250 || model == 950)
				{
					if(model == 250)
					{
						if(noEngines > 2)
							noEngines = 2;
						
						sizeNumber = DAE.Tabasco;
						spare = noEngines;
						
						//if capacity higher than maximum, set it to maximum possible
						if(usableCapacity > AllFlashArray.TOTAL_USABLE_CAPACITY_250F)
							usableCapacity = AllFlashArray.TOTAL_USABLE_CAPACITY_250F;
					}
					
					if(model == 950)
					{
						sizeNumber = DAE.Viking;
						importConf950SizerXML = true;
						
						if(noEngines > 8)
							noEngines = 8;
						
						//if capacity less than minimum, set it to minimum possible for selected raidType
						if(hostType == HostType.OPEN_SYSTEMS)
						{
							if(usableCapacity < AllFlashArray.BASE_CONFIG_V_BRICK_CAPACITY)
								usableCapacity = AllFlashArray.BASE_CONFIG_V_BRICK_CAPACITY;
							
							if(drRaid == "RAID5-7+1")
							{
								//if capacity higher than maximum, set it to maximum possible for selected raidType
								if(usableCapacity > AllFlashArray.TOTAL_USABLE_CAPACITY_RAID5)
									usableCapacity = AllFlashArray.TOTAL_USABLE_CAPACITY_RAID5;
							}
							else
							{
								//if capacity higher than maximum, set it to maximum possible for selected raidType
								if(usableCapacity > AllFlashArray.TOTAL_USABLE_CAPACITY_RAID6)
									usableCapacity = AllFlashArray.TOTAL_USABLE_CAPACITY_RAID6;
							}
							
						}
						else
						{
							if(drRaid == "RAID5-7+1")
							{
								if(usableCapacity < AllFlashArray.FLASH_BLOCK_CAPACITY_13TB)
									usableCapacity = AllFlashArray.FLASH_BLOCK_CAPACITY_13TB;
								
								//if capacity higher than maximum, set it to maximum possible for selected raidType
								if(usableCapacity > AllFlashArray.TOTAL_USABLE_CAPACITY_RAID5)
									usableCapacity = AllFlashArray.TOTAL_USABLE_CAPACITY_RAID5;
							}
							else
							{
								if(usableCapacity < AllFlashArray.FLASH_BLOCK_CAPACITY_26TB)
									usableCapacity = AllFlashArray.FLASH_BLOCK_CAPACITY_26TB;
								
								//if capacity higher than maximum, set it to maximum possible for selected raidType
								if(usableCapacity > AllFlashArray.TOTAL_USABLE_CAPACITY_RAID6)
									usableCapacity = AllFlashArray.TOTAL_USABLE_CAPACITY_RAID6;
							}
						}
					}
					
					//set sysBayType
					if(noEngines < 2)
						sysBayType = 1;
					else
						sysBayType = 2;
					
					
					if(noDriveType == DriveType.FLASH_SAS_960GB.capacity)
						drTypeFromSizerXml = noDriveType.toString() + "GB Flash";
					else
						drTypeFromSizerXml = (noDriveType/1000).toString() + "TB Flash";
						
					//set driveType
					if(drTypeFromSizerXml == DriveType.FLASH_SAS_960GB.name)
						drType = DriveType.FLASH_SAS_960GB;
					else if(drTypeFromSizerXml == DriveType.FLASH_SAS_1920GB.name)
						drType = DriveType.FLASH_SAS_1920GB;
					else if(drTypeFromSizerXml == DriveType.FLASH_SAS_3840GB.name)
						drType = DriveType.FLASH_SAS_3840GB;
					else if(drTypeFromSizerXml == DriveType.FLASH_SAS_7680GB.name)
						drType = DriveType.FLASH_SAS_7680GB;
					else
						drType = DriveType.FLASH_SAS_15360GB;
					
					//set driveRaidLevel
					if(drRaid == "RAID5-3+1")
						drRaidLevel = DriveRaidLevel.R53;
					else if(drRaid == "RAID5-7+1")
						drRaidLevel = model == 250 ? DriveRaidLevel.R57_forTabasco : DriveRaidLevel.R57;
					else if(drRaid == "RAID6-6+2")
						drRaidLevel = DriveRaidLevel.R66;
					else
						drRaidLevel = DriveRaidLevel.R614;
				}
				else // for pm2000 and pm8000 
				{
					if(model == 2000)
					{
						if(noEngines > 2)
							noEngines = 2;
						
						//if capacity higher than maximum, set it to maximum possible for selected raidType
						if(drRaid == "RAID5-7+1")
						{
							if(usableCapacity > AllFlashArray.BASE_PM2000_CONFIG_MAXIMUM_CAPACITY_FOR_RAID57)
								usableCapacity = AllFlashArray.BASE_PM2000_CONFIG_MAXIMUM_CAPACITY_FOR_RAID57;
						}
						else if(drRaid == "RAID5-3+1")
						{
							if(usableCapacity > AllFlashArray.BASE_PM2000_CONFIG_MAXIMUM_CAPACITY_FOR_RAID53)
								usableCapacity = AllFlashArray.BASE_PM2000_CONFIG_MAXIMUM_CAPACITY_FOR_RAID53;
						}
						else if(drRaid == "RAID6-6+2")
						{
							if(usableCapacity > AllFlashArray.BASE_PM2000_CONFIG_MAXIMUM_CAPACITY_FOR_RAID66)
								usableCapacity = AllFlashArray.BASE_PM2000_CONFIG_MAXIMUM_CAPACITY_FOR_RAID66;
						}
						
					}else
					{
						if(noEngines > 8)
							noEngines = 8;
						
						//if capacity higher than maximum, set it to maximum possible for selected raidType
						if(drRaid == "RAID5-7+1")
						{
							if(usableCapacity > AllFlashArray.MAXIMUM_CAPACITY_PM8000_RAID57)
								usableCapacity = AllFlashArray.MAXIMUM_CAPACITY_PM8000_RAID57;
						}
						else if(drRaid == "RAID5-3+1" || drRaid == "RAID6-6+2")
						{
							if(usableCapacity > AllFlashArray.MAXIMUM_CAPACITY_PM8000_RAID66)
								usableCapacity = AllFlashArray.MAXIMUM_CAPACITY_PM8000_RAID66;
						}
					}
						
					drTypeFromSizerXml = (noDriveType/1000).toString() + "TB NVMe";
					sizeNumber = DAE.Nebula;
					spare = noEngines;
					
					//set driveType
					if(drTypeFromSizerXml == DriveType.FLASH_NVM_1920GB.name)
						drType = DriveType.FLASH_NVM_1920GB;
					else if(drTypeFromSizerXml == DriveType.FLASH_NVM_3840GB.name)
						drType = DriveType.FLASH_NVM_3840GB;
					else 
						drType = DriveType.FLASH_NVM_7680GB;
					
					//set driveRaidLevel
					if(drRaid == "RAID5-3+1")
						drRaidLevel = DriveRaidLevel.R53_Nebula;
					else if(drRaid == "RAID5-7+1")
						drRaidLevel = DriveRaidLevel.R57_Nebula;
					else
						drRaidLevel = DriveRaidLevel.R66_Nebula;
					
					//set sysBayType
					if(noEngines <= 4)
						sysBayType = 1;
					else
						sysBayType = 2;
					
				}
				
				//if capacity less than minimum, set it to minimum possible for selected raidType
				//this is for 250f, pm2000, pm8000
				if(usableCapacity < AllFlashArray.BASE_250F_CONFIG_MINIMUM_CAPACITY && (drRaid == "RAID5-3+1" || drRaid == "RAID6-6+2"))
				{
					usableCapacity = AllFlashArray.BASE_250F_CONFIG_MINIMUM_CAPACITY;
				}
				else if(usableCapacity < AllFlashArray.BASE_250F_CONFIG_MINIMUM_CAPACITY_FOR_RAID57)
				{
					usableCapacity = AllFlashArray.BASE_250F_CONFIG_MINIMUM_CAPACITY_FOR_RAID57;
				}
				
				if(hostType == "MIXED")
					hostType = "Mixed";
				
				//set OS,MF or Mixed capacity
				switch(hostType)
				{
					case HostType.OPEN_SYSTEMS:
						osCapacity = usableCapacity;
						mfCapacity = 0;
						break;
					case HostType.MAINFRAME_HOST:
						mfCapacity = usableCapacity;
						osCapacity = 0;
						break;
					case HostType.MIXED:
						osCapacity = usableCapacity/2;
						mfCapacity = usableCapacity/2;
						break;
				}
				
				numberOfDrives = AllFlashArray.calculateEFDcount(usableCapacity, noEngines, cfgFactory, model, drRaidLevel, hostType, drType);
				
				if(model == 950)
					spare = Math.ceil(numberOfDrives / 50);
				
				drivesAndSpares = numberOfDrives + spare;
				
				driveGroup = DriveGroup.create(DriveRegister.register(drType, drRaidLevel, sizeNumber), NaN, numberOfDrives);
				driveGroups.addItem(driveGroup);
				cfg = cfgFactory.createConfiguration(noEngines, sysBayType, drTypeFromSizerXml, drivesAndSpares, dispersion, driveGroups.toArray(), tier, osCapacity, mfCapacity, false );
				importConf950SizerXML = false;
				
				cfg.tierSolution = tier;
				cfg.totCapacity = usableCapacity;
				cfg.hostType = hostType;
				cfg.activesAndSpares = drivesAndSpares;
				cfg.osUsableCapacity = osCapacity;
				cfg.mfUsableCapacity = mfCapacity;
				cfg.driveType = drTypeFromSizerXml;
				if(model == 950)
					cfg.numberOfDrives = drivesAndSpares;
				
				if(hostType == HostType.MIXED)
				{
					cfg.osUsableCapacity = null;
					cfg.mfUsableCapacity = null;
				}
				
				return cfg;
			}
            
            configuration.noEngines = xml.@noEngines;
            configuration.noStorageBay = xml.@storageBay;
			configuration.dispersed = xml.@dispersed;
			configuration.daeType = xml.@daeType;
			
            var children:XMLList = xml.children();
            for each (var child:XML in children)
            {
                deserializeParts(child, configuration);
            }

            return configuration;
        
	}

        public static function deserializeParts(xml:XML, root:ComponentBase):void
        {
            var clazz:Class = getDefinitionByName(xml.@classType) as Class;
			
            var children:XMLList = xml.children();
            for (var i:int = 0; i < children.length(); i++)
            {
                var componentBase:ComponentBase = clazz["createFromXml"](children[i]);
				componentBase.parent = root;
				
				if (componentBase.position.depth == Position.PDP_DEPTH && !PDP.missingXML)
				{
					var pduExist:Boolean = false;
					for each (var rootChild:ComponentBase in root.children)
					{
						if (rootChild.position.depth == Position.PDU_DEPTH)
						{
							pduExist = true;
							break;
						}
					}
					if (pduExist)
					{
						root.children.push(componentBase);					
					}
					else
					{
						PDP.missingXML = xml;
						break;
					}
				}
				else
				{
	                for each (var child:XML in children[i].children())
	                {
	                    ComponentBase.deserializeParts(child, componentBase);
	                }
					if (PDP.missingXML && componentBase.isBay)
					{
						ComponentBase.deserializeParts(PDP.missingXML, componentBase);
						PDP.missingXML = null;
					}
					
	                root.children.push(componentBase);
				}
			}
        }
		
        protected function appendChildrenXML(componentBase:ComponentBase, xmlParent:XML):XML
        {
            if (componentBase.children.length != 0)
            {
                var dictionary:Dictionary = new Dictionary();
                for each (var child:ComponentBase in componentBase.children)
                {
                    var className:String = getQualifiedClassName(child);
                    className = className.replace("::", ".");
                    if (dictionary[className] == null)
                    {
                        dictionary[className] = new ArrayCollection();
                    }
                    (dictionary[className] as ArrayCollection).addItem(child);
                }
				
                for each (var key:Object in dictionary)
                {
                    var typeName:String = getQualifiedClassName((key as ArrayCollection)[0]);
                    typeName = typeName.replace("::", ".");
                    var arr:Array = typeName.split(".");

                    var newXml:XML = new XML(<{(arr.pop() as String).toLowerCase()} classType={typeName}/>);
                    xmlParent.appendChild(newXml);
                    for (var i:int = 0; i < key.length; i++)
                    {
                        newXml.appendChild((key[i] as ComponentBase).serializeToXML());
                    }
                }
            }
            return xmlParent;
        }
		
		/**
		 * Creates base XML node for provided component
		 * @return new XML
		 * 
		 */		
		protected function createXMLnode():XML
		{
			var className:String = getQualifiedClassName(this);
			var nodeName:String = className.split("::")[1];
			
			return new XML(<{nodeName} id={this.id} />);
		}

        /**
        * determines if components are of equal type
        * Base method compares by class name
        * Override methods in extended classes
        */
        public function equals(component:ComponentBase):Boolean
        {
            return getQualifiedClassName(this) == getQualifiedClassName(component);
        }

		/**
		 * returns true if this is DAE component
		 */
		public final function get isDAE():Boolean
		{
			return this is D15 || this is Vanguard || this is Voyager || this is Viking || this is Tabasco || this is Nebula;
		}
		
        /**
        * returns true if this is engine
        */
        public final function get isEngine():Boolean
        {
            return this is sym.objectmodel.common.Engine;
        }

        /**
        * returns true if this is configuration
        */
        public final function get isConfiguration():Boolean
        {
            return this is sym.objectmodel.common.Configuration;
        }

		/**
        * returns true if this is VG3R configuration
        */
        public final function get isVG3Rconfiguration():Boolean
        {
            return this is Configuration_VG3R;
        }
		
		/**
		 * returns true if this is bay
		 */
		public final function get isBay():Boolean
		{
			return this is sym.objectmodel.common.Bay;
		} 
    
        /**
         *  creates clone for given parent
         * @param parent reference of parent component
         * @return 
         * 
         */        
        public function clone(parent:ComponentBase = null):ComponentBase{
            return null;
        }
        
        /**
         * copies basic data without copying it
         * @param component
         * 
         */        
        protected function cloneBasicData(component:ComponentBase):void{
			_position = component._position != null ? component._position.clone() : component._position;
			_size=component._size;
			_type=component._type;
            
            for each(var cc:ComponentBase in component._children){
                _children.push(cc.clone(this));
            }
        }
    }
}
