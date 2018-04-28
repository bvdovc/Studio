import flash.events.Event;

import mx.events.FlexEvent;

import spark.components.List;

import sym.controller.SymmController;

/**
 * SelectionComponent backend script
 */


/**
 * moves (vertical) slider until selected item is brought into view
 */
protected function updateCompleteHandler(event:FlexEvent):void
{
	(this as List).ensureIndexIsVisible((this as List).selectedIndex);
}

/**
 * Selection changing handler - disables selection depending on selectionEnabled flag 
 */
protected function selectionChangingHandler(event:Event):void
{
    if(!SymmController.instance.selectionEnabled)
    {
        event.preventDefault();
    }
}
