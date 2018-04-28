import flash.events.MouseEvent;
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;
import mx.events.ResizeEvent;
import mx.utils.StringUtil;

import spark.events.IndexChangeEvent;
import spark.events.PopUpEvent;
import spark.layouts.HorizontalAlign;

import sym.configurationmodel.common.ConfigurationFactoryBase_VG3R;
import sym.configurationmodel.common.ConfigurationFilter;
import sym.configurationmodel.utils.AllFlashArrayUtility;
import sym.configurationmodel.utils.IntUtil;
import sym.configurationmodel.utils.TieringUtility_VG3R;
import sym.configurationmodel.v250f.ConfigurationFactory;
import sym.controller.FilterController;
import sym.controller.NavigationContoller;
import sym.controller.SymmController;
import sym.controller.events.FilterWizardEvent;
import sym.controller.events.NavigationRequestEvent;
import sym.controller.model.FilterWizardPortsStateModel;
import sym.controller.model.FilterWizardStateModel;
import sym.controller.model.FilterWizardTierStateModel;
import sym.objectmodel.common.ComponentBase;
import sym.objectmodel.common.Configuration;
import sym.objectmodel.common.Configuration_VG3R;
import sym.objectmodel.common.Constants;
import sym.objectmodel.common.DAE;
import sym.objectmodel.common.DriveGroup;
import sym.objectmodel.common.Engine;
import sym.objectmodel.common.PortConfiguration;
import sym.objectmodel.driveUtils.enum.DriveRaidLevel;
import sym.objectmodel.driveUtils.enum.DriveType;
import sym.objectmodel.driveUtils.enum.HostType;
import sym.viewer.mobile.utils.CommonUtility;
import sym.viewer.mobile.validation.CustomToolTip;
import sym.viewer.mobile.views.components.filter.FilterComponent;
import sym.viewer.mobile.views.components.popups.MessagePopup;
import sym.viewer.mobile.views.components.wizard.WizardTierComponent;

private var model:FilterWizardStateModel;

[Bindable]
private var _customTierWizard:Boolean = false;

[Bindable]
public static var title:String;

[Bindable]
private var _desc:String;

[Bindable]
private var _filterDataProvider:ArrayCollection;

//used for vanguard count 10ke series and Engine count M series
[Bindable]
private var _filterDataProvider2:ArrayCollection;

[Bindable]
private var _step:String;

[Bindable]
private var _noResult:Boolean = false;

[Bindable]
private var _noResultDescription:String;

[Bindable]
private var _summaryDataProvider:ArrayCollection;

private var _skipDispersionStep:Boolean = false;

// wizard step list data provider
[Bindable]
public static var stepsDataProvider:ArrayCollection;  

[Bindable]
public static var _titleCurrentStep:String;

[Bindable]
private var _gridSelectionStep:Boolean = false;

[Bindable]
private var _isFirstStep:Boolean = true;

private var _resetEnginePortModel:Boolean = false;

public var WIZARD_COUNT_NONE_VALUE:String = getResString("main", "WIZARD_DAE_COUNT_NONE");
public var WIZARD_COUNT_ANY_VALUE:String = getResString("main", "FILTER_ENGINES_ANY");


/**
 * preinitialize handler for FilterWizardPopUp component
 * <p>adds FilterWizardController event listeners</p>
 */
protected function onPreinitialize(event:FlexEvent):void
{
    SymmController.instance.dispersionDisabled = false;
    FilterController.instance.addEventListener(FilterWizardEvent.FILTER_WIZARD_STATE_CHANGED, filterWizardStateChangedHandler, false, 0, true);
}

/**
 * creationComplete handler for FilterWizardPopUp component
 * <p>sets vmax seria icon and tooltip</p>
 * <p>Calls FilterWizardController initialize method</p>
 */
protected function onCreationComplete(event:FlexEvent):void
{ 
	selectionHGroup1.horizontalAlign = selectionHGroup2.horizontalAlign = (SymmController.instance.isAFA() || SymmController.instance.isPM()) ? HorizontalAlign.LEFT : HorizontalAlign.RIGHT;
	selectionHGroup1.gap = selectionHGroup2.gap = (SymmController.instance.isAFA() || SymmController.instance.isPM()) ? 40 : 20;
	
    if(!filterWizardStepGroup.hasEventListener(IndexChangedEvent.CHILD_INDEX_CHANGE)){
        filterWizardStepGroup.addEventListener(IndexChangedEvent.CHILD_INDEX_CHANGE, onStepIndexChange); 
    }
    FilterController.instance.initialize();
    initializeStateArray();
    updateLabels();
	updateTitle();
}

/**
 * Sets error toolTip new position if necessary 
 */
protected function wizardResizeHandler(event:ResizeEvent):void
{
	if (driveMixStep.visible)
	{
		driveMixStep.onWizardResize();
	}
	else if (capacityStep.visible)
	{
		capacityStep.onWizardResize();
	}
}


protected function showHandler(event:FlexEvent):void
{
	this.minWidth = this.width;
	this.minHeight = this.height;
}

private function updateTitle():void
{
	title = getResString('main', 'STATE_MIXED_CONFIG_TITLE');
}

public function get disableNonMixed():Boolean
{
	return FilterController.instance.mixedConfigsOnly;
}

public function set disableNonMixed(value:Boolean):void
{
	FilterController.instance.mixedConfigsOnly = value;
}

/**
 * sets states array depending of current vmax configuration
 */
