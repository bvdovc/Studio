import mx.collections.ArrayCollection;
import mx.events.FlexEvent;

import sym.controller.NavigationContoller;
import sym.controller.events.NavigationRequestEvent;
import sym.controller.events.RefreshNavigationEvent;
import sym.viewer.mobile.views.ConfigurationView;


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
    _breadcrumbDataProvider = null;
    _breadcrumbDataProvider = event.breadcrumbDataProvider;
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
			this._configView = null;
		}
		getNavigator().popToFirstView();
    }
}
