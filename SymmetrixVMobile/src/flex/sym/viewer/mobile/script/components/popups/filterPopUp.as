import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.utils.StringUtil;

import spark.components.Button;
import spark.events.PopUpEvent;

import sym.configurationmodel.common.ConfigurationFilter;
import sym.configurationmodel.utils.TieringUtility_VG3R;
import sym.controller.FilterController;
import sym.controller.SymmController;
import sym.controller.events.FilterChangeRequestEvent;
import sym.controller.events.FilterWizardEvent;
import sym.objectmodel.common.DAE;
import sym.viewer.mobile.script.ViewConstants;
import sym.viewer.mobile.views.components.popups.Engine10kMixPopup;

private static const OFFSET:Number = 20;

public var configFilter:ConfigurationFilter;
public var point:Point;
public var selectedFilterButton:Button;
[Bindable]
public var title:String;
[Bindable]
private var _filterBy:String;
[Bindable]
private var _dataProvider:ArrayCollection;
[Bindable]
private var _selectedIndex:int;
[Bindable]
private var _selectedIndices:Vector.<int> = null;
[Bindable]
public var allowMultipleSelection:Boolean = false;

public var labelWidth:int;
public var textField:TextField = new TextField();

private var wizardPointerPopup:Engine10kMixPopup = new Engine10kMixPopup();

/**
 * DAE type filter values
 */
private var labelValues:Object = {
	1: getResString('main', 'DAE_TYPE_D15'),
	2: getResString('main', 'DAE_TYPE_VANGUARD'),
	3: getResString('main', 'DAE_TYPE_MIXED_D15'),
	4: getResString('main', 'DAE_TYPE_MIXED_VANGUARD'),
	5: getResString('main', 'DAE_TYPE_VOYAGER'),
	6: getResString('main', 'DAE_TYPE_VIKING'),
	7: getResString('main', 'DAE_TYPE_MIXED_VOYAGER')};

public function set filterBy(filter:String):void{
	_filterBy = filter;
	if (_filterBy == ConfigurationFilter.FILTER_ENGINES)
	{
		if(SymmController.instance.isAFA())
		{
			title = getResString('main', 'FILTER_TITLE_ENGINES_AFA');
		}
		else if(SymmController.instance.isPM())
		{
			title = getResString('main', 'FILTER_TITLE_ENGINES_PM');
		}
		else
			title = getResString('main', 'FILTER_TITLE_ENGINES');
	}
	if(_filterBy == ConfigurationFilter.FILTER_DRIVE_TYPE)
	{
		title = getResString('main', 'FILTER_TITLE_DRIVE_TYPE');
	}
	if(_filterBy == ConfigurationFilter.FILTER_DRIVES)
	{
		title = getResString('main', 'FILTER_TITLE_NUMBER_OF_DRIVES');
	}
	if (_filterBy == ConfigurationFilter.FILTER_STORAGE_BAYS)
	{
		title = getResString('main', 'FILTER_TITLE_STORAGE_BAYS');
	}
	if (_filterBy == ConfigurationFilter.FILTER_SYSTEM_BAYS)
	{
		title = getResString('main', 'FILTER_TITLE_SYSTEM_BAYS');
	}
	if (_filterBy == ConfigurationFilter.FILTER_DAE_TYPE)
	{
		title = getResString('main', 'FILTER_TITLE_DAE_TYPE');
	
	}
	if (_filterBy == ConfigurationFilter.FILTER_DAE_COUNT)
	{
		title = getResString('main', 'FILTER_TITLE_DAE_COUNT');
	}
	if (_filterBy == ConfigurationFilter.FILTER_DATA_MOVERS)
	{
		title = getResString('main', 'FILTER_TITLE_DATA_MOVER');
	}
	if (_filterBy == ConfigurationFilter.FILTER_DISPERSED)
	{
		if(SymmController.instance.isAFA() || SymmController.instance.isPM())
		{
			title = getResString('main', 'FILTER_TITLE_DISPERSED_M');
		}
		else
		{
			title = getResString('main', 'FILTER_TITLE_DISPERSED');
		}
	}
	if (_filterBy == ConfigurationFilter.FILTER_TIERING)
	{
		title = getResString('main', 'FILTER_TITLE_TIER');
	
	}
}

private function onInit(event:FlexEvent):void
{
    SymmController.instance.eventHandler.addEventListener(FilterWizardEvent.FILTER_WIZARD_OPEN_REQUEST, onWizardOpenRequest);
}