private function initializeStateArray():void
{
	if (SymmController.instance.vmaxConfiguration == Constants.IMPORTED_CONFIGS)
	{
		stepsDataProvider = new ArrayCollection([getResString("main", FilterController.STATE_ENGINES), 
			getResString("main", FilterController.STATE_STGBAYS), 
			getResString("main", FilterController.STATE_DAE), 
			getResString("main", FilterController.STATE_DISPERSED), 
			getResString("main", FilterController.STATE_SUMMARY)]);
	}
/*	if (SymmController.instance.isMFamily())
	{
		stepsDataProvider = new ArrayCollection([getResString("main", FilterController.STATE_TIER),
			getResString("main", FilterController.STATE_SYSBAYS_TYPE), 
			getResString("main", FilterController.STATE_ENGINE_PORTS), 
			getResString("main", FilterController.STATE_DISPERSED_VG3R), 
			getResString("main", FilterController.STATE_SUMMARY)]);
	}*/
	if (SymmController.instance.isAFA())
	{
		if(is450F() || is950F())
		{
			stepsDataProvider = new ArrayCollection([getResString("main", FilterController.STATE_USABLE_CAPACITY),
				getResString("main", "STATE_AFA_ENGINES"),
				getResString("main", FilterController.STATE_DRIVE_TYPE),
				getResString("main", FilterController.STATE_ENGINE_PORTS),
				getResString("main", FilterController.STATE_DISPERSED_VG3R),
				getResString("main", FilterController.STATE_SUMMARY)]);
		}
		else if(is250F())
		{
			stepsDataProvider = new ArrayCollection([getResString("main", FilterController.STATE_USABLE_CAPACITY),
				getResString("main", "STATE_AFA_ENGINES_250F"),
				getResString("main", FilterController.STATE_DRIVE_TYPE),
				getResString("main", FilterController.STATE_ENGINE_PORTS),
				getResString("main", FilterController.STATE_SUMMARY)]);
		}
	}
	if(SymmController.instance.isPM())
	{
		if(isPM2000())
		{
			stepsDataProvider = new ArrayCollection([getResString("main", FilterController.STATE_USABLE_CAPACITY),
				getResString("main", "STATE_PM2000_ENGINES"),
				getResString("main", FilterController.STATE_DRIVE_TYPE_PM),
				getResString("main", FilterController.STATE_ENGINE_PORTS),
				getResString("main", FilterController.STATE_SUMMARY)]);
		}
		else if(isPM8000())
		{
			stepsDataProvider = new ArrayCollection([getResString("main", FilterController.STATE_USABLE_CAPACITY),
				getResString("main", "STATE_PM_ENGINES"),
				getResString("main", FilterController.STATE_DRIVE_TYPE_PM),
				getResString("main", FilterController.STATE_ENGINE_PORTS),
				getResString("main", FilterController.STATE_DISPERSED_VG3R),
				getResString("main", FilterController.STATE_SUMMARY)]);
		}
	}
}

/**
 * updates title
 */
private function updateLabels():void
{
    _titleCurrentStep = StringUtil.substitute(getResString('main', 'STATE_TITLE_STEPS'), FilterController.instance.currentState + 1, FilterController.instance.states.length);

	var isNewSeries:Boolean = (SymmController.instance.isAFA() || SymmController.instance.isPM()); // for AFA  series labels for dispersion will not be updated
	
    switch (FilterController.instance.currentStateString)
    {
        case FilterController.STATE_DAE:
		case FilterController.STATE_VNX:
		case FilterController.STATE_STGBAYS:
			drop1.selectedItem = model.selectedItem;
            break;
        case FilterController.STATE_DAE_COUNT: //this is only for VMAX 10
            drop1.selectedItem = model.selectedItem[0];
            drop2.selectedItem = model.selectedItem[1];
            break;
		case FilterController.STATE_TIER:
			if (!driveMixStep.customConfigSelected)
				driveMixStep.updateLabels();
			break;
		case FilterController.STATE_USABLE_CAPACITY:
			capacityStep.updateLabels();
			break;
		case FilterController.STATE_DISPERSED:
			if(!isNewSeries)
				drop1.selectedItem = model.selectedItem;
        default:
            break;
    }
}

/**
 * update popUp data with current values
 */
