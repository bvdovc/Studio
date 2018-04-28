import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.core.ClassFactory;
import mx.core.IFactory;
import mx.events.FlexEvent;
import mx.utils.StringUtil;
import mx.resources.ResourceManager;

import spark.components.gridClasses.GridColumn;
import spark.events.GridEvent;
import spark.events.GridItemEditorEvent;
import spark.events.IndexChangeEvent;
import spark.skins.spark.DefaultItemRenderer;

import sym.configurationmodel.utils.TieringUtility_VG3R;
import sym.controller.SymmController;
import sym.controller.events.DropDownEvent;
import sym.controller.events.FilterWizardEvent;
import sym.controller.events.WizardDataGridEvent;
import sym.controller.model.FilterWizardPortsStateModel;
import sym.controller.model.FilterWizardTierStateModel;
import sym.objectmodel.common.Constants;
import sym.objectmodel.common.DAE;
import sym.objectmodel.common.Engine;
import sym.objectmodel.common.EnginePort;
import sym.objectmodel.common.EnginePortGroup;
import sym.objectmodel.driveUtils.enum.HostType;
import sym.viewer.mobile.utils.FileSaveUtility;
import sym.viewer.mobile.views.components.wizard.CustomGridPortItemRenderer;
import sym.viewer.mobile.views.components.wizard.CustomWizardGridRenderer;
import sym.viewer.mobile.views.skins.grid.WizardDataGridSkin;


// wizard grid port types
public static const FIBRE_CHANNEL_TYPE:String = "Fibre Channel";
public static const MAINFRAME_TYPE:String = "FICON";
public static const ISCSI_TYPE:String = "iSCSI";
public static const GIGE_SRDF_TYPE:String = "GigE SRDF";
public static const FILE_TYPE:String = "Ethernet File";
public static const COMPRESSION_TYPE:String = "Compression";

// wizard grid port speeds
public static const WIZARD_PORT_SPEED_8_16GB:String = "{0}/{1}/{2} Gb/s";
public static const WIZARD_PORT_SPEED:String = "{0} Gb/s";

private static const UNKNOWN_VALUE:String = "N/A";

public static const DEFAULT_GRID_COLUMNS_LENGTH:int = 4;

private static var _FC_PORT_GROUP:EnginePortGroup;
private static var _FICON_PORT_GROUP:EnginePortGroup;
private static var _ISCSI_PORT_GROUP:EnginePortGroup;
private static var _FILE_PORT_GROUP:EnginePortGroup;
private static var _COMPRESSION_PORT_GROUP:EnginePortGroup;


[Bindable]
private var _portGridDataProvider:ArrayCollection;

private var _model:FilterWizardPortsStateModel;

[Bindable]
private var _columnCount:int;

[Bindable]
public var hostProtocolDP:ArrayCollection;

[Bindable]
public var afaSelected:Boolean = false;

/**
 * Engine Port state model
 */
public function get model():FilterWizardPortsStateModel
{
	return _model;
}

