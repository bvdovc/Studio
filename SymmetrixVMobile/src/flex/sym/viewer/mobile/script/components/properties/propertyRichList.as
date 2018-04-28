import flash.events.TimerEvent;
import flash.text.Font;
import flash.utils.Timer;

import mx.events.FlexEvent;

import sym.controller.SymmController;
import sym.controller.events.PropertiesLoadEvent;

[Bindable]
public var title:String;

[Bindable]
public var enableEvents:Boolean = true;

private var timer:Timer = new Timer(200);

protected function onPropertyRichListInit(event:FlexEvent):void{
    if(enableEvents)
    {
        SymmController.instance.propertyTextProvider.addEventListener(PropertiesLoadEvent.PROPERTY_LIST_LOADED, onPropsLoaded);
        SymmController.instance.propertyTextProvider.addEventListener(PropertiesLoadEvent.PROPERTY_LIST_LOAD_FAILED, onPropsLoadError);
    }
    timer.addEventListener(TimerEvent.TIMER, showList);
}


private function onPropsLoaded(event:PropertiesLoadEvent):void{
    properties.visible = false;
    lblTitle.visible = false; 
    properties.dataProvider = null;
    properties.dataProvider = event.properties.properties;
	title = event.properties.title; 
    timer.start();
}

private function showList(event:TimerEvent):void{
    properties.visible = true;
    lblTitle.visible = true;
    timer.stop();
}

private function onPropsLoadError(event:PropertiesLoadEvent):void{
    properties.dataProvider = event.properties.properties; 
	title = event.properties.title;
}