protected function filterWizardStateChangedHandler(event:FilterWizardEvent):void
{
    _noResult = false;
    drop1.labelFunction = null;
    drop2.labelFunction = null;
    var currentComponent:ComponentBase = SymmController.instance.currentComponent;
	
	_isFirstStep = FilterController.instance.currentState == 0 && (SymmController.instance.isAFA() || SymmController.instance.isPM());
	_gridSelectionStep = false;
	
    switch (FilterController.instance.currentStateString)
    {
        case FilterController.STATE_ENGINES:
			
			if (SymmController.instance.isAFA())
			{
				var isMainframe:Boolean = capacityStep.model.selectedMFcapacity > 0 && capacityStep.model.selectedOScapacity == 0;
				_desc = getResString("main", is250F() ? isMainframe ? "STATE_AFA_ENGINES_INFO_MAINFRAME" : "STATE_AFA_ENGINES_INFO_OPEN_SYSTEM" : isMainframe ? "STATE_AFA_V_BRICKS_INFO_MAINFRAME" : "STATE_AFA_V_BRICKS_INFO_OPEN_SYSTEM");
				_step = getResString("main", isMainframe ? "STATE_AFA_ENGINES_MAINFRAME" : "STATE_AFA_ENGINES_OPEN_SYSTEM");
				// no label function - possible values are [1, 2, 3, 4]
				break;
			}
			if (SymmController.instance.isPM())
			{
				var isMainframe:Boolean = capacityStep.model.selectedMFcapacity > 0 && capacityStep.model.selectedOScapacity == 0;
				_desc = getResString("main", isMainframe ? "STATE_PM_Z_POWER_BRICK_INFO_MAINFRAME" : "STATE_PM_POWER_BRICK_INFO_OPEN_SYSTEM");
				_step = getResString("main", isMainframe ? "STATE_PM_ENGINES_MAINFRAME" : "STATE_PM_ENGINES_OPEN_SYSTEM");
				// no label function - possible values are [1, 2, 3, 4]
				break;
			}
			
            _desc = getResString("main", "STATE_ENGINES_DESCRIPTION");
            _step = getResString("main", "STATE_ENGINES");
            
			drop1.labelFunction = engineCountLabelFunction;
			drop2.labelFunction = engineCountLabelFunction;
			
		case FilterController.STATE_DRIVE_TYPE:
			_desc = getResString("main", is250F() ? "STATE_DRIVE_TYPE_INFO" : isPM2000() || isPM8000() ? "STATE_DRIVE_TYPE_INFO_PM" :"STATE_DRIVE_TYPE_INFO_950F");
			_step = getResString("main", isPM2000() || isPM8000() ? "STATE_NVM_DRIVE_TYPE_PM" : "STATE_DRIVE_TYPE");
			
			break;
        case FilterController.STATE_STGBAYS:
            _desc = getResString("main", "STATE_STGBAYS_DESCRIPTION");
            _step = getResString("main", "STATE_STGBAYS");
			drop1.labelFunction = storageBayCountLabelFunction;
            break;
        case FilterController.STATE_DISPERSED:
            _desc =  (SymmController.instance.isAFA() || SymmController.instance.isPM()) ? getResString("main", "STATE_DISPERSED_M_DESCRIPTION") : getResString("main", "STATE_DISPERSED40K_DESCRIPTION");
            _step = getResString("main", (SymmController.instance.isAFA() || SymmController.instance.isPM()) ? "STATE_DISPERSED_VG3R" : "STATE_DISPERSED");
			drop1.labelFunction = disperseLabelFunction;
            break;
        case FilterController.STATE_DAE:
            _desc = getResString("main", "STATE_DAE_DESCRIPTION");
            _step = getResString("main", "STATE_DAE");
            drop1.labelFunction = daeTypeLabelFunction;
            break;
		case FilterController.STATE_VNX:
			_desc = getResString("main", "STATE_VNX_DESCRIPTION");
			_step = getResString("main", "STATE_VNX");
			//no label function - possible values are [2, 3, 4]
			break;
        case FilterController.STATE_DAE_COUNT:
            _desc = getResString("main", "STATE_DAE_COUNT_DESCRIPTION");
            _step = getResString("main", "STATE_DAE_COUNT");           
            break;
		case FilterController.STATE_USABLE_CAPACITY:
			capacityStep.setLabelFunctions();
			break;
		case FilterController.STATE_TIER:
			driveMixStep.setLabelFunctions();
			_gridSelectionStep = true;
			break;
		case FilterController.STATE_ENGINE_PORTS:
			_gridSelectionStep = true;
			break;
        case FilterController.STATE_SUMMARY:
            _desc = getResString("main", "STATE_SUMMARY");
    }

    if (event.model != null)
    {
        model = event.model as FilterWizardStateModel;
        _filterDataProvider = null;
        _filterDataProvider2 = null;
        if (FilterController.instance.states[FilterController.instance.currentState] == FilterController.STATE_DAE_COUNT)
        {
            _filterDataProvider = new ArrayCollection(model.dataProvider[0]);
            _filterDataProvider2 = new ArrayCollection(model.dataProvider[1]);
            drop1.selectedItem = model.selectedItem[0];
            drop2.selectedItem = model.selectedItem[1];
        }
        else if (!_gridSelectionStep && !_isFirstStep)
        {
            _filterDataProvider = model.dataProvider;
			
			// Dispersed state M and AFA series
			if (FilterController.instance.states[FilterController.instance.currentState] == FilterController.STATE_DISPERSED &&
				(SymmController.instance.isAFA() || SymmController.instance.isPM()))
			{
				
				//dispersionModel holds previously selected values, model is reset
				var dispersionModel:FilterWizardStateModel = FilterController.instance.getStateModel(FilterController.STATE_DISPERSED,false);
                model = FilterController.instance.getStateModel(FilterController.STATE_DISPERSED, true);
				
                _filterDataProvider = model.dataProvider;
                model.selectedItem = dispersionModel.selectedItem; 
				
				var tempArr:Vector.<int> = new Vector.<int>();
				for(var i:int = 0; i < model.selectedItem.length; i++)
				{
					tempArr.push(_filterDataProvider.getItemIndex(model.selectedItem[i]));
				}               
				drop1.selectedIndices = tempArr;
			}
			// Engine state M series
	/*		else if (FilterController.instance.currentStateString == FilterController.STATE_ENGINES && SymmController.instance.isMFamily())
			{
                var oldModel:FilterWizardStateModel = FilterController.instance.getStateModel(FilterController.STATE_ENGINES);
				
				model = FilterController.instance.getStateModel(FilterController.STATE_ENGINES, true);
				
				_filterDataProvider = new ArrayCollection(model.dataProvider[0]);
				
				var sysBayType:Object = model.selectedItem[0] = model.dataProvider[0].indexOf(oldModel.selectedItem[0]) > -1 ? 
					oldModel.selectedItem[0] : 
					(model.dataProvider[0].indexOf(model.selectedItem[0]) > -1 ? model.selectedItem[0] : model.dataProvider[0][0]);
				
				_filterDataProvider2 = new ArrayCollection(model.dataProvider[sysBayType]);
				
				model.selectedItem[1] =  model.dataProvider[sysBayType].indexOf(oldModel.selectedItem[1]) > -1 ? 
					oldModel.selectedItem[1] : 
					(model.dataProvider[sysBayType].indexOf(model.selectedItem[1]) > -1 ? model.selectedItem[1] : model.dataProvider[sysBayType][0]);
				
				drop1.selectedItem = model.selectedItem[0];
				drop2.selectedItem = model.selectedItem[1];
			}*/
			// V-Bricks state for AFA model only
			else if (FilterController.instance.currentStateString == FilterController.STATE_ENGINES && (SymmController.instance.isAFA() || SymmController.instance.isPM()))
			{
				var oldEngineModel:FilterWizardStateModel = model;
				
				model = FilterController.instance.getStateModel(FilterController.STATE_ENGINES, true);
				_filterDataProvider = model.dataProvider;
				
				if (_filterDataProvider.contains(oldEngineModel.selectedItem))
				{
					model.selectedItem = oldEngineModel.selectedItem;
				}
				
				drop1.selectedItem = model.selectedItem;
			}
			//Drive Type state 
			else if(FilterController.instance.currentStateString == FilterController.STATE_DRIVE_TYPE)
			{
				model = FilterController.instance.getStateModel(FilterController.STATE_DRIVE_TYPE, true);
				
				_filterDataProvider = new ArrayCollection();
				
				for each (var drive:Object in model.dataProvider)
				{
					_filterDataProvider.addItem(driveTypeLabelFunction(drive, model.dataProvider));
				}
				
				drop1.selectedIndex = model.dataProvider.getItemIndex(model.selectedItem);
				
			}
			else 
			{
				if(FilterController.instance.currentStateString == FilterController.STATE_ENGINES)
				{
					drop1.selectedIndex = _filterDataProvider.getItemIndex(model.selectedItem);
				}
			}
        }
		// Capacity/Drive Mix state - 1st wizard step
		else if (_isFirstStep)
		{
			if (FilterController.instance.currentStateString == FilterController.STATE_TIER) 
			{
				// Drive Mix step
				initiateFirstStepModel(driveMixStep);
			}
			if (FilterController.instance.currentStateString == FilterController.STATE_USABLE_CAPACITY)
			{
				// Capacity step
				initiateFirstStepModel(capacityStep);
			}
		}
		else if (FilterController.instance.states[FilterController.instance.currentState] == FilterController.STATE_ENGINE_PORTS)
		{
			// Engine Port state
			model = FilterController.instance.getStateModel(FilterController.STATE_ENGINE_PORTS, true);
			
			enginePortStep.model = model as FilterWizardPortsStateModel;
			
			// set host protocol DropDown's selected item(s)
			if (SymmController.instance.isAFA() || SymmController.instance.isPM())
			{
				if (enginePortStep.hostProtocolDrop.allowMultipleSelection)
				{
					var tempArray:Vector.<int> = new Vector.<int>();
					for (var l:int = 0; l < enginePortStep.model.selectedProtocol.length; l++)
					{
						tempArray.push(enginePortStep.hostProtocolDrop.dataProvider.getItemIndex(enginePortStep.model.selectedProtocol[l]));
					}
					enginePortStep.hostProtocolDrop.selectedIndices = tempArray;
				}
				else
				{
					enginePortStep.hostProtocolDrop.selectedItem = enginePortStep.model.selectedProtocol[0];
				}
			}
		}
    }
	else
    {
        displaySummaryScreen(new ArrayCollection(stepsDataProvider.toArray()));
    }
    updateLabels();
	
	if (FilterController.instance.currentStateString == FilterController.STATE_DAE){
		this.callLater(calculateWizardWidth);
	}
	
}

