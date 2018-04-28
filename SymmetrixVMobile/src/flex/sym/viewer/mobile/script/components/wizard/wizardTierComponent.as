import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.events.FlexEvent;
import mx.events.ResizeEvent;
import mx.events.ValidationResultEvent;
import mx.utils.StringUtil;
import mx.validators.ValidationResult;

import spark.components.gridClasses.GridColumn;
import spark.events.GridItemEditorEvent;
import spark.events.IndexChangeEvent;
import spark.events.PopUpEvent;
import spark.events.TextOperationEvent;

import sym.configurationmodel.common.ConfigurationFactoryBase_VG3R;
import sym.configurationmodel.common.ConfigurationFilter;
import sym.configurationmodel.utils.AllFlashArrayUtility;
import sym.configurationmodel.utils.TieringUtility_VG3R;
import sym.controller.FilterController;
import sym.controller.SymmController;
import sym.controller.events.DropDownEvent;
import sym.controller.events.WizardDataGridEvent;
import sym.controller.model.FilterWizardStateModel;
import sym.controller.model.FilterWizardTierStateModel;
import sym.objectmodel.common.Configuration_VG3R;
import sym.objectmodel.common.Constants;
import sym.objectmodel.common.DAE;
import sym.objectmodel.common.DriveGroup;
import sym.objectmodel.driveUtils.DriveDef;
import sym.objectmodel.driveUtils.DriveRegister;
import sym.objectmodel.driveUtils.enum.DriveRaidLevel;
import sym.objectmodel.driveUtils.enum.DriveType;
import sym.objectmodel.driveUtils.enum.HostType;
import sym.viewer.mobile.utils.Settings;
import sym.viewer.mobile.validation.CustomToolTip;
import sym.viewer.mobile.views.components.popups.MessagePopup;
import sym.viewer.mobile.views.skins.grid.WizardDataGridSkin;

[Bindable]
public var allFlashArraysSelected:Boolean = false;

public static const MAINFRAME_MIN_CAPACITY_PERCENT:int = 1;
public static const MAINFRAME_MAX_CAPACITY_PERCENT:int = 100;


private var _lastCorrectCapacity:String;
private var _lastCorrectMFpercent:String;

private var _capacityValidationFailed:Boolean;
private var _mfCapacityValidationFailed:Boolean;

private var _model:FilterWizardTierStateModel;

// holds error toolTip instance
public var errorTip:CustomToolTip;

[Bindable]
private var _tierSolutionDP:ArrayCollection; 

[Bindable]
private var _driveTypeDP:ArrayCollection;

[Bindable]
private var _driveTypeDP_family:ArrayCollection;

[Bindable]
private var _driveRaidDP:ArrayCollection;

[Bindable]
private var _driveSizeDP:ArrayCollection;

[Bindable]
private var _customConfigSelected:Boolean = false;

[Bindable]
private var _minUsableCapacity:Number;

[Bindable]
private var _maxUsableCapacity:Number;

[Bindable]
private var _dgDataProvider:ArrayCollection;

[Bindable]
private var _inputFieldsSelected:Boolean = false;


/**
 * Indicates Quick or Custom Tier solution is selected
 * <p>
 * <code>True</code> if Custom tier
 * <br/> Otherwise, <code> False </code>if Quick tier
 * </p>
 */
public function get customConfigSelected():Boolean
{
	return _customConfigSelected;;
}

public function set customConfigSelected(val:Boolean):void
{
	_customConfigSelected = val;
}

/**
 * Keeps track of capacity validation 
 */
public function get capacityValidationFailed():Boolean
{
	return _capacityValidationFailed;
}

public function set capacityValidationFailed(val:Boolean):void
{
	_capacityValidationFailed = val;
}

public function get tierSolutionDP():ArrayCollection
{
	return _tierSolutionDP;
}

public function set tierSolutionDP(dp:ArrayCollection):void
{
	_tierSolutionDP = dp;
}

/**
 * Tier Grid data provider 
 */
public function get dgDataProvider():ArrayCollection
{
	return _dgDataProvider;
}

public function set dgDataProvider(dp:ArrayCollection):void
{
	_dgDataProvider = dp;
}

/**
 * Gets description of user's selected tiers
 */
public function get selectedTierDesc():String
{
	var selectedTierDesc:String;
	var tierLineDesc:String;
	var selecTedTier:int = int(tierDrop.selectedItem);
	// 1/2/3-Tier
	var tierSolution:int = TieringUtility_VG3R.getTierCount(selecTedTier, _customConfigSelected ? _dgDataProvider : null);
	
	selectedTierDesc = FilterController.instance.tierLabelFunction(tierDrop.selectedItem);
	
	for each (var tierLine:DriveGroup in _dgDataProvider)
	{
		
		tierLineDesc = StringUtil.substitute(getResString("main", "WIZARD_DRIVE_DESCRIPTION"), 
			percentLabelFunction(tierLine),
			driveTypeDataGridLabelFunction(tierLine), 
			sizeDataGridLabelFunction(tierLine),
			raidDataGridLabelFunction(tierLine),
			tierLine.activeCount);
		
		selectedTierDesc += "\n" + tierLineDesc;
	}
	
	return selectedTierDesc;
}

/**
 * Tier state model - model's <i>data provider, selectedItem, selectedCapacity, selectedTiers<i/>
 */
public function get model():FilterWizardTierStateModel
{
	return _model;
}

