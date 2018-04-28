import flash.events.MouseEvent;

import mx.core.FlexGlobals;
import mx.events.FlexEvent;

import sym.configurationmodel.common.ConfigurationFilter;
import sym.controller.SymmController;
import sym.controller.events.FilterChangeRequestEvent;
import sym.controller.events.FilterWizardEvent;
import sym.controller.model.FilterWizardStateModel;

[Bindable]
private var _messagePart1:String;

[Bindable]
private var _messagePart2:String;

private var _engineFilterValue:int;

public function set engineFilter(value:int):void{
    _engineFilterValue = value;
}

/**
 * initializes strings
 */
private function onInitialize(event:FlexEvent):void
{
    var messageParts:Array = getResString("main", "FILTER_10K_ENGINES_MESSAGE2").split("[]");
    if (messageParts.length == 2)
    {
        _messagePart1 = messageParts[0];
        _messagePart2 = messageParts[1];
    }
}

/**
 * sets size of popup after creation
 * Popup is screen centered
 */
private function creationComplete(event:FlexEvent):void
{   
    var popUpWidth:Number = FlexGlobals.topLevelApplication.width * 0.6;
    var popUpHeight:Number = popUpWidth * 0.5;

    event.target.x = (FlexGlobals.topLevelApplication.width - popUpWidth) / 2;
    event.target.y = (FlexGlobals.topLevelApplication.height - popUpHeight) / 2;

    event.target.width = popUpWidth;
    event.target.height = popUpHeight;
}

/**
 * sends wizard open request, closes itself
 */
private function btnOpenWizard_Click(event:MouseEvent):void{
    SymmController.instance.eventHandler.dispatchEvent(new FilterWizardEvent(FilterWizardEvent.FILTER_WIZARD_OPEN_REQUEST, _engineFilterValue));
    this.close();
}