/**
 * Sets first wizard state (Drive mix, Capacity) model amd error tooltip 
 */
private function initiateFirstStepModel(comp:WizardTierComponent):void
{
	comp.model = model as FilterWizardTierStateModel;
	
	if (!comp.initializeErrorTip())
	{
		comp.errorTip.hide();
	}
}

//dae type label function - default D15
private function daeTypeLabelFunction(item:Object):String
{
	return getResString('main', 'FILTER_DAE_TYPE_' + item);
}

//dae count label function - default NONe
private function daeCountLabelFunction(item:Object):String
{
	return item == ConfigurationFilter.NO_DAE_COUNT_DEFAULT ? WIZARD_COUNT_NONE_VALUE : item.toString();
}

//engine label function - default ANY
private function engineCountLabelFunction(item:Object):String{
	return item == ConfigurationFilter.NO_ENGINE_DEFAULT ? WIZARD_COUNT_ANY_VALUE : item.toString();
}

//Drive Type label function
private function driveTypeLabelFunction(item:Object, dataProvider:ArrayCollection = null):String
{
	var drive:DriveType = item as DriveType;
	var driveTypeLabel:String = (isPM2000() || isPM8000()) ? AllFlashArrayUtility.SUPPORTED_DRIVE_TYPES_PM2000[drive.capacity] : AllFlashArrayUtility.SUPPORTED_DRIVE_TYPES_250F[drive.capacity];
	
	if(is250F())
	{
		driveTypeLabel += getResString("main", dataProvider.getItemIndex(item) == 0 ?  "DRIVE_TYPE_SLOT_EFFICIENT" : "DRIVE_TYPE_HIGH_PERFORMANCE");
	}
	return driveTypeLabel;
}
//storage bay label function - default ANY
private function storageBayCountLabelFunction(item:Object):String{
	return item == ConfigurationFilter.NO_STORAGE_BAYS_DEFAULT ? WIZARD_COUNT_ANY_VALUE : item.toString();	
}

//dispersed label function - differed for 10k/Unified and the rest
private function disperseLabelFunction(item:Object, engineLabel:Boolean = true):String
{
	if ((SymmController.instance.isAFA() || SymmController.instance.isPM()) && !engineLabel)
	{	
		return item == ConfigurationFilter.NO_DISPERSED_DEFAULT ? getResString("main", FilterController.instance.currentStateString == FilterController.STATE_SUMMARY ? "STATE_SUMMARY_VG3R_DISPERSED_NO" : "FILTER_DISPERSED_NO_VG3R") : 
			StringUtil.substitute(getResString("main", "STATE_SUMMARY_VG3R_DISPERSED"), item.toString());
	}
	
	if ((SymmController.instance.isAFA() || SymmController.instance.isPM()) && engineLabel)
	{
		var syBayType:int = ConfigurationFilter.DUAL_ENGINE_BAY;
		var engineInd:int = syBayType == ConfigurationFilter.DUAL_ENGINE_BAY ? int(item) * syBayType - 1 : int(item);
		
		return item == ConfigurationFilter.NO_DISPERSED_DEFAULT ? getResString("main", "FILTER_DISPERSED_NO_VG3R") : 
			SymmController.instance.isAFA() ? StringUtil.substitute(getResString("main", "FILTER_DISPERSED_VG3R"), engineInd) : getResString("main", "FILTER_DISPERSED_PM");
	}
	
	return item == ConfigurationFilter.NO_DISPERSED_DEFAULT ? getResString("main", "FILTER_DISPERSED_NO") : item.toString();
}

/**
 * bay type Label function
 */
private function bayTypeLabelFunction(item:Object):String
{
	if (FilterController.instance.currentStateString == FilterController.STATE_SUMMARY)
	{
		return getResString("main", item == ConfigurationFilter.SINGLE_ENGINE_BAY ? "SINGLE_ENGINE_BAY_SUMMARY" : "DUAL_ENGINE_BAY_SUMMARY");
	}
	
	return getResString("main", item == ConfigurationFilter.SINGLE_ENGINE_BAY ? "SINGLE_ENGINE_BAY" : "DUAL_ENGINE_BAY");
}

/**
 * Ok button click handler
 * configurations are filtered by selected filter values via wizard selection
 */
protected function executeFilterWizardSelection(event:MouseEvent):void
{ 
    var filter:ConfigurationFilter = SymmController.instance.configFilter.clone();
	var configs:ArrayCollection;
		
    if (isImported())
	{
        filter = updateFilterWithSelectedValues(filter);

        if (SymmController.instance.configFactory.filter(filter).length > 0)
        {
            this.visible = false;
            this.close(true, [filter]);
        }
        else
        { 
			setNoResults(getResString("main", "STATE_SUMMARY_NO_RESULT"));
        }
    }
	else if (SymmController.instance.isAFA() || SymmController.instance.isPM())
	{
		var configFactoryVG3R:ConfigurationFactoryBase_VG3R = SymmController.instance.configFactory as ConfigurationFactoryBase_VG3R;
		
		filter = updateFilterWithSelectedValues(filter);
        
		var capacityStateModel:FilterWizardTierStateModel = FilterController.instance.getStateModel(FilterController.STATE_USABLE_CAPACITY) as FilterWizardTierStateModel;
		
        var portsStateModel:FilterWizardPortsStateModel = FilterController.instance.getStateModel(FilterController.STATE_ENGINE_PORTS) as FilterWizardPortsStateModel;
		
		var driveGroups:Array;
		var generatedConfig:Configuration_VG3R;
		
		if (is250F() || isPM2000())
		{
			var selectedDriveType:DriveType = FilterController.instance.getStateModel(FilterController.STATE_DRIVE_TYPE).selectedItem as DriveType;
			
			driveGroups = AllFlashArrayUtility.calculateEFDcount(filter.totCapacity, filter.noEngines, configFactoryVG3R, filter.hostType, selectedDriveType).toArray();
			filter = updateFilterWithSelectedValues(filter, driveGroups[0].activeCount, driveGroups[0].driveDef.raid.raidGroupSize);
		}
		else
		{
			selectedDriveType = FilterController.instance.getStateModel(FilterController.STATE_DRIVE_TYPE).selectedItem as DriveType;
			
			driveGroups = AllFlashArrayUtility.calculateEFDcount(filter.totCapacity, filter.noEngines, configFactoryVG3R, filter.hostType, selectedDriveType).toArray();
			filter = updateFilterWithSelectedValues(filter, driveGroups[0].activeCount, driveGroups[0].driveDef.raid.raidGroupSize);
		}			
		
    	generatedConfig = configFactoryVG3R.wizardConfigGenerator(filter.noEngines, filter.driveType, filter.noDrives, filter.sysBayType, driveGroups, filter.tiering, filter.totCapacity, filter.dispersed_m, filter.hostType, capacityStateModel.selectedOScapacity, capacityStateModel.selectedMFcapacity, portsStateModel.dataProvider);
        
		if (generatedConfig)
		{
            filter.daeType = generatedConfig.daeType;
			filter.daeCount = generatedConfig.totalDaeNumber;
			filter.noEngines = generatedConfig.noEngines;
			filter.noSystemBays = generatedConfig.countSystemBay;
			filter.driveType = generatedConfig.driveType;
			filter.noDrives = generatedConfig.numberOfDrives;
			
			// set FileCapacity
			generatedConfig.fileCapacity = portsStateModel.fileCapacitySelected;
			
			this.visible = false;
			this.close(false, [filter, generatedConfig]);
		}
		else
		{
			setNoResults(getResString("main", "STATE_SUMMARY_NO_RESULT"));
		}
	}
	
}