public function set model(tierStateModel:FilterWizardTierStateModel):void
{
	_model = tierStateModel;
	
	// AFA model logic
	if (allFlashArraysSelected)
	{
		// set RAID drop data provider
		afaRaidDrop.dataProvider = _model.dataProvider;
		afaRaidDrop.selectedItem = _model.selectedItem;
		// OS is only option for Vmax 250F and PowerMax 2000
		hostTypeDrop.dataProvider = new ArrayCollection(AllFlashArrayUtility.getHostTypes(is250F() || isPM2000()));
		
		if(mfCapacityGroup.visible == false)
			hostTypeDrop.selectedItem = _model.selectedMFcapacity > 0 ? HostType.MAINFRAME_HOST : HostType.OPEN_SYSTEMS;
		else
			hostTypeDrop.selectedItem = HostType.MIXED;
		
		// set capacity
		setCapacityValidation();
		
		if (!_model.selectedOScapacity && hostTypeDrop.selectedItem == HostType.OPEN_SYSTEMS)
		{
			_model.selectedOScapacity = _minUsableCapacity;
		}
		
		return;
	}
	
	_tierSolutionDP = _model.dataProvider;
	tierDrop.selectedIndex = _tierSolutionDP.getItemIndex(_model.selectedItem);
	
	_customConfigSelected = _model.selectedItem == TieringUtility_VG3R.TIER_CUSTOM_CONFIG;
		
	// set capacity
	if (!_customConfigSelected)
	{
		setCapacityValidation();
		if (!_model.selectedOScapacity && !_model.selectedMFcapacity)
		{
			_model.selectedOScapacity = _minUsableCapacity;
		}
	}
	// sets drive selection drops
	if (_customConfigSelected)
	{
		setDriveSelectionDP();
	}
	// set data grid values
	if (!_model.selectedTiers || !_dgDataProvider)
	{
		_dgDataProvider = new ArrayCollection();
		_model.selectedTiers = setTierDataGridDP(int(_model.selectedItem));
        this.callLater(refreshDataGridDP);
	}
}

/**
 * Refreshes DataGrid dataProvider so that its items are correctly displayed 
 */
private function refreshDataGridDP():void
{
	(tierDG.dataProvider as ArrayCollection).refresh();
}

/**
 * Gets usable capacity in apropriate format 
 * @param hostType indicates OS/MF host
 * @return formatted OS/MF capacity
 */

public function getFormattedCapacity(hostType:String):String
{
	if (hostType == HostType.OPEN_SYSTEMS)
	{
		if (_model.selectedOScapacity == 0)
		{
			_model.selectedOScapacity = (SymmController.instance.configFactory as ConfigurationFactoryBase_VG3R).calculateCapacity(_dgDataProvider);
		}
		
		return capacityFormatter.format(_model.selectedOScapacity);
	}
	
	if (hostType == HostType.MAINFRAME_HOST)
	{
		if (_model.selectedMFcapacity == 0)
		{
			_model.selectedMFcapacity = (SymmController.instance.configFactory as ConfigurationFactoryBase_VG3R).calculateCapacity(_dgDataProvider, hostType);
		}
		
		return capacityFormatter.format(_model.selectedMFcapacity);
	}
	
	return capacityFormatter.format(_model.totUsableCapacity);
}

/**
 * Sets error tookTip new position on wizard resize 
 */
public function onWizardResize():void
{
	if (this.errorTip)
	{
		CustomToolTip.positionChanged = true;
		
		if (this.customConfigSelected && this.errorTip.currentToolTip.visible)
		{
			callLater(this.errorTip.display, [this.driveCountField, this.errorTip.currentToolTip.text]);
		}
		else if (!this.customConfigSelected && this.capacityValidationFailed &&
			this.errorTip.currentToolTip.visible)
		{
			callLater(this.errorTip.display, [this.capacityField, this.errorTip.currentToolTip.text]);
		}
	}
}

/**
 * Initialize error toolTip instance 
 * @return <code> true </code> if new toolTip instance is created, otherwise <code> false </code>
 *  
 */
public function initializeErrorTip():Boolean
{
	if (!errorTip)
	{
		if (_customConfigSelected)
		{
			errorTip = new CustomToolTip(driveCountField.errorString, driveCountField);
		}
		else
		{
			errorTip = new CustomToolTip(capacityField.errorString, capacityField);
		}
		return true;
	}
	
	return false;
}

protected function resizeHandler(event:ResizeEvent):void
{
	if (tierDG.dataProvider && tierDG.scroller.viewport.verticalScrollPosition > 0)
		this.callLater(refreshDataGridDP);
}

protected function onCreationComplete(event:FlexEvent):void
{
	
	if (allFlashArraysSelected)
		return;
		
	this.callLater(initializeLayout);
}

/**
 * Initialize layout based on selected Language
 */
private function initializeLayout():void
{
    if (Settings.instance.currentLanguage == Constants.LANG_RUSSIA || 
        Settings.instance.currentLanguage == Constants.LANG_BRASIL)
    {
        capacityLabel.minWidth = 0;
//        tierLabel.minWidth = 0;
    }
    else
    {
//		tierLabel.minWidth = capacityLabel.width > tierLabel.width ? capacityLabel.width : tierLabel.width; 
        capacityLabel.minWidth = capacityLabel.width > tierLabel.width ? capacityLabel.width : tierLabel.width;
    }
	
	
}

/**
 * Adds event listeners 
 */
protected function onPreinitialize(event:FlexEvent):void
{
	tierDrop.addEventListener(DropDownEvent.SHOW, popUpShowHandler);
	tierDrop.addEventListener(DropDownEvent.HIDE, popUpHideHandler);
//	this.tierDG.addEventListener(GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_STARTING, onGridItemEditorStart);
    this.tierDG.addEventListener(WizardDataGridEvent.DRIVE_COUNT_EDIT_SESSION_REQUEST, startActiveCountEditSession);
}

