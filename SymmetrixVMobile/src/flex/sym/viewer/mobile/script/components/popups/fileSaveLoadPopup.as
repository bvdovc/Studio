import flash.events.MouseEvent;

import mx.core.FlexGlobals;
import mx.events.FlexEvent;

import spark.components.TextInput;
import spark.events.PopUpEvent;

import sym.controller.SymmController;
import sym.controller.events.ExportFileEvent;

[Bindable]
public var title:String;

[Bindable]
public var prompt:String;

[Bindable]
public var isXml:Boolean;

[Bindable]
public var isVisible:Boolean = true;

private function yesButtonClicked(event:MouseEvent):void
{
	var filename:String;
	
	if(fileNameTextInput.text.length == 0){
		filename = prompt;
	}
	else{
		filename = fileNameTextInput.text;
	}
	
	this.isVisible = false;
	
	SymmController.instance.eventHandler.dispatchEvent(new ExportFileEvent(ExportFileEvent.EXPORT_REQUEST, filename, isXml));
	//this.close();
}

private function closePopUp(event:MouseEvent):void{
	this.fileNameTextInput.text = "";
	this.close();
}

/**
 * PopUp open handler. <br/>
 * PopUp should be always visible when opened. 
 */
protected function onPopUpOpened(event:PopUpEvent):void
{
	this.isVisible = true;
}

/**
 * update co mplete handler
 * pop up central positioning
 */
protected function fileSaveLoadPopUpUpdateCompleteHandler(event:FlexEvent):void
{
	event.target.x = FlexGlobals.topLevelApplication.width/2 - event.target.width/2;
	event.target.y  = FlexGlobals.topLevelApplication.height/2 - event.target.height/2;
}