/**
 * no results after execution
 * set flags and control state
 * @param description 
 * 
 */
private function setNoResults(description:String):void
{            
	navigateToStep(stepsDataProvider.length - 1);
	_noResultDescription = description;
	_noResult = true;
	btnOK.enabled = false; 
}

/**
 * 
 */
private function updateFilterWithSelectedValues(filter:ConfigurationFilter, driveCount:Number = 0, raidGroupSize:Number = 0):ConfigurationFilter
{ 
    var dictionary:Dictionary = FilterController.instance.wizardSteps;
    var dictionaryLength:int = 0;
    
    for each (var item:Object in dictionary)
    {
        dictionaryLength++;
    }
    
    for (var state:int = 0; state < dictionaryLength; state++)
    {
        if(dictionary.hasOwnProperty(state))
		{
            var stateModel:FilterWizardStateModel = dictionary[state];
            var filterBy:String = stateModel.stateType;
            var selectedItem:Object = stateModel.selectedItem;
            var selectedIndex:int = stateModel.dataProvider.getItemIndex(selectedItem);
            
            if (filterBy == ConfigurationFilter.FILTER_DAE_TYPE || filterBy == ConfigurationFilter.FILTER_TIERING ||
				filterBy == ConfigurationFilter.FILTER_HOST_TYPE)
            {
                filter[filterBy] = selectedItem;
            }
            else if(filterBy == ConfigurationFilter.FILTER_DAE_COUNT)
            {
                filter[filterBy] = selectedItem[0] == ConfigurationFilter.NO_DAE_COUNT_DEFAULT ? selectedItem[1] : selectedItem[0];
            }
			
			else if(filterBy == ConfigurationFilter.FILTER_DRIVE_TYPE)
			{
				filter[filterBy] = selectedItem.name;
			}
            else if(filterBy == ConfigurationFilter.FILTER_DISPERSED)
            {
				if (SymmController.instance.isAFA() || SymmController.instance.isPM())
				{
					var dispersedValues:Array = [];
					filterBy = ConfigurationFilter.FILTER_DISPERSED_M;
					
					for each (var dispersedValue:Object in selectedItem) 
					{
						dispersedValues.push(dispersedValue);
					}
					
					filter[filterBy] = dispersedValues;
				}
                else 
                {
                    filter[filterBy] = selectedIndex == 0 ? ConfigurationFilter.NO_DISPERSED_DEFAULT : selectedItem;
                }
            }
    		else if (filterBy == ConfigurationFilter.FILTER_DATA_MOVERS)
    		{
    			filter[filterBy] = FilterController.instance.getDefaultFilterValue(filterBy);
    			
    		}
            else
            {
                if (selectedIndex == 0)
                {
                    filter[filterBy] = FilterController.instance.getDefaultFilterValue(filterBy);
                }
                else
                {
                    filter[filterBy] = selectedItem;
                }
            }
        }
    } 
	
	if (SymmController.instance.isAFA() || SymmController.instance.isPM())
	{
        var engineModel:FilterWizardStateModel = FilterController.instance.getStateModel(FilterController.STATE_ENGINES);
		var capacityModel:FilterWizardTierStateModel = FilterController.instance.getStateModel(FilterController.STATE_USABLE_CAPACITY) as FilterWizardTierStateModel;
        
        filter.sysBayType = SymmController.instance.configFactory.sysBayType[0];
    	filter.noEngines = int(engineModel.selectedItem);
		
		// for update value on filter drives button we need to calculate how many drives we have per engine
		// and add spares depending on number of drives per engine
		// for result collect total number of drives (driveCount) and spare.
		var totalDrivesEngine: Array = new Array();
		var minPerEngine:int = 2 * raidGroupSize;
		var driveCountPerEngine:int = int( driveCount / (minPerEngine * filter.noEngines)) * minPerEngine;
		var restDrivesToAdd:int = driveCount - (driveCountPerEngine * filter.noEngines);
		var minDrivesToAdd:int = raidGroupSize;
		var engIndex:int = 0;
		var spare:int = 0;

		if(driveCount != 0)
		{
			for (var eng:int = 0; eng < filter.noEngines; eng++)
			{
				totalDrivesEngine.push(0);
			}
		
		for(var engInd:int = 0; engInd < filter.noEngines; engInd++)
		{
			totalDrivesEngine[engInd] += driveCountPerEngine;
		}
		
		while(minDrivesToAdd <= restDrivesToAdd)
		{
			if(is250F())
			engIndex = IntUtil.minValueIndex(totalDrivesEngine);
			var drives:int = raidGroupSize; //track adding drives per engine
			
			for(minDrivesToAdd, drives; drives <= minPerEngine && minDrivesToAdd <= restDrivesToAdd; minDrivesToAdd += raidGroupSize, drives += raidGroupSize)
			{
				if(!is250F())
				engIndex = IntUtil.minValueIndex(totalDrivesEngine);
				
				totalDrivesEngine[engIndex] += raidGroupSize;
			}
		}
		
		for each(var drivesPerEngine:int in totalDrivesEngine)
		{
			spare = spare + Math.ceil(Number(drivesPerEngine / 50));
		}
		
		filter.noDrives = driveCount + spare;
		
		}
		
        filter.sysBayType = SymmController.instance.configFactory.sysBayType[0];
    	filter.noEngines = int(engineModel.selectedItem); 
		if (is250F())
			filter.sysBayType = filter.noEngines;
		
		filter.totCapacity = capacityModel.totUsableCapacity;
	}
    return filter;
}

/**
 * selected item clicked list handler
 * <p>updates button's label with selected value from list</p>
 * <p>selected data is saved in FilterWizardStateModel from previous(next) step in wizard</p>
 */
