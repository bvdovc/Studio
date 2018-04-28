import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;

import mx.charts.renderers.DiamondItemRenderer;
import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.events.FlexEvent;
import mx.events.ResizeEvent;

import spark.events.IndexChangeEvent;

import sym.configurationmodel.common.ConfigurationFilter;
import sym.controller.FilterController;
import sym.controller.SymmController;
import sym.controller.events.DropDownEvent;

[Bindable]
private var _prompt:String = "";

[Bindable]
private var _selectedItem:Object;

[Bindable]
private var _selectedItems:Vector.<Object> = null;

[Bindable]
private var _selectedIndices:Vector.<int> = null;

[Bindable]
private var _selectedLabel:String;

[Bindable]
private var _labelField:String;

[Bindable]
private var _labelFunction:Function;

private var _openListEvent:Boolean = false;

[Bindable]
private var _dataProvider:IList;	

[Bindable]
public var allowMultipleSelection:Boolean = false;

/**
 * <p> Default - sets List's <code> requestedRowCount </code> to the number of items in the list.</p>
 * <p> Otherwise <code> requestedRowCount </code> is set to the user custom input value
 */
[Bindable]
public var maxRowCount:int;

/**
 *  The prompt for the DropDown component
 *  The prompt is a deafult String that is displayed in the
 *  DropDown when <code>selectedIndex</code> = -1.
 */
public function get prompt():String
{
	return _prompt;
}

public function set prompt(val:String):void
{
	selectedItem = _prompt = val;
}

/**
 * DropDown list's dataProvider 
 */
public function get dataProvider():IList
{
	return _dataProvider;
}

public function set dataProvider(dp:IList):void
{
	_dataProvider = dp;
	
	bindingList.typicalItem = getTypicalContentItem();
}

/**
 * sets label field
 */
public function set labelField(value:String):void
{
	_labelField = value;
}

/**
 * gets label field 
 */
public function get labelField():String
{
	return _labelField;
}

/**
 * sets label function
 */
public function set labelFunction(value:Function):void
{
	_labelFunction = value;
}

/**
 * gets label function
 */
public function get labelFunction():Function
{
	return _labelFunction;
}

/**
 * gets selected index
 */
public function get selectedIndex():int	
{
	if (bindingList)
	{
		return bindingList.selectedIndex;
	}
	else if (dataProvider && selectedItem)
	{
		return dataProvider.getItemIndex(selectedItem);
	}
	return -1;
}

/**
 * sets selected index
 */
public function set selectedIndex(value:int):void
{
	if (bindingList)
	{
		if (dataProvider)
		{
			_selectedItem = dataProvider.getItemAt(value);
			bindingList.selectedItem = _selectedItem;
			updateLabel();
		}
	}
}

/**
 * gets selected Indices
 */
public function get selectedIndices():Vector.<int>
{
	return _selectedIndices;	
}

/**
 * sets selected index
 */
public function set selectedIndices(value:Vector.<int>):void
{
	if (bindingList)
	{
		if (dataProvider)
		{
			_selectedIndices = value;
			
			var tempArray:Vector.<Object> = new Vector.<Object>();
			for (var i:int = 0; i < value.length; i++)
			{
				tempArray.push(dataProvider.getItemAt(value[i]));
			}
			
			_selectedItems = tempArray;
			bindingList.selectedItems = _selectedItems;
			
			updateLabel();
		}
	}
}

public function get selectedItems():Vector.<Object>
{
	return _selectedItems;
}

public function set selectedItems(value:Vector.<Object>):void
{
	_selectedItems = value;
}

/**
 *  gets selected item object
 */
public function get selectedItem():Object
{
    return _selectedItem;
}

/**
 * Checks if currently selected item is the Prompt(Default) string
 */
public function isDefaultSelected():Boolean
{
	return _selectedItem == _prompt;
}

/**
 * sets selected item
 * updates label
 */
public function set selectedItem(value:Object):void
{
    if (value == null || !dataProvider || dataProvider.getItemIndex(value) == -1)
    {
        _selectedItem = _selectedLabel = _prompt;
        return;
    }

    _selectedItem = value;
    if (bindingList)
    {
        bindingList.selectedItem = _selectedItem;
    }
    updateLabel();
}

/**
 * selection change handler
 */