public function popUpShowHandler(event:Event):void
{  
	errorTip.hide();
}

public function popUpHideHandler(event:Event):void
{
	if (errorTip)
	{
		if (_customConfigSelected)
		{
			if (_dgDataProvider.length > 0)
			{
				errorTip.hide(driveCountField);
			}
			else
			{
				driveCountModuloValidator.validate();
			}
		}
		else if (_capacityValidationFailed)
		{
			errorTip.display(capacityField, errorTip.currentToolTip.text);
		}
	}
}

private function startActiveCountEditSession(event:WizardDataGridEvent):void
{
    this.callLater(startDriveCountSession, [event.rowIndex]);
}

private function startDriveCountSession(row:int):void
{
    this.tierDG.startItemEditorSession(row, this.driveCount.columnIndex);    
}

/**
 * Sets drive selection DropDown data providers.
 */
private function setDriveSelectionDP():void
{
	_driveTypeDP = new ArrayCollection(DriveType.values);
	// _driveTypeDB_family is used for 100/200/400K series, it doesn't contain unsupported 3.84TB drive
	_driveTypeDP_family = new ArrayCollection(DriveType.values_family);
	
	if(is250F() || is950F())
	{
		_driveRaidDP = new ArrayCollection(DriveRaidLevel.values);
	}
	else
	{
		_driveRaidDP = new ArrayCollection(DriveRaidLevel.values_Nebula);
	}
	_driveSizeDP = new ArrayCollection(DriveDef.getSizeValues());
	
	if (driveTypeDrop.selectedIndex != -1)
	{
		if (!_driveTypeDP.contains(driveTypeDrop.selectedItem))
		{
			driveTypeDrop.selectedItem = _driveTypeDP.getItemAt(0);
		}
		_driveSizeDP = new ArrayCollection(DriveDef.getSupportedSize(driveTypeDrop.selectedItem as DriveType, true) as Array);			
	}
	if (driveRaidDrop.selectedIndex != -1)
	{
		if (!_driveRaidDP.contains(driveRaidDrop.selectedItem))
		{
			driveRaidDrop.selectedItem = _driveRaidDP.getItemAt(0);
		}
	}
	if (driveSizeDrop.selectedIndex != -1)
	{
		if (!_driveSizeDP.contains(driveSizeDrop.selectedItem))
		{
			driveSizeDrop.selectedItem = _driveSizeDP.getItemAt(0);
		}
	}
}

/**
 * Filters drive selection DropDown data providers<br/>
 * If data provider not set, sets to default values
 * @param filterBy indicates DropDown which drove to filtering other drops
 * 
 */
private function filterDriveSelectionDP(filterBy:Object):void
{
	if (filterBy == driveTypeDrop)
	{
		// filters size drops
		var selectedDriveType:DriveType = driveTypeDrop.selectedItem as DriveType;
		
		_driveSizeDP = new ArrayCollection(DriveDef.getSupportedSize(selectedDriveType, true) as Array);
		
		if (driveSizeDrop.selectedIndex != -1)
		{
			if (!_driveSizeDP.contains(driveSizeDrop.selectedItem))
			{
				driveSizeDrop.selectedItem = _driveSizeDP.getItemAt(0);
			}
		}
	}
	
	if (filterBy == driveRaidDrop)
	{
		// filters driveType/size drops
		var selectedRaid:DriveRaidLevel = driveRaidDrop.selectedItem as DriveRaidLevel;
		
        driveCountModuloValidator.errorMessage = StringUtil.substitute(getResString("main", "VALIDATION_DRIVE_GROUP_MODULO_FORMAT"), selectedRaid.raidGroupSize);
        driveCountModuloValidator.modulo = selectedRaid.raidGroupSize;
	}
	
	if (filterBy == driveSizeDrop)
	{
		// filters driveType/raid drops
		var selectedSize:int = int(driveSizeDrop.selectedItem);
		
		_driveTypeDP_family = new ArrayCollection(DriveDef.getSupportedDrives(selectedSize));

		if (driveTypeDrop.selectedIndex != -1)
		{
			if (!_driveTypeDP_family.contains(driveTypeDrop.selectedItem))
			{
				driveTypeDrop.selectedItem = _driveTypeDP_family.getItemAt(0);
			}
		}
		
	}
}

/**
 * Sets tier DataGrid values
 * @param indicates quick tier solution
 * @return Tier DataGrid dataProvider
 * 
 */
private function setTierDataGridDP(tier:int):ArrayCollection
{
	var tiers:ArrayCollection = new ArrayCollection();

	for each (var dg:DriveGroup in TieringUtility_VG3R.getDriveGroups(tier, false, true))
	{
		tiers.addItem(dg);
	}
	
	if (_dgDataProvider.length > 0)
	{
		_dgDataProvider.removeAll();
	}
	_dgDataProvider.addAll(tiers);
	
	return _dgDataProvider;
}

/**
 * Adds custom tier selection to DataGrid
 * <p> Create new DriveGroup from custom tier selection </p>
 * @param event MouseEvent.CLICK 
 */