private function onCreationComplete(event:FlexEvent):void{
	var textFormat:TextFormat = new TextFormat();
	for each(var item:Object in filterList.dataProvider){
		if(item.hasOwnProperty("label")){
			textFormat.size = filterList.getStyle("fontSize");
            textFormat.font = filterList.getStyle("fontFamily");
			var wid:Number = measureString(item.label, textFormat);
			if(wid > labelWidth){
				labelWidth = wid;
			}
		}
	}
	labelWidth = (titleLabel.width > labelWidth) ? (titleLabel.width + 20): labelWidth;

	switch (_filterBy){
		case ConfigurationFilter.FILTER_DAE_TYPE:
			filterList.labelFunction = daeTypeLabelFunction;			
			break;
		case ConfigurationFilter.FILTER_DISPERSED:
			filterList.labelFunction = disperseLabelFunction;			
			break;
		case ConfigurationFilter.FILTER_ENGINES:
			filterList.labelFunction = engineCountLabelFunction;
			break;
		//driveType
		case ConfigurationFilter.FILTER_DRIVE_TYPE:
			filterList.labelFunction = driveTypeLabelFunction;
			break;
		//numberOfDrives
		case ConfigurationFilter.FILTER_DRIVES:
			filterList.labelFunction = numberOfDrivesLabelFunction;
			break;
		case ConfigurationFilter.FILTER_STORAGE_BAYS:
			filterList.labelFunction = storageBayCountLabelFunction;
			break;
		case ConfigurationFilter.FILTER_SYSTEM_BAYS:
			filterList.labelFunction = systemBayCountLabelFunction;
			break;
		case ConfigurationFilter.FILTER_DAE_COUNT:
			filterList.labelFunction = daeCountLabelFunction;
			break;
		case ConfigurationFilter.FILTER_TIERING:
			filterList.labelFunction = FilterController.instance.tierLabelFunction;
			break;
		default:
			filterList.labelFunction = null;
			break;
	} 

	if((SymmController.instance.isAFA() || SymmController.instance.isPM()) && _filterBy == ConfigurationFilter.FILTER_DISPERSED)
	{
		filterList.selectedIndices = selectedIndices;
	}
}

// dae type label function 
private function daeTypeLabelFunction(item:Object):String
{ 
	return item == ConfigurationFilter.NO_DAE_DEFAULT_MFAMILY ? getResString("main", "FILTER_DAE_TYPE_ANY") : labelValues[item];
}

//dispersion label function 
private function disperseLabelFunction(item:Object):String
{
/*	if(is10K() || is10KUnified()){
		return item == ConfigurationFilter.NO_DISPERSED_DEFAULT ? getResString("main", "FILTER_DISPERSED_NO") : getResString("main", "FILTER_DISPERSED_YES");
	}*/
	
	return item == ConfigurationFilter.NO_DISPERSED_DEFAULT ? getResString("main", 
		(SymmController.instance.isAFA() || SymmController.instance.isPM()) ? "FILTER_DISPERSED_NO_VG3R" : "FILTER_DISPERSED_NO") : item.toString();
}

//engine label function - default ANY
private function engineCountLabelFunction(item:Object):String{
	return item == ConfigurationFilter.NO_ENGINE_DEFAULT ? getResString("main", "FILTER_ENGINES_ANY") : item.toString();
}

//dae count label function - default ANY
private function daeCountLabelFunction(item:Object):String{
	return item == ConfigurationFilter.NO_DAE_COUNT_DEFAULT ? getResString("main", "FILTER_DAE_COUNT_ANY") : item.toString();
}

//driveType label function - default ANY
private function driveTypeLabelFunction(item:Object):String{
	return item == ConfigurationFilter.DRIVE_TYPE_DEFAULT ? getResString("main", "FILTER_DAE_COUNT_ANY") : item.toString();
}

//numberOfDrives label function - default ANY
private function numberOfDrivesLabelFunction(item:Object):String{
	return item == ConfigurationFilter.NO_DRIVES_DEFAULT ? getResString("main", "FILTER_NUMBER_OF_DRIVES_ANY") : item.toString();
}

//storage bay label function - default ANY
private function storageBayCountLabelFunction(item:Object):String{
	return item == ConfigurationFilter.NO_STORAGE_BAYS_DEFAULT ? getResString("main", "FILTER_SBAYS_ANY") : item.toString();	
}