protected function onListChange(event:IndexChangeEvent):void
{
    if (model)
    {
        if(SymmController.instance.isAFA() || SymmController.instance.isPM())
        {
			// Dispersed state M/AFA series
			if (FilterController.STATE_DISPERSED == FilterController.instance.currentStateString)
			{
				model.selectedItem = drop1.selectedItems;
			}
			else
			{
				model.selectedItem = model.dataProvider[event.currentTarget.selectedIndex];
			}
        }
    }
    updateLabels();
	
	if (FilterController.instance.currentStateString == FilterController.STATE_DAE){
		this.callLater(calculateWizardWidth);
	}
	
	drop1.selectedItem = _filterDataProvider.getItemAt(drop1.selectedIndex);
}

/**
 * Resets Dispersion model with new(current) selected values
 */
private function resetMfamilyDisperseModel():void
{
	var dispersedModel:FilterWizardStateModel = FilterController.instance.getStateModel(FilterController.STATE_DISPERSED);
	var selectedDisperseValue:Object = dispersedModel.selectedItem;
	var count:int = 0;
	
	// reset dispersedModel
	dispersedModel = FilterController.instance.getStateModel(FilterController.STATE_DISPERSED, true);
	for (var i:int = 0; i < selectedDisperseValue.length; i++)
	{
		if (dispersedModel.dataProvider.contains(selectedDisperseValue[i]))
		{
			count++;
		}
	}
	
	// if new (reset) model contains old selected value then set selected value with old one
	if (count == selectedDisperseValue.length)
	{
		dispersedModel.selectedItem = selectedDisperseValue;		
	}
}

private function reset10kDisperseModel():void{
    var daeModel:FilterWizardStateModel = FilterController.instance.wizardSteps[FilterController.instance.getStateIndex(FilterController.STATE_DAE_COUNT)];
    var dispersedStateModel:FilterWizardStateModel = FilterController.instance.getStateModel(FilterController.STATE_DISPERSED);
    var engineStateModel:FilterWizardStateModel = FilterController.instance.getStateModel(FilterController.STATE_ENGINES) ;
    
    var dispersionSelection:Object = dispersedStateModel.selectedItem;
    dispersedStateModel  = FilterController.instance.getStateModel(FilterController.STATE_DISPERSED, true);
    var daeSum:int = 0;
    if(daeModel)
        daeSum = (daeModel.selectedItem[0] > 0 ?daeModel.selectedItem[0] : 0) + (daeModel.selectedItem[1] > 0 ?daeModel.selectedItem[1] : 0);
    

    if(((engineStateModel.selectedItem > 0 && engineStateModel.selectedItem < 3) || (daeSum < 12)) && dispersedStateModel.dataProvider.length > 1){
        dispersedStateModel.dataProvider.removeItemAt(1);
    }
    if(dispersedStateModel.dataProvider.contains(dispersionSelection)){
        dispersedStateModel.selectedItem = dispersionSelection;
    }
    else
    {
        dispersedStateModel.selectedItem = dispersedStateModel.dataProvider[0];
    } 
}

public function calculateWizardWidth():void 
{
    var wizardWidthPercent:Number = (SymmController.instance.isAFA() || SymmController.instance.isPM()) ? 0.94 : 0.8;
	var calculatedWidth:Number;
	if ((selectionLabel1.width + drop1.btnDrop.width + 50) > mainContainer.width)
	{
		calculatedWidth = (selectionLabel1.width + drop1.btnDrop.width + 50) - mainContainer.width;
		this.width += calculatedWidth;
		//mainContainer.width += calculatedWidth;
		this.x = (FlexGlobals.topLevelApplication.width - this.width) / 2;
	}
	else if (this.width > FlexGlobals.topLevelApplication.width * wizardWidthPercent)
	{
		calculatedWidth = mainContainer.width - (selectionLabel1.width + drop1.btnDrop.width + 50);
		this.width -= calculatedWidth;
		//mainContainer.width -= calculatedWidth;
		this.x = (FlexGlobals.topLevelApplication.width - this.width) / 2;
	} 
}
 
private function onStepsResize(event:ResizeEvent):void{
    calculateWizardWidth();
}

/**
 * If there is no configs in selection list then user is redirected to Home view.<br/>
 * Otherwise aprropriate config is displayed on the view
 * @param event 
 */
private function cancelBtn_ClickHandler(event:MouseEvent):void
{
	this.visible = false;
	
	if (SymmController.instance.selectionDataProvider.length > 0)
	{
		this.close();	
	}
	else
	{
		NavigationContoller.instance.dispatchEvent(new NavigationRequestEvent(NavigationRequestEvent._NAVIGATION_REQUEST, NavigationContoller.HOME_VIEW));
	}
	
	if (_isFirstStep && (SymmController.instance.isAFA() || SymmController.instance.isPM()))
	{
		// hide error toolTip if exists
		capacityStep && capacityStep.visible ? capacityStep.errorTip.hide() : driveMixStep.errorTip.hide();
	}
}

/**
 * step list changed index handler
 */
private function onStepIndexChange(event:IndexChangedEvent):void{
    navigateToStep(event.newIndex);
}