protected function composeTierLine(event:MouseEvent):void
{
	var driveType:DriveType = driveTypeDrop.selectedItem as DriveType;
	var raid:DriveRaidLevel = driveRaidDrop.selectedItem as DriveRaidLevel;
	var size:Object = driveSizeDrop.selectedItem;
	var noDrives:int = int(driveCountField.text);
	var tierLine:DriveGroup = DriveGroup.create(DriveRegister.register(driveType, raid, size), NaN, noDrives);
	
	_dgDataProvider.addItem(tierLine);
	if (validateDriveCount(_dgDataProvider))
	{
		var rowIndex:int = _dgDataProvider.getItemIndex(tierLine);
		tierDG.ensureCellIsVisible(rowIndex);
		tierDG.setSelectedIndex(rowIndex);
			
		_model.selectedTiers = _dgDataProvider;  
	}
	else
	{ 
	    var confFactory:ConfigurationFactoryBase_VG3R = SymmController.instance.configFactory as ConfigurationFactoryBase_VG3R;
	    var minValidCount:int = confFactory.calculateMinValidDriveCount(_dgDataProvider.toArray(), _dgDataProvider.getItemIndex(tierLine));
	    var supportsGreaterAmount:Boolean = confFactory.testGreaterAmountOfDrives(_dgDataProvider.toArray(), _dgDataProvider.getItemIndex(tierLine));
		var currentCapacity:Number = confFactory.calculateCapacity(_dgDataProvider);
		var supportsCurrentCapacity:Boolean = currentCapacity <= confFactory.totCapacity;
	    
	    if(minValidCount == 0 && !supportsGreaterAmount) //no space
	    {
	        _dgDataProvider.removeItemAt(_dgDataProvider.getItemIndex(tierLine));
	        MessagePopup.open(getResString("main", "STATE_TIER_NO_MORE_PLACE_FOR_ACTIVE_DRIVES"), 
	            getResString("main", "STATE_TIER"), 
	            this, 
	            MessagePopup.ERROR_MESSAGE,
	            MessagePopup.BUTTON_OK);
	        
	        return;
	    }
	    else if(tierLine.activeCount < minValidCount && supportsCurrentCapacity)
	    {
	        var message:MessagePopup = MessagePopup.open(StringUtil.substitute(getResString("main", "STATE_TIER_DRIVE_COUNT_MINIMUM_QUESTION"), minValidCount), 
	            getResString("main", "STATE_TIER"), 
	            this, 
	            MessagePopup.ERROR_MESSAGE,
	            MessagePopup.BUTTON_OK | MessagePopup.BUTTON_CANCEL);
	        
	        message.addEventListener(PopUpEvent.CLOSE, function (event:PopUpEvent):void
	        {
	            if(event.target.result == MessagePopup.RESULT_CANCEL)
	            {
	                _dgDataProvider.removeItemAt(_dgDataProvider.getItemIndex(tierLine));
	            }
	        });
	        return;
	    }
	    
	    var maxValidCount:int = confFactory.calculateMaxValidDriveCount(_dgDataProvider.toArray(), _dgDataProvider.getItemIndex(tierLine));
		
	    if(maxValidCount > 0 && maxValidCount < tierLine.activeCount && supportsGreaterAmount && supportsCurrentCapacity)
	    {
	        var message:MessagePopup = MessagePopup.open(StringUtil.substitute(getResString("main", "STATE_TIER_DRIVE_COUNT_OVERFLOW_QUESTION"), maxValidCount),
	            getResString("main", "STATE_TIER"), 
	            this, 
	            MessagePopup.ERROR_MESSAGE,
	            MessagePopup.BUTTON_OK | MessagePopup.BUTTON_CANCEL);
	        message.addEventListener(PopUpEvent.CLOSE, function (event:PopUpEvent):void
	        {
	           if(event.target.result == MessagePopup.RESULT_CANCEL)
	           {
	               _dgDataProvider.removeItemAt(_dgDataProvider.getItemIndex(tierLine));
	           }
	        });
	        return;
	    }
	    else if(maxValidCount == 0 && supportsGreaterAmount && supportsCurrentCapacity)
	    {
	        var fullMaxCount:int = confFactory.calculateAdaptableMaxDriveCount(_dgDataProvider.toArray(), _dgDataProvider.getItemIndex(tierLine));
	        var message:MessagePopup = MessagePopup.open(StringUtil.substitute(getResString("main", "STATE_TIER_DRIVE_COUNT_OVERFLOW_QUESTION"), fullMaxCount),
	            getResString("main", "STATE_TIER"), 
	            this, 
	            MessagePopup.ERROR_MESSAGE,
	            MessagePopup.BUTTON_OK | MessagePopup.BUTTON_CANCEL);
	        message.addEventListener(PopUpEvent.CLOSE, function (event:PopUpEvent):void
	        {
	            if(event.target.result == MessagePopup.RESULT_CANCEL)
	            {
	                _dgDataProvider.removeItemAt(_dgDataProvider.getItemIndex(tierLine));
	            }
	        });
	        return;
	    }
	    else if(!supportsGreaterAmount && supportsCurrentCapacity)
	    {  
	        var fullMaxCount:int = confFactory.calculateAdaptableMaxDriveCount(_dgDataProvider.toArray(), _dgDataProvider.getItemIndex(tierLine));
	        _dgDataProvider.removeItemAt(_dgDataProvider.getItemIndex(tierLine));
	        var message:MessagePopup = MessagePopup.open(StringUtil.substitute(getResString("main", "STATE_TIER_DRIVE_COUNT_DEFINIT_OVERFLOW_QUESTION"), fullMaxCount),
	            getResString("main", "STATE_TIER"), 
	            this, 
	            MessagePopup.ERROR_MESSAGE,
	            MessagePopup.BUTTON_OK); 
	    }
		else if (!supportsCurrentCapacity)
		{
			// current usable capacity has reached maximum capacity limit for current VMAX array 
			var capacityLimitDriveCount:int =  confFactory.calculateCapacityLimitMaxDrives(_dgDataProvider, _dgDataProvider.getItemIndex(tierLine));
			_dgDataProvider.removeItemAt(_dgDataProvider.getItemIndex(tierLine));
			
			var messageDesc:String = capacityLimitDriveCount > 0 ? StringUtil.substitute(getResString("main", "STATE_TIER_CAPACITY_OVERFLOW"), capacityFormatter.format(currentCapacity), capacityFormatter.format(confFactory.totCapacity), capacityLimitDriveCount) :
				getResString("main", "STATE_TIER_NO_MORE_PLACE_FOR_ACTIVE_DRIVES");
			
			MessagePopup.open(messageDesc,
				getResString("main", "STATE_TIER"),
				this, 
				MessagePopup.ERROR_MESSAGE,
				MessagePopup.BUTTON_OK);
		}
	    else
	    {
	        _dgDataProvider.removeItemAt(_dgDataProvider.getItemIndex(tierLine));
			MessagePopup.open(getResString("main", "STATE_TIER_INCORRECT_ACTIVE_DRIVE_COUNT"),
				getResString("main", "STATE_TIER"), 
				this, 
				MessagePopup.ERROR_MESSAGE,
				MessagePopup.BUTTON_OK);
	    }
	}
}

