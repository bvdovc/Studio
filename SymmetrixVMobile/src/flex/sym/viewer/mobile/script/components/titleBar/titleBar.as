import mx.events.FlexEvent;

import spark.components.View;

import sym.controller.SymmController;
import sym.objectmodel.common.Constants;
import sym.viewer.mobile.utils.CommonUtility;
import sym.viewer.mobile.views.ConfigurationView;

[Bindable]
[InstanceType("spark.components.View;")]
public var currentView:View;

[Bindable]
private var _seriesName:String;

[Bindable]
private var _configView:Boolean;

[Bindable]
private var _mainTitle:String;

[Bindable]
private var _appVersion:String;

private function preinitializeHandler(event:FlexEvent):void
{
	_configView = currentView is ConfigurationView;
		
	
	switch (SymmController.instance.vmaxConfiguration)
	{
		case Constants.VMAX_450F:
			_seriesName = getResString('main', 'VMAX_450F');
			break;
		case Constants.VMAX_950F:
			_seriesName = getResString('main', 'VMAX_950F');
			break;
		case Constants.VMAX_250F:
			_seriesName = getResString('main', 'VMAX_250F');
			break;
		case Constants.PowerMax_2000:
			_seriesName = getResString('main', 'PM_2000');
			break;
		case Constants.PowerMax_8000:
			_seriesName = getResString('main', 'PM_8000');
			break;
		default:
			_seriesName = getResString('main', 'VMAX_IMPORTED_CONFIGS');
			break;
	}
	
	_mainTitle = getResString('main', CommonUtility.INCLUDE_AFA_SERIES ? 'APPLICATION_TITLE' : 'APPLICATION_TITLE_PM_SERIES');
	_appVersion = _configView ? CommonUtility.APP_VERSION + " - " : CommonUtility.APP_VERSION;
}