//system bay label function - default ANY
private function systemBayCountLabelFunction(item:Object):String{
	return item == ConfigurationFilter.NO_SYSTEM_BAYS_DEFAULT ? getResString("main", "FILTER_SYSTEM_BAYS_ANY") : item.toString();	
}


private function measureString(str:String, format:TextFormat):Number {
	textField.defaultTextFormat = format;
	textField.text = str;
	
	return textField.textWidth + 40;
}
	
private function onWizardOpenRequest(event:FilterWizardEvent):void
{
	this.close();
}


/**
 * sets ConfigurationFilter and it's filter property
 */
private function onListChange(event:Event):void
{
/*    if ( SymmController.instance.is10kGroup() && 
        (SymmController.instance.configFilter.daeType == DAE.MixedD15 || SymmController.instance.configFilter.daeType == DAE.MixedVanguard) && 
        _filterBy == ConfigurationFilter.FILTER_ENGINES &&
        (this.filterList.selectedItem == 2 || this.filterList.selectedItem == 3))
    {
        wizardPointerPopup.engineFilter = this.filterList.selectedItem;
        wizardPointerPopup.addEventListener(PopUpEvent.CLOSE, onPopupClose);
        wizardPointerPopup.open(this, true);
        return;
    }*/
/*    if (SymmController.instance.is10kGroup() && 
       _filterBy == ConfigurationFilter.FILTER_DAE_TYPE && 
        this.filterList.selectedItem == DAE.MixedD15)
	{
		SymmController.instance.eventHandler.dispatchEvent(new FilterWizardEvent(FilterWizardEvent.FILTER_WIZARD_OPEN_REQUEST, true));
		this.close();
	}*/
	if ((SymmController.instance.isAFA() || SymmController.instance.isPM()) && _filterBy == ConfigurationFilter.FILTER_DISPERSED)
	{
		filterDispersedConfigurations();
	}
	else
	{
	    filterConfigurations();
	}
}

private function filterDispersedConfigurations():void
{
	FilterController.instance.filterList(this.filterList);
	
	var filterByValues:Array = [];
	for each(var index:int in this.filterList.selectedIndices)
	{
		filterByValues.push(this.filterList.dataProvider.getItemAt(index));
	}
	
	SymmController.instance.eventHandler.dispatchEvent(new FilterChangeRequestEvent(FilterChangeRequestEvent.CHANGE_REQUEST, "dispersed_m", filterByValues, -1));
}


private function onPopupClose(event:PopUpEvent):void{
    if(event.commit){
        filterConfigurations();
    }
}

/**
 * does configuration filtering
 */
private function filterConfigurations():void{
    this.close();
    if (_filterBy == ConfigurationFilter.FILTER_DAE_TYPE)
    {
        SymmController.instance.eventHandler.dispatchEvent(new FilterChangeRequestEvent(FilterChangeRequestEvent.CHANGE_REQUEST, _filterBy, this.filterList.selectedItem, this.filterList.selectedIndex));
    }
/*	else if(SymmController.instance.is10kGroup() && _filterBy == ConfigurationFilter.FILTER_DISPERSED && this.filterList.selectedItem == getResString('main', 'FILTER_DISPERSED_YES')){
		SymmController.instance.eventHandler.dispatchEvent(new FilterChangeRequestEvent(FilterChangeRequestEvent.CHANGE_REQUEST, _filterBy, ConfigurationFilter.DISPERSED3, this.filterList.selectedIndex));
	}*/
    else
    {
        SymmController.instance.eventHandler.dispatchEvent(new FilterChangeRequestEvent(FilterChangeRequestEvent.CHANGE_REQUEST, _filterBy, this.filterList.selectedItem, this.filterList.selectedIndex));
    }
}

public function set selectedIndex(value:int):void
{
    _selectedIndex = value;
}

public function get selectedIndex():int
{
	return _selectedIndex;
}

public function set selectedIndices(value:Vector.<int>):void
{
	_selectedIndices = value;  
}

public function get selectedIndices():Vector.<int>
{
	return _selectedIndices;
}

private function clickOutside(event:MouseEvent):void
{
    this.close();
}

public function get dataProvider():ArrayCollection
{
    return _dataProvider;
}

public function set dataProvider(dp:ArrayCollection):void
{
    _dataProvider = dp;
}