/**
 * Validates custom configuration values.
 * <p>Returns <code> true </code> if validation succeeds, <code> false </code> otherwise.
 * 
 */
public function validateTierValues():Boolean
{
    var resultEvent:ValidationResultEvent = driveCountModuloValidator.validate();
    return resultEvent == null || resultEvent.results == null || resultEvent.results.length == 0;
}

/**
 * Validates active drive count for current drive group selection
 * @param driveGroups indicates all currently selected tiers
 * @return <code> true </code> if validation succeeds, otherwise <code> false <code>
 */
public function validateDriveCount(driveGroups:ArrayCollection):Boolean
{
	var cfgFactory:ConfigurationFactoryBase_VG3R = SymmController.instance.configFactory as ConfigurationFactoryBase_VG3R;
	var engineValues:ArrayCollection = FilterController.instance.generateAllFilterValues(ConfigurationFilter.FILTER_ENGINES);
	var generatedCfg:Configuration_VG3R;
	var driveCountValidation:Boolean = false;
	
	// max total usable capacity for current VMAX array
	var maxVMAXcap:Number = cfgFactory.totCapacity;
	var currentCap:Number = cfgFactory.calculateCapacity(driveGroups);
	
	if (currentCap <= maxVMAXcap)
	{
		for each (var noEngines:int in engineValues)
		{
			generatedCfg = cfgFactory.createConfiguration(noEngines, ConfigurationFilter.SINGLE_ENGINE_BAY,"",0, ConfigurationFilter.DISPERSEDNON_M, driveGroups.toArray(), _model.selectedOScapacity, _model.selectedMFcapacity);
			if (generatedCfg)
			{
				driveCountValidation = true;
				break;
			}
		}
	}
	
	return driveCountValidation;
}

/**
 * RAID drop down change handler 
 */
protected function raidChangeHandler(event:IndexChangeEvent):void
{
	_model.selectedItem = _model.dataProvider.getItemAt(event.newIndex);
	
	// trigger capacity validation when switching from one RAID to another
	setCapacityValidation();
	updateLabels();
}

/**
 * Host type drop down change handler
 */
protected function hostTypeChangeHandler(event: IndexChangeEvent):void
{
	// reset model's MF/OS capacity
	// only if capacity validation has not failed
	if (!capacityValidationFailed)
		_model.selectedMFcapacity = hostTypeDrop.selectedItem == HostType.MAINFRAME_HOST ? 100 : 0;
	
	// 950f, if mixed is chosen set mixed capacity field visible
	if(hostTypeDrop.selectedItem == HostType.MIXED)
		mfCapacityGroup.visible = true;
	else
		mfCapacityGroup.visible = false;
	
	setCapacityValidation();
	updateLabels();
}
/**
 * selected item clicked list handler
 * <p>updates button's label with selected value from list</p>
 * <p>selected data is saved in FilterWizardStateModel from previous(next) step in wizard</p>
 */
public function onListChange(event:IndexChangeEvent):void
{
	if (_model)
	{
		if (event.currentTarget == tierDrop)
		{
			_customConfigSelected = tierDrop.selectedItem == TieringUtility_VG3R.TIER_CUSTOM_CONFIG;
			if (!_customConfigSelected)
			{
				setCapacityValidation();
				// previous selection was Custom tier
				if (_model.selectedItem == TieringUtility_VG3R.TIER_CUSTOM_CONFIG)
				{
					_model.selectedMFcapacity = 0;
					_model.selectedOScapacity = _minUsableCapacity;
					
					errorTip.hide();
					CustomToolTip.positionChanged = true;
				}
				
				updateLabels();
				
				_model.selectedItem = _model.dataProvider.getItemAt(event.newIndex);
				_model.selectedTiers = setTierDataGridDP(int(_model.selectedItem));
				
				callLater(initializeLayout);
			}
			else
			{
				_model.selectedMFcapacity = 0;
				
				_model.selectedItem = _model.dataProvider.getItemAt(event.newIndex);
				if (_dgDataProvider.length > 0)
				{
					_dgDataProvider.removeAll();
				}
				
				setDriveSelectionDP();
				
				errorTip.hide();
				CustomToolTip.positionChanged = true;
				
				callLater(validateTierValues);
				
			}
		}
		else 
		{
			filterDriveSelectionDP(event.currentTarget);
			_inputFieldsSelected = !isAddBtnDisabled();
		}
	}
}

/**
 * Returns <code>true</code> if Add button should be disabled.<br/>
 * Otherwise is <code>false</code>
 */
private function isAddBtnDisabled():Boolean
{
	return driveTypeDrop.isDefaultSelected() || driveSizeDrop.isDefaultSelected() || 
		driveRaidDrop.isDefaultSelected() || driveCountField.text.length == 0 || !validateTierValues();
}

/**
 * <code> driveCountField </code> change handler
 * @param event   
 * 
 */
protected function driveCountField_changeHandler(event:TextOperationEvent):void
{
	_inputFieldsSelected = !isAddBtnDisabled();
	
	if (_inputFieldsSelected && !event)
	{
		composeTierLine(null);
	}
}

/**
 * Examines usable capacity validation
 * @return false if validation fails
 * 
 */
public function checkCapacityValidation():Boolean
{
	setCapacityValidation();
	_capacityValidationFailed = _model.selectedOScapacity < _minUsableCapacity || model.selectedOScapacity > _maxUsableCapacity; 
	
	return !_capacityValidationFailed;
}

/**
 * Sets min/max capacity values for Quick Tier solutions
 */
private function setCapacityValidation():void
{
	if (allFlashArraysSelected)
	{
		if(!is250F() && !isPM2000() && !isPM8000()){
			if(hostTypeDrop.selectedIndex == -1 || hostTypeDrop.selectedIndex == 0)
			{
				// set capacity for AFA model
				_minUsableCapacity = AllFlashArrayUtility.FLASH_BLOCK_CAPACITY_13TB;
			}
			else
			{
				if(afaRaidDrop.selectedIndex == -1 || afaRaidDrop.selectedIndex == 0)
					_minUsableCapacity = AllFlashArrayUtility.BASE_CONFIG_V_BRICK_CAPACITY;
				else
					_minUsableCapacity = AllFlashArrayUtility.FLASH_BLOCK_CAPACITY_26TB;/**/
			}
	//		_maxUsableCapacity = (SymmController.instance.configFactory as ConfigurationFactoryBase_VG3R).totCapacity;
			_maxUsableCapacity = AllFlashArrayUtility.MAXIMUM_USABLE_CAPACITY[_model.selectedItem.name][SymmController.instance.configFactory.noEngines];
		}
		else if(is250F())
		{
			if(afaRaidDrop.selectedIndex == -1 || afaRaidDrop.selectedIndex == 0)
			{
				_minUsableCapacity = AllFlashArrayUtility.BASE_250F_CONFIG_MINIMUM_CAPACITY_FOR_RAID57;
			}
			else
			{
				_minUsableCapacity = AllFlashArrayUtility.BASE_250F_CONFIG_MINIMUM_CAPACITY;
			}
			_maxUsableCapacity = AllFlashArrayUtility.BASE_250F_CONFIG_MAXIMUM_CAPACITY;
		}
		else if(isPM2000())
		{
			if(afaRaidDrop.selectedIndex == -1 || afaRaidDrop.selectedIndex == 0)
			{
				_minUsableCapacity = AllFlashArrayUtility.BASE_PM2000_CONFIG_MINIMUM_CAPACITY_FOR_RAID57;
				_maxUsableCapacity = AllFlashArrayUtility.BASE_PM2000_CONFIG_MAXIMUM_CAPACITY;
			}
			else if(afaRaidDrop.selectedIndex == -2 || afaRaidDrop.selectedIndex == 2)
			{
				_minUsableCapacity = AllFlashArrayUtility.FLASH_CAPACITY_PACK_11TB;
				_maxUsableCapacity = AllFlashArrayUtility.BASE_PM2000_CONFIG_MAXIMUM_CAPACITY_FOR_RAID66;
			}
			else
			{
				_minUsableCapacity = AllFlashArrayUtility.FLASH_CAPACITY_PACK_11TB;
				_maxUsableCapacity = AllFlashArrayUtility.BASE_PM2000_CONFIG_MAXIMUM_CAPACITY_FOR_RAID53;
			}
		}
		else if(isPM8000())
		{
			if(afaRaidDrop.selectedIndex == -1 || afaRaidDrop.selectedIndex == 0)
			{
				_minUsableCapacity = AllFlashArrayUtility.BASE_250F_CONFIG_MINIMUM_CAPACITY_FOR_RAID57;
				_maxUsableCapacity = AllFlashArrayUtility.MAXIMUM_CAPACITY_PM8000_RAID57;
			}
			else
			{
				_minUsableCapacity = AllFlashArrayUtility.BASE_250F_CONFIG_MINIMUM_CAPACITY;
				_maxUsableCapacity = AllFlashArrayUtility.MAXIMUM_CAPACITY_PM8000_RAID66;
			}
		}
		return;
	}
	
	// max usable capacity for current VMAX array
	var upperCapacityLimit:Number = SymmController.instance.configFactory[ConfigurationFilter.FILTER_USABLE_CAPACITY];
	
	_minUsableCapacity = TieringUtility_VG3R.getMinCap(int(tierDrop.selectedItem));
	
	// 100k - 2 engines 
	// 200k - 4 engines
	// 800k - 8 engines max
	_maxUsableCapacity = TieringUtility_VG3R.USABLE_CAPACITY_MAXIMUMS[tierDrop.selectedItem][SymmController.instance.configFactory.noEngines]; //SymmController.instance.configFactory[ConfigurationFilter.FILTER_USABLE_CAPACITY];
}

