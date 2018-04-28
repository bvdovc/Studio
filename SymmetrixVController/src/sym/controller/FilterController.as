package sym.controller
{
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.utils.Dictionary;
    
    import mx.collections.ArrayCollection;
    import mx.managers.ISystemManagerChildManager;
    import mx.resources.ResourceManager;
    
    import spark.components.List;
    
    import sym.configurationmodel.common.ConfigurationFactoryBase;
    import sym.configurationmodel.common.ConfigurationFactoryBase_VG3R;
    import sym.configurationmodel.common.ConfigurationFilter;
    import sym.configurationmodel.pm2000.ConfigurationFactory;
    import sym.configurationmodel.pm8000.ConfigurationFactory;
    import sym.configurationmodel.utils.AllFlashArrayUtility;
    import sym.configurationmodel.utils.TieringUtility_VG3R;
    import sym.controller.events.FilterWizardEvent;
    import sym.controller.events.FilterWizardLabelStepItemEvent;
    import sym.controller.model.FilterWizardPortsStateModel;
    import sym.controller.model.FilterWizardStateModel;
    import sym.controller.model.FilterWizardTierStateModel;
    import sym.objectmodel.common.ComponentBase;
    import sym.objectmodel.common.Configuration_VG3R;
    import sym.objectmodel.common.Constants;
    import sym.objectmodel.common.DAE;
    import sym.objectmodel.common.DriveGroup;
    import sym.objectmodel.common.Engine;
    import sym.objectmodel.common.EnginePort;
    import sym.objectmodel.common.EnginePortGroup;
    import sym.objectmodel.driveUtils.DriveDef;
    import sym.objectmodel.driveUtils.DriveRegister;
    import sym.objectmodel.driveUtils.enum.DriveRaidLevel;
    import sym.objectmodel.driveUtils.enum.DriveType;
    import sym.objectmodel.driveUtils.enum.HostType;

    /**
     * FilterController
     * <p> Controller for filter wizard states </p>
     */
    [Bindable]
    public class FilterController extends EventDispatcher
    {

        private static const _instance:FilterController = new FilterController();
        //filter states
        public static const STATE_ENGINES:String = "STATE_ENGINES";
        public static const STATE_STGBAYS:String = "STATE_STGBAYS";
        public static const STATE_SYSBAYS_TYPE:String = "STATE_SYSBAYS_TYPE";
        public static const STATE_DISPERSED:String = "STATE_DISPERSED";
        public static const STATE_DISPERSED_VG3R:String = "STATE_DISPERSED_VG3R";
        public static const STATE_DAE:String = "STATE_DAE";
        public static const STATE_DAE_COUNT:String = "STATE_DAE_COUNT";
		public static const STATE_VNX:String = "STATE_VNX";
		public static const STATE_USABLE_CAPACITY:String = "STATE_USABLE_CAPACITY";
		public static const STATE_TIER:String = "STATE_TIER";	
		public static const STATE_ENGINE_PORTS:String = "STATE_ENGINE_PORTS";		
        public static const STATE_SUMMARY:String = "STATE_SUMMARY";
		public static const STATE_DRIVE_TYPE:String = "STATE_DRIVE_TYPE";
		public static const STATE_DRIVE_TYPE_PM:String = "STATE_DRIVE_TYPE_PM";
		public static const STATE_FILTER_DRIVES_TYPE:String = "STATE_FILTER_DRIVES_TYPE";

        // step buttons
        public static const STEP_PREVIOUS:int = -1;
        public static const STEP_NEXT:int = 1;
        
        public static const STATE_FACTORY_GETTER_MAP:Object = {
                STATE_ENGINES: ConfigurationFilter.FILTER_ENGINES, 
                STATE_STGBAYS: ConfigurationFilter.FILTER_STORAGE_BAYS, 
				STATE_SYSBAYS_TYPE: ConfigurationFilter.FILTER_SYSBAYS_TYPE, 
                STATE_DAE: ConfigurationFilter.FILTER_DAE_TYPE, 
                STATE_DAE_COUNT: ConfigurationFilter.FILTER_DAE_COUNT, 
				STATE_VNX: ConfigurationFilter.FILTER_DATA_MOVERS,
                STATE_DISPERSED: ConfigurationFilter.FILTER_DISPERSED,
                STATE_USABLE_CAPACITY: ConfigurationFilter.FILTER_USABLE_CAPACITY,
                STATE_TIER: ConfigurationFilter.FILTER_TIERING,
				STATE_ENGINE_PORTS: ConfigurationFilter.FILTER_HOST_TYPE,
				STATE_DRIVE_TYPE: ConfigurationFilter.FILTER_DRIVE_TYPE,
				STATE_DRIVE_TYPE_PM: ConfigurationFilter.FILTER_DRIVE_TYPE,
				STATE_FILTER_DRIVES_TYPE: ConfigurationFilter.FILTER_DRIVES
		};
			
        public static function get STATE_DP_ROOT_ITEM_MAP():Object {
			return {	
                	STATE_ENGINES: ConfigurationFilter.NO_ENGINE_DEFAULT, 
                	STATE_STGBAYS: ConfigurationFilter.NO_STORAGE_BAYS_DEFAULT, 
					STATE_SYSTEM_BAYS: ConfigurationFilter.NO_SYSTEM_BAYS_DEFAULT, 
                	STATE_DISPERSED: ConfigurationFilter.NO_DISPERSED_DEFAULT,
                	STATE_DAE_COUNT: ConfigurationFilter.NO_DAE_COUNT_DEFAULT
				   };
	    }
             
/*        private static const daeCountValuesPerDaeType:Object = {1: sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_D15_VALUES, 
            2: sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_VANGUARD_VALUES, 
            3: [sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_MIXED_VALUES_NO_DISPERSION, 
                sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_MIXED_VALUES_DISPERSION]};*/
/*        public static const engineLimitsPerDaeType:Object = {1: [sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_D15_ENGINE_ANY, 
            sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_D15_ENGINE_1, 
            sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_D15_ENGINE_2, 
            sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_D15_ENGINE_3, 
            sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_D15_ENGINE_4], 
            2: [sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_VANGUARD_ENGINE_ANY, 
                sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_VANGUARD_ENGINE_1, 
                sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_VANGUARD_ENGINE_2, 
                sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_VANGUARD_ENGINE_3, 
                sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_VANGUARD_ENGINE_4], 
            3: [null, sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_MIXED_ENGINE_1, 
                sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_MIXED_ENGINE_2, 
                sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_MIXED_ENGINE_3_NO_DISPERSED, 
                sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_MIXED_ENGINE_4_NO_DISPERSED, 
                sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_MIXED_ENGINE_3_DISPERSED, 
                sym.configurationmodel.v10ke.Configuration10kFactoryBase.DAE_COUNT_MIXED_ENGINE_4_DISPERSED]};*/
		
        public var mixedConfigsOnly:Boolean = false;
        
        private var _states:Array;
        private var _currentState:int = 0;
        private var _wizardSteps:Dictionary = new Dictionary();
		

        public function FilterController(target:IEventDispatcher = null)
        {
            super(target);
        }

        /**
         * Gets singleton instance of NavigationContoller
         */
        public static function get instance():FilterController
        {
            return _instance;
        }


        public function get currentState():int
        {
            return _currentState;
        }

        public function set currentState(value:int):void
        {
            _currentState = value;
        }

        public function get currentStateString():String
        {
            return states[_currentState];
        }

        public function get wizardSteps():Dictionary
        {
            return _wizardSteps;
        }

        public function set wizardSteps(dictionary:Dictionary):void
        {
            _wizardSteps = dictionary;
        }

        public function get states():Array
        {
            return _states;
        }

        private function set states(array:Array):void
        {
            _states = array;
        }

        /**
         * sets wizardPopUp first state
         */
        public function initialize():void
        {
			var wizardStateModel:FilterWizardStateModel;
            currentState = 0;

			if (_wizardSteps)
            {
                _wizardSteps = null;
                _wizardSteps = new Dictionary();
            }
			
			switch(SymmController.instance.vmaxConfiguration)
            {
				case Constants.IMPORTED_CONFIGS:
					states = [STATE_ENGINES, STATE_STGBAYS, STATE_DAE, STATE_DISPERSED, STATE_SUMMARY];
					
					resetImportedConfigs();
					break;
				case Constants.VMAX_450F:
				case Constants.VMAX_950F:
					states = [STATE_USABLE_CAPACITY, STATE_ENGINES, STATE_DRIVE_TYPE, STATE_ENGINE_PORTS, STATE_DISPERSED, STATE_SUMMARY];
					
					resetAFAmodels();
					break;
				
				case Constants.VMAX_250F:
				case Constants.PowerMax_2000:
					states = [STATE_USABLE_CAPACITY, STATE_ENGINES,STATE_DRIVE_TYPE, STATE_ENGINE_PORTS, STATE_SUMMARY];
					
					resetPMmodels();
					break;
				case Constants.PowerMax_8000:
					states = [STATE_USABLE_CAPACITY, STATE_ENGINES, STATE_DRIVE_TYPE, STATE_ENGINE_PORTS, STATE_DISPERSED, STATE_SUMMARY];
					
					resetPMmodels();
					break;
            }

			if (_wizardSteps[currentState])
			{
				wizardStateModel = _wizardSteps[currentState];
			}
			else
			{
				wizardStateModel = SymmController.instance.isAFA() || SymmController.instance.isPM() ? getStateModel(STATE_USABLE_CAPACITY) : getStateModel(STATE_ENGINES);
			}
			
            FilterController.instance.dispatchEvent(new FilterWizardEvent(FilterWizardEvent.FILTER_WIZARD_STATE_CHANGED, wizardStateModel));
        }

        /**
         * navigates the given to step
         * @param step directly navigate to step in wizard
         */
        public function step(step:int):void
        {  
            FilterController.instance.currentState = step; 
            
            var wizardStateModel:FilterWizardStateModel = _wizardSteps[FilterController.instance.currentState];

            if (wizardStateModel == null && states[FilterController.instance.currentState] != STATE_SUMMARY)
            {
                wizardStateModel = getStateModel(FilterController.instance.currentStateString);
            }
            if (states[FilterController.instance.currentState] == STATE_SUMMARY)
            {
                wizardStateModel = null;
            }

            FilterController.instance.dispatchEvent(new FilterWizardEvent(FilterWizardEvent.FILTER_WIZARD_STATE_CHANGED, wizardStateModel));

            FilterController.instance.dispatchEvent(new FilterWizardLabelStepItemEvent(FilterWizardLabelStepItemEvent.WIZARD_LABEL_STATE_ITEM_CHANGED, FilterController.instance.currentState));
        }

        /**
         * adds new model to FilterWizardStateModel Dictionary with <b>state</b> key
         * @param state (not Summary) step in wizard, key for model in Dictionary
         * @return new generated state model
         *
         */
        public function getStateModel(stateName:String, resetModel:Boolean = false):FilterWizardStateModel
        {
			var state:int = getStateIndex(stateName);
			if(resetModel)
				_wizardSteps[state] = null;
			
			if (_wizardSteps[state] != null)
			{
				return _wizardSteps[state];
			}
			
	        var model:FilterWizardStateModel = new FilterWizardStateModel();

            if (isImported() || SymmController.instance.isAFA() || SymmController.instance.isPM())
            {
				var configFactory:ConfigurationFactoryBase = SymmController.instance.configFactory;
				model.dataProvider = generateAllFilterValues(STATE_FACTORY_GETTER_MAP[states[state]]);
				
				if (stateName == STATE_TIER)
				{
					// Drive Mix step
					model = new FilterWizardTierStateModel();
					
					model.dataProvider = generateAllFilterValues(ConfigurationFilter.FILTER_TIERING);
					model.selectedItem = model.dataProvider.getItemAt(0);
				}
				else if (stateName == STATE_USABLE_CAPACITY)
				{
					// Usable Capacity step
					model = new FilterWizardTierStateModel();
					if(!is250F() && !isPM2000() && !isPM8000()){
						// RAID data source
						model.dataProvider = new ArrayCollection(AllFlashArrayUtility.supportedRAIDs);
						// RAID 5(7+1) is default
						model.selectedItem = model.dataProvider.getItemAt(0);
					}
					else if(is250F())
					{
						//RAID data source for 250F
						model.dataProvider = new ArrayCollection(AllFlashArrayUtility.supportedRAIDs_250F);
						//RAID 5(7+1) is default
						model.selectedItem = model.dataProvider.getItemAt(0);
					}
					else if(SymmController.instance.isPM())
					{
						//raid data source for powermax 8000 and powermax 2000
						model.dataProvider = new ArrayCollection(AllFlashArrayUtility.supportedRAIDs_PM);
									
						model.selectedItem = model.dataProvider.getItemAt(0);
					}
				}
				else if ((SymmController.instance.isAFA() || isPM8000()) && stateName == STATE_DISPERSED)
				{
					// filters data provider depending of system bay model selection 
					var engineStateModel:FilterWizardStateModel = FilterController.instance.getStateModel(STATE_ENGINES);
                    var tsModel:FilterWizardTierStateModel = this.getStateModel(STATE_USABLE_CAPACITY) as FilterWizardTierStateModel;
                    var maxSystemBays:int = 0;
                    
                    if(tsModel && tsModel.totUsableCapacity > 0)
					{
						if (SymmController.instance.isAFA())
						{
	                        maxSystemBays = int(int(engineStateModel.selectedItem) / ConfigurationFilter.DUAL_ENGINE_BAY) + int(engineStateModel.selectedItem) % ConfigurationFilter.DUAL_ENGINE_BAY;
						}
						
						else if(isPM8000())
						{
							maxSystemBays = 2; // PowerMax 8000 can only have 2 system bays at max
						}

						if (model.dataProvider.length > maxSystemBays)
						{
							model.dataProvider.source.splice(maxSystemBays, model.dataProvider.length - maxSystemBays);
						}
                    
					}
					model.selectedItem = resetModel ? ConfigurationFilter.DISPERSEDNON_M : SymmController.instance.configFilter[ConfigurationFilter.FILTER_DISPERSED_M];
					
				}
			
				else if (stateName == STATE_ENGINE_PORTS)
				{
					// Engine Port Configuration step
					model = new FilterWizardPortsStateModel();
					
					
					var capacityModel:FilterWizardTierStateModel = FilterController.instance.getStateModel(STATE_USABLE_CAPACITY) as FilterWizardTierStateModel;
					
					// used for determining engine count
					var selectedEngineCount:int = int(FilterController.instance.getStateModel(STATE_ENGINES).selectedItem);
					
					// OS/MF/mixed host type selected
					model.selectedItem = capacityModel.selectedOScapacity > 0 && capacityModel.selectedMFcapacity > 0 ? HostType.Mixed.name : 
						capacityModel.selectedMFcapacity > 0 ? HostType.Mainframe.name : HostType.OpenSystems.name;
					
					if (capacityModel.selectedItem == TieringUtility_VG3R.TIER_CUSTOM_CONFIG)
						model.selectedItem = HostType.OPEN_SYSTEMS;

					// data provider for engine ports grid
					model.dataProvider = new ArrayCollection(Engine.initPortGroupMap(selectedEngineCount, is250F())[model.selectedItem]);

					if (SymmController.instance.isAFA() || SymmController.instance.isPM())
					{
						(model as FilterWizardPortsStateModel).selectedProtocol = FilterWizardPortsStateModel.DEFAULT_HOST_PROTOCOL[model.selectedItem];
						
						// filter provider if needed based on selected protocol
						var tempDP:Array = model.dataProvider.toArray();
						for each (var epg:EnginePortGroup in tempDP)
						{
							if ((model as FilterWizardPortsStateModel).selectedProtocol == FilterWizardPortsStateModel.FC_PROTOCOL)
							{
								// remove iSCSI - OS/Mixed selected
								// remove FICON - Mixed selected
								
								if (epg.port.isFCOE_ISCSI || epg.port.isMainframe)
									{
										model.dataProvider.removeItemAt(model.dataProvider.getItemIndex(epg));
										continue;
									}
								
							}
							if(epg.hostType == HostType.Mixed.name && epg.port.isFCOE_ISCSI)
							{
								model.dataProvider.removeItemAt(model.dataProvider.getItemIndex(epg));
								continue;
							}
						}
					}
				}
				else if (stateName == STATE_DRIVE_TYPE)
				{
					// Drive Type state - for 250F and 950F AFA
					var capModel:FilterWizardTierStateModel = FilterController.instance.getStateModel(STATE_USABLE_CAPACITY) as FilterWizardTierStateModel;
					var brickModel:FilterWizardStateModel = FilterController.instance.getStateModel(STATE_ENGINES); 
					if(is250F() || isPM2000())
					{
						if(is250F())
						{
							model.dataProvider = (configFactory as ConfigurationFactoryBase_VG3R).validateSupportedDriveTypes(capModel.totUsableCapacity, AllFlashArrayUtility.systemDriveRAID, int(brickModel.selectedItem));
						}
						else
						{
							model.dataProvider = (configFactory as sym.configurationmodel.pm2000.ConfigurationFactory).validateSupportedDriveTypes(capModel.totUsableCapacity, AllFlashArrayUtility.systemDriveRAID, int(brickModel.selectedItem));

						}
						model.selectedItem = model.dataProvider.getItemAt(0);
					}
					else
					{
						var hostType:String = capModel.selectedMFcapacity > 0 ? HostType.MAINFRAME_HOST : HostType.OPEN_SYSTEMS;
						if(is950F())
							model.dataProvider = (configFactory as ConfigurationFactoryBase_VG3R).validateSupportedDriveTypesFor950F(capModel.totUsableCapacity, AllFlashArrayUtility.systemDriveRAID, int(brickModel.selectedItem), hostType);
						else
							model.dataProvider = (configFactory as sym.configurationmodel.pm8000.ConfigurationFactory).validateSupportedDriveTypes(capModel.totUsableCapacity, AllFlashArrayUtility.systemDriveRAID, int(brickModel.selectedItem));
						model.selectedItem = model.dataProvider.getItemAt(0);
					}
				}
				else if ((SymmController.instance.isAFA() || SymmController.instance.isPM()) && stateName == STATE_ENGINES)
				{
					var capacityStateModel:FilterWizardTierStateModel = this.getStateModel(FilterController.STATE_USABLE_CAPACITY) as FilterWizardTierStateModel;
					var hostType:String = capacityStateModel.selectedMFcapacity > 0 ? HostType.MAINFRAME_HOST : HostType.OPEN_SYSTEMS;
					
					if (capacityStateModel.totUsableCapacity > 0 && AllFlashArrayUtility.systemDriveRAID)
					{
						if(!is250F() && !isPM2000()){
							if(is950F())
							{
								var dG:DriveGroup = AllFlashArrayUtility.calculateActiveDrives(capacityStateModel.totUsableCapacity, hostType);
								var dualEngVal:ArrayCollection = (SymmController.instance.configFactory as ConfigurationFactoryBase_VG3R).getSupportedEngines(
									[AllFlashArrayUtility.calculateActiveDrives(capacityStateModel.totUsableCapacity, hostType)], 
									ConfigurationFilter.DUAL_ENGINE_BAY);
								var maxVBricks:int;
								
								if(capacityStateModel.totUsableCapacity < AllFlashArrayUtility.BASE_CONFIG_V_BRICK_CAPACITY)
								{
									if(capacityStateModel.totUsableCapacity >= AllFlashArrayUtility.FLASH_BLOCK_CAPACITY_26TB)
										maxVBricks = capacityStateModel.totUsableCapacity / AllFlashArrayUtility.FLASH_BLOCK_CAPACITY_26TB;
									else
										maxVBricks = capacityStateModel.totUsableCapacity / AllFlashArrayUtility.FLASH_BLOCK_CAPACITY_13TB;
								}
								else
								{
									maxVBricks = capacityStateModel.totUsableCapacity / AllFlashArrayUtility.BASE_CONFIG_V_BRICK_CAPACITY;
								}
								
								if (dualEngVal.length > maxVBricks)
								{
									dualEngVal.source.splice(maxVBricks, dualEngVal.length - maxVBricks);
								}
								
								//model.dataProvider = dualEngVal;
								
								// V-Bricks for 950F
								var j:int = 1;
								if(maxVBricks > 8)
								{
									maxVBricks = 8;
								}
								if(capacityStateModel.totUsableCapacity > 3000)
									j = 2;
								model.dataProvider.removeAll();
								for(var i:int = j; i<=maxVBricks; i++)
								{	
									model.dataProvider.addItem(i);
								}	
							}
							else //for PM8000
							{
								model.dataProvider.removeAll();
								
								var capacityPacks:Array;  //used for determination of max number of PowerBricks
								var maxNumberOfCapacityPacks:Number = 4;
								if(capacityStateModel.selectedItem == DriveRaidLevel.R57_Nebula)
									capacityPacks = ([13.2, 26.4, 52.6]);
								else if(capacityStateModel.selectedItem == DriveRaidLevel.R53_Nebula)
								{
									maxNumberOfCapacityPacks = 8;
									capacityPacks = ([5.6, 11.3, 22.6]);
								}
								else 
									capacityPacks = ([11.3, 22.6, 45.1]);
																
								var actualNumberOfPacks:Number;
								
								for(var i:int = 1; i <= 8; i++)
								{
									for(var z:int = 2; z >= 0;z--)
									{
									    actualNumberOfPacks = capacityStateModel.totUsableCapacity / capacityPacks[z];
										if(actualNumberOfPacks % 1 != 0)
											actualNumberOfPacks = actualNumberOfPacks - (actualNumberOfPacks % 1) + 1;
										if(actualNumberOfPacks >= i && actualNumberOfPacks <= maxNumberOfCapacityPacks)
										{
											if(model.dataProvider.length == 0)
												model.dataProvider.addItem(i);
											else if(model.dataProvider[model.dataProvider.length-1] != i)
												model.dataProvider.addItem(i);
										}
									}
									if(capacityStateModel.selectedItem == DriveRaidLevel.R53_Nebula)
										maxNumberOfCapacityPacks += 8;
									else
										maxNumberOfCapacityPacks += 4;
								}
								
							}
						}
						else if(is250F())
						{
							model.dataProvider.removeItemAt(0);
							
							if((capacityStateModel.selectedItem == DriveRaidLevel.R66 && capacityStateModel.totUsableCapacity == AllFlashArrayUtility.FLASH_CAPACITY_PACK_11TB) ||
								(capacityStateModel.selectedItem == DriveRaidLevel.R57_forTabasco && capacityStateModel.totUsableCapacity == AllFlashArrayUtility.FLASH_CAPACITY_PACK_13TB) ||
								(capacityStateModel.selectedItem == DriveRaidLevel.R53 && capacityStateModel.totUsableCapacity == AllFlashArrayUtility.FLASH_CAPACITY_PACK_11TB))
							{
								model.dataProvider.removeItemAt(1);
							}
								// if capacity is larger then 541.5 TB then only option is 2 V-Bricks
							if(capacityStateModel.totUsableCapacity > AllFlashArrayUtility.BASE_250F_CONFIG_MAXIMUM_CAPACITY / 2)
							{
								model.dataProvider.removeItemAt(0);
							}	
							
						} else //for PM2000
						{
							var maxCapacityPerEngineForPM2000:Number;	
							
							model.dataProvider.removeItemAt(0);
														
							if(capacityStateModel.selectedItem == DriveRaidLevel.R57_Nebula)
								maxCapacityPerEngineForPM2000 = AllFlashArrayUtility.BASE_PM2000_CONFIG_MAXIMUM_CAPACITY / 2;
							else if(capacityStateModel.selectedItem == DriveRaidLevel.R53_Nebula)
								maxCapacityPerEngineForPM2000 = AllFlashArrayUtility.BASE_PM2000_CONFIG_MAXIMUM_CAPACITY_FOR_RAID53 / 2;
							else if(capacityStateModel.selectedItem == DriveRaidLevel.R66_Nebula)
								maxCapacityPerEngineForPM2000 = AllFlashArrayUtility.BASE_PM2000_CONFIG_MAXIMUM_CAPACITY_FOR_RAID66 / 2;
							
							if ((capacityStateModel.selectedItem == DriveRaidLevel.R57_Nebula && capacityStateModel.totUsableCapacity == AllFlashArrayUtility.FLASH_CAPACITY_PACK_13TB) ||
								(capacityStateModel.selectedItem == DriveRaidLevel.R53_Nebula && capacityStateModel.totUsableCapacity == AllFlashArrayUtility.FLASH_CAPACITY_PACK_11TB) ||
								(capacityStateModel.selectedItem == DriveRaidLevel.R66_Nebula && capacityStateModel.totUsableCapacity == AllFlashArrayUtility.FLASH_CAPACITY_PACK_11TB))
							{
								// if capacity is 11.3 and RAID6 is chosen then only option is 1 V-Brick
								model.dataProvider.removeItemAt(1);
							}
							// if capacity is larger then 263 TB, 248.6 TB, 225.5 TB (depends on Raid group) then only option is 2 V-Bricks >>> this is for PowerMax 2000
							if(capacityStateModel.totUsableCapacity > maxCapacityPerEngineForPM2000)
							{
								model.dataProvider.removeItemAt(0);
							}
						}
					}
					
					model.selectedItem = model.dataProvider.getItemAt(0);
				}
				else if (stateName == STATE_ENGINES)
				{
					// System Bay Type (Engines) step
					var sysBayTypeValues:ArrayCollection;
					var singleEngineValues:ArrayCollection;
					var dualEngineValues:ArrayCollection;
					
					sysBayTypeValues = generateAllFilterValues(ConfigurationFilter.FILTER_SYSBAYS_TYPE);
                    
                    var tierStep:FilterWizardTierStateModel = this.getStateModel(FilterController.STATE_TIER) as FilterWizardTierStateModel;
                    
					// Custom solution
                    if(tierStep.selectedItem == TieringUtility_VG3R.TIER_CUSTOM_CONFIG && tierStep.selectedTiers)
                    {
						singleEngineValues = (SymmController.instance.configFactory as ConfigurationFactoryBase_VG3R).getSupportedEngines(tierStep.selectedTiers.toArray());
						dualEngineValues = (SymmController.instance.configFactory as ConfigurationFactoryBase_VG3R).getSupportedEngines(tierStep.selectedTiers.toArray(), ConfigurationFilter.DUAL_ENGINE_BAY);
                        
						if (dualEngineValues.length == 0) // remove dual engine option if there are no appropriate values
						{
                            sysBayTypeValues.removeItemAt(sysBayTypeValues.getItemIndex(ConfigurationFilter.DUAL_ENGINE_BAY));
						}
                    }
					else 
					{
						var singleEngCount:int;
						var dualEngCount:int;
						
						singleEngineValues = generateAllFilterValues(ConfigurationFilter.FILTER_ENGINES);
						
						if(tierStep && tierStep.selectedItem && tierStep.selectedTiers)
						{
							// Cost/flash quick
							if (TieringUtility_VG3R.isCostTier(int(tierStep.selectedItem)) || TieringUtility_VG3R.isFlashTier(int(tierStep.selectedItem)))
							{
								dualEngineValues = (SymmController.instance.configFactory as ConfigurationFactoryBase_VG3R).getSupportedEngines(tierStep.selectedTiers.toArray(), ConfigurationFilter.DUAL_ENGINE_BAY);
								singleEngCount = (configFactory as ConfigurationFactoryBase_VG3R).calculateEngineCount(tierStep.selectedTiers.toArray(), int(tierStep.selectedItem), ConfigurationFilter.SINGLE_ENGINE_BAY); 
								
								if (dualEngineValues.length == 0)
								{
									sysBayTypeValues.removeItemAt(sysBayTypeValues.getItemIndex(ConfigurationFilter.DUAL_ENGINE_BAY));
								}
								
								singleEngineValues = new ArrayCollection([singleEngCount]);
							}
							// Performance quick
		                    else 
		                    {
								singleEngCount = (configFactory as ConfigurationFactoryBase_VG3R).calculateEngineCount(tierStep.selectedTiers.toArray(), int(tierStep.selectedItem), ConfigurationFilter.SINGLE_ENGINE_BAY); 
								dualEngCount = (configFactory as ConfigurationFactoryBase_VG3R).calculateEngineCount(tierStep.selectedTiers.toArray(), int(tierStep.selectedItem), ConfigurationFilter.DUAL_ENGINE_BAY); 
								
								singleEngineValues = new ArrayCollection([singleEngCount]);
								
								if (dualEngCount)
								{
									dualEngineValues = new ArrayCollection([dualEngCount]);
								}
								else
								{
									sysBayTypeValues.removeItemAt(sysBayTypeValues.getItemIndex(ConfigurationFilter.DUAL_ENGINE_BAY));
								}
		                    }
						}
					}
					
					model.dataProvider = ((dualEngineValues && dualEngineValues.length == 0) || !dualEngineValues) ? new ArrayCollection([sysBayTypeValues.toArray(), singleEngineValues.toArray()]) : 
						new ArrayCollection([sysBayTypeValues.toArray(), singleEngineValues.toArray(), dualEngineValues.toArray()]);

					model.selectedItem = [sysBayTypeValues.getItemAt(0), singleEngineValues.getItemAt(0)];
				}
				else
				{
					model.selectedItem = SymmController.instance.configFilter[STATE_FACTORY_GETTER_MAP[states[state]]];
					
					if (model.selectedItem == -1)
					{
						model.selectedItem = STATE_DP_ROOT_ITEM_MAP[states[state]];
					}
				}
            }
			else	
            {
                switch (states[state])
                {
                    case STATE_ENGINES:
                    {
                        model.dataProvider = generateAllFilterValues(STATE_FACTORY_GETTER_MAP[states[state]]);
						
						if(mixedConfigsOnly && model.dataProvider.contains(ConfigurationFilter.NO_ENGINE_DEFAULT)){ 
							model.dataProvider.removeItemAt(model.dataProvider.getItemIndex(ConfigurationFilter.NO_ENGINE_DEFAULT));
						}

						model.selectedItem = SymmController.instance.configFilter[STATE_FACTORY_GETTER_MAP[states[state]]];
                        if (model.selectedItem == -1)
                        {
                            model.selectedItem = model.dataProvider[0];
                        }
                        break;
                    }
                    case STATE_DISPERSED:
                    {
                        var dispersionProvider:ArrayCollection = new ArrayCollection([ConfigurationFilter.NO_DISPERSED_DEFAULT, 3]);
                        var engineModel:FilterWizardStateModel = _wizardSteps[getStateIndex(STATE_ENGINES)];
                        var daeModel:FilterWizardStateModel = _wizardSteps[getStateIndex(STATE_DAE_COUNT)];
                        var daeSum:int = 0;
                        if(daeModel)
                            daeSum = (daeModel.selectedItem[0] > 0 ? daeModel.selectedItem[0] : 0) + (daeModel.selectedItem[1] > 0 ? daeModel.selectedItem[1] : 0);
                        
                        if((engineModel.selectedItem > 0 && engineModel.selectedItem < 3) || (!mixedConfigsOnly && daeSum < 12)){
                            dispersionProvider.removeItemAt(1);
                        }
                        model.dataProvider = dispersionProvider;
                        model.selectedItem = model.dataProvider[0];
                        
                        if(SymmController.instance.configFilter[STATE_FACTORY_GETTER_MAP[states[state]]] > ConfigurationFilter.NO_DISPERSED_DEFAULT && model.dataProvider.length > 1)
                            model.selectedItem = model.dataProvider[1];
                         
                        break;
                    }
                    case STATE_DAE_COUNT:
                    {
                        var engineModel1:FilterWizardStateModel = getStateModel(STATE_ENGINES);
                        var dispersionModel:FilterWizardStateModel = getStateModel(STATE_DISPERSED); 
                        
                        var selectedDispersion:int = dispersionModel? int(dispersionModel.selectedItem) : ConfigurationFilter.NO_DISPERSED_DEFAULT;
                            
                        var d15Values:ArrayCollection = null;
                        var vangValues:ArrayCollection = null;
                       
                        if(!mixedConfigsOnly)
                        {
                            d15Values = getDaeCountValues(int(engineModel1.selectedItem), DAE.D15, selectedDispersion > 0 ?  ConfigurationFilter.DISPERSED3 : ConfigurationFilter.NO_DISPERSED_DEFAULT, true);
                            vangValues= getDaeCountValues(int(engineModel1.selectedItem), DAE.Vanguard,  selectedDispersion > 0 ?  ConfigurationFilter.DISPERSED3 : ConfigurationFilter.NO_DISPERSED_DEFAULT, true);
                            
                            d15Values.addItemAt(ConfigurationFilter.NO_DAE_COUNT_DEFAULT, 0);
                            vangValues.addItemAt(ConfigurationFilter.NO_DAE_COUNT_DEFAULT, 0);
                        }
          /*              else{

                            const minDAETypeCountPerMix:int = 4; //minimum of both types 
                            
                            var limits:Object = getMOD4Limits(int(engineModel1.selectedItem));
                            
                            d15Values = new ArrayCollection(generate10kMixConfigsDAECountValues(int(engineModel1.selectedItem),  selectedDispersion > 0, limits.min - minDAETypeCountPerMix));
                            vangValues = new ArrayCollection(generate10kMixConfigsDAECountValues(int(engineModel1.selectedItem), selectedDispersion > 0, minDAETypeCountPerMix));
                        }*/
                        model.dataProvider = new ArrayCollection([d15Values.toArray(), vangValues.toArray()]);
                        
                        var daeTypeModel:int = SymmController.instance.configFilter[ConfigurationFilter.FILTER_DAE_TYPE];
                        var daeCount:int = SymmController.instance.configFilter[ConfigurationFilter.FILTER_DAE_COUNT];
                        
                        model.selectedItem = [model.dataProvider[0][0], model.dataProvider[1][0]]; 

                        if([DAE.D15, DAE.Vanguard].indexOf(daeTypeModel) > -1 && daeCount > ConfigurationFilter.NO_DAE_COUNT_DEFAULT && (model.dataProvider[daeTypeModel - 1] as Array).indexOf(daeCount) > -1)
                        {
                            if(daeTypeModel == DAE.D15)
                            {
                                model.selectedItem[0] = daeCount;
                            }
                            else if(daeTypeModel == DAE.Vanguard)
                            {
                                model.selectedItem[1] = daeCount;
                            }
                        }
                    
                        break;
                    }
                }
            }
			
            model.stateType = STATE_FACTORY_GETTER_MAP[states[state]];

            _wizardSteps[state] = model;

            return model;
        }

		/**
		 * generates all values for given filter including default values (-1 for most, D15 for dae type, 2 for data movers...) 
		 * @param filterName 
		 * @return ArrayCollection with all nonfiltered values
		 * 
		 */        
        public function generateAllFilterValues(filterName:String):ArrayCollection
        {
            var dp:ArrayCollection = new ArrayCollection();
			var configFactoryBase:ConfigurationFactoryBase = SymmController.instance.configFactory;
			
            if (filterName == ConfigurationFilter.FILTER_DISPERSED)
            {
				dp.addItemAt(ConfigurationFilter.NO_DISPERSED_DEFAULT, 0);
				
				if(SymmController.instance.isAFA() || SymmController.instance.isPM())
				{
					dp.addAll(new ArrayCollection(configFactoryBase[ConfigurationFilter.FILTER_DISPERSED_M]));
					
					if (!(configFactoryBase as ConfigurationFactoryBase_VG3R).wizardTiering)
					{					
						// dispersion filter popUp list provider
						var config:Configuration_VG3R = SymmController.instance.currentComponent.parentConfiguration as Configuration_VG3R;
						if(dp.source.length > config.countSystemBay)
						{
							dp.source.splice(config.countSystemBay, dp.source.length - config.countSystemBay);	
						}
					}
				}
				else
				{
					dp.addAll(new ArrayCollection(configFactoryBase[filterName]));
				}
            }
            else if (filterName == ConfigurationFilter.FILTER_DAE_COUNT)
            {  
				dp.addItemAt(ConfigurationFilter.NO_DAE_COUNT_DEFAULT, 0);
				//dp.addAll(new ArrayCollection(Configuration10kFactoryBase.DAE_COUNT_ALL_VALUES));
            }
    /*        else if (filterName == ConfigurationFilter.FILTER_DAE_TYPE)
            {
				if(SymmController.instance.isMFamily())
				{	
					dp.addItem(ConfigurationFilter.NO_DAE_DEFAULT_MFAMILY);
                    dp.addItem(DAE.Viking);
					dp.addItem(DAE.Voyager);
                    dp.addItem(DAE.MixedVoyager);
				}
				else
				{
					dp.addItem(DAE.D15);
	                dp.addItem(DAE.Vanguard);
	
	                if (!is10K() && !is10KUnified())
	                {
	                    dp.addItem(DAE.MixedD15);
	                    dp.addItem(DAE.MixedVanguard);
	                }
	                else
	                {
						dp.addItem(DAE.MixedD15);
	                }
				}
            }*/
            else if (filterName == ConfigurationFilter.FILTER_ENGINES)
            {	
				if (!SymmController.instance.isAFA() || 
					!(configFactoryBase as ConfigurationFactoryBase_VG3R).wizardTiering || !SymmController.instance.isPM())
				{
					dp.addItemAt(ConfigurationFilter.NO_ENGINE_DEFAULT, 0);
				}
				
                for (var jk:int = 0; jk < configFactoryBase[filterName]; jk++)
                {
					dp.addItem(jk + 1);
                }
            }
			else if (filterName == ConfigurationFilter.FILTER_DRIVE_TYPE)
			{
				dp.addItemAt(ConfigurationFilter.DRIVE_TYPE_DEFAULT, 0);
				var driveTypeDP:Array = configFactoryBase.getAllConfigurations();
				for each (var driveDP:Configuration_VG3R in driveTypeDP)
				{
					for each (var driveGroup:DriveGroup in driveDP.driveGroups)
					{
						if(!dp.contains(driveGroup.driveDef.type.name))
						dp.addItem(driveGroup.driveDef.type.name);
					}
				}
			}
			else if (filterName == ConfigurationFilter.FILTER_DRIVES)
			{
				dp.addItemAt(ConfigurationFilter.NO_DRIVES_DEFAULT, 0);
				var numberDrives:Array = configFactoryBase.getAllConfigurations();
				for each (var drives:Configuration_VG3R in numberDrives)
				{
					if(!dp.contains(drives.activesAndSpares))
						{
							dp.addItem(drives.activesAndSpares);
						}
				}
			}		
            else if (filterName == ConfigurationFilter.FILTER_STORAGE_BAYS)
            {
				dp.addItemAt(ConfigurationFilter.NO_STORAGE_BAYS_DEFAULT, 0);
			 
            }
			else if(filterName == ConfigurationFilter.FILTER_SYSTEM_BAYS){
				dp.addItemAt(ConfigurationFilter.NO_SYSTEM_BAYS_DEFAULT, 0);
				for(var i:int = 0; i < configFactoryBase[filterName]; i++){
					dp.addItem(i + 1);
				}
			}
			
			else if (filterName == ConfigurationFilter.FILTER_SYSBAYS_TYPE)
			{
				dp.source = new ArrayCollection(configFactoryBase[filterName] as Array).toArray();
			}
			else if (filterName == ConfigurationFilter.FILTER_TIERING)
			{
				if (!(configFactoryBase as ConfigurationFactoryBase_VG3R).wizardTiering)
				{
					dp.addItemAt(ConfigurationFilter.TIER_SOLUTION_DEFAULT, 0);
				}
				
				dp.addAll(getTierValues());
			}
			else if (filterName == ConfigurationFilter.FILTER_HOST_TYPE)
			{
				dp.source = Engine.VARIABLE_ENGINE_PORTS;
			}
			
            return dp;
        }
       
		/**
		 * removes items from dataprovider that do not pass configuration filter validation
		 * @param filterName field
		 * @param dataProvider collection
		 * @param filter configuration filter used for validation
		 * @returns none
		 */		
		public function filterDataProvider(filterName:String, dataProvider:ArrayCollection, filter:ConfigurationFilter = null):void{
			if(dataProvider && filterName){
				var configFilterChecker:ConfigurationFilter;
				
				if(SymmController.instance.isAFA() || SymmController.instance.isPM()){
					configFilterChecker = filter == null ? SymmController.instance.configFilter.cloneMSeries() : filter;
				}
				else{
					configFilterChecker = filter == null ? SymmController.instance.configFilter.clone() : filter;
				}
				
				for(var uv:int = 0; uv < dataProvider.length; uv++)
				{
					
					if(!checkFilterResult(configFilterChecker, filterName, dataProvider[uv]))
					{
						dataProvider.removeItemAt(uv);
						uv--;
					}
				}
			}
		}
       
		/**
		 * Filter dropDown when multiple selection is enabled
		 * @param filterList
		 * 
		 */		
		public function filterList(filterList:List):void
		{
			var selItems:Vector.<Object> = filterList.selectedItems;
			
			if (filterList.selectedItem && filterList.selectedItem == -1)
			{
				filterList.selectedIndices.length = 0;
				filterList.selectedIndices.push(0);
			}
			else if(selItems.length > 0)
			{
				var hasDefaultValue:Boolean = false;
				for(var i:int = 0; i < selItems.length; i++)
				{
					if((selItems[i] as int) == -1)
					{
						hasDefaultValue = true;
						break;
					}
				}
				if(hasDefaultValue)
				{
					for(var k:int = 0; k < filterList.selectedIndices.length; k++)
					{
						if(filterList.dataProvider.getItemAt(filterList.selectedIndices[k]) == -1)
						{
							filterList.selectedIndices.splice(k, 1);
							break;
						}
					}
				}
			}
			else
			{
				filterList.selectedIndices.push(0);
			}
			
			(filterList.dataProvider as ArrayCollection).refresh();
			filterList.dataGroup.invalidateDisplayList();
		}
		
		/**
		 * Compare function for host protocol sorting. <br/>
		 * First goes "FC", then "iSCSI", "FICON"
		 * @param hostProtocol1 
		 * @param hostProtocol2
		 * @param fields
		 * @return 
		 * 
		 */        
		public function sortByHostProtocol(hp1:Object, hp2:Object, fields:Array = null):int
		{
			if (hp1 == FilterWizardPortsStateModel.FC_PROTOCOL || 
				(hp1 == FilterWizardPortsStateModel.ISCSI_PROTOCOL && hp2 == FilterWizardPortsStateModel.FICON_PROTOCOL))
				return -1;
				
			if (hp2 == FilterWizardPortsStateModel.FC_PROTOCOL || 
				(hp2 == FilterWizardPortsStateModel.ISCSI_PROTOCOL && hp1 == FilterWizardPortsStateModel.FICON_PROTOCOL))
				return 1;
			
			return 0;
		}
		
		/**
		 * Gnererates tier data provider values 
		 * @return 
		 * 
		 */		
		public static function getTierValues():ArrayCollection
		{
			var dp:ArrayCollection = new ArrayCollection();
			
			dp.addItem(TieringUtility_VG3R.TIER_CUSTOM_CONFIG);
			dp.addAll(new ArrayCollection(TieringUtility_VG3R.getAllTiers()));
			
			return dp;
		}
		
		/**
		 * Tier label function
		 */		
		public function tierLabelFunction(item:Object):String
		{
			if (item == ConfigurationFilter.TIER_SOLUTION_DEFAULT)
			{
				return ResourceManager.getInstance().getString("main", "FILTER_TIER_ANY");
			}
			
			var tier:int = int(item);
			var tierSolution:int = TieringUtility_VG3R.getTierCount(tier);
//			var driveSize:String = ResourceManager.getInstance().getString("main", TieringUtility_VG3R.getAllowedTiers(DAE.Viking).contains(tier) ? "TIER_NON_MIXED" : "TIER_MIXED");

			if (tier == TieringUtility_VG3R.TIER_CUSTOM_CONFIG)
			{
				return 	ResourceManager.getInstance().getString("main", "TIER_CUSTOM_CONFIG");
			}
			
			return  ResourceManager.getInstance().getString("main", TieringUtility_VG3R.isCostTier(tier) ? "TIER_COST" : 
				TieringUtility_VG3R.isFlashTier(tier) ? "TIER_EFD" : "TIER_PERFORMANCE");						
		}
		
		/**
		 * Wizard Drive Type DropDown Label function
		 */		
		public function driveTypeDropLabelFunction(item:Object):String
		{
			return (item as DriveType).name;
		}
		
		/**
		 * Wizard Drive Raid DropDown Label function
		 */
		public function raidDropLabelFunction(item:Object):String
		{
			return (item as DriveRaidLevel).name;
		}

		/**
		 * Host type DropDown label function
		 */
		public function hostTypeDropLabelFunction(item:Object):String
		{
			return ResourceManager.getInstance().getString("main", item == HostType.OPEN_SYSTEMS ? "OS_HOST_TYPE" : item == HostType.MAINFRAME_HOST ? "MF_HOST_TYPE" : "MIXED_HOST_TYPE");
		}
		
		/**
		 * Wizard Drive Size DropDown Label function
		 */
		public function sizeDropLabelFunction(item:Object):String
		{
			return ResourceManager.getInstance().getString("main", item == DAE.Viking ? "DRIVE_SIZE_VIKING" : "DRIVE_SIZE_VOYAGER");
		}
		
        /**
        * generates dae count values data provider for given daeType, engine count, dispersed flag
        */
        public function getDaeCountValues(noEngines:int, daeType:int, dispersed:int, validateResult:Boolean, validateFilterInstance:Boolean = false):ArrayCollection{
			var configFilterChecker:ConfigurationFilter;
			if(SymmController.instance.isAFA() || SymmController.instance.isPM()){
			   configFilterChecker = SymmController.instance.configFilter.cloneMSeries()();
		   }
			else{
				configFilterChecker = SymmController.instance.configFilter.clone();
			}
            if(!validateFilterInstance){
                configFilterChecker = new ConfigurationFilter();
                configFilterChecker.noEngines= noEngines == 0? -1: noEngines;
                configFilterChecker.daeType = daeType;
                configFilterChecker.dispersed = dispersed;
            }
            
            var daeValues:Array = null;
            var dp:ArrayCollection = new ArrayCollection();
			var enginesForDispersion:Boolean =  [-1,3,4].indexOf(noEngines) > -1;
		 
 
/*            if (daeType == ConfigurationFilter.DAETYPED15 || daeType == ConfigurationFilter.DAETYPEVanguard)
            {
                daeValues = daeCountValuesPerDaeType[daeType];
            }
            else if (daeType == ConfigurationFilter.DAETYPEMixedD15)
            {
                daeValues = daeCountValuesPerDaeType[daeType][dispersed == ConfigurationFilter.NO_DISPERSED_DEFAULT ? 0 : 1];
            }*/
			
            if (noEngines == ConfigurationFilter.NO_ENGINE_DEFAULT)
            {    
                for (var dc:int = 0; dc < daeValues.length; dc++)
                {
                    if (!validateResult || checkFilterResult(configFilterChecker, ConfigurationFilter.FILTER_DAE_COUNT, daeValues[dc]))
                    {
                        dp.addItem(daeValues[dc]);
                    }
                }
            }
            else
            {
				for (var dce1:int = 0; dce1 < daeValues.length; dce1++)
				{
					if (!validateResult || checkFilterResult(configFilterChecker, ConfigurationFilter.FILTER_DAE_COUNT, daeValues[dce1]) ||
						(enginesForDispersion && dispersed > 0))
					{
						dp.addItem(daeValues[dce1]);
					}
				}
    /*            var limits:Array = null;

                if (daeType == ConfigurationFilter.DAETYPED15 || daeType == ConfigurationFilter.DAETYPEVanguard)
                {
                    limits = engineLimitsPerDaeType[daeType][noEngines];
                }
                else if (daeType == ConfigurationFilter.DAETYPEMixedD15)
                {
                    limits = engineLimitsPerDaeType[daeType][(noEngines < 3 ? noEngines : (noEngines + (dispersed == ConfigurationFilter.NO_DISPERSED_DEFAULT ? 0 : 2)))];
                }
				
                for (var dce1:int = 0; dce1 < daeValues.length; dce1++)
                {
                    if (daeValues[dce1] >= limits[0] && daeValues[dce1] <= limits[1])
                    {
                        if (!validateResult || checkFilterResult(configFilterChecker, ConfigurationFilter.FILTER_DAE_COUNT, daeValues[dce1]) ||
                            (enginesForDispersion && dispersed > 0))
                        {
                            dp.addItem(daeValues[dce1]);
                        }
                    }
                }*/
            }
            if (dispersed > 0)
            {
                if (!enginesForDispersion && dp.contains(4))
                    dp.removeItemAt(dp.getItemIndex(4));
                if (!enginesForDispersion && dp.contains(8))
                    dp.removeItemAt(dp.getItemIndex(8));
                if (enginesForDispersion && !dp.contains(8))
                    dp.addItemAt(8, 0);
                if (enginesForDispersion && !dp.contains(4))
                    dp.addItemAt(4, 0);
            }
            return dp; 
        } 

        private function checkFilterResult(filter:ConfigurationFilter, filterName:String, updateValue:Object):Boolean
        {
			var includeAllConfigs:Boolean = false;
			if((SymmController.instance.isAFA() || SymmController.instance.isPM()) && filterName == ConfigurationFilter.FILTER_DISPERSED)
			{
				filterName = ConfigurationFilter.FILTER_DISPERSED_M;
				var updateArr:Array = [];
				updateArr.push(updateValue);
				filter[filterName] = updateArr;
				includeAllConfigs = true;
			}
			else
			{
				filter[filterName] = updateValue;
			}
			
			if((SymmController.instance.isAFA() || SymmController.instance.isPM()) && filterName == ConfigurationFilter.FILTER_DISPERSED_M)
			{
				var cfgFactory:ConfigurationFactoryBase_VG3R = SymmController.instance.configFactory as ConfigurationFactoryBase_VG3R;
				return cfgFactory.validateDispersedValues(filter);
			}
			else
			{
		/*		if (SymmController.instance.isMFamily() && filterName == ConfigurationFilter.FILTER_DAE_TYPE &&
					filter.noEngines == ConfigurationFilter.NO_ENGINE_DEFAULT &&
					filter.noSystemBays == ConfigurationFilter.NO_SYSTEM_BAYS_DEFAULT &&
					filter.tiering == ConfigurationFilter.TIER_SOLUTION_DEFAULT &&
					filter.dispersed_m[0] == ConfigurationFilter.NO_DISPERSED_DEFAULT &&
					SymmController.instance.configFactory.filter(filter).length == 0)
				{
					return checkMseriesDaeTypeFilter(filter, true);
				}*/
				
		        return SymmController.instance.configFactory.filter(filter).length != 0;
			}
			return false;
        }

        /**
         * normalizes filter values
         */
        public function getDefaultFilterValue(filterType:String):int
        {

            switch (filterType)
            {
                case ConfigurationFilter.FILTER_DAE_COUNT:
                    return ConfigurationFilter.NO_DAE_COUNT_DEFAULT;
                case ConfigurationFilter.FILTER_DAE_TYPE:
                    return ConfigurationFilter.NO_DAE_DEFAULT;
                case ConfigurationFilter.FILTER_DISPERSED:
                    return ConfigurationFilter.NO_DISPERSED_DEFAULT;
                case ConfigurationFilter.FILTER_ENGINES:
                    return ConfigurationFilter.NO_ENGINE_DEFAULT;
				case ConfigurationFilter.FILTER_DRIVES:
					return ConfigurationFilter.NO_DRIVES_DEFAULT;
				case ConfigurationFilter.FILTER_DATA_MOVERS:
					return ConfigurationFilter.NO_DATA_MOVER_DEFAULT;
                case ConfigurationFilter.FILTER_STORAGE_BAYS:
                    return ConfigurationFilter.NO_STORAGE_BAYS_DEFAULT;
                case ConfigurationFilter.FILTER_SYSTEM_BAYS:
                    return ConfigurationFilter.NO_SYSTEM_BAYS_DEFAULT;
                case ConfigurationFilter.FILTER_SYSBAYS_TYPE:
                    return ConfigurationFilter.SYSTEM_BAY_TYPE_DEFAULT;
                case ConfigurationFilter.FILTER_USABLE_CAPACITY:
                    return ConfigurationFilter.USABLE_CAPACITY_DEFAULT;
                case ConfigurationFilter.FILTER_TIERING:
                    return ConfigurationFilter.TIER_SOLUTION_DEFAULT;
            }
            return 0;
        }

		/**
		 * Checks DAE type filter values for M series 
		 * @param filter indicates filter values
		 * @param isValidation indicates if it is just validation
		 * @return <code> true </code> if filter values can be applied. Otherwise <code> false </code>
		 * 
		 */		
		public function checkMseriesDaeTypeFilter(filter:ConfigurationFilter, isValidation:Boolean = false):Boolean
		{
			var cfgFactory:ConfigurationFactoryBase_VG3R = SymmController.instance.configFactory as ConfigurationFactoryBase_VG3R;
			var allConfigs:Array = cfgFactory.getAllConfigurations();
			
			// just validation
			if (isValidation)
			{
					for each (var cfg:Configuration_VG3R in allConfigs)
					{
						if (cfg.daeType == filter.daeType)
						{
							return true; 
						}
					}
					return false;
			}
			// generate appropriate dae type config
			else
			{
				if (cfgFactory.filter(filter).length == 0)
				{
					var filteredConfigs:Array = new Array();
					var complexCfg:Configuration_VG3R;
					
					for each (var cfg:Configuration_VG3R in allConfigs)
					{
						if (cfg.daeType == filter.daeType)
						{
							filteredConfigs.push(cfg);
						}
					}
					complexCfg = filteredConfigs.length == 1 ? filteredConfigs[0] : SymmController.instance.getMostComplexConfig(filteredConfigs) as Configuration_VG3R;
					
					cfgFactory.createDispersionClone(complexCfg, filter.dispersed_m);
					
					return true;
				}
			}
			
			return false;
		}
		
        /**
        * gets d15/Vanguard values for given engine count and dispersion and differed dae type count
        */
        public function generate10kMixConfigsDAECountValues(engineCount:int, dispersed:Boolean, differedDaeCount:int):Array
        {
            var dp:Array = new Array();
    /*        var limits:Object = getMOD4Limits(engineCount);

            var maxDaeCount:int = 0;
            var minDaeCount:int = 0;

            maxDaeCount = (Boolean(limits.dispersionEnabled && dispersed) ? limits.max[1] : limits.max[0]) - differedDaeCount;
            minDaeCount = differedDaeCount < limits.min ? (limits.min - differedDaeCount) : 4;
      
            
            for (var daeCount:int = minDaeCount; daeCount <= maxDaeCount; daeCount += 4)
            {
                dp.push(daeCount);   //4, 8, differedCount <= min - 4 
            }*/
            return dp;
        }
        
        /**
         * gets dae limits for mixed configurations 
         * @param engines
         * @return 
         * 
         */        
 /*       private function getMOD4Limits(engines:int):Object{
            return ConfigurationVNX10kFactory.MOD4_MIX_DAE_LIMITS_PER_ENGINE[engines];
        }*/

        /**
        * gets index of given state
        */
        public function getStateIndex(state:String):int
        {
            if (states == null || states.length == 0)
            {
                return -1;
            }
            return states.indexOf(state);
        }
        
		/**
		 * gets state name for given state index 
		 * @param state state index
		 * @return state name
		 * 
		 */		
		public function getStateName(state:int):String{
			if(states == null || states.length == 0 || state < 0 || state >= states.length){
				return "";
			}
			return states[state];
		}
        
		public function resetImportedConfigs():void {
			var engineModel2:FilterWizardStateModel = getStateModel(FilterController.STATE_ENGINES);
			var storageBayModel2:FilterWizardStateModel = getStateModel(FilterController.STATE_STGBAYS);
			var dispersedModel:FilterWizardStateModel = getStateModel(FilterController.STATE_DISPERSED);
			var daeModel:FilterWizardStateModel = getStateModel(FilterController.STATE_DAE);
		}
			
		public function resetMfamilyStepModels():void
		{
			var tierModel:FilterWizardStateModel = getStateModel(FilterController.STATE_TIER);
			var engineModel:FilterWizardStateModel = getStateModel(FilterController.STATE_ENGINES, true);
//			var portsModel:FilterWizardStateModel = getStateModel(FilterController.STATE_ENGINE_PORTS, true);
			var dispersionModel:FilterWizardStateModel = getStateModel(FilterController.STATE_DISPERSED);
		}
		
		/**
		 * Resets AFA wizard step models 
		 * 
		 */		
		public function resetAFAmodels():void
		{
			var capacityModel:FilterWizardStateModel = getStateModel(FilterController.STATE_USABLE_CAPACITY);
			var engineModel:FilterWizardStateModel = getStateModel(FilterController.STATE_ENGINES, true);
			if(!is250F())
			{
				var dispersionModel:FilterWizardStateModel = getStateModel(FilterController.STATE_DISPERSED);
			}
		}
		/**
		 * Resets PowerMax wizard step models 
		 * 
		 */
		public function resetPMmodels():void
		{
			var capacityModel:FilterWizardStateModel = getStateModel(FilterController.STATE_USABLE_CAPACITY);
			var engineModel:FilterWizardStateModel = getStateModel(FilterController.STATE_ENGINES, true);
			if(!isPM2000())
			{
				var dispersionModel:FilterWizardStateModel = getStateModel(FilterController.STATE_DISPERSED);
			}
		}
		
        public function reset10keStepModels():void {
            var engineModel2:FilterWizardStateModel = getStateModel(FilterController.STATE_ENGINES);
            var dispersedModel:FilterWizardStateModel = getStateModel(FilterController.STATE_DISPERSED);
            var daeCountModel:FilterWizardStateModel = getStateModel(FilterController.STATE_DAE_COUNT);
            
            var dispersedSelection:Object = dispersedModel.selectedItem;
            dispersedModel = getStateModel(STATE_DISPERSED, true);
            
            if(engineModel2.selectedItem < 3 && engineModel2.selectedItem > 0){
                dispersedModel.selectedItem = dispersedModel.dataProvider[0];
            }
            else{
                dispersedModel.selectedItem = dispersedSelection;
            }
            
            var d15Selection:int;
            var vangSelection:int;
            if(daeCountModel != null){
                d15Selection = daeCountModel.selectedItem[0];
                vangSelection = daeCountModel.selectedItem[1];
            }
            
          var model:FilterWizardStateModel = getStateModel(STATE_DAE_COUNT, true);
            if(model.dataProvider[0].indexOf(d15Selection) > -1){
                model.selectedItem[0] = d15Selection;
            }
            
            if(model.dataProvider[1].indexOf(vangSelection) > -1){
                model.selectedItem[1] = vangSelection;
            }  
        }
		
		
		public function resetUnified10kStepModels():void {
			var engineModel2:FilterWizardStateModel = getStateModel(FilterController.STATE_ENGINES);
			//var dispersedModel:FilterWizardStateModel = getStateModel(FilterController.STATE_DISPERSED);
			var daeCountModel:FilterWizardStateModel = getStateModel(FilterController.STATE_DAE_COUNT);
			var vnxCountModel:FilterWizardStateModel = getStateModel(FilterController.STATE_VNX);

			//var dispersedSelection:Object = dispersedModel.selectedItem;
			//dispersedModel = getStateModel(STATE_DISPERSED, true);
			
			/*if(engineModel2.selectedItem < 3){
				dispersedModel.selectedItem = dispersedModel.dataProvider[0];
			}
			else{
				dispersedModel.selectedItem = dispersedSelection;
			}*/
			
			var d15Selection:int;
			var vangSelection:int;
			if(daeCountModel != null){
				d15Selection = daeCountModel.selectedItem[0];
				vangSelection = daeCountModel.selectedItem[1];
			}
			
			var model:FilterWizardStateModel = getStateModel(STATE_DAE_COUNT, true);  
            
            var selectedEngine:int =  engineModel2.selectedItem == engineModel2.dataProvider[0] ? -1 : int(engineModel2.selectedItem);
             
            if(model.dataProvider[0].indexOf(d15Selection) > -1){
                model.selectedItem[0] = d15Selection;
            }  
            else {
                model.selectedItem[0] = model.dataProvider[0][0];
            }
            
            if(model.dataProvider[1].indexOf(vangSelection) > -1){
                model.selectedItem[1] = vangSelection;
            }  
            else {
                model.selectedItem[1] = model.dataProvider[1][0];
            }
		}
        
        /**
        * filter 20k wizard values
        */
        public function reset20kStepModel(excludeFilter:String):void {
			//retrieve or create models
			var engineModel4:FilterWizardStateModel = getStateModel(FilterController.STATE_ENGINES);
			var storageModel:FilterWizardStateModel = getStateModel(FilterController.STATE_STGBAYS);
			var daeModel:FilterWizardStateModel = getStateModel(FilterController.STATE_DAE);
			
			//state - filter map
			//state name: [filter name, default root String, full filter data provider] 
			var stateFilterValues:Object = {
				STATE_ENGINES: [ConfigurationFilter.FILTER_ENGINES , ConfigurationFilter.NO_ENGINE_DEFAULT,[ConfigurationFilter.NO_ENGINE_DEFAULT, 1, 2, 3, 4, 5, 6, 7, 8]], 
				STATE_DAE: [ConfigurationFilter.FILTER_DAE_TYPE, ConfigurationFilter.NO_DAE_DEFAULT], 
				STATE_STGBAYS: [ConfigurationFilter.FILTER_STORAGE_BAYS, ConfigurationFilter.NO_STORAGE_BAYS_DEFAULT, [ConfigurationFilter.NO_STORAGE_BAYS_DEFAULT, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]]};
			
			//used for state index retrieving in models collection
			var filterIndices:Array = [ConfigurationFilter.FILTER_ENGINES, ConfigurationFilter.FILTER_STORAGE_BAYS, ConfigurationFilter.FILTER_DAE_TYPE];
			
			//holds models for a fiven state
			var models:Array = [[STATE_ENGINES, engineModel4], 
				[STATE_STGBAYS, storageModel],
				[STATE_DAE, daeModel]];
			
			//default state values
			var defaultFilterPerState:Object = {STATE_ENGINES: ConfigurationFilter.NO_ENGINE_DEFAULT,
				STATE_STGBAYS: ConfigurationFilter.NO_STORAGE_BAYS_DEFAULT,
				STATE_DAE: ConfigurationFilter.NO_DAE_DEFAULT};
			
			//remove model by exclude filter param
			if (excludeFilter)
			{
				delete models[filterIndices.indexOf(excludeFilter)];
				delete filterIndices[filterIndices.indexOf(excludeFilter)];
			}
			
			//config checker
			var configFilter:ConfigurationFilter = new ConfigurationFilter(); 
			var previousSelection:Object = null;
			
			//filter each model except excluded one
			for each(var model:Array in models){
				previousSelection = (model[1] as FilterWizardStateModel).selectedItem; //save previous value
				wizardSteps[getStateIndex(model[0])] = null;                           //reset wizard step model
				
				//create new step model
				var newModel:FilterWizardStateModel = new  FilterWizardStateModel();
				newModel.stateType = stateFilterValues[model[0]][0];
				newModel.dataProvider = new ArrayCollection();
				
				configFilter.noEngines = int(engineModel4.selectedItem) ? int(engineModel4.selectedItem) : ConfigurationFilter.NO_ENGINE_DEFAULT;
				configFilter.noStorageBays = int(storageModel.selectedItem) ? int(storageModel.selectedItem) : ConfigurationFilter.NO_STORAGE_BAYS_DEFAULT;
				configFilter.daeType =int(daeModel.selectedItem);
				
				//generate filtered model for each step except excluded one (because excluded filter is the step which invoked filtering)
				switch (model[0]){
					case STATE_ENGINES: 
					case STATE_STGBAYS: 
					{
						for each(var item:Object in stateFilterValues[model[0]][2]){   //all possible values for this specific filter
							configFilter[stateFilterValues[model[0]][0]] = int(item) ? int(item) : defaultFilterPerState[model[0]];  //test for each value
							if(SymmController.instance.configFactory.filter(configFilter).length > 0){
								newModel.dataProvider.addItem(item);
							}
						}
						
						//reset old or default selection
						if(newModel.dataProvider.contains(previousSelection)){
							newModel.selectedItem = previousSelection;
						}
						else{
							newModel.selectedItem = stateFilterValues[model[0]][1]; //default
						}
						
						wizardSteps[getStateIndex(model[0])] = newModel;  //reset wizard step model
						break;
					}                      
					case STATE_DAE:
					{ 
						for each(var item1:Object in stateFilterValues[model[0]][2]){   //all possible values for this specific filter
							configFilter[stateFilterValues[model[0]][0]] = int(item1) ? int(item1) : defaultFilterPerState[model[0]];  //test for each value
							if(SymmController.instance.configFactory.filter(configFilter).length > 0){
								newModel.dataProvider.addItem(item1);
							}
						}
						
						//reset old or default selection
						if(newModel.dataProvider.contains(previousSelection)){
							newModel.selectedItem = previousSelection;
						}
						else{
							newModel.selectedItem = newModel.dataProvider.getItemAt(0); //default
						}
						
						wizardSteps[getStateIndex(model[0])] = newModel;  //reset wizard step model
						break;
					}
				}
			} 
        }
 
        /**
        * filter 40k wizard values
        */
        public function reset40kStepModel(excludeFilter:String = null):void
        {
            //retrieve or create models
            var engineModel4:FilterWizardStateModel = getStateModel(FilterController.STATE_ENGINES);
            var storageModel:FilterWizardStateModel = getStateModel(FilterController.STATE_STGBAYS);
            var daeModel:FilterWizardStateModel = getStateModel(FilterController.STATE_DAE);
            var dispersedModel:FilterWizardStateModel = getStateModel(FilterController.STATE_DISPERSED);
            
            //state - filter map
            //state name: [filter name, default root String, full filter data provider] 
            var stateFilterValues:Object = {
                STATE_ENGINES: [ConfigurationFilter.FILTER_ENGINES , ConfigurationFilter.NO_ENGINE_DEFAULT,[ConfigurationFilter.NO_ENGINE_DEFAULT, 1, 2, 3, 4, 5, 6, 7, 8]], 
                STATE_DAE: [ConfigurationFilter.FILTER_DAE_TYPE, ConfigurationFilter.NO_DAE_DEFAULT], 
                STATE_STGBAYS: [ConfigurationFilter.FILTER_STORAGE_BAYS, ConfigurationFilter.NO_STORAGE_BAYS_DEFAULT, [ConfigurationFilter.NO_STORAGE_BAYS_DEFAULT, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]], 
                STATE_DISPERSED: [ConfigurationFilter.FILTER_DISPERSED, ConfigurationFilter.NO_DISPERSED_DEFAULT, [ConfigurationFilter.NO_DISPERSED_DEFAULT, 3, 5, 7]]};

            //used for state index retrieving in models collection
            var filterIndices:Array = [ConfigurationFilter.FILTER_ENGINES, ConfigurationFilter.FILTER_STORAGE_BAYS, ConfigurationFilter.FILTER_DAE_TYPE, ConfigurationFilter.FILTER_DISPERSED];
            
            //holds models for a fiven state
            var models:Array = [[STATE_ENGINES, engineModel4], 
                [STATE_STGBAYS, storageModel],
                [STATE_DAE, daeModel],
                [STATE_DISPERSED, dispersedModel]];
            
            //default state values
            var defaultFilterPerState:Object = {STATE_ENGINES: ConfigurationFilter.NO_ENGINE_DEFAULT,
            STATE_STGBAYS: ConfigurationFilter.NO_STORAGE_BAYS_DEFAULT,
            STATE_DAE: ConfigurationFilter.NO_DAE_DEFAULT,
            STATE_DISPERSED: ConfigurationFilter.NO_DISPERSED_DEFAULT};

            //remove model by exclude filter param
            if (excludeFilter)
            {
                delete models[filterIndices.indexOf(excludeFilter)];
                delete filterIndices[filterIndices.indexOf(excludeFilter)];
            }
            
             //config checker
             var configFilter:ConfigurationFilter = new ConfigurationFilter(); 
             var previousSelection:Object = null;
             
             //filter each model except excluded one
             for each(var model:Array in models){
                 previousSelection = (model[1] as FilterWizardStateModel).selectedItem; //save previous value
                 wizardSteps[getStateIndex(model[0])] = null;                           //reset wizard step model
                 
                 //create new step model
                 var newModel:FilterWizardStateModel = new  FilterWizardStateModel();
                 newModel.stateType = stateFilterValues[model[0]][0];
                 newModel.dataProvider = new ArrayCollection();
                 
                 configFilter.noEngines = int(engineModel4.selectedItem) ? int(engineModel4.selectedItem) : ConfigurationFilter.NO_ENGINE_DEFAULT;
                 configFilter.noStorageBays = int(storageModel.selectedItem) ? int(storageModel.selectedItem) : ConfigurationFilter.NO_STORAGE_BAYS_DEFAULT;
                configFilter.daeType =int(daeModel.selectedItem);
                 configFilter.dispersed = int(dispersedModel.selectedItem) ? int(dispersedModel.selectedItem) : ConfigurationFilter.NO_DISPERSED_DEFAULT;
           
                 //generate filtered model for each step except excluded one (because excluded filter is the step which invoked filtering)
                 switch (model[0]){
                    case STATE_ENGINES: 
                    case STATE_STGBAYS: 
                    case STATE_DISPERSED:
                    {
                        for each(var item:Object in stateFilterValues[model[0]][2]){   //all possible values for this specific filter
                            configFilter[stateFilterValues[model[0]][0]] = int(item) ? int(item) : defaultFilterPerState[model[0]];  //test for each value
                            if(SymmController.instance.configFactory.filter(configFilter).length > 0){
                                newModel.dataProvider.addItem(item);
                            }
                        }
                        
                        //reset old or default selection
                        if(newModel.dataProvider.contains(previousSelection)){
                            newModel.selectedItem = previousSelection;
                        }
                        else{
                            newModel.selectedItem = stateFilterValues[model[0]][1]; //default
                        }
                        
                        wizardSteps[getStateIndex(model[0])] = newModel;  //reset wizard step model
                        break;
                    }                      
                    case STATE_DAE:
                    { 
                        for each(var item1:Object in stateFilterValues[model[0]][2]){   //all possible values for this specific filter
                            configFilter[stateFilterValues[model[0]][0]] = int(item1) ? int(item1) : defaultFilterPerState[model[0]];  //test for each value
                            if(SymmController.instance.configFactory.filter(configFilter).length > 0){
                                newModel.dataProvider.addItem(item1);
                            }
                        }
                        
                        //reset old or default selection
                        if(newModel.dataProvider.contains(previousSelection)){
                            newModel.selectedItem = previousSelection;
                        }
                        else{
                            newModel.selectedItem = newModel.dataProvider.getItemAt(0); //default
                        }
                        
                        wizardSteps[getStateIndex(model[0])] = newModel;  //reset wizard step model
                        break;
                    }
                 }
             }             
        }
        
		public function findStateForStep(state:int):String{
			return _states[state];
		}
		
    }
}