private function navigateToStep(stepIndex:int):void
{
    if(FilterController.instance.currentStateString == FilterController.STATE_DAE_COUNT){
        var daeCountModel:FilterWizardStateModel = FilterController.instance.getStateModel(FilterController.STATE_DAE_COUNT);
        if(daeCountModel.selectedItem[0] <= 0 && daeCountModel.selectedItem[1] <= 0){
            MessagePopup.open(getResString("main", "STATE_DAE_COUNT_NO_SELECTION"), 
                getResString("main", "STATE_DAE_COUNT_NO_SELECTION_TITLE"), 
                this, 
                MessagePopup.WARNING_MESSAGE,
                MessagePopup.BUTTON_OK);
            return;
        }
    }
	if (FilterController.instance.currentStateString == FilterController.STATE_ENGINE_PORTS)
	{
		// disable Dispersion step if there are no dispersion values
		if (FilterController.instance.states[stepIndex] == FilterController.STATE_DISPERSED)
		{
			var dispersionModel:FilterWizardStateModel = FilterController.instance.getStateModel(FilterController.STATE_DISPERSED, true);
			
			if (dispersionModel.dataProvider.length == 1 && dispersionModel.dataProvider.getItemAt(0) == ConfigurationFilter.NO_DISPERSED_DEFAULT)
			{
				SymmController.instance.dispersionDisabled = _skipDispersionStep = true;
				stepIndex++;
			}
			else if(isPM8000())
			{
				var engineModel:FilterWizardStateModel = FilterController.instance.getStateModel(FilterController.STATE_ENGINES);
				if(engineModel.selectedItem < 5)
				{
					SymmController.instance.dispersionDisabled = _skipDispersionStep = true;
					stepIndex++
				}
			}
			else
			{
                SymmController.instance.dispersionDisabled = _skipDispersionStep = false;
			}
		}
		
		
		_resetEnginePortModel = is250F() ? FilterController.instance.states[stepIndex] == FilterController.STATE_DRIVE_TYPE :
			FilterController.instance.states[stepIndex] == FilterController.STATE_ENGINES;
		
	}
	if (FilterController.instance.currentStateString == FilterController.STATE_SUMMARY && (SymmController.instance.isAFA() || SymmController.instance.isPM()))
	{
		if (_skipDispersionStep)
		{
			stepIndex--;
		}
	}
	if (FilterController.instance.currentStateString == FilterController.STATE_USABLE_CAPACITY)
	{
		// Usable Capacity step
		
		// capacity validation is failed
		if (capacityStep.capacityValidationFailed)
		{
			popUp = displayCapacityPopUpError();
		}
		
		if (popUp)
		{
			popUp.addEventListener(PopUpEvent.OPEN, capacityStep.popUpShowHandler);
			popUp.addEventListener(PopUpEvent.CLOSE, capacityStep.popUpHideHandler);
			
			return;
		}
		
		model = capacityStep.model;

		// set system selected RAID
		AllFlashArrayUtility.systemDriveRAID = capacityStep.model.selectedItem as DriveRaidLevel;
	}
	
	if (FilterController.instance.currentStateString == FilterController.STATE_TIER)
	{
		// Drive Mix step
		var popUp:MessagePopup;
		var invalidIndeX:int = (SymmController.instance.configFactory as ConfigurationFactoryBase_VG3R).validateDriveDivisibility(driveMixStep.dgDataProvider.toArray());
		var cfgFactory:ConfigurationFactoryBase_VG3R = SymmController.instance.configFactory as ConfigurationFactoryBase_VG3R;
		
		_customTierWizard = driveMixStep.customConfigSelected;
		
		// capacity validation is failed
		if (!_customTierWizard && driveMixStep.capacityValidationFailed)
		{
			popUp = displayCapacityPopUpError();
		}
		// DataGrid has no items(tiers) in case of custom tier solution
		else if (_customTierWizard && driveMixStep.dgDataProvider.length == 0)
		{
			popUp = MessagePopup.open(getResString("main", "STATE_TIER_DATA_GRID_NO_TIERS"), 
				getResString("main", "STATE_TIER"), 
				this, 
				MessagePopup.ERROR_MESSAGE,
				MessagePopup.BUTTON_OK);
		}
        else if(_customTierWizard && invalidIndeX > -1)
        { 
            this.driveMixStep.tierDG.startItemEditorSession(invalidIndeX, this.driveMixStep.driveCount.columnIndex);
        }
        else if (_customTierWizard && cfgFactory.getSupportedEngines(driveMixStep.dgDataProvider.toArray()).length == 0)
        {
			popUp = MessagePopup.open(getResString("main", "STATE_TIER_DATA_GENERAL_ERROR"),
                getResString("main", "STATE_TIER"), 
                this, 
                MessagePopup.ERROR_MESSAGE,
                MessagePopup.BUTTON_OK);
        }
		
		if (popUp || invalidIndeX > -1)
		{
			if (popUp)
			{
				popUp.addEventListener(PopUpEvent.OPEN, driveMixStep.popUpShowHandler);
				popUp.addEventListener(PopUpEvent.CLOSE, driveMixStep.popUpHideHandler);
			}
			
			return;
		}
		else
		{
			if (_customTierWizard)
			{
				driveMixStep.model.selectedOScapacity = cfgFactory.calculateCapacity(driveMixStep.dgDataProvider);
			}
			
			model = driveMixStep.model;
			
			// hide errorTip and disable validation
			driveMixStep.errorTip.hide(driveMixStep.driveCountField);
		}
		
	}
    FilterController.instance.step(stepIndex);
}

/**
 * Displays error popup with wrong selected capacity 
 */
private function displayCapacityPopUpError():MessagePopup
{
	return MessagePopup.open(getResString("main", "STATE_CAPACITY_WRONG_SELECTION"), 
		getResString("main", "STATE_USABLE_CAPACITY"), 
		this, 
		MessagePopup.ERROR_MESSAGE,
		MessagePopup.BUTTON_OK);
}

/**
 * Vanguard count list change - for 10k vmax <br/>
 * Engine count list change
 */ 
private function onListChange2(event:IndexChangeEvent):void
{
    if (model && FilterController.instance.currentStateString == FilterController.STATE_DAE_COUNT)
    {
        var engineStateModel:FilterWizardStateModel = FilterController.instance.getStateModel(FilterController.STATE_ENGINES);
        var dispersedStateModel:FilterWizardStateModel = null;

        model.selectedItem[1] = model.dataProvider[1][event.currentTarget.selectedIndex];
	

        var mixValues:ArrayCollection = null;
        if(model.selectedItem[1] != ConfigurationFilter.NO_DAE_COUNT_DEFAULT){
            mixValues = new ArrayCollection(FilterController.instance.generate10kMixConfigsDAECountValues(int(engineStateModel.selectedItem), dispersedStateModel && dispersedStateModel.selectedItem != dispersedStateModel.dataProvider.getItemAt(0), int(model.selectedItem[1])));
            if(!disableNonMixed)
                mixValues.addItemAt(ConfigurationFilter.NO_DAE_COUNT_DEFAULT, 0);
        }
        else{
            mixValues = FilterController.instance.getDaeCountValues(int(engineStateModel.selectedItem), DAE.D15, dispersedStateModel && dispersedStateModel.selectedItem != dispersedStateModel.dataProvider.getItemAt(0)? int(dispersedStateModel.selectedItem) : ConfigurationFilter.NO_DISPERSED_DEFAULT, true);
            if(!disableNonMixed)
                mixValues.addItemAt(ConfigurationFilter.NO_DAE_COUNT_DEFAULT, 0);
        }
        
        model.dataProvider[0] = mixValues.toArray();
        _filterDataProvider = new ArrayCollection(model.dataProvider[0]);
        
        if ((model.dataProvider[0] as Array).indexOf(model.selectedItem[0]) == -1)
        {
            model.selectedItem[0] = model.dataProvider[0][0];
            drop1.selectedIndex = 0;
        }
        else{
            drop1.selectedIndex = (model.dataProvider[0] as Array).indexOf(model.selectedItem[0]);
        }
    }
	else if (model && FilterController.instance.currentStateString == FilterController.STATE_ENGINES)
	{
		model.selectedItem[1] = model.dataProvider[1][event.currentTarget.selectedIndex];
	}
		
    updateLabels();
}