/**
 * Handler when capacity validation succeeds/fails
 * @param event ValidationResultEvent
 * 
 */
protected function capacityValidationHandler(event:ValidationResultEvent):void
{
	_capacityValidationFailed = event.type == ValidationResultEvent.INVALID;
	
	if (_capacityValidationFailed)
	{
		var error:String = (event.results[0] as ValidationResult).errorMessage;
		if (error == capacityValidator.decimalPointCountError|| 
			error == capacityValidator.fractionalDigitsError ||
			error == capacityValidator.parseError)
		{
			event.stopImmediatePropagation();
			capacityField.text = _lastCorrectCapacity;
		}
		else
		{
			_lastCorrectCapacity = capacityField.text;
			
			errorTip.display(capacityField, error);
		}
	}
	else
	{
		_lastCorrectCapacity = capacityField.text;
		
		errorTip.hide();
	}
	
	_model.selectedOScapacity = capacityFormatter.parseNumber(capacityField.text);
	
	if (allFlashArraysSelected && hostTypeDrop.selectedItem == HostType.MAINFRAME_HOST && !_capacityValidationFailed)
	{
		// set mf capacity to 100% since pure (100%) MF host is selected
		_model.selectedOScapacity -= _model.selectedMFcapacity;
		_model.selectedMFcapacity = 100;
	}
}

/**
 * Mainframe usable capacity percentage validation handler
 * @param event ValidationResultEvent
 * 
 */
protected function mfCapValidationHandler(event:ValidationResultEvent):void
{
	_mfCapacityValidationFailed = event.type == ValidationResultEvent.INVALID;
	
	if (_mfCapacityValidationFailed)
	{
		var error:String = (event.results[0] as ValidationResult).errorMessage;
		
		if (error == mfCapValidator.lessThanMinError)
		{
			event.stopImmediatePropagation();
			mfCapacityField.text = _lastCorrectMFpercent;
		}
	}
	else
	{
		_lastCorrectMFpercent = mfCapacityField.text;
		
		_model.selectedMFcapacity = mfCapFormatter.parseNumber(mfCapacityField.text);
	}
}

/**
 * Handler when drive count validation succeeds/fails.
 * <p> If validation fails displays appropriate error toolTip, otherwise hide toolTip if exists. </p>
 * @param event ValidationResultEvent
 * 
 */
protected function driveCountModuloValidationHandler(event:ValidationResultEvent):void
{
	if (event.results && event.results.length > 0 &&
		event.results[0].errorMessage)
	{
		errorTip.display(driveCountField, event.results[0].errorMessage);
	}
	else
	{
		errorTip.hide(driveCountField);
	}
}

/**
 * Updates Tier step labels 
 */
public function updateLabels():void
{
	if(is250F())
	{
		capacityField.text = _model.totUsableCapacity.toString();
		if(afaRaidDrop.selectedIndex != 0 && afaRaidDrop.selectedIndex != -1)
			capacityField.text = AllFlashArrayUtility.BASE_250F_CONFIG_MINIMUM_CAPACITY.toString();
		else
			capacityField.text = AllFlashArrayUtility.BASE_250F_CONFIG_MINIMUM_CAPACITY_FOR_RAID57.toString();
	}
	else if(isPM2000())
	{
		capacityField.text = _model.totUsableCapacity.toString();
		if(afaRaidDrop.selectedIndex != 0 && afaRaidDrop.selectedIndex != -1 && afaRaidDrop.selectedIndex != 2)
		{
			capacityField.text = AllFlashArrayUtility.FLASH_CAPACITY_PACK_11TB.toString();
		}
		else if(afaRaidDrop.selectedIndex == 2)
			capacityField.text = AllFlashArrayUtility.FLASH_CAPACITY_PACK_11TB.toString();
		else
			capacityField.text = AllFlashArrayUtility.BASE_PM2000_CONFIG_MINIMUM_CAPACITY_FOR_RAID57.toString();
	}
	else if(isPM8000())
	{
		capacityField.text = _model.totUsableCapacity.toString();
		if(afaRaidDrop.selectedIndex != 0 && afaRaidDrop.selectedIndex != -1 && afaRaidDrop.selectedIndex != 2)
		{
			capacityField.text = AllFlashArrayUtility.FLASH_CAPACITY_PACK_11TB.toString();
		}
		else if(afaRaidDrop.selectedIndex == 2)
			capacityField.text = AllFlashArrayUtility.FLASH_CAPACITY_PACK_11TB.toString();
		else
			capacityField.text = AllFlashArrayUtility.BASE_PM2000_CONFIG_MINIMUM_CAPACITY_FOR_RAID57.toString();
	}
	else
	{
		if(hostTypeDrop.selectedIndex == -1 || hostTypeDrop.selectedIndex == 0)
		{
			//capacityField.text = _model.totUsableCapacity.toString();	
			capacityField.text = AllFlashArrayUtility.BASE_CONFIG_V_BRICK_CAPACITY.toString();
			// set capacity for AFA model
			_minUsableCapacity = AllFlashArrayUtility.BASE_CONFIG_V_BRICK_CAPACITY;
		}
		else
		{
			if(afaRaidDrop.selectedIndex == -1 || afaRaidDrop.selectedIndex == 0)
				_minUsableCapacity = AllFlashArrayUtility.FLASH_BLOCK_CAPACITY_13TB;
			else
				_minUsableCapacity = AllFlashArrayUtility.FLASH_BLOCK_CAPACITY_26TB;
			capacityField.text = _minUsableCapacity.toString();
		}
	}
	if (_model.selectedMFcapacity == 0)
		mfCapacityField.text = "";
	
	onCapacityValueChanged(null);
}


/**
 * Capacity field Focus out and Enter event handlers
 * <p> Formats Capacity value. </p>
 * <p> Updates DataGrid drive count column. </p>
 * 
 */
protected function onCapacityValueChanged(event:Event):void
{	
	capacityValidator.validate();
	if (!_capacityValidationFailed)
	{
		// format capacity value
		var formattedCapacity:String = capacityFormatter.format(capacityField.text);
		if (formattedCapacity)
		{
			capacityField.text = formattedCapacity;
		}
		
		// do this only for vmax3 arrays
		if (_model.selectedMFcapacity > 0 && !allFlashArraysSelected)
		{
			// set new MF and OS capacities since Total Capacity is changed
			_model.selectedOScapacity -= _model.selectedMFcapacity;
			
			_model.selectedMFcapacity = mfCapFormatter.parseNumber(mfCapacityField.text);
		}
		
		calculateDriveCount();
	}
}

/**
 * Calculates active drive count.</br>
 * Updates DataGrid drive count column for predefined drive mix options.
 * Otherwise calculate Flash drives for AFA model
 */
private function calculateDriveCount():void
{
	if (allFlashArraysSelected)
	{
		// do not calculate for AFA model
		// it will be calculated in next Engines step
		return;
	}
	
	var selectedTier:int = int(tierDrop.selectedItem);
	var driveGroups:Array = TieringUtility_VG3R.getDriveGroups(selectedTier);
	
	for each (var driveGroup:DriveGroup in driveGroups)
	{
		var activeDrives:int = 0;
		
		if (_model.selectedOScapacity > 0)
		{
			// OS host drive number calculation
			activeDrives = TieringUtility_VG3R.calculateNoActives(selectedTier, driveGroup, _model.selectedOScapacity);
		}
		
		if (_model.selectedMFcapacity > 0)
		{
			// MF host drive number calculation
			activeDrives += TieringUtility_VG3R.calculateNoActives(selectedTier, driveGroup, _model.selectedMFcapacity, HostType.Mainframe.name);
		}
		
		driveGroup.activeCount = activeDrives;
	}
}

/**
 * Mainframe capacity input field Focus out and Enter event handlers
 * <p> Formats Capacity value. </p>
 * <p> Updates DataGrid drive count column. </p>
 * 
 */
protected function mfCapValueChanged(event:Event):void
{
	if (!_mfCapacityValidationFailed && !_capacityValidationFailed)
	{
		calculateDriveCount();
	}
}

/**
 * Message pop up close handler when tier selection is made
 * @param event PopUpEvent.CLOSE
 * 
 */
private function onCapacityPopupClosed(event:PopUpEvent):void
{
	if(event.target.result == MessagePopup.RESULT_OK)
	{
		_model.selectedOScapacity = _minUsableCapacity;
		_model.selectedItem = tierDrop.selectedItem;
		
		updateLabels();
	}
	else 
	{
		tierDrop.selectedItem = _model.selectedItem;
		setCapacityValidation();
	}
	
	_customConfigSelected = _model.selectedItem == TieringUtility_VG3R.TIER_CUSTOM_CONFIG;
	if (!_customConfigSelected)
	{
		_model.selectedTiers = setTierDataGridDP(int(_model.selectedItem));
	}
}

/**
 * Sets dropDowns Label functions 
 */
public function setLabelFunctions():void
{
	if (allFlashArraysSelected)
	{
		afaRaidDrop.labelFunction = FilterController.instance.raidDropLabelFunction;
		hostTypeDrop.labelFunction = FilterController.instance.hostTypeDropLabelFunction;
	}
	else
	{
		tierDrop.labelFunction = FilterController.instance.tierLabelFunction;
		driveTypeDrop.labelFunction = FilterController.instance.driveTypeDropLabelFunction;
		driveRaidDrop.labelFunction = FilterController.instance.raidDropLabelFunction;
		driveSizeDrop.labelFunction = FilterController.instance.sizeDropLabelFunction;
	}
}

/** 
 * Tier DataGrid Label function
 */		
public function tierTypeLabelFunction(item:Object, column:GridColumn = null):String
{
	var tierType:int = TieringUtility_VG3R.getTierType((item as DriveGroup).driveDef.type);
	
	return getResString("main", tierType == TieringUtility_VG3R.EFD_TIER ? "WIZARD_EFD_TIER" : 
		tierType == TieringUtility_VG3R.PERF_TIER ? "WIZARD_PERF_TIER" : "WIZARD_CAP_TIER");
}

/**
 * Drive Type DataGrid Label function
 */		
public function driveTypeDataGridLabelFunction(item:Object, column:GridColumn = null):String
{
	return (item as DriveGroup).driveDef.type.name;
}

/**
 *  Drive Raid DataGrid Label function
 */
public function raidDataGridLabelFunction(item:Object, column:GridColumn = null):String
{
	return (item as DriveGroup).driveDef.raid.name;
}

/**
 * Drive Size DataGrid Label function 
 */
public function sizeDataGridLabelFunction(item:Object, column:GridColumn = null):String
{
	return getResString("main", (item as DriveGroup).driveDef.size == DAE.Viking ? "DRIVE_SIZE_VIKING" : "DRIVE_SIZE_VOYAGER");
}

/**
 * DataGrid Usable capacity percent label function
 */
public function percentLabelFunction(item:Object, column:GridColumn = null):String
{
	var percent:String = ((item as DriveGroup).percent * 100).toFixed(1).toString();
	
	return capacityFormatter.parseNumber(percent).toString();
}