public function set model(portModel:FilterWizardPortsStateModel):void
{
	_model = portModel;
	
	// disable File checkbox if MF is selected
	fileCapacity.enabled = _model.selectedItem != HostType.MAINFRAME_HOST && _model.fileCapacityEnabled;
	
	fileCapacity.selected = _model.fileCapacitySelected;
	
	_columnCount = (_model.dataProvider.getItemAt(0) as EnginePortGroup).engineCountMap.length + 3;
	
	// add missing "Engine" columns
	if (portGrid.columnsLength < _columnCount)
	{
		var noEnginesToAdd:int = _columnCount - portGrid.columnsLength;
		for (var i:int = 0; i < noEnginesToAdd; i++)
		{
			addEngineColumn(total, total.columnIndex - 1);
		}
	}
	// remove redudant "Engine columns"
	else if (_columnCount < portGrid.columnsLength)
	{
		var noEnginesToRemove:int = portGrid.columnsLength - _columnCount;
		for (var j:int = 0; j < noEnginesToRemove; j++)
		{
			removeEngineColumn(portGrid.columns.getItemAt(3) as GridColumn);
		}
		
		// update engine column labels
		if (portGrid.columnsLength > DEFAULT_GRID_COLUMNS_LENGTH)
		{
			var indLength:int = (portGrid.columnsLength - DEFAULT_GRID_COLUMNS_LENGTH) + 1;
			for (var ind:int = 2; ind <= indLength; ind++)
			{
				(portGrid.columns.getItemAt(ind + 1) as GridColumn).dataField = Constants.WIZARD_PORT_GRID_NO_ENGINE_COLUMN + " " + ind;
			}
		}
	}
	
	// add item renderer function
	for (var col:int = 0; col < this.portGrid.columnsLength; col++)
	{
		(this.portGrid.columns.getItemAt(col) as GridColumn).itemRendererFunction = customItemRendererFunction;
	}
	
	// set protocol engine port groups
	_FC_PORT_GROUP = EnginePortGroup.create(EnginePort.FC_PORT_PROTOTYPE, _columnCount-3, _model.selectedItem.toString(), true);
	_FICON_PORT_GROUP = EnginePortGroup.create(EnginePort.FICON_PORT_PROTOTYPE, _columnCount-3, _model.selectedItem.toString(), true);
	_ISCSI_PORT_GROUP = EnginePortGroup.create(EnginePort.ISCSI_PORT_PROTOTYPE, _columnCount-3, _model.selectedItem.toString(), true);	
	
	this.setDataProviders();
}

/**
 * Sets grid, host protocol, grid view data providers 
 */
private function setDataProviders():void
{
	// set grid's data provider, columns, etc.
	if (!_portGridDataProvider)
	{
		_portGridDataProvider = new ArrayCollection();
		
		_COMPRESSION_PORT_GROUP = EnginePortGroup.create(EnginePort.COMPRESSION_PROTOTYPE, _columnCount-3, model.selectedItem.toString());
	}
	else if (_portGridDataProvider.length > 0)
	{
		_portGridDataProvider.removeAll();
	}
	
	// add Compression module to the Grid provider
	// for AFA only or if module grid view is chosen
	var compressionExists:Boolean = false;
	for each (var row:EnginePortGroup in _model.dataProvider)
	{
		if (row.port.type == EnginePort.COMPRESSION_ASTEROID)
		{
			compressionExists = true;
			break;
		}
	}
	
	if (!compressionExists && isCompressionVisible(model.selectedItem))
	{
		_model.dataProvider.addItem(_COMPRESSION_PORT_GROUP);
	}
	
	_portGridDataProvider.addAll(_model.dataProvider);
	
	// set host protocol Drop data provider
	if (afaSelected)
	{
		var tempDP:ArrayCollection = new ArrayCollection(FilterWizardPortsStateModel.HOST_PROTOCOLS[model.selectedItem]);
		hostProtocolDP = new ArrayCollection(tempDP.toArray());
		
		// allow multiple selection only if provider has minimum 2 items
		hostProtocolDrop.allowMultipleSelection = hostProtocolDP.length > 1;
		
		filterHostProtocolDP(0);
	}
	
    var GRID_VIEW_TYPES:Array = [ResourceManager.getInstance().getString("main", "STATE_ENGINE_PORTS_GRID__PORT_VIEW"), ResourceManager.getInstance().getString("main", "STATE_ENGINE_PORTS_GRID_MODULE_VIEW")];

	// set grid view dropDown provider
	//if (!gridViewDrop.dataProvider)
	gridViewDrop.dataProvider = new ArrayCollection(GRID_VIEW_TYPES);
	
	gridViewDrop.selectedItem = _model.portViewModel ? GRID_VIEW_TYPES[0] : GRID_VIEW_TYPES[1];
}