private function updateDaeCountValues():void
{
    var engineModel:FilterWizardStateModel = FilterController.instance.getStateModel(FilterController.STATE_ENGINES);
    var dispersedModel:FilterWizardStateModel = FilterController.instance.getStateModel(FilterController.STATE_DISPERSED);
    var daeCountModel:FilterWizardStateModel = FilterController.instance.getStateModel(FilterController.STATE_DAE_COUNT);

    var d15Selection:int;
    var vangSelection:int;
    if (daeCountModel != null)
    {
        d15Selection = daeCountModel.selectedItem[0];
        vangSelection = daeCountModel.selectedItem[1];
    }
}

/**
 * filterWizardStepList selected item changed handler
 * displays selected step in wizard
 */
protected function onStepChange(event:IndexChangeEvent):void
{
    if (model)
    {
        if (FilterController.instance.currentStateString == FilterController.STATE_DAE_COUNT)
        {
            model.selectedItem[0] = model.dataProvider[0][drop1.selectedIndex];
            model.selectedItem[1] = model.dataProvider[1][drop2.selectedIndex];
        }
        else
        {
            model.selectedItem = model.dataProvider[drop1.selectedIndex == -1 ? 0 : drop1.selectedIndex];
        }
    }
}


/**
 * when current state is Summary state this method is called for displaying summary screen
 * @param dp step list data provider
 */
private function displaySummaryScreen(dp:ArrayCollection):void
{
    var dictionary:Dictionary = FilterController.instance.wizardSteps;
    _summaryDataProvider = new ArrayCollection();

    for (var state:int = 0; state < dp.length - 1; state++)
    {
        var stateModel:FilterWizardStateModel = FilterController.instance.getStateModel(FilterController.instance.getStateName(state));
		var stateTierDesc:Object;
        var selectedItem:Object = stateModel.selectedItem;
        var selectedState:Object = dp.getItemAt(state);


        if (stateModel.stateType == ConfigurationFilter.FILTER_DAE_TYPE)
        {
            _summaryDataProvider.addItem({label: selectedState, value: getResString("main", "FILTER_DAE_TYPE_" + selectedItem)});
        }
		else if(stateModel.stateType == ConfigurationFilter.FILTER_ENGINES)
		{
			if (SymmController.instance.isAFA())
			{
				var isMainframe:Boolean = capacityStep.hostTypeDrop.selectedIndex == 1 ? true : false;
				_summaryDataProvider.addItem({label: getResString("main", "STATE_SYSBAYS_TYPE"), value: bayTypeLabelFunction(is250F() ? selectedItem : ConfigurationFilter.DUAL_ENGINE_BAY)});
				_summaryDataProvider.addItem({label: getResString("main", isMainframe ? "SUMMARY_AFA_ENGINES_MAINFRAME" : "SUMMARY_AFA_ENGINES_OPEN_SYSTEM"), value: engineCountLabelFunction(selectedItem)});
			}
			else if(SymmController.instance.isPM())
			{
				var isMainframe:Boolean = capacityStep.hostTypeDrop.selectedIndex == 1 ? true : false;
				_summaryDataProvider.addItem({label: getResString("main", "STATE_SYSBAYS_TYPE"), value: bayTypeLabelFunction(isPM2000() ? selectedItem : ConfigurationFilter.DUAL_ENGINE_BAY)});
				_summaryDataProvider.addItem({label: getResString("main", isMainframe ? "SUMMARY_PM_ENGINES_MAINFRAME" : "SUMMARY_PM_ENGINES_OPEN_SYSTEM"), value: engineCountLabelFunction(selectedItem)});
			}
			else
			{
				_summaryDataProvider.addItem({label: getResString("main", "STATE_ENGINES"), value: engineCountLabelFunction(selectedItem)});
			}
		}
		else if(stateModel.stateType == ConfigurationFilter.FILTER_DRIVE_TYPE)
		{
			_summaryDataProvider.addItem({label: getResString("main", "STATE_DRIVE_TYPE"), value:driveTypeLabelFunction(selectedItem, stateModel.dataProvider)});
			
		}
		else if(stateModel.stateType == ConfigurationFilter.FILTER_DISPERSED){
			_summaryDataProvider.addItem({label: getResString("main", 
				(SymmController.instance.isAFA() || SymmController.instance.isPM()) ? "STATE_DISPERSED_VG3R" : "STATE_DISPERSED"), value: disperseLabelFunction(selectedItem, false)});
		}
		else if(stateModel.stateType == ConfigurationFilter.FILTER_STORAGE_BAYS){
			_summaryDataProvider.addItem({label: getResString("main", "STATE_STGBAYS"), value: storageBayCountLabelFunction(selectedItem)});
		}
		else if (stateModel.stateType == ConfigurationFilter.FILTER_TIERING || stateModel.stateType == ConfigurationFilter.FILTER_USABLE_CAPACITY)
		{	
			var selectedHost:String = FilterController.instance.getStateModel(FilterController.STATE_ENGINE_PORTS).selectedItem.toString();
			
			var capacityInfo:String = stateModel.stateType == ConfigurationFilter.FILTER_TIERING ? driveMixStep.getFormattedCapacity(selectedHost) : 
				capacityStep.getFormattedCapacity(selectedHost);
			
			if (selectedHost == HostType.MIXED)
			{
				capacityInfo = stateModel.stateType == ConfigurationFilter.FILTER_TIERING ? driveMixStep.getFormattedCapacity(HostType.OPEN_SYSTEMS) + "/" + driveMixStep.getFormattedCapacity(HostType.MAINFRAME_HOST):
					capacityStep.getFormattedCapacity(HostType.OPEN_SYSTEMS) + "/" + capacityStep.getFormattedCapacity(HostType.MAINFRAME_HOST);
			}
			
			_summaryDataProvider.addItem({label: getResString("main", selectedHost == HostType.OPEN_SYSTEMS ? "SUMMARY_OS_USABLE_CAPACITY" :
				selectedHost == HostType.MAINFRAME_HOST ? "SUMMARY_MF_USABLE_CAPACITY" : "SUMMARY_USABLE_CAPACITY"), 
				value: capacityInfo});
			
			if (stateModel.stateType == ConfigurationFilter.FILTER_USABLE_CAPACITY)
			{
				_summaryDataProvider.addItem({label: getResString("main", "WIZARD_DRIVE_RAID"), value: FilterController.instance.raidDropLabelFunction(selectedItem)});
			}
			
			if (stateModel.stateType == ConfigurationFilter.FILTER_TIERING)
				stateTierDesc = {label: getResString("main", "STATE_TIER"), value: driveMixStep.selectedTierDesc};
		}
		else if (stateModel.stateType == ConfigurationFilter.FILTER_HOST_TYPE)
		{
			// Engine Port configuration state
			_summaryDataProvider.addItem({label: selectedState, value: enginePortStep.enginePortInfo});
		}
        else
        {
            _summaryDataProvider.addItem({label: selectedState, value: selectedItem});
        }
    }
	if (stateTierDesc)
		_summaryDataProvider.addItem(stateTierDesc);
}