private function onListIndexChanged(event:IndexChangeEvent):void
{
	if (allowMultipleSelection)
	{
		FilterController.instance.filterList(this.bindingList);
		
		_selectedItems = bindingList.selectedItems;
	}
	else
	{
		_selectedItem = dataProvider.getItemAt(event.newIndex);
	    this.dropListAnchor.displayPopUp = false;
		this.dispatchEvent(new DropDownEvent(DropDownEvent.HIDE));
	}
    this.dispatchEvent(event);
	
    updateLabel();
}

/**
 * updates selected item label
 */
private function updateLabel():void
{
	var selectedObject:Object;
	
	if (allowMultipleSelection)
	{
		FilterController.instance.currentStateString == FilterController.STATE_DISPERSED ? 
			_selectedItems.sort(Array.NUMERIC) : _selectedItems.sort(FilterController.instance.sortByHostProtocol);
		
		selectedObject = _selectedItems;
	}
	else
	{
		selectedObject = _selectedItem;	
	}
	
    if (!selectedObject)
        _selectedLabel = "";

    _selectedLabel = _labelFunction != null ? ((SymmController.instance.isAFA() || SymmController.instance.isPM()) && FilterController.instance.currentStateString == FilterController.STATE_DISPERSED) ? _labelFunction(selectedObject, false) : 
		_labelFunction(selectedObject) : (_labelField ? selectedObject[_labelField] : selectedObject.toString());
}

/**
 * DropDown preinitialize handler.<br/>
 * Adds resize listener to the dropDown's parentDocument object 
 */
protected function dropDown_preinitializeHandler(event:FlexEvent):void
{
	if (this.parentDocument)
		this.parentDocument.addEventListener(ResizeEvent.RESIZE, onAppResize);	
}

/**
 * Application resize handler.<br/>
 * Recalculate popUp list position if list is displayed 
 */
protected function onAppResize(event:ResizeEvent):void
{
	if (dropListAnchor.displayPopUp)
		dropListAnchor.invalidateDisplayList();
}

/**
 * mouse out click handler
 * removes popup
 */
private function onMouseDownOut(event:MouseEvent):void
{
    dropListAnchor.displayPopUp = false;
	this.dispatchEvent(new DropDownEvent(DropDownEvent.HIDE));
}

/**
 * dropdown click handler
 * opens popup
 */
private function clickHandler(event:MouseEvent):void
{
    if (!this.dropListAnchor.displayPopUp)
    {
        this.dropListAnchor.displayPopUp = true;
        _openListEvent = true;
		allowMultipleSelection ? bindingList.selectedItems = selectedItems : bindingList.selectedItem = _selectedItem;
		this.dispatchEvent(new DropDownEvent(DropDownEvent.SHOW));
    }
}

/**
 * List click handler, should close popup if selection is not changed (when clicking selected item again)
 */
private function listClickHandler(event:MouseEvent):void
{
	if (!allowMultipleSelection)
	{
		var sameSelection:Boolean = _labelField ? _selectedItem[_labelField] == bindingList.selectedItem[_labelField] : 
												_selectedItem == bindingList.selectedItem;
		if (sameSelection) 
		{
			this.dropListAnchor.displayPopUp = false;
			this.dispatchEvent(new DropDownEvent(DropDownEvent.HIDE));
		}
		_openListEvent = false;
	}
}

/**
 * list outside click
 * closes popup
 */
private function onListMouseDownOutside(event:MouseEvent):void
{
    this.dropListAnchor.displayPopUp = false;
	this.dispatchEvent(new DropDownEvent(DropDownEvent.HIDE));
}

/**
 * Calculates DropDown list's content max width for its dataProvider members 
 * @return typical data item to determine the default size of the list
 */
private function getTypicalContentItem():Object
{
	var textField:TextField = new TextField();
	var format:TextFormat = new TextFormat();
	
	format.font = bindingList.getStyle("font-family");
	format.size = bindingList.getStyle("font-size");
	textField.defaultTextFormat = format;
	
	for each (var item:Object in _dataProvider)
	{
		var typicalItem:Object;
		var itemWidth:Number;
		
		textField.text = _labelFunction != null ? _labelFunction(item) : (_labelField ? item[_labelField] : item.toString());
		itemWidth = textField.textWidth;
		
		if (item == _dataProvider.getItemAt(0))
		{
			var calculatedWidth:Number = itemWidth;
		}
		
		if (itemWidth > calculatedWidth)
		{
			calculatedWidth = itemWidth;
			typicalItem = item;
		}
	}
	
	return typicalItem;
}