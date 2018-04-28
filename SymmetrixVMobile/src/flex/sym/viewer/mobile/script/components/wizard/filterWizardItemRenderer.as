import flash.events.MouseEvent;
import flash.text.engine.FontWeight;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;

import spark.components.Label;

import sym.controller.FilterController;
import sym.controller.SymmController;
import sym.controller.events.FilterWizardLabelStepItemEvent;
import sym.viewer.mobile.script.ViewConstants;
import sym.viewer.mobile.views.components.wizard.FilterWizardPopUp;
 

/**
 * preinitialize event handler 
 */
protected function preinitializeHandler(event:FlexEvent):void
{
	FilterController.instance.addEventListener(FilterWizardLabelStepItemEvent.WIZARD_LABEL_STATE_ITEM_CHANGED, wizardLabelStateChanged,false, 0, true);
}

/**
 * 
 * sets initial label step text to bold
 */
override public function set data(value:Object):void
{
	super.data = value;
	
	if (data)
    {
        stepItem.text = data.toString();
        setItemStyle(data.toString() == FilterWizardPopUp.stepsDataProvider[0]);
	}
}

/**
 * FilterWizardLabelStepItemEvent handler
 * <p> sets current label step text to bold. if not current label sets normal fonWeight text </p>
 */
protected function wizardLabelStateChanged(event:FilterWizardLabelStepItemEvent):void {
    setItemStyle(stepItem.text == FilterWizardPopUp.stepsDataProvider[event.currentState]);
}

/**
 * handler when clicked on label step item
 */
protected function labelClickedHandler(event:MouseEvent):void {
	var steps:ArrayCollection = new ArrayCollection();
	var stepIndex:int;
	
	steps.source = FilterWizardPopUp.stepsDataProvider.toArray();
	stepIndex = steps.getItemIndex(data);
	var indexEvent:IndexChangedEvent  = new IndexChangedEvent(IndexChangedEvent.CHILD_INDEX_CHANGE, true);
    indexEvent.newIndex = stepIndex;
	
/*	if (!SymmController.instance.isMFamily() && !SymmController.instance.isAFA())
	{
	    this.dispatchEvent(indexEvent); 
	}*/
}
 
private function setItemStyle(selected:Boolean):void
{    
    if(stepItem)
    {
        stepItem.setStyle("fontWeight", selected? FontWeight.BOLD: FontWeight.NORMAL);
        //stepItem.setStyle("color", selected? "#FFFFFF": "#000000");
		stepItem.setStyle("fontSize", selected? 14 * FlexGlobals.topLevelApplication.height/ViewConstants.DEFAULT_APP_HEIGHT :
			14 * FlexGlobals.topLevelApplication.height/ViewConstants.DEFAULT_APP_HEIGHT);
		titleContent.useHandCursor = stepItem.useHandCursor = (SymmController.instance.isAFA() || SymmController.instance.isPM()) ? false : !selected;
		titleContent.buttonMode = stepItem.buttonMode = !selected;
    }
    if (titleContent && backgroundArrowContent)
    {
		backgroundArrowContent.x = -5;
		titleContent.x = -5;
    }
}
