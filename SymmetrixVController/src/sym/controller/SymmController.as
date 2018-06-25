package sym.controller
{
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.messaging.errors.MessagingError;
	import mx.messaging.events.MessageEvent;
	import mx.messaging.messages.ErrorMessage;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	
	import sym.configurationmodel.common.ConfigurationFactoryBase;
	import sym.configurationmodel.common.ConfigurationFactoryBase_VG3R;
	import sym.configurationmodel.common.ConfigurationFilter;
	import sym.configurationmodel.pm2000.ConfigurationFactory;
	import sym.configurationmodel.pm8000.ConfigurationFactory;
	import sym.configurationmodel.v250f.ConfigurationFactory;
	import sym.configurationmodel.v450f.ConfigurationFactory;
	import sym.configurationmodel.v950f.ConfigurationFactory;
	import sym.controller.events.ComponentSelectionChangedEvent;
	import sym.controller.events.FilterChangeRequestEvent;
	import sym.controller.events.FilterChangedEvent;
	import sym.controller.events.FilterWizardEvent;
	import sym.controller.events.RedrawEvent;
	import sym.controller.events.SelectionComponentDataChangedEvent;
	import sym.controller.events.VMaxSelectionChangeRequestEvent;
	import sym.controller.events.VMaxSelectionChangedEvent;
	import sym.controller.events.XmlImportErrorEvent;
	import sym.controller.events.XmlImportedEvent;
	import sym.controller.model.DragDropController;
	import sym.controller.model.SelectionModel;
	import sym.controller.utils.ComponentNameProvider;
	import sym.controller.utils.HtmlPropertyTextProvider;
	import sym.controller.utils.IComponentNameProvider;
	import sym.controller.utils.IPropertyTextProvider;
	import sym.objectmodel.common.ComponentBase;
	import sym.objectmodel.common.Configuration;
	import sym.objectmodel.common.Configuration_VG3R;
	import sym.objectmodel.common.Constants;
	import sym.objectmodel.common.ControlStation;
	import sym.objectmodel.common.DAE;
	import sym.objectmodel.common.DataMover;
	import sym.objectmodel.common.Engine;
	import sym.objectmodel.common.EnginePort;
	import sym.objectmodel.common.KVM;
	import sym.objectmodel.common.MIBE;
	import sym.objectmodel.common.PDP;
	import sym.objectmodel.common.PDU;
	import sym.objectmodel.common.PortConfiguration;
	import sym.objectmodel.common.SPS;
	import sym.objectmodel.common.Server;
	import sym.objectmodel.common.UPS;
	import sym.objectmodel.driveUtils.DictionaryExt;
	import sym.objectmodel.driveUtils.enum.HostType;
	
	/**
	 * SymmController
	 * Main UI controller independent of client platform
	 * eventHandler - main event handler/dispatcher - event communication between client and controller should be done here
	 */
    [Bindable]
	public class SymmController
	{
		private static const _inst:SymmController = new SymmController();
		
		public static const DEFAULT_DATA_MOVER_COUNT:int = 2;
		private const _eventHandler:EventDispatcher = new EventDispatcher();
		private var _model:SelectionModel = new SelectionModel();
		private var _configFactory:ConfigurationFactoryBase;
		private var _configFilter:ConfigurationFilter = new ConfigurationFilter();
		private var _configurations:ArrayCollection = new ArrayCollection();
		private var _selectionListBaseObject:ComponentBase;
		private var _componentNameProvider:IComponentNameProvider = new ComponentNameProvider();
		private var _propertyTextProvider:IPropertyTextProvider = new HtmlPropertyTextProvider();
		
		private var _configFactory450f:ConfigurationFactoryBase = null;
		private var _configFactory950f:ConfigurationFactoryBase = null;
		private var _configFactory250f:ConfigurationFactoryBase = null;
		private var _configFactoryPM2000:ConfigurationFactoryBase = null;
		private var _configFactoryPM8000:ConfigurationFactoryBase = null;
		private var isImportXmlFromHome:Boolean = false;
        
		private var _providerType:Object;
		// store vg3r config icons
		public var vg3rConfigIcons:DictionaryExt = new DictionaryExt();
		public var lastImportedConfig:Configuration = null;
		public var keepSelectionBox:Boolean = false;
		public var viewPerspective:String = Constants.FRONT_VIEW_PERSPECTIVE;
        
        //selection component - allow selection
        public var selectionEnabled:Boolean = true;
        
        public var dispersionDisabled:Boolean = false;
        
        /**
         * Drag-Drop controller
         * <p>Currently used for VG3R engine port</p> 
         */        
        public var dragDropController:DragDropController = new DragDropController();
		
		public static const DP_TYPE_CONFIGURATIONS:int = 0;
		public static const DP_TYPE_SPS:int = 1;
		public static const DP_TYPE_PDP:int = 2;
		public static const DP_TYPE_ENGINE_PORT:int = 3;
        
		public static const TYPE_MAP:Object = {
			"SPS": DP_TYPE_SPS, 
			"PDP": DP_TYPE_PDP, 
			"PDU": DP_TYPE_PDP, 
			"EnginePort": DP_TYPE_ENGINE_PORT,
			"Bay": DP_TYPE_CONFIGURATIONS,
			"MIBE": DP_TYPE_CONFIGURATIONS,
			"Server": DP_TYPE_CONFIGURATIONS,
			"UPS": DP_TYPE_CONFIGURATIONS,
			"KVM": DP_TYPE_CONFIGURATIONS,
			"ControlStation": DP_TYPE_CONFIGURATIONS,
			"DataMover": DP_TYPE_CONFIGURATIONS,
			"DAE": DP_TYPE_CONFIGURATIONS,
			"Engine": DP_TYPE_CONFIGURATIONS,
			"Configuration": DP_TYPE_CONFIGURATIONS
		} 
		
		public function SymmController()
		{
		}
		
/*		public function get importedConfigurations():ImportedConfigurationFactory{
			return _importedConfigurations;
		}*/
		
		public function get configFactory():ConfigurationFactoryBase
		{
			return _configFactory;
		}
		
		public function get configFilter():ConfigurationFilter
		{
			return _configFilter;
		}
        
        
		public function get configFactory450F():ConfigurationFactoryBase
        {
            return _configFactory450f;
        }

		public function get configFactory950F():ConfigurationFactoryBase
        {
            return _configFactory950f;
        }

		public function get configFactory250F():ConfigurationFactoryBase
        {
            return _configFactory250f;
        }
		
		public function get configFactoryPM2000():ConfigurationFactoryBase
		{
			return _configFactoryPM2000;
		}
		public function get configFactoryPM8000():ConfigurationFactoryBase
		{
			return _configFactoryPM8000;
		}
		

		/**
		 * Is VMAX All Flash array
		 * @return 
		 * 
		 */		
		public function isAFA():Boolean
		{
			return is450F() || is950F() || is250F(); //need to remove pm2000
		}
		
		
		/**
		 * Is PowerMax array
		 * @return 
		 * 
		 */	
		public function isPM():Boolean
		{
			return isPM2000() || isPM8000();
		}
		
		/**
		 * initialize controller
		 * add event listeners...
		 */
		public function initialize():void
		{
			_configFactory450f = new sym.configurationmodel.v450f.ConfigurationFactory;
			_configFactory950f = new sym.configurationmodel.v950f.ConfigurationFactory;
			_configFactory250f = new sym.configurationmodel.v250f.ConfigurationFactory;
			_configFactoryPM2000 = new sym.configurationmodel.pm2000.ConfigurationFactory;			
			_configFactoryPM8000 = new sym.configurationmodel.pm8000.ConfigurationFactory;
			
			
			eventHandler.addEventListener(VMaxSelectionChangeRequestEvent.CHANGE_REQUEST, onVMAXChangeRequest);
			eventHandler.addEventListener(FilterChangeRequestEvent.CHANGE_REQUEST, onFilterChangeRequest);
			eventHandler.addEventListener(FilterChangeRequestEvent.REPLACE_REQUEST, onFilterChangeRequest);
			eventHandler.addEventListener(MouseEvent.CLICK, importFromHomeView);
			eventHandler.addEventListener(XmlImportedEvent.XML_FILES_IMPORTED, onFilesImported);
		}
		
		/**
		 * gets singleton instance of controller
		 */
		public static function get instance():SymmController
		{
			return _inst;
		}
		
		/**
		 * gets main event handler
		 */
		public function get eventHandler():EventDispatcher
		{
			return _eventHandler;
		}
		
		/**
		 * gets currently shown central object
		 */
		public function get currentComponent():ComponentBase
		{
			return _model.currentComponent;
		}
		
		/**
		 * gets previously selected configuration
		 */
		public function get previousConfiguration():ComponentBase
		{
			return _model.previousConfiguration;
		}
		
		/**
		 * gets data provider for selection list component
		 */
		public function get selectionDataProvider():ArrayCollection
		{
			return _model.selectionComponentDataProvider;
		}
		
		/**
		 * currently selected vmax config
		 */
		public function get vmaxConfiguration():String
		{
			return _model.vmaxConfiguration;
		}
		
		public function get configurations():ArrayCollection
		{
			return _configurations;
		}
		
		/**
		 * provider used for getting user friendly names of components for Selection component etc
		 */
		public function get componentNameProvider():IComponentNameProvider
		{
			return _componentNameProvider;
		}
		
		/**
		 * provider used for getting user friendly names of components for Selection component etc
		 */
		public function set componentNameProvider(provider:IComponentNameProvider):void
		{
			_componentNameProvider = provider;
		}
		
		public function get propertyTextProvider():IPropertyTextProvider{
			return _propertyTextProvider;	
		}
		
		public function set propertyTextProvider(provider:IPropertyTextProvider):void{
			_propertyTextProvider = provider;
		}
		
		
		/**
		 * handles component showing on central screen
		 * this also can be called from Navigation controller when user navigates trought breadcrumb
		 */
		public function showComponent(component:ComponentBase, forceRedraw:Boolean = false):void
		{
			if (component && (forceRedraw || (_model.currentComponent != component)))
			{
				if (component.isConfiguration)
				{
					_model.previousConfiguration = _model.currentConfiguration;
					_model.currentConfiguration = component;
				}
				_model.currentComponent = component;
				//whoever whants to listen this change just hook up event handler on SymmController.instance.eventHandler
				eventHandler.dispatchEvent(new ComponentSelectionChangedEvent(ComponentSelectionChangedEvent.COMPONENT_SELECTION_CHANGED, component));
				
				eventHandler.dispatchEvent(new ComponentSelectionChangedEvent(ComponentSelectionChangedEvent.BREADCRUMB_CHANGED, component));
			}
		}
		
		/**
		 * selection change in selection component
		 */
		public function selectComponent(component:ComponentBase):void{
			keepSelectionBox = true;
			if(component is SPS){
				_configFactory.setCurrentSPSType(component.type);   
			}
			else if(component is PDU){
				_configFactory.setCurrentPowerType(component.type);
			}
			else if(component is PortConfiguration){
				_configFactory.setCurrentPortConfiguration(component.type);   
			}
			else {
				showComponent(component);
				keepSelectionBox = false;
				
				return;
			}
			
			eventHandler.dispatchEvent(new RedrawEvent(RedrawEvent.REDRAW_EVENT));
		}
		
		//EVENT HANDLERS
		
		/**
		 * VMaxSelectionChangeRequestEvent handler
		 * loads vmax configuration and dispatches VMaxSelectionChangedEvent
		 */
		protected function onVMAXChangeRequest(event:VMaxSelectionChangeRequestEvent):void
		{
			switch (event.vmax)
			{
				case Constants.VMAX_450F:
					_configFactory = _configFactory450f;
					break;
				case Constants.VMAX_950F:
					_configFactory = _configFactory950f;
					break;
				case Constants.VMAX_250F:
					_configFactory = _configFactory250f;
					break;
				case Constants.PowerMax_2000:
					_configFactory = _configFactoryPM2000;
					break;
				case Constants.PowerMax_8000:
					_configFactory = _configFactoryPM8000;
					break;
			}
			
			// reset _selectionListBaseObject to null
			// to avoid enabling dragging for old K series
			if (_selectionListBaseObject)
				_selectionListBaseObject = null;
			
			_configFilter = new ConfigurationFilter();			
			
			this._model.vmaxConfiguration = event.vmax;			
			
			reloadConfiguration();
			
			this.eventHandler.dispatchEvent(new VMaxSelectionChangedEvent(VMaxSelectionChangedEvent.SELECTION_CHANGED, event.vmax));
		}
		
		/**
		 * Removes configuration from the configuration list
		 * @param configuration
		 * 
		 */		
		public function removeConfiguration(configuration:Configuration_VG3R):void
		{
			/* remove config from factory config list */
			if (_configFactory is ConfigurationFactoryBase_VG3R)
			{
				var configs:ArrayCollection = new ArrayCollection(_configFactory.getAllConfigurations());
				
				if (configs.contains(configuration))
				{
					configs.removeItemAt(configs.getItemIndex(configuration));
					
					var allDispersedConfigs:Boolean = true;
					if (_configurations.length == 1 && configs.length > 0)
					{
						// check if there are only dispersed configs
						// if so then select first dispersed by setting the filter dispersed value with that dispersed value
						// Otherwise, just reset filters to default values
						for each (var cfg:Configuration_VG3R in configs)
						{
							if (cfg.dispersed_m[0] == ConfigurationFilter.NO_DISPERSED_DEFAULT)
							{
								allDispersedConfigs = false;
								break;
							}
						}
						
						resetConfigurationFilter(true);
						
						if (allDispersedConfigs)
						{
							// set filter to match first config dispersed value
							_configFilter.dispersed_m = getMostComplexConfig(configs.toArray()).dispersed_m;	
						}
					}
					
					reloadConfiguration();
					
					this.eventHandler.dispatchEvent(new FilterChangedEvent(FilterChangedEvent.FILTER_CHANGED));
				}
			}
			
			if (_configurations.length == 0)
			{
				// open wizard popUp if config list is empty
				this.eventHandler.dispatchEvent(new FilterWizardEvent(FilterWizardEvent.FILTER_WIZARD_OPEN_REQUEST, null));
			}
		}
		
		private function importFromHomeView(event):void
		{
			isImportXmlFromHome = true;
		}
		
		/**
		 * XML files imported handler. </br>
		 * Generates all previosly saved configurations
		 * 
		 */		
		public function onFilesImported(ev:XmlImportedEvent):void
		{
			if (ev.importedXml || ev.importedXMLs.length > 0)
			{
				var isValid:Boolean = false;
				
				for each (var xmlFile:Object in ev.importedXMLs)
				{
					var myXML:XML = xmlFile["xml"];
					
					isValid = ComponentBase.validateXml(myXML);
					
					if(!isValid)
					{
                        //throw new Error("XML " + myXML.toString() + " has invalid data");
						trace("XML " + myXML.toString() + " has invalid data!\n");
						continue;
					}
					 
					var cfg:sym.objectmodel.common.Configuration = null;
					
					try
					{
						cfg = ComponentBase.deserializeFromXML(myXML, this.configFactory) as sym.objectmodel.common.Configuration;
					} 
					catch(error:Error)
					{
                        //throw new Error(error.message + " XML has invalid data");
						trace(error.message + " XML has invalid data!\n");
						continue;
					}
					
					_configFilter.daeType = cfg.daeType;
					_configFilter.daeCount = cfg.totalDaeNumber;
					_configFilter.noEngines = cfg.noEngines;
					_configFilter.noSystemBays = cfg.countSystemBay;
					_configFilter.driveType = cfg.driveType;
					_configFilter.noDrives = cfg.numberOfDrives;
					_configFilter.totCapacity = cfg.totCapacity;
					
					// filter xml array by selected VMAX series
					var series:String = myXML.child(Configuration_VG3R.MODEL_XML_NAME).toString();
					// set config file name
					(cfg as Configuration_VG3R).fileName = xmlFile["fileName"];
					
					if (cfg && series == this.vmaxConfiguration)
					{
						// add config to the list of all configurations for selected VMAX
						this.configFactory.appendConfiguration(cfg);
					}
				}
				//import for sizerXML
				if(ev.importedXml != null)
				{
					var myXML:XML = ev.importedXml;
					var cfg:sym.objectmodel.common.Configuration = null;
					var model:Number = ev.importedXml.config.model;
					var seriaName:String = ev.importedXml.config.make;
					var configFactory:ConfigurationFactoryBase;
					var seriaModel:String;
					
					if(isImportXmlFromHome == false)
					{
						switch(model)
						{
							case 250:
								_configFactory = _configFactory250f;
								seriaModel = seriaName + "-" + model.toString() + "F";
								break;
							case 950:
								_configFactory = _configFactory950f;
								seriaModel = seriaName + "-" + model.toString() + "F/FX";
								break;
							case 2000:
								_configFactory = _configFactoryPM2000;
								seriaModel = "PowerMax" + "-" + model.toString();
								break;
							case 8000:
								_configFactory = _configFactoryPM8000;
								seriaModel = "PowerMax" + "-" + model.toString();
								break;
						}
						
					}
					
					try
					{	
						if(isImportXmlFromHome == true)
						{
							cfg = ComponentBase.deserializeFromXML(myXML, this.configFactory) as sym.objectmodel.common.Configuration;
						}else
						{
							if(_model.vmaxConfiguration == seriaModel)
								cfg = ComponentBase.deserializeFromXML(myXML, this.configFactory) as sym.objectmodel.common.Configuration;
							else
							{
								//set to the previous configfactory
								switch(_model.vmaxConfiguration)
								{
									case "VMAX-250F":
										_configFactory = _configFactory250f;
										break;
									case "VMAX-950F/FX":
										_configFactory = _configFactory950f;
										break;
									case "PowerMax-2000":
										_configFactory = _configFactoryPM2000;
										break;
									case "PowerMax-8000":
										_configFactory = _configFactoryPM8000;
										break;
								}
								//throw error if wrong XML is choosen
								SymmController.instance.eventHandler.dispatchEvent(new XmlImportErrorEvent(XmlImportErrorEvent.XML_WRONG_ERROR));
								return;
							}
						}	
						
					} 
					catch(error:Error)
					{
						//throw new Error(error.message + " XML has invalid data");
						trace(error.message + " XML has invalid data!\n");
						SymmController.instance.eventHandler.dispatchEvent(new XmlImportErrorEvent(XmlImportErrorEvent.XML_IMPORT_ERROR));
						return;
					}
					
					_configFilter.daeType = cfg.daeType;
					_configFilter.daeCount = cfg.totalDaeNumber;
					_configFilter.noEngines = cfg.noEngines;
					_configFilter.noSystemBays = cfg.countSystemBay;
					_configFilter.driveType = cfg.driveType;
					_configFilter.noDrives = cfg.numberOfDrives;
					_configFilter.totCapacity = cfg.totCapacity;
					
					isImportXmlFromHome = false;
					this.configFactory.appendConfiguration(cfg);
				}
				// no need to filter configs if there is no imported xml configs for current factory
				if (this.configFactory.getAllConfigurations().length > 0)
				{	
					resetSelectionProvider();
					
					this.eventHandler.dispatchEvent(new FilterChangedEvent(FilterChangedEvent.FILTER_CHANGED));
				}
			}
		}
		
		/**
		 * reloads configurations when importing configuration from xml
		 */
		public function reloadImportedConfigurations(dispersed:int, daeType:int):void{
			_configFilter = new ConfigurationFilter();
			_configFilter.dispersed = dispersed;
			_configFilter.daeType = daeType;
			reloadConfiguration();
			
			this.eventHandler.dispatchEvent(new FilterChangedEvent(FilterChangedEvent.FILTER_CHANGED));
			this.eventHandler.dispatchEvent(new FilterChangedEvent(FilterChangedEvent.RELOAD_CONFIGS));
		}
		
		/**
		 * resets configuration filter to default values and loads all configuratons
		 * @param justCreateNew indicates creating new instance of Configuration Filter
		 * 		  and settting default DAE value for M-series
		 */
		public function resetConfigurationFilter(justCreateNew:Boolean = false):void
		{
			_configFilter = new ConfigurationFilter();
					
			if (!justCreateNew)
			{
				resetSelectionProvider();
	
				this.eventHandler.dispatchEvent(new FilterChangedEvent(FilterChangedEvent.FILTER_CHANGED));
				this.eventHandler.dispatchEvent(new FilterChangedEvent(FilterChangedEvent.RELOAD_CONFIGS));
			}
		}
		
		/**
		 * <p>Reset selection list provider. </p>
		 * <p>Generate non-dispersed configs for all Dispersed.
		 * On this way we have ensured that always non-dispersed configs will be displayed since default dispersion filter is - Adjacent (not-dispersed)</p>
		 */		
		public function resetSelectionProvider():void
		{
			// do this only for 450/850 AFA or 100/200/400K series, and if system config list is not empty
			if ((is450F() || is950F()) && this.configFactory.getAllConfigurations().length > 0)
			{
				var allConfigs:ArrayCollection = new ArrayCollection(_configFactory.getAllConfigurations());
				
				for each (var cfg:Configuration_VG3R in allConfigs)
				{
					if (cfg.dispersed_m[0] != ConfigurationFilter.NO_DISPERSED_DEFAULT)
					{
						(configFactory as ConfigurationFactoryBase_VG3R).createDispersionClone(cfg, _configFilter.dispersed_m);
					}
				}
			}
			
			reloadConfiguration();
		}
		
		/**
		 * reloads complete configuration
		 */
		private function reloadConfiguration():void
		{
			_configurations.removeAll();
			var collection: ArrayCollection;
			
			if(vmaxConfiguration == Constants.IMPORTED_CONFIGS)
			{
				collection = findImportedCollection();
			}
			else
			{
				collection = new ArrayCollection(_configFactory.filter(_configFilter));
			}
			
			if(isAFA() || isPM())
			{
				var sortField1:SortField = new SortField("noEngines", false, true);
				var sortField2:SortField = new SortField("totalDaeNumber", false, true);
				var sortField3:SortField = new SortField((isAFA() || isPM()) ? "countSystemBay" : "countStorageBay", false, true);
				if (isAFA() || isPM())
				{
					var sortField4:SortField = new SortField("activesAndSpares", false, true);
				}
					
				
				collection.sort = new Sort();
				
				collection.sort.fields = (isAFA() || isPM()) ? [sortField1, sortField2, sortField3, sortField4] : [sortField1, sortField2, sortField3];
				
				collection.refresh();
			}
			
			_configurations.addAll(collection);
			if (!_model.selectionComponentDataProvider)
			{
				_model.selectionComponentDataProvider = new ArrayCollection();
			}
			
			_model.selectionComponentDataProvider.removeAll();
			_model.selectionComponentDataProvider.addAll(_configurations);
			
			_model.previousConfiguration = _model.currentConfiguration;
			_model.currentConfiguration = null;
			_model.currentComponent = null;
		}
		
		/**
		 *  Find Imported configurations that meet the filtering requirements
		 * @return array of configurations 
		 * 
		 */		
		private function findImportedCollection():ArrayCollection
		{
			var configs:ArrayCollection = new ArrayCollection();
			if (_configFactory.filter(_configFilter).length == 0)
			{
				var daeTypeValues:ArrayCollection = new ArrayCollection();
				var dispersedValues:ArrayCollection = new ArrayCollection();
				var filterFound:Boolean = false; // flag to break out of nested for loops
				// when minimum filter values are found
				var sort:Sort = new Sort();
				sort.fields = [new SortField()];
				
				daeTypeValues.source = removeDuplicate(daeTypeValues.toArray());
				dispersedValues.source = removeDuplicate(dispersedValues.toArray());
				
				daeTypeValues.sort = sort;
				dispersedValues.sort = sort; 	
				
				daeTypeValues.refresh();
				dispersedValues.refresh();
				
				for (var i:int = 0; i < daeTypeValues.length && !filterFound; i++)
				{
					_configFilter.daeType = daeTypeValues[i];
					for (var j:int = 0; j < dispersedValues.length; j++)
					{
						_configFilter.dispersed = dispersedValues[j];
						if (_configFactory.filter(_configFilter).length > 0)
						{
							filterFound = true;
							break;
						}
					}
				}
			}
			configs.source = _configFactory.filter(_configFilter);
			
			return configs;
		}
		
		
		/**
		 * Removes duplicates from an array
		 * @param array
		 * 
		 */
		private function removeDuplicate(array:Array):Array
		{
			return array.filter(function(e:*, i:int, a:Array):Boolean
			{
				return a.indexOf(e) == i;
			});
		}
		
		/**
		 * Filter change request
		 */
		protected function onFilterChangeRequest(event:FilterChangeRequestEvent):void
		{
			if (event.type == FilterChangeRequestEvent.CHANGE_REQUEST)
			{   
				if((isAFA() || isPM()) && event.filterType == ConfigurationFilter.FILTER_DISPERSED_M)
				{
					_configFilter[event.filterType] = event.filterValue.length > 0 ? event.filterValue : ConfigurationFilter.NO_DISPERSED_DEFAULT_M;
					
                    (configFactory as ConfigurationFactoryBase_VG3R).createDispersionClone(this.currentComponent.parentConfiguration as Configuration_VG3R, _configFilter[event.filterType] as Array);
				}
				//new for drive type
				if (event.filterType == ConfigurationFilter.FILTER_DRIVE_TYPE)
				{
					_configFilter[event.filterType] = event.filterValue;
				}
				if (event.filterType == ConfigurationFilter.FILTER_DRIVES)
				{
					_configFilter[event.filterType] = event.filterValue;
				}
				if (event.filterType == ConfigurationFilter.FILTER_ENGINES)
				{
					_configFilter[event.filterType] = event.filterValue;
				}
				if (event.filterType == ConfigurationFilter.FILTER_SYSTEM_BAYS)
				{
					_configFilter[event.filterType] = event.filterValue;
				}
				
				if (event.filterIndex != 0)
				{ 
					if (event.filterType != ConfigurationFilter.FILTER_DISPERSED_M && event.filterType == ConfigurationFilter.FILTER_DAE_TYPE)
						_configFilter[event.filterType] = event.filterValue;
					
					if(event.filterType == ConfigurationFilter.FILTER_ENGINES && (_configFilter.noEngines == 1 || _configFilter.noEngines == 2)){
						_configFilter[ConfigurationFilter.FILTER_DISPERSED] = ConfigurationFilter.NO_DISPERSED_DEFAULT;
					}
					if (event.filterType == ConfigurationFilter.FILTER_ENGINES && _configFilter.noStorageBays != ConfigurationFilter.NO_STORAGE_BAYS_DEFAULT)
					{
						var sbdp:ArrayCollection = FilterController.instance.generateAllFilterValues(ConfigurationFilter.FILTER_STORAGE_BAYS);
						FilterController.instance.filterDataProvider(event.filterType, sbdp);
						
						if (sbdp.getItemIndex(configFilter[event.filterType]) == -1 ||
							sbdp.getItemIndex(configFilter[event.filterType]) == 0)
						{
							_configFilter[ConfigurationFilter.FILTER_STORAGE_BAYS] = ConfigurationFilter.NO_STORAGE_BAYS_DEFAULT;
						}
					}
					//new for drive type
					if(event.filterType == ConfigurationFilter.FILTER_DRIVE_TYPE && _configFilter.driveType != ConfigurationFilter.DRIVE_TYPE_DEFAULT)
					{
						var driveType:ArrayCollection = FilterController.instance.generateAllFilterValues(ConfigurationFilter.FILTER_DRIVE_TYPE);
						FilterController.instance.filterDataProvider(event.filterType, driveType);
						
					}
					//number of drives
					if(event.filterType == ConfigurationFilter.FILTER_DRIVES && _configFilter.noDrives != ConfigurationFilter.NO_DRIVES_DEFAULT)
					{
						var numberOfDrives:ArrayCollection = FilterController.instance.generateAllFilterValues(ConfigurationFilter.FILTER_DRIVES);
						FilterController.instance.filterDataProvider(event.filterType, numberOfDrives);
						
						if (numberOfDrives.getItemIndex(configFilter[event.filterType]) == -1 ||
							numberOfDrives.getItemIndex(configFilter[event.filterType]) == 0)
						{
							_configFilter[ConfigurationFilter.FILTER_DRIVES] = ConfigurationFilter.NO_DRIVES_DEFAULT;
						}
						
					}
				}
				else
				{
					if (event.filterType == ConfigurationFilter.FILTER_ENGINES)
					{
						_configFilter[event.filterType] = ConfigurationFilter.NO_ENGINE_DEFAULT;
					}
					//new filter drive 
					if (event.filterType == ConfigurationFilter.FILTER_DRIVE_TYPE)
					{
						_configFilter[event.filterType] = ConfigurationFilter.DRIVE_TYPE_DEFAULT;
					}
					//numberOfDrives
					if (event.filterType == ConfigurationFilter.FILTER_DRIVES)
					{
						_configFilter[event.filterType] = ConfigurationFilter.NO_DRIVES_DEFAULT;
					}
					if (event.filterType == ConfigurationFilter.FILTER_STORAGE_BAYS)
					{
						_configFilter[event.filterType] = ConfigurationFilter.NO_STORAGE_BAYS_DEFAULT;
					}
					if (event.filterType == ConfigurationFilter.FILTER_SYSTEM_BAYS)
					{
						_configFilter[event.filterType] = ConfigurationFilter.NO_SYSTEM_BAYS_DEFAULT;
					}
					if (event.filterType == ConfigurationFilter.FILTER_DISPERSED)
					{
						_configFilter[event.filterType] = event.filterValue > 0 ? event.filterValue : ConfigurationFilter.NO_DISPERSED_DEFAULT;
					}
					if (event.filterType == ConfigurationFilter.FILTER_DAE_COUNT)
					{
						_configFilter[event.filterType] = ConfigurationFilter.NO_DAE_COUNT_DEFAULT;
					}
				} 
			} 
			else if (event.type == FilterChangeRequestEvent.REPLACE_REQUEST) 
			{
				_configFilter = event.filterValue as ConfigurationFilter;
			}
			
			reloadConfiguration();
			
			this.eventHandler.dispatchEvent(new FilterChangedEvent(FilterChangedEvent.FILTER_CHANGED));
		}
		
		/**
		 * Reloads selection list component items
		 * @param event holds component currently selected
		 */
		public function reloadSelectionComponent(component:ComponentBase):void
		{
			//if selection list component is filtered by same object type than there is no need to change selection data provider
			if (_selectionListBaseObject)
			{
				if((component is PDP) && _providerType == TYPE_MAP["PDP"]){
					return;
				}
				else if((component is PDU) && _providerType == TYPE_MAP["PDU"]){
					return;
				}
				else if((component is SPS) && _providerType == TYPE_MAP["SPS"]){
					return;
				}
				else if((component is MIBE) && _providerType == TYPE_MAP["MIBE"]){
					return;
				}
				else if((component is Server) && _providerType == TYPE_MAP["Server"]){
					return;
				}
				else if((component is UPS) && _providerType == TYPE_MAP["UPS"]){
					return;
				}
				else if((component is KVM) && _providerType == TYPE_MAP["KVM"]){
					return;
				}
				else if((component is DataMover) && _providerType == TYPE_MAP["DataMover"]){
					return;
				}
				else if((component is ControlStation) && _providerType == TYPE_MAP["ControlStation"]){
					return;
				}
                else if(component.isEngine && (isAFA() || isPM()) && _providerType == DP_TYPE_ENGINE_PORT && viewPerspective == Constants.REAR_VIEW_PERSPECTIVE)
                    return;
				else if((component.isEngine) && _providerType == TYPE_MAP["Engine"] && viewPerspective == Constants.FRONT_VIEW_PERSPECTIVE){
					return;
				}
				else if((component is EnginePort) && _providerType == TYPE_MAP["EnginePort"]){
					return;
				}
				else if((component is DAE) && _providerType == TYPE_MAP["DAE"]){
					return;
				}
				else if((component.isBay) && _providerType == TYPE_MAP["Bay"]){
					return;
				}
				else if((component.isConfiguration) && _providerType == TYPE_MAP["Configuration"]){
					return;
				}
			}
            
			_model.selectionComponentDataProvider.removeAll();
			
			var dataProviderType:String = "";
			
            if (currentComponent is Engine && component.isEngine && (isAFA() || isPM()) && viewPerspective == Constants.REAR_VIEW_PERSPECTIVE)
            {
                dataProviderType = Constants.ENGINE_PORT_TYPE;
				
				_model.selectionComponentDataProvider.addAll((component as Engine).getPortsSelectionDP());
				
                _providerType = DP_TYPE_ENGINE_PORT;
            }
/*            else if (((currentComponent.isEngine || component.isEngine) && viewPerspective == Constants.REAR_VIEW_PERSPECTIVE && !isAFA()) || component is EnginePort)
			{ 
				dataProviderType = Constants.PORT_CONFIGURATION_TYPE;
				var portConfigs:ArrayCollection =_configFactory.getAllowedPortConfigurations();
				for (var i:int = 0; i < portConfigs.length; i++)
				{
					if (portConfigs[i] != null)
						_model.selectionComponentDataProvider.addItem(portConfigs[i]);
				}
				_providerType = DP_TYPE_ENGINE_PORT;
			}*/
			else if (component is PDP || component is PDU)
			{
				dataProviderType = Constants.PDP_TYPE;
				
				_model.selectionComponentDataProvider.addItem(new PDU(null, PDU.TYPE1PHASE));
			
				_providerType = DP_TYPE_PDP;
			}
			else if (component is SPS)
			{ 
				dataProviderType = Constants.SPS_TYPE;
 
				_model.selectionComponentDataProvider.addItem(new SPS(null, SPS.TYPE_LION)); 

                _providerType = DP_TYPE_SPS;
			}
			else
			{
				dataProviderType = Constants.CONFIGURATION_TYPE;
				_model.selectionComponentDataProvider.addAll(_configurations);
				_providerType = DP_TYPE_CONFIGURATIONS;
			}
			
			_selectionListBaseObject = component;
            
            selectionEnabled = !(component.isEngine && (isAFA() || isPM()) && currentComponent is Engine && this.viewPerspective == Constants.REAR_VIEW_PERSPECTIVE); //disable selection for vg3r engine ports
            
			dragDropController.dragEnabled = (component.isEngine && (isAFA() || isPM()) && currentComponent is Engine && 
				this.viewPerspective == Constants.REAR_VIEW_PERSPECTIVE) || (_providerType == DP_TYPE_CONFIGURATIONS && (isAFA() || isPM()));
			
			SymmController.instance.eventHandler.dispatchEvent(new SelectionComponentDataChangedEvent(SelectionComponentDataChangedEvent.DATA_SOURCE_CHANGED, _model.selectionComponentDataProvider, dataProviderType));
		}
		
		public function getCurrentSelectedIndex(dpType:String):int
		{
			switch(dpType)
			{
				case Constants.CONFIGURATION_TYPE:
				{
					return _model.selectionComponentDataProvider.getItemIndex(_model.currentConfiguration);
					break;
				}
				case Constants.PDP_TYPE:
				{
					for each(var object:Object in _model.selectionComponentDataProvider)
					{
						if((object as PDU).type == _configFactory.getCurrentPowerType()){
							return _model.selectionComponentDataProvider.getItemIndex(object);
							break;
						}
					}
				}	
				case Constants.SPS_TYPE:
				{
					for each(var obj:Object in _model.selectionComponentDataProvider)
					{
						if((obj as SPS).type == _configFactory.getCurrentSPSType()){
							return _model.selectionComponentDataProvider.getItemIndex(obj);
							break;
						}
					}
				}	
				case Constants.PORT_CONFIGURATION_TYPE:
				{
                    if(isAFA() || isPM())
                    {
                        return -1;  //for AFA Family engine port selection is disabled, it will be supported by drag-drop functionality
                    }
                    else
                    {
					    return _model.selectionComponentDataProvider.getItemIndex(_configFactory.getCurrentPortConfiguration());
                    }
					break;
				}	
			}
			return -1;			
		}
		
		/**
		 * gets most complex configuration for the given array
		 */
		public function getMostComplexConfig(configs:Array):sym.objectmodel.common.Configuration{
			if(!configs || configs.length == 0){
				return null;
			}
			
			var complex:sym.objectmodel.common.Configuration = configs[0];
				
			for each(var config:sym.objectmodel.common.Configuration in configs){
				if(	config.noViking >= complex.noViking &&
					config.totalDaeNumber >= complex.totalDaeNumber &&
					config.noEngines >= complex.noEngines){
					complex = config;
				}
			}
			return complex;
		}
	}
}
