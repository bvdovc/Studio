import mx.collections.ArrayCollection;
import mx.events.FlexEvent;

import sym.controller.NavigationContoller;
import sym.controller.events.NavigationRequestEvent;
import sym.controller.events.RefreshNavigationEvent;
import sym.viewer.mobile.views.ConfigurationView;
import sym.viewer.mobile.views.components.breadcrumb.ArrowBreadCrumb;
import sym.viewer.mobile.views.components.breadcrumb.ArrowBreadCrumbNode;

private var currentColorIndex:int = 0;

[Bindable]
private var _breadcrumbDataProvider:ArrayCollection = new ArrayCollection();

private var _configView:ConfigurationView = null;


/**
 * preinitialize handler for breadcrumbComponent
 * adds navigationContoller event listeners
 */
protected function breadcrumbComponentPreinitializeHandler(event:FlexEvent):void
{ 
    this.addEventListeners();
} 
 
/**
 * RefreshNavigationEvent handler
 * set breadcrumb data provider
 */
private function onRefresh(event:RefreshNavigationEvent):void
{
    refreshNavigation(event.breadcrumbDataProvider);
}

/**
 * NavigationRequestEvent handler
 * navigate to the home view
 */
protected function navigateHandler(event:NavigationRequestEvent):void
{
    if (event.view == NavigationContoller.HOME_VIEW)
    {
		if(this._configView){
			this._configView.removeEventListeners();
			
			// hide existing toolTip for selected component 
			this._configView.hideComponentToolTip();
			
			this._configView = null;
		}
        getNavigator().popToFirstView();
    }
}



/**
 * rerender bread crumb items
 */
public function refreshNavigation(items:ArrayCollection):void
{  
    this.removeAllElements();
    
    this.currentColorIndex = 0;
    
    for (var i:int=0; i < items.length; i++)
    {
        var breadCrumbItem:ArrowBreadCrumbNode=new ArrowBreadCrumbNode();
        breadCrumbItem.navigationNode=items[i];
        breadCrumbItem.colorIndex = this.currentColorIndex++;
        breadCrumbItem.useHandCursor = true;
        breadCrumbItem.buttonMode = true;
        this.addElement(breadCrumbItem);
    }
}