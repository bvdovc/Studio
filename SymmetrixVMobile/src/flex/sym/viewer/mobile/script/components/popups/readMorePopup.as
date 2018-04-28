import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;

import mx.core.FlexGlobals;
import mx.events.FlexEvent;

import sym.viewer.mobile.views.components.popups.ReadMorePopup;

public static const NORMAL_MESSAGE:int = 0;
public static const INFO_MESSAGE:int = 1;
public static const WARNING_MESSAGE:int = 2;
public static const ERROR_MESSAGE:int = 3;

public static const RESULT_OK:int = 0;
public static const RESULT_NO:int = 1;
public static const RESULT_CANCEL:int = 2;

public static const BUTTON_OK:uint = 0x1;
public static const BUTTON_NO:uint = 0x2;
public static const BUTTON_CANCEL:uint = 0x4;
public static const BUTTON_YES:uint = 0x8;

[Embed(source = "/images/info.png")]
private static const infoImg:Class;

[Embed(source = "/images/warning.png")]
private static const warningImg:Class;

[Embed(source = "/images/error.png")]
private static const errorImg:Class;

[Bindable]
private var _title:String;

[Bindable]
private var _message:String;

[Bindable]
private var _type:int = NORMAL_MESSAGE; 

private var _result:int = RESULT_CANCEL;
private var _buttons:uint = BUTTON_OK;


public function set title(value:String):void
{
	_title = value;
}

public function set message(value:String):void
{
	_message = value;
}

public function set type(value:int):void
{
	_type = value; 
}

public function set buttons(value:uint):void
{
	_buttons = value;
}

public function get result():int
{
	return _result;
}

/**
 * creation complete handler
 * Positions popup in the middle of the app frame
 */
protected function skinnablepopupcontainer1_creationCompleteHandler(event:FlexEvent):void
{
	if(_type == INFO_MESSAGE){
		this.imgIcon.source = new infoImg();
	}
	else if(_type == WARNING_MESSAGE){
		this.imgIcon.source = new warningImg();
	}
	else if(_type == ERROR_MESSAGE){
		this.imgIcon.source = new errorImg();
	}
	
	this.x = (FlexGlobals.topLevelApplication.width - this.width) / 2;
	this.y = (FlexGlobals.topLevelApplication.height - this.height) / 2;
	
	this.btnOK.visible = this.btnOK.includeInLayout = Boolean(_buttons & BUTTON_OK);
	this.btnNO.visible = this.btnNO.includeInLayout = Boolean(_buttons & BUTTON_NO);
	this.btnYES.visible = this.btnYES.includeInLayout = Boolean(_buttons & BUTTON_YES);
	this.btnCancel.visible = this.btnCancel.includeInLayout = Boolean(_buttons & BUTTON_CANCEL);
	
}

/**
 * update complete handler
 * pop up central positioning
 */
protected function messagePopUpUpdateCompleteHandler(event:FlexEvent):void {
	event.target.x = FlexGlobals.topLevelApplication.width/2 - event.target.width/2;
	event.target.y  = FlexGlobals.topLevelApplication.height/2 - event.target.height/2;
}

/**
 * buttons click handler
 */
protected function buttonClickHandler(event:MouseEvent):void
{
	if (event.target == this.btnOK || event.target == this.btnYES)
	{
		_result = RESULT_OK;
	}
	else if (event.target == this.btnNO)
	{
		_result = RESULT_NO;
	}
	else
	{
		_result = RESULT_CANCEL;
	}
	this.close();
}

/**
 * opens popup with message of given type
 */
public static function open(message:String, title:String, owner:DisplayObjectContainer, type:int = NORMAL_MESSAGE, buttons:uint = BUTTON_OK):ReadMorePopup
{
	var popup:ReadMorePopup = new ReadMorePopup();
	popup.message = message;
	popup.title = title;
	popup.type = type;
	popup.buttons = buttons;
	popup.open(owner, true);
	
	return popup;
}

public override function open(owner:DisplayObjectContainer, modal:Boolean=false):void
{
	super.open(owner, modal);
	
	// sets focus to popUp
	this.stage.focus = this;
}

public override function close(commit:Boolean=false, data:*=null):void
{
	super.close(commit, data);
	
	this.stage.focus = null;
}