/**
 * Examines if Compression module row is visible/displayed in Grid 
 * and therefore default placed in engine reseved slot.
 * @return <code> true </code>if examined array is 450/850F AFA only.
 * Otherwise is <code>false</code>.
 * 
 */		
public function isCompressionVisible(hostType:Object = HostType.OPEN_SYSTEMS):Boolean
{
	// for 450/850 AFA compression row is visible since Compression occupies Slot 9 (FE slot) and therefore there are 3 slot total for FE
	// for 250F we should not show Compresssion since it occupies Slot 7 as default which is not FE slot and therefore user can select all 4 FE modules
	// also only visible in OS systems
	return (is450F() || is950F()) && hostType == HostType.OPEN_SYSTEMS;
}

/**
 * Use separate item renderers - one for Compression row cells to disable it
 * and one for other typical rows in Grid 
 */
private function customItemRendererFunction(item:Object, column:GridColumn):IFactory
{
	var epg:EnginePortGroup = item as EnginePortGroup;
	
	if (epg && epg.port.type == EnginePort.COMPRESSION_ASTEROID)
		return new ClassFactory(CustomGridPortItemRenderer);
	
	return new ClassFactory(CustomWizardGridRenderer);
}

/**
 * Gets description of selected host type and engine ports for the summary page 
 */
public function get enginePortInfo():String
{
	var engineConfigInfo:Array = [];
	var hostInfo:String;
	var portInfo:String;
	
	// host type info
	hostInfo = getResString("main", model.selectedItem == HostType.OPEN_SYSTEMS ? "SUMMARY_OS_PORTS" : 
		model.selectedItem == HostType.MAINFRAME_HOST ? "SUMMARY_MF_PORTS" : "SUMMARY_MIXED_PORTS") + "\n";
	
	for each (var epg:EnginePortGroup in _portGridDataProvider)
	{
		// Engine Port info
		if (epg.totalPortCount == 0)
			continue;
		
		portInfo = epg.totalPortCount + " x " + "\""+ portSpeedLabelFunction(epg) + " " + portTypeLabelFunction(epg) + "\"";
		
		engineConfigInfo.push(portInfo);
	}	
	
	for (var i:int = 0; i < engineConfigInfo.length; i++)
	{
/*		if (SymmController.instance.isMFamily())
		{
			if (i == 1 || i == 2 || i == 4)
			{
				engineConfigInfo[i] = "\n" + engineConfigInfo[i];
			}
			
			if (i == 3)
			{
				engineConfigInfo[i] = "\n" + engineConfigInfo[i];
			}
		}*/
		if (i >= 1)
		{
			engineConfigInfo[i] = "\n" + engineConfigInfo[i];
		}
	}
	
	return hostInfo + (engineConfigInfo.toString()).split(",").join(" ");
}

/**
 * Preinitialize event handler. <br/>
 * Add here event listeners if needed.
 */
protected function onPreinitialize(event:FlexEvent):void
{
	this.portGrid.addEventListener(GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_STARTING, onGridItemEditorStart);
	
}

/**
 * DataGrid item editor session starting event handler.<br/>
 * <p> If Compression module row cell is selected forbid its editor to open. </p>
 */
private function onGridItemEditorStart(event:GridItemEditorEvent):void
{
	// disable editting of Compression module row cells if compression is not visible
	if ((SymmController.instance.isAFA() || SymmController.instance.isPM()) && event.rowIndex == this.portGrid.dataProvider.length -1 && isCompressionVisible(model.selectedItem))
		event.preventDefault();
}

/**
 * Inserts "Engine "column to the left of specified column
 * @param column indicates grid's column to the right of inserted column
 * @param column indicates engine index in new column name
 */
private function addEngineColumn(column:GridColumn, engineInd:int):void
{
	var newColumn:GridColumn = new GridColumn();
	
	newColumn.dataField = Constants.WIZARD_PORT_GRID_NO_ENGINE_COLUMN + " " + engineInd;
	newColumn.labelFunction = engineLabelFunction;
	
	this.portGrid.columns.addItemAt(newColumn, column.columnIndex);
}

/**
 * Removes engine column from DataGrid 
 */
private function removeEngineColumn(column:GridColumn):void
{
	this.portGrid.columns.removeItemAt(column.columnIndex);
}

/**
 * Handler when user interacts with File <code> CheckBox, </code>
 * and traks <code> CheckBox </code> selection changes.
 * <p>
 * If quick tier solution is currently selected and CheckBox is selected 
 * then tier solution is automatically switched to Custom tier solution
 * </p>
 * <p>
 * If custom tier solution is currently selected and CheckBox is selected
 * DropDowns will be filtered in such way that only Flash drives will remain as option
 * and other Drive types will be removed from DataGrid
 * </p>
 * <p>
 * If Custom tier solution is selected and CheckBox is not selected 
 * then DropDowns will be filtered in such way that all Drive Types are included
 * </p> 
 */
protected function fileCapacity_changeHandler(event:Event):void
{
	var fileRowInd:int;
	
	// File is selected
	if (fileCapacity.selected)
	{
		// add new File port group to the grid dataProvider
		// File should be added before Compression if exist, otherwise is added as last item
		_FILE_PORT_GROUP = EnginePortGroup.create(EnginePort.FILE_PORT_PROTOTYPE, _columnCount-3, model.selectedItem.toString());
		fileRowInd = isCompressionVisible() ? (_portGridDataProvider.length - 1) : _portGridDataProvider.length; 
		
		addItemToGrid(_FILE_PORT_GROUP, fileRowInd);
	}
	// File isn't selected
	else
	{
		// remove File from grid data providers
		fileRowInd = isCompressionVisible() ? (_portGridDataProvider.length - 2) : _portGridDataProvider.length - 1; 
		_portGridDataProvider.removeItemAt(fileRowInd);
	}
	// reSet model's dataProvider
	_model.dataProvider.removeAll();
	_model.dataProvider.addAll(_portGridDataProvider);
	
	// set model's fileCapacity flag
	_model.fileCapacitySelected = fileCapacity.selected;
	
	// check host protocol provider
	filterHostProtocolDP(0);
}

/**
 * Grid view type DropDown change handler
 */
protected function gridViewDrop_changeHandler(event:IndexChangeEvent):void
{
	// save grid view type changes to model
	_model.portViewModel = gridViewDrop.dataProvider.getItemAt(event.newIndex) == FilterWizardPortsStateModel.PORT_VIEW;
	
	// refresh grid provider in order to properly display port/module count values
	_portGridDataProvider.refresh();
}

/**
 * Host Protocol DropDown change handler 
 */
protected function onHostProtocolChange(event:IndexChangeEvent):void
{
	var epg:EnginePortGroup;
	
	if (model.selectedProtocol.length < hostProtocolDrop.selectedItems.length)
	{
		// this means one additional item is selected
		var newSelectedProtocol:Object = hostProtocolDrop.dataProvider.getItemAt(event.newIndex);
		var rowIndex:int;
		
		// add new protocol to the DataGrid provider
		if (newSelectedProtocol == FilterWizardPortsStateModel.FC_PROTOCOL)
		{
			epg = _FC_PORT_GROUP;
			rowIndex = 0;
		}
		if (newSelectedProtocol == FilterWizardPortsStateModel.ISCSI_PROTOCOL)
		{
			epg = _ISCSI_PORT_GROUP;
			rowIndex = hostProtocolDrop.selectedItems.length - 1;
		}
		if (newSelectedProtocol == FilterWizardPortsStateModel.FICON_PROTOCOL)
		{
			epg = _FICON_PORT_GROUP;
			rowIndex = hostProtocolDrop.selectedItems.length == 2 && 
				hostProtocolDrop.selectedItems[1] == FilterWizardPortsStateModel.ISCSI_PROTOCOL ? 0 : 1;
		}
		
		addItemToGrid(epg, rowIndex);
	}
	
	if (model.selectedProtocol.length > hostProtocolDrop.selectedItems.length ||
		model.selectedProtocol.length == hostProtocolDrop.selectedItems.length)
	{
		// one item is deselected from list
		
		var protocolToRemove:Object;
		var addFC:Boolean = false;
		
		if (model.selectedProtocol.length > hostProtocolDrop.selectedItems.length)
		{
			for each (var hp:Object in model.selectedProtocol)
			{
				if (hostProtocolDrop.selectedItems.indexOf(hp) == -1)
				{
					// find protocol item which was in the previous selection
					protocolToRemove = hp;
					break;
				}
			}
		}
		else
		{
			if (model.selectedProtocol[0] != FilterWizardPortsStateModel.FC_PROTOCOL)
			{
				protocolToRemove = model.selectedProtocol[0];
				addFC = true;
			}
			else 
				return;
		}
		
		for each (var epg1:EnginePortGroup in _portGridDataProvider)
		{
			if (protocolToRemove == FilterWizardPortsStateModel.FC_PROTOCOL && epg1.port.isFC ||
				protocolToRemove == FilterWizardPortsStateModel.ISCSI_PROTOCOL && epg1.port.isFCOE_ISCSI ||
				protocolToRemove == FilterWizardPortsStateModel.FICON_PROTOCOL && epg1.port.isMainframe)
			{
				epg = epg1;
				break;
			}
		}
		
		// remove item from DataGrid
		_portGridDataProvider.removeItemAt(_portGridDataProvider.getItemIndex(epg));	
		
		if (addFC)
		{
			// also, add FC protocol item to the Grid
			addItemToGrid(_FC_PORT_GROUP, 0);
		}
	}
	
	// FILE checkbox visibility
	checkFileVisibility(0);
	
	// filter protocol provider, and reset selected indices for protocol dropDown
	filterHostProtocolDP(0);
	
	var tempArray:Vector.<int> = new Vector.<int>();
	for (var i:int = 0; i < hostProtocolDrop.selectedItems.length; i++)
	{
		tempArray.push(hostProtocolDrop.dataProvider.getItemIndex(hostProtocolDrop.selectedItems[i]));
	}
	hostProtocolDrop.selectedIndices = tempArray;
	
	// save selected protocol(s) to model
	model.selectedProtocol = hostProtocolDrop.selectedItems;
	
	// reSet model's dataProvider
	_model.dataProvider.removeAll();
	_model.dataProvider.addAll(_portGridDataProvider);
}

/**
 * Check if FILE checkbox is in enabled/disabled state
 */
public function checkFileVisibility(engineInd:int):void
{
	// if engine index != 0 there is no need to check FILE checkbox visibility,it should stay as it is
	if (_model.selectedItem != HostType.MAINFRAME_HOST && engineInd == 0 && !this.fileCapacity.selected)
	{
		// Disable Filecheckbox if total port count per first Engine or total modules havve reached the maximum
		model.fileCapacityEnabled = fileCapacity.enabled = !EnginePortGroup.allSlotsPopulated(_portGridDataProvider.toArray(), engineInd);
	}
}

/**
 * Check and filter host protocol data provider if port/module count has reached max limit
 */
public function filterHostProtocolDP(engineInd:int):void
{
	if (SymmController.instance.isAFA() || SymmController.instance.isPM())
	{
/*		if (EnginePortGroup.allSlotsPopulated(_portGridDataProvider.toArray(), engineInd))
		{
			// if there is no empty slots
			// remove all unselected host protocols from provider
			var dp:Array = hostProtocolDP.toArray();
			
			for each (var hp:Object in dp)
			{
				if (hostProtocolDrop.selectedItems.indexOf(hp) == -1)
				{
					hostProtocolDP.removeItemAt(hostProtocolDP.getItemIndex(hp));
				}
			}
		}
		else
		{
			// check if there are all host protocols vaules within provider
			var hostProvider:Array = FilterWizardPortsStateModel.HOST_PROTOCOLS[model.selectedItem];
			
			if (hostProtocolDP.length != hostProvider.length)
			{
				hostProtocolDP.removeAll();
				hostProtocolDP.addAll(new ArrayCollection(hostProvider));
			}
		}*/
		
		var hostProvider:Array = FilterWizardPortsStateModel.HOST_PROTOCOLS[model.selectedItem];
		
		if (hostProtocolDP.length != hostProvider.length)
		{
			hostProtocolDP.removeAll();
			hostProtocolDP.addAll(new ArrayCollection(hostProvider));
		}
	}
}

/**
 * Adds item to the specific place in the DataGrid
 * @param item indicates EnginePortGroup instance
 * @param index indicates row index in the Grid
 */
private function addItemToGrid(item:Object, rowIndex:int):void
{
	// add port group item to the Grid provider
	_portGridDataProvider.addItemAt(item, rowIndex);
	
	// ensure that added row is always visible
	portGrid.ensureCellIsVisible(rowIndex);
	portGrid.setSelectedIndex(rowIndex);
	
	setDefaultSelectionColor();
}

/**
 * Sets Grid selection color to its default skin color values 
 */
private function setDefaultSelectionColor():void
{
	this.portGrid.setStyle("rollOverColor", WizardDataGridSkin.defaultRollOverColor);
	this.portGrid.setStyle("selectionColor", WizardDataGridSkin.defaultSelectionColor);
}

/** 
 * Port Type DataGrid Label function
 */		
private function portTypeLabelFunction(item:Object, column:GridColumn = null):String
{
	var epg:EnginePortGroup = item as EnginePortGroup;
	
	return epg.port.isFC ? FIBRE_CHANNEL_TYPE : epg.port.isMainframe ? MAINFRAME_TYPE : epg.port.isFCOE_ISCSI ? ISCSI_TYPE :
		epg.port.isSRDF ? GIGE_SRDF_TYPE : epg.port.isFile ? FILE_TYPE : COMPRESSION_TYPE;
}

/** 
 * Port Speed DataGrid Label function
 */		
public function portSpeedLabelFunction(item:Object, column:GridColumn = null):String
{
	var pg:EnginePortGroup = item as EnginePortGroup;
	
	if (pg.port.type == EnginePort.COMPRESSION_ASTEROID)
		return UNKNOWN_VALUE;
	
	if (column != null && (pg.port.speed == EnginePort.PORT_SPEED_16GB || pg.port.speed == EnginePort.PORT_SPEED_8GB))
		return StringUtil.substitute(WIZARD_PORT_SPEED_8_16GB, pg.speed, pg.speed/2, pg.speed/4);
	
	return StringUtil.substitute(WIZARD_PORT_SPEED, pg.speed);
	
}

/** 
 * Engine index DataGrid Label function
 */		
private function engineLabelFunction(item:Object, column:GridColumn):String
{
	var epg:EnginePortGroup = item as EnginePortGroup;
	var portCount:int = epg.engineCountMap[column.columnIndex - 2];
	
	if (epg.port.type == EnginePort.COMPRESSION_ASTEROID && model.portViewModel)
		return UNKNOWN_VALUE;
	
	// if module view is selected, display module count values
	// otherwise display port count
	return model.portViewModel ? portCount.toString() : EnginePortGroup.convertPortsToModules(epg, portCount).toString();
}


/** 
 * Total column DataGrid Label function
 */		
private function totalCountLabelFunction(item:Object, column:GridColumn):String
{
	var epg:EnginePortGroup = item as EnginePortGroup;
	
	if (epg.port.type == EnginePort.COMPRESSION_ASTEROID && model.portViewModel)
		return UNKNOWN_VALUE;
	
	return model.portViewModel ? epg.totalPortCount.toString() : epg.totalModuleCount.toString();
		
}





