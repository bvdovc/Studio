import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.GestureEvent;
import flash.events.GesturePhase;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.events.TransformGestureEvent;
import flash.filesystem.File;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.FileFilter;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.Capabilities;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.controls.ToolTip;
import mx.core.FlexGlobals;
import mx.core.IToolTip;
import mx.core.UIComponent;
import mx.effects.Zoom;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.events.ResizeEvent;
import mx.events.ToolTipEvent;
import mx.managers.PopUpManager;
import mx.managers.ToolTipManager;
import mx.messaging.events.MessageEvent;
import mx.utils.StringUtil;

import spark.components.BorderContainer;
import spark.components.Button;
import spark.components.Image;
import spark.components.TextArea;
import spark.effects.Fade;
import spark.effects.Move;
import spark.effects.Resize;
import spark.events.PopUpEvent;

import sym.configurationmodel.common.ConfigurationFactoryBase;
import sym.configurationmodel.common.ConfigurationFactoryBase_VG3R;
import sym.configurationmodel.common.ConfigurationFilter;
import sym.configurationmodel.pm2000.ConfigurationFactory;
import sym.configurationmodel.utils.AllFlashArrayUtility;
import sym.controller.FilterController;
import sym.controller.NavigationContoller;
import sym.controller.SymmController;
import sym.controller.components.TransparentOverlayComponent;
import sym.controller.components.UIComponentBase;
import sym.controller.events.ComponentDragDropEvent;
import sym.controller.events.ComponentSelectionChangedEvent;
import sym.controller.events.ExportFileEvent;
import sym.controller.events.FilterChangeRequestEvent;
import sym.controller.events.FilterChangedEvent;
import sym.controller.events.FilterWizardEvent;
import sym.controller.events.RedrawEvent;
import sym.controller.events.RefreshNavigationEvent;
import sym.controller.events.RemoveConfigurationEvent;
import sym.controller.events.SelectionComponentDataChangedEvent;
import sym.controller.events.ToolTipCustomEvent;
import sym.controller.events.VMaxSelectionChangeRequestEvent;
import sym.controller.events.XmlImportErrorEvent;
import sym.controller.events.XmlImportedEvent;
import sym.controller.model.DragDropController;
import sym.controller.model.FilterWizardPortsStateModel;
import sym.controller.model.PropertiesPanelItems;
import sym.controller.utils.HtmlPropertyTextProvider;
import sym.controller.utils.ImageRenderer;
import sym.controller.utils.RenderUtility;
import sym.controller.utils.ToolTipProvider;
import sym.objectmodel.common.ComponentBase;
import sym.objectmodel.common.Configuration;
import sym.objectmodel.common.Configuration_VG3R;
import sym.objectmodel.common.Constants;
import sym.objectmodel.common.DAE;
import sym.objectmodel.common.Drive;
import sym.objectmodel.common.Engine;
import sym.objectmodel.common.EnginePort;
import sym.objectmodel.common.SPS;
import sym.objectmodel.common.Tabasco;
import sym.objectmodel.common.Viking;
import sym.objectmodel.common.Voyager;
import sym.objectmodel.driveUtils.enum.DriveType;
import sym.viewer.mobile.script.ViewConstants;
import sym.viewer.mobile.utils.CommonUtility;
import sym.viewer.mobile.utils.FileSaveUtility;
import sym.viewer.mobile.validation.CustomToolTip;
import sym.viewer.mobile.views.HomeView;
import sym.viewer.mobile.views.components.busy.BusyIndicator;
import sym.viewer.mobile.views.components.popups.FileSaveLoadPopup;
import sym.viewer.mobile.views.components.popups.FilterPopUp;
import sym.viewer.mobile.views.components.popups.MessagePopup;
import sym.viewer.mobile.views.components.wizard.FilterWizardPopUp;
import sym.viewer.mobile.views.skins.FilterWizardPopUpSkin;

private static const MAIN_CONTAINER_PADDING_LEFT:Number=30;
private static const MAIN_CONTAINER_PADDING_TOP:Number=30;
private static const MAIN_CONTAINER_PADDING_RIGHT_BIG:Number=30;
private static const MAIN_CONTAINER_PADDING_RIGHT_SMALL:Number=10;
private static const MAIN_CONTAINER_PADDING_BOTTOM:Number=30;
private static const DOUBLE_ZOOM_IN:Number=2;
private static const DOUBLE_ZOOM_OUT:Number=0.5;
private static const CENTRAL_SCREEN_COMPONENT:String="parentContainer";

public var currentComponent:UIComponentBase=null;
private var _renderer:RenderUtility=null;
private var _selectedComponent:UIComponentBase=null;
private var _alert:FileSaveLoadPopup;
private var _viewSide:String=Constants.FRONT_VIEW_PERSPECTIVE;
private var _busyIndicator:BusyIndicator=new BusyIndicator();
private var _busyIndicatorShown:Boolean=false;
private var _selectedFilter:BorderContainer=null;
private var _disableRefreshProperty:Boolean=false;
private var _parentContainerSelected:Boolean=false;
private var _selectionRemoved:Boolean=true;

private var _generatedConfig:sym.objectmodel.common.Configuration;

// tracks coomponent size while zooming 
private var _zoomedComponentSize:Point=null;
private var _currentComponentSize:Point;
private var _startComponentPos:Point;
private var _screenBounds:Point;
// tracks if zoom, pan or scroll is started
private var _eventStarted:Boolean=false;

/**
 * keeps reference for external point
 * related to parent component while zooming
 */
private var _externalPoint:Point;

/**
 * keeps local point percentage
 * on the beggining of Gesture zoom
 */
private var _localPercentPoint:Point;
/**
 * keeps starting zoom position at the Begin phase of Gesture zoom event
 */
private var _oldLocalPoint:Point;

private var helpLoader:URLLoader=new URLLoader();

//timer variables needed for vg3r engine port drag-drop (move, remove)
private var timer:Timer=new Timer(200, 1);
private var timerStarted:Boolean=false;
//highlighted slot borders for dragged component
private var _highlightedBorders:ArrayCollection=new ArrayCollection();

[Embed(source="/images/toolbar/backside.png")]
public static const FlipIcon:Class;

[Embed(source="/images/toolbar/picture_2_clipboard.png")]
public static const CopyPicture2ClipboardIcon:Class;

[Embed(source="/images/toolbar/export_picture_down_point.png")]
public static const ExportPictureIcon:Class;

[Embed(source="/images/toolbar/save_icon.png")]
public static const SaveConfgPictureIcon:Class;

[Embed(source="/images/toolbar/exportXML.png")]
public static const ExportXMLIcon:Class;

[Embed(source="/images/toolbar/importXML.png")]
public static const ImportXMLIcon:Class;

[Embed(source="/images/toolbar/loops.png")]
public static const LoopsIcon:Class;

[Embed(source="/images/toolbar/properties.png")]
public static const PropertiesIcon:Class;

[Embed(source="/images/toolbar/wireframe.png")]
public static const DiagramViewIcon:Class;

[Embed(source="/images/toolbar/Wizard_off.png")]
public static const WizardOff:Class;

[Embed(source="/images/toolbar/Wizard_on.png")]
public static const WizardOn:Class;

[Embed(source="/images/delete_icon_1.png")]
public static const TrashCan:Class;

[Embed(source="/images/delete_icon_2.png")]
public static const TrashCanOpened:Class;

[Embed(source="/images/toolbar/loops_2.png")]
public static const LoopsIcon2:Class;

[Embed(source="/images/toolbar/backside2.png")]
public static const FlipIcon2:Class;

[Embed(source="/images/toolbar/backside_top.png")]
public static const FlipIcon3:Class;

[Embed(source="/images/toolbar/3D_side.png")]
public static const FlipIcon4:Class;

[Embed(source="/images/toolbar/floor_top_side.png")]
public static const FloorTopIcon:Class;

[Embed(source="/images/toolbar/properties2.png")]
public static const PropertiesIcon2:Class;

[Embed(source="/images/toolbar/help.png")]
public static const HelpIcon:Class;

[Bindable]
private var _filterComponents:Number=(SymmController.instance.isAFA() || SymmController.instance.isPM()) ? 5 : 4;

[Bindable]
private var _propertiesEnabled:Boolean=true;

[Bindable]
private var _propEnabled:Boolean=true;

[Bindable]
private var _exportFunctionalityEnabled:Boolean=(CommonUtility.OPERATING_SYSTEM != CommonUtility.IOS || CommonUtility.OPERATING_SYSTEM != CommonUtility.ANDROID);

[Bindable]
private var _isExportXmlButtonEnabled:Boolean=_exportFunctionalityEnabled;

[Bindable]
private var _isSaveCfgButtonEnabled:Boolean=true;

[Bindable]
private var _isImportXmlButtonEnabled:Boolean=_exportFunctionalityEnabled;

[Bindable]
private var _includeImportExportButtons:Boolean=true;

[Bindable]
private var _includeSaveImageButtons:Boolean=true;

[Bindable]
private var _includeSaveCfgButton:Boolean=false;

[Bindable]
private var isDesktopVersion:Boolean = true;

[Bindable]
private var _includeDiagramButton:Boolean=false;

[Bindable]
private var _isToggleConnButtonEnabled:Boolean=true;

[Bindable]
private var _isImageSaveButtonEnabled:Boolean=_exportFunctionalityEnabled;

[Bindable]
private var _isDiagramButtonEnabled:Boolean=false;

[Bindable]
private var _isFlipButtonEnabled:Boolean=true;

[Bindable]
private var _seriesName:String;

[Bindable]
private var _resX:Number;

[Bindable]
private var _resY:Number;

[Bindable]
private var _wizardToolTIp:String;

[Bindable]
private var _isConfigTrashCanVisible:Boolean;

[Bindable]
private var _displayHelp:Boolean=false;

private var wizardPopUp:FilterWizardPopUp=null;

private var popUp:FilterPopUp=null;

private var cpbTimer:Timer=new Timer(400);

private var _cmpToolTip:CustomToolTip;

protected function showBusyIndicator():Boolean
{
	if (_busyIndicatorShown)
	{
		return false;
	}

	PopUpManager.addPopUp(_busyIndicator, this, true);
	PopUpManager.centerPopUp(_busyIndicator);
	this.enabled=false;
	this.alpha=0.5;
	_busyIndicatorShown=true;
	return true;
}

protected function hideBusyIndicator():void
{
	if (!_busyIndicatorShown)
	{
		return;
	}

	this.enabled=true;
	this.alpha=1;
	PopUpManager.removePopUp(_busyIndicator);
	_busyIndicatorShown=false;
}

/**
 * handles preinitialize event
 * adds symmcontroller event listeners
 */
protected function preinitializeHandler(event:FlexEvent):void
{
	SymmController.instance.eventHandler.addEventListener(ComponentSelectionChangedEvent.COMPONENT_SELECTION_CHANGED, refreshCentralModelHandler);
	SymmController.instance.eventHandler.addEventListener(SelectionComponentDataChangedEvent.DATA_SOURCE_CHANGED, refreshSelectionComponentData);
	SymmController.instance.eventHandler.addEventListener(ExportFileEvent.EXPORT_REQUEST, onExportFileRequest);
	SymmController.instance.eventHandler.addEventListener(RedrawEvent.REDRAW_EVENT, redrawCentralModelHandler);
	SymmController.instance.eventHandler.addEventListener(XmlImportedEvent.XML_IMPORTED, onXmlImported);
	SymmController.instance.eventHandler.addEventListener(XmlImportErrorEvent.XML_IMPORT_ERROR, onXmlImportError);
	SymmController.instance.eventHandler.addEventListener(FilterChangedEvent.RELOAD_CONFIGS, onConfigsReload);
	SymmController.instance.eventHandler.addEventListener(FilterChangedEvent.FILTER_CHANGED, onFilterChanged);
	SymmController.instance.eventHandler.addEventListener(FilterWizardEvent.FILTER_WIZARD_OPEN_REQUEST, openWizardRequestHandler);
	SymmController.instance.eventHandler.addEventListener(ToolTipCustomEvent.SHOW_TOOLTIP, showComponentToolTip);
	SymmController.instance.eventHandler.addEventListener(ToolTipCustomEvent.START_TOOLTIP, showComponentToolTip);
	SymmController.instance.eventHandler.addEventListener(ToolTipCustomEvent.HIDE_TOOLTIP, hideComponentToolTip);
	SymmController.instance.eventHandler.addEventListener(ToolTipEvent.TOOL_TIP_SHOWN, hideComponentToolTip);
	SymmController.instance.eventHandler.addEventListener(XmlImportErrorEvent.XML_WRONG_ERROR, errorMessagePopUp);

	_renderer=new RenderUtility(new ImageRenderer(), new ToolTipProvider());
	SymmController.instance.propertyTextProvider=new HtmlPropertyTextProvider(); //new PropertyTextProvider();

	ToolTipManager.enabled=true;

	// mobile version
	if (CommonUtility.OPERATING_SYSTEM == CommonUtility.IOS || CommonUtility.OPERATING_SYSTEM == CommonUtility.ANDROID || CommonUtility.OPERATING_SYSTEM == CommonUtility.BB)
	{
		if (SymmController.instance.isAFA() || SymmController.instance.isPM())
		{
			_includeSaveCfgButton=true;
			isDesktopVersion = false;
		}

		_includeSaveImageButtons=_includeImportExportButtons=false;
	}
	else if (SymmController.instance.isAFA() || SymmController.instance.isPM())
	{
		_includeImportExportButtons=false;
		_includeSaveCfgButton=true;
	}

	dragController.addEventListener(ComponentDragDropEvent.COMPONENT_DROPPED, componentDroppedHandler);
	dragController.addEventListener(ComponentDragDropEvent.COMPONENT_DRAG_STARTED, componentDragStartHandler);
	dragController.addEventListener(ComponentDragDropEvent.COMPONENT_MOVED, componentMovedHandler);

	SymmController.instance.eventHandler.addEventListener(RemoveConfigurationEvent.DELETE_CONFIG, removeConfiguration);
}

/**
 * handles first load of selection component(configurations)
 */
protected function creationCompleteHandler(event:Event):void
{
	//enable Zoom
	checkScreenResolution();

	if (CommonUtility.getOS() == CommonUtility.IOS || CommonUtility.getOS() == CommonUtility.ANDROID)
	{
		Multitouch.inputMode=MultitouchInputMode.GESTURE;
		if (!parentContainer.hasEventListener(TransformGestureEvent.GESTURE_ZOOM))
		{
			parentContainer.addEventListener(TransformGestureEvent.GESTURE_ZOOM, onGestureZoom);
		}
		if (!parentContainer.hasEventListener(TransformGestureEvent.GESTURE_PAN))
		{
			parentContainer.addEventListener(TransformGestureEvent.GESTURE_PAN, onPan);
		}
		/*if (!parentContainer.hasEventListener(TransformGestureEvent.GESTURE_ROTATE))
		{
			parentContainer.addEventListener(TransformGestureEvent.GESTURE_ROTATE, onRotate);
		}*/
		if (!parentContainer.hasEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP))
		{
			parentContainer.addEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP, onGestureZoom)
		}
	}
	if (!parentContainer.hasEventListener(MouseEvent.MOUSE_DOWN))
	{
		parentContainer.addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
	}
	if (!parentContainer.hasEventListener(MouseEvent.MOUSE_UP))
	{
		parentContainer.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
	}
	if (!parentContainer.hasEventListener(MouseEvent.MOUSE_WHEEL))
	{
		parentContainer.addEventListener(MouseEvent.MOUSE_WHEEL, onZoom);
	}
	/*if (!parentContainer.hasEventListener(MouseEvent.DOUBLE_CLICK))
	{
		parentContainer.addEventListener(MouseEvent.DOUBLE_CLICK, onZoom);
	}*/

	parentContainer.buttonMode=true;
	parentContainer.useHandCursor=false;
	parentContainer.percentWidth=100;
	parentContainer.addEventListener(MouseEvent.CLICK, centralComponent_Click);

	// resize busy indicator
	_busyIndicator.indicator.width=this.width / 10;
	_busyIndicator.indicator.height=_busyIndicator.indicator.width;

	SymmController.instance.viewPerspective=Constants.FRONT_VIEW_PERSPECTIVE;

	// select first/most complex config if any. Otherwise. open wizard popUp
	SymmController.instance.resetSelectionProvider();

	this.selectionComponent.dataProvider=SymmController.instance.selectionDataProvider;

	if (SymmController.instance.selectionDataProvider && SymmController.instance.selectionDataProvider.length > 0)
	{
		this.selectionComponent.selectedItem=SymmController.instance.getMostComplexConfig(SymmController.instance.selectionDataProvider.toArray()); //SymmController.instance.selectionDataProvider[SymmController.instance.selectionDataProvider.length - 1];

		if (SymmController.instance.vmaxConfiguration == Constants.IMPORTED_CONFIGS)
		{
			for (var i:int=0; i < SymmController.instance.selectionDataProvider.length; i++)
			{
				if (SymmController.instance.lastImportedConfig.id == SymmController.instance.selectionDataProvider[i].id)
				{
					this.selectionComponent.selectedItem=SymmController.instance.selectionDataProvider[i];
					break;
				}
			}
			if (SymmController.instance.configFilter.dispersed == ConfigurationFilter.NO_DISPERSED_DEFAULT)
			{
				dispersion.filterName=getResString('main', "FILTER_DISPERSED");
				dispersion.filterValue=getResString('main', "FILTER_DISPERSED_NO");
			}
			else
			{
				dispersion.filterName=getResString('main', "FILTER_DISPERSED");
				dispersion.filterValue=SymmController.instance.configFilter.dispersed.toString();
			}

			daeType.filterName=getResString('main', "FILTER_DAE_TYPE");
			//daeType.filterValue=getResString('main', "FILTER_DAE_TYPE_" + SymmController.instance.configFilter.daeType.toString());
			daeType.filterValue = getResString('main', "FILTER_DAE_TYPE_ANY")
		}

		SymmController.instance.showComponent(this.selectionComponent.selectedItem as ComponentBase);
		
		// call to refresh filter buttons and icon in conf. list
		SymmController.instance.eventHandler.dispatchEvent(new FilterChangedEvent(FilterChangedEvent.FILTER_CHANGED));
		currentComponent=_renderer.renderStage(this.selectionComponent.selectedItem, _viewSide);
		resizeCentralComponent();
		
	}

	_wizardToolTIp=getResString('main', 'BUTTON_FILTER_WIZARD');
	wizardToggleButton.selected=false;

	if ( (SymmController.instance.isAFA() || SymmController.instance.isPM()) && this.selectionComponent.dataProvider.length == 0)
	{
		showBusyIndicator();

		this.callLater(function():void
		{
			FileSaveUtility.importSavedXMLs();

			if (SymmController.instance.configurations.length == 0)
				SymmController.instance.eventHandler.dispatchEvent(new FilterWizardEvent(FilterWizardEvent.FILTER_WIZARD_OPEN_REQUEST, null));

			hideBusyIndicator();
		});
	}

	helpLoader.addEventListener(Event.COMPLETE, loadingCompleted);
	helpLoader.addEventListener(IOErrorEvent.IO_ERROR, loadingFailed);
	helpLoader.addEventListener(ErrorEvent.ERROR, loadingFailed);
	cpbTimer.addEventListener(TimerEvent.TIMER, copyToClipboardTimerHandler);

	dragController.container=this.dragContainer;
}

/**
 * Sets proertiesButton sellected property to true in order that property page is default opened just for old K series
 */
private function onPropertyButtonInit(event:Event):void
{
	if (!SymmController.instance.isAFA() || !SymmController.instance.isPM())
	{
		propertiesButton.selected=false;
		propertiesButtom_Toggle(null);
	}
}

/**
 * Help button click
 */
private function helpButton_Click(event:Event):void
{
	if (!_displayHelp)
	{
		if(SymmController.instance.isAFA())
		{
			helpLoader.load(new URLRequest(resourceManager.getString("component", "POWERMAX_MAIN_HELP_XML")));
		}
		else
		helpLoader.load(new URLRequest(resourceManager.getString("component", "POWERMAX_MAIN_HELP_XML")));
		// remove existing toolTip for selected component
		hideComponentToolTip();
	}
	else
		// show toolTip if component is selected
		showComponentToolTip(event, false);
		
	_displayHelp=!_displayHelp;
	copyToClipboardButton.enabled=_isImageSaveButtonEnabled && !_displayHelp;
}

protected function loadingFailed(evt:Event):void
{
	//TODO: Handle loading error
}

/**
 * xml loaded handler
 */
protected function loadingCompleted(evt:Event):void
{
	var xml:XML=new XML(String(helpLoader.data));
	var propProvider:PropertiesPanelItems=HtmlPropertyTextProvider.parseXML(xml);

	helpPanel.title=propProvider.title;
	helpPanel.properties.dataProvider=propProvider.properties;
}

/**
 * action bar items are created after creation complete of the view ??!?
 */
protected function onBreadCrumbCreated(event:FlexEvent):void
{
	breadcrumbComponent.addEventListeners();
	NavigationContoller.instance.initialize();
	if (this.selectionComponent.selectedItem)
		SymmController.instance.eventHandler.dispatchEvent(new ComponentSelectionChangedEvent(ComponentSelectionChangedEvent.BREADCRUMB_CHANGED, this.selectionComponent.selectedItem as ComponentBase));
}

/**
 * Pan gesture handler for dragging component
 * @param event
 *
 */
private function onPan(event:TransformGestureEvent):void
{
	if (event.phase == GesturePhase.BEGIN)
	{
		_eventStarted=true;
		if (parentContainer.hasEventListener(TransformGestureEvent.GESTURE_ZOOM))
		{
			parentContainer.removeEventListener(TransformGestureEvent.GESTURE_ZOOM, onGestureZoom);
		}
		if (parentContainer.hasEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP))
		{
			parentContainer.removeEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP, onGestureZoom);
		}
		if (parentContainer.hasEventListener(MouseEvent.CLICK))
		{
			parentContainer.removeEventListener(MouseEvent.CLICK, centralComponent_Click);
		}
	}
	/*if (event.phase == GesturePhase.UPDATE)
	{
		_currentComponent.x += event.offsetX;
		_currentComponent.y += event.offsetY;
	}*/
	if (event.phase == GesturePhase.END)
	{
		if (!parentContainer.hasEventListener(TransformGestureEvent.GESTURE_ZOOM))
		{
			parentContainer.addEventListener(TransformGestureEvent.GESTURE_ZOOM, onGestureZoom);
		}
		if (!parentContainer.hasEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP))
		{
			parentContainer.addEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP, onGestureZoom);
		}
		return;
	}

	checkComponentVisibility(event);
}

/**
 * Zoom gesture handler.
 * If it's GestureEvent.GESTURE_TWO_FINGER_TAP event then we've double zoom out
 * @param event TransformGestureEvent.GESTURE_ZOOM and GestureEvent.GESTURE_TWO_FINGER_TAP
 *
 */
private function onGestureZoom(event:GestureEvent):void
{
	event.stopImmediatePropagation();

	var scale:Number=event.type == GestureEvent.GESTURE_TWO_FINGER_TAP ? DOUBLE_ZOOM_OUT : (event as TransformGestureEvent).scaleX;

	if (zoomEnabled(scale))
	{
		currentComponent.stopDrag();
		_eventStarted=true;

		if (event.phase == GesturePhase.BEGIN)
		{
			_oldLocalPoint=null;

			if ((event.target as UIComponent).id != CENTRAL_SCREEN_COMPONENT)
			{
				_oldLocalPoint=new Point(event.localX, event.localY);
			}

			if (parentContainer.hasEventListener(MouseEvent.CLICK))
			{
				parentContainer.removeEventListener(MouseEvent.CLICK, centralComponent_Click);
			}
			if (parentContainer.hasEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP))
			{
				parentContainer.removeEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP, onGestureZoom)
			}
		}

		// this is only for GestureEvent.GESTURE_TWO_FINGER_TAP event
		if (event.phase == GesturePhase.ALL)
		{
			if (parentContainer.hasEventListener(MouseEvent.CLICK))
			{
				parentContainer.removeEventListener(MouseEvent.CLICK, centralComponent_Click);
			}

			determineZoomPoints(new Point(event.localX, event.localY), event);
		}

		if (event.phase == GesturePhase.END)
		{
			if (!parentContainer.hasEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP))
			{
				parentContainer.addEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP, onGestureZoom)
			}
			return;
		}

		if (event.type == TransformGestureEvent.GESTURE_ZOOM && (event.target as UIComponent).id != CENTRAL_SCREEN_COMPONENT)
		{
			determineZoomPoints(_oldLocalPoint ? _oldLocalPoint : new Point(event.localX, event.localY), event);
		}

		zoomMatrix(event, scale, _externalPoint, _localPercentPoint);

//		checkComponentVisibility(event);
	}
}

/**
 * Determines zoom position points
 * @param local indicates local point at which zoom event occurs relative to the containing component
 *
 */
private function determineZoomPoints(local:Point, event:GestureEvent):void
{
	var globalPoint:Point=currentComponent.localToGlobal(local);

	if (event.target.parent is UIComponentBase || event.target.parent is TransparentOverlayComponent)
	{
		globalPoint=event.target.localToGlobal(local);

		local=currentComponent.globalToLocal(globalPoint);
	}

	_externalPoint=parentContainer.globalToLocal(globalPoint);

	_localPercentPoint=new Point(local.x / currentComponent.width, local.y / currentComponent.height);
}

/**
 * Zoom handler, double zoom in/out
 * @param event MouseEvent.MOUSE_WHEEL
 *
 */
private function onZoom(event:MouseEvent):void
{
	var scale:Number=event.delta > 0 ? DOUBLE_ZOOM_IN : DOUBLE_ZOOM_OUT;

	if (zoomEnabled(scale))
	{
		_eventStarted=false;

		if (parentContainer.hasEventListener(MouseEvent.CLICK))
		{
			parentContainer.removeEventListener(MouseEvent.CLICK, centralComponent_Click);
		}

		zoomMatrix(event, scale);

//		checkComponentVisibility(event);
	}
}

/**
 * Zoom component from a specific point
 * @param event TransformGestureEvent.GESTURE_ZOOM, GestureEvent.GESTURE_TWO_FINGER_TAP, MouseEvent.MOUSE_WHEEL(DOUBLE_CLICK)
 * @param scale indicates scale of the component
 * @param externalPoint indicates external point in which zooming occurs
 * @param gesturePercent indicates local position percents at which gesture zoom starts
 *
 */
private function zoomMatrix(event:Event, scale:Number, externalPoint:Point=null, gesturePercent:Point=null):void
{
	currentComponent.scaleX*=scale;
	currentComponent.scaleY*=scale;

	var matrix:Matrix=currentComponent.transform.matrix;
	var internalPoint:Point;
	var point:Point=null;

	if ((event.target as UIComponent).id == CENTRAL_SCREEN_COMPONENT)
	{
		externalPoint=new Point(parentContainer.width / 2, parentContainer.height / 2);

		internalPoint=new Point(currentComponent.x + (currentComponent.width * currentComponent.scaleX) / 2, currentComponent.y + (currentComponent.height * currentComponent.scaleY) / 2);
	}
	else
	{
		if (event.type == TransformGestureEvent.GESTURE_ZOOM || event.type == GestureEvent.GESTURE_TWO_FINGER_TAP)
		{
			internalPoint=new Point(currentComponent.x + gesturePercent.x * currentComponent.width * currentComponent.scaleX, currentComponent.y + gesturePercent.y * currentComponent.height * currentComponent.scaleY);
		}
		else if (event.type == MouseEvent.MOUSE_WHEEL)
		{
			internalPoint=new Point(currentComponent.mouseX * scale, currentComponent.mouseY * scale);
			externalPoint=new Point(parentContainer.mouseX, parentContainer.mouseY);

			var transformPoint:Point=matrix.transformPoint(internalPoint);
		}
	}

	point=transformPoint ? new Point(externalPoint.x - transformPoint.x, externalPoint.y - transformPoint.y) : new Point(externalPoint.x - internalPoint.x, externalPoint.y - internalPoint.y);

	matrix.translate(point.x, point.y);

	currentComponent.transform.matrix=matrix;

}

private function onRotate(event:TransformGestureEvent):void
{

//	event.stopImmediatePropagation();

	var rotateMatrix:Matrix=currentComponent.transform.matrix;
//	var rotateMatrix:Matrix3D = currentComponent.transform.matrix3D;
	var p:Point=null;
//	var v:Vector3D = null;
	p=rotateMatrix.transformPoint(new Point(currentComponent.width / 2, currentComponent.height / 2));
	rotateMatrix.translate(-p.x, -p.y);
	rotateMatrix.rotate(event.rotation * (Math.PI / 180));
	rotateMatrix.translate(p.x, p.y);
	currentComponent.transform.matrix=rotateMatrix;

	/*v = rotateMatrix.transformVector(new Vector3D(_currentComponent.width/2, _currentComponent.height/2, 0));
	rotateMatrix.appendTranslation(-v.x, -v.y, -v.y);
	rotateMatrix.appendRotation(event.rotation * (Math.PI/180), new Vector3D(0, 1, 0), v);
	rotateMatrix.appendTranslation(v.x, v.y, v.z);
	_currentComponent.transform.matrix3D = rotateMatrix;*/


	if (event.phase == GesturePhase.BEGIN)
	{
		if (parentContainer.hasEventListener(TransformGestureEvent.GESTURE_ZOOM))
		{
			parentContainer.removeEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoom);
		}
	}
	if (event.phase == GesturePhase.END)
	{
		if (!parentContainer.hasEventListener(TransformGestureEvent.GESTURE_ZOOM))
		{
			parentContainer.addEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoom);
		}
	}

}

/**
 * Mouse Down handler
 * @param event
 *
 */
private function startDragging(event:MouseEvent):void
{
	checkComponentVisibility(event);

	if (!parentContainer.hasEventListener(MouseEvent.MOUSE_MOVE))
	{
		parentContainer.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}

	hideComponentToolTip();
}

/**
 * Mouse Move handler
 * @param event
 *
 */
private function onMouseMove(event:MouseEvent):void
{
	_eventStarted=true;

	if (parentContainer.hasEventListener(MouseEvent.CLICK))
	{
		parentContainer.removeEventListener(MouseEvent.CLICK, centralComponent_Click);
	}

	stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);

	if (!dragController.isDragging)
	{
		timer.stop();
		timerStarted=false;
	}
	else
	{
		//if we started dragging of vg3r engine component, stop possible drag of complet central component (engine)
		stopDragging(null);
	}
}

/**
 * Mouse Up handler
 * @param event
 *
 */
private function stopDragging(event:MouseEvent):void
{
//	event.stopImmediatePropagation();

	if (timerStarted)
	{
		timer.stop();
		timerStarted=false;
	}

	currentComponent.stopDrag();

	if (!parentContainer.hasEventListener(MouseEvent.CLICK))
	{
		parentContainer.addEventListener(MouseEvent.CLICK, centralComponent_Click);
	}
	if (parentContainer.hasEventListener(MouseEvent.MOUSE_MOVE))
	{
		parentContainer.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}

	this.callLater(enableEvents);
}

/**
 * Checks component for zooming
 * @param scale the scale of the component
 * @return true if component can be zoomed
 *
 */
private function zoomEnabled(scale:Number):Boolean
{
	var startSize:Point=_zoomedComponentSize ? new Point(_zoomedComponentSize.x * scale, _zoomedComponentSize.y * scale) : new Point(_currentComponentSize.x * scale, _currentComponentSize.y * scale);

	if ((startSize.x > _screenBounds.x && startSize.y > _screenBounds.y) || startSize.x < _currentComponentSize.x || startSize.y < _currentComponentSize.y)
	{
		return false;
	}
	_startComponentPos=new Point(currentComponent.x, currentComponent.y);
	_zoomedComponentSize=startSize;

	return true;
}

/**
 * Checks if this is vg3r engine port that can be dragged, if true, starts timer which starts drag after 200 miliseconds
 */
private function startVg3rEnginePortDrag():void
{
	if (dragController.dragEnabled && currentComponent.componentBase is Engine)
	{
		var dragSlot:int=RenderUtility.getVg3rEngineSlotByPoint(currentComponent.mouseX, currentComponent.mouseY, currentComponent);
		var positionIndex:int=Engine.getPositionIndexBySlot(dragSlot);
		dragController.component=(currentComponent.componentBase as Engine).getIOModuleByPosition(positionIndex);

		if (dragController.component != null && (dragController.component as EnginePort).isDraggable)
		{
			if (!timer.hasEventListener(TimerEvent.TIMER))
				timer.addEventListener(TimerEvent.TIMER, timerHandler);

			timer.start();
			timerStarted=true;
		}
	}
}

/**
 * Timer handler - starts dragging
 * <ul>
 * <li>Captures component snapshot</li>
 * <li>Stops list scrolling</li>
 * <li>Start dragging</li>
 * </ul>
 */
private function timerHandler(event:TimerEvent):void
{
	timer.stop();
	timerStarted=false;

	stopDragging(null);

	var bitmap:Image=new Image();
	var size:Rectangle=getDraggedComponentSize();

	bitmap.source=ImageRenderer.getComponentSmallImage(dragController.component.type);
	bitmap.width=size.width;
	bitmap.height=size.height;

	stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);

	dragController.startDrag(bitmap, dragController.component, true);
}

public static function getDraggedComponentSize():Rectangle
{
	var screen:Point=new Point(Capabilities.screenResolutionX, Capabilities.screenResolutionY);
	var width:Number;
	var height:Number;

	// iOS or Android
	if (CommonUtility.getOS() == CommonUtility.IOS || CommonUtility.getOS() == CommonUtility.ANDROID)
	{
		width=(screen.x > 1500 && screen.y > 1500) ? 110 : 60;
		height=(screen.x > 1500 && screen.y > 1500) ? 45 : 26;
	}
	else
	{
		width=48;
		height=20;
	}

	return new Rectangle(0, 0, width, height);
}

/**
 * Stage mouse up handler - stops dragging
 */
private function mouseUpHandler(event:MouseEvent):void
{
	timer.stop();
	timerStarted=false;

	dragController.stopDrag();
	stopDragging(null);

	showComponentToolTip(event, false);

	stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
}

/**
 * Checks if component is completely out of stage.
 * If true, sets component position to its last visible position
 * @param event
 *
 */
private function checkComponentVisibility(event:Event):void
{
	var pos:Point=currentComponent.localToGlobal(new Point(0, 0));
	var mainScreenPos:Point=mainContainer.localToGlobal(new Point(0, 0));
	var mainScreenSize:Point=mainContainer.localToGlobal(new Point(mainContainer.width, mainContainer.height));

	switch (event.type)
	{
		case MouseEvent.MOUSE_DOWN:
		case TransformGestureEvent.GESTURE_PAN:
		{
			var compSize:Point=new Point(currentComponent.width * currentComponent.scaleX, currentComponent.height * currentComponent.scaleY);
			var posX:Number=-compSize.x * 0.95;
			var posY:Number=-compSize.y * 0.95;
			var width:Number=parentContainer.width + compSize.x * 0.9;
			var height:Number=parentContainer.height + compSize.y * 0.9;

			var bounds:Rectangle=new Rectangle(posX, posY, width, height);

			currentComponent.startDrag(false, bounds);

			startVg3rEnginePortDrag();
			break;
		}
		case TransformGestureEvent.GESTURE_ZOOM:
		case GestureEvent.GESTURE_TWO_FINGER_TAP:
		case MouseEvent.MOUSE_WHEEL:
		{
			// out off the Left-Top of stage?
			if (currentComponent.x + _zoomedComponentSize.x < 0 && pos.y + _zoomedComponentSize.y < mainScreenPos.y)
			{
				currentComponent.x=-_zoomedComponentSize.x / 2;
				currentComponent.y=-_zoomedComponentSize.y / 2;
			}
			// out off the left-Bottom of stage?
			else if (currentComponent.x + _zoomedComponentSize.x < 0 && pos.y > mainScreenPos.y + mainContainer.height)
			{
				currentComponent.x=-_zoomedComponentSize.x / 2;
				currentComponent.y=_startComponentPos.y;
			}
			//out off the Right-Bottom of stage?
			else if ((pos.x > mainScreenSize.x && pos.y > mainScreenPos.y + mainContainer.height))
			{
				currentComponent.x=_startComponentPos.x;
				currentComponent.y=(mainScreenPos.y + mainContainer.height) / 2;
			}

			// out off the Right-Top of stage?
			else if ((pos.x > mainScreenSize.x && pos.y + _zoomedComponentSize.y < mainScreenPos.y))
			{
				currentComponent.x=_startComponentPos.x;
				currentComponent.y=mainScreenPos.y - _zoomedComponentSize.y / 2;
			}
			// if Left of stage 
			else if (currentComponent.x + _zoomedComponentSize.x < 0)
			{
				currentComponent.x=_startComponentPos.x + _zoomedComponentSize.x;
				currentComponent.y=currentComponent.y + _zoomedComponentSize.y < mainScreenPos.y ? mainScreenPos.y - _zoomedComponentSize.y / 2 : currentComponent.y;
			}
			// if Top of stage 
			else if (pos.y + _zoomedComponentSize.y < mainScreenPos.y)
			{
				currentComponent.y=_startComponentPos.y + _zoomedComponentSize.y;
			}
			// if Bottom of stage
			else if (pos.y > mainScreenPos.y + mainContainer.height)
			{
				currentComponent.x=_startComponentPos.x > 0 ? _startComponentPos.x : -_zoomedComponentSize.x / 2;
				currentComponent.y=_startComponentPos.y;
			}
			// if Right of stage 
			else if (pos.x > mainScreenSize.x)
			{
				currentComponent.x=_startComponentPos.x;
				currentComponent.y=_startComponentPos.y + _zoomedComponentSize.y < mainScreenPos.y ? currentComponent.y : _startComponentPos.y;
			}

			break
		}
	}
}

private function checkScreenResolution():void
{
	var resX:Number=Capabilities.screenResolutionX;
	var resY:Number=Capabilities.screenResolutionY;

	if ((CommonUtility.getOS() == CommonUtility.IOS || CommonUtility.getOS() == CommonUtility.ANDROID) && resY > resX)
	{
		_screenBounds=new Point(resY, resX);
	}
	else
	{
		_screenBounds=new Point(resX * 1.5, resY * 1.75);
	}
}

private function enableEvents():void
{
	_eventStarted=false;
}

/**
 * refreshes central model of view
 */
private function refreshCentralModelHandler(event:ComponentSelectionChangedEvent):void
{
	var smt:Configuration_VG3R = SymmController.instance.currentComponent as Configuration_VG3R;
	// populate DAEs with drives for 250F only before displaying config on configuratiion view
	// since drives can be visible in the front view of bay
	if (SymmController.instance.currentComponent.isVG3Rconfiguration && (is250F() || isPM2000() || isPM8000()))
	{
		SymmController.instance.configFactory.populateWithDrives(SymmController.instance.currentComponent as Configuration_VG3R);
	}

	showBusyIndicator();
	updateSaveXmlButtons(event.selectedItem);

	this.callLater(refreshCentralModel, [event.selectedItem]);
	SymmController.instance.reloadSelectionComponent(event.selectedItem);

}

/**
 * redraw event handler
 */
private function redrawCentralModelHandler(event:RedrawEvent):void
{
	refreshCentralModel(currentComponent.componentBase);
	
}

/**
 * refresh view with given model
 */
private function refreshCentralModel(component:ComponentBase):void
{
	var triggeredBusyWait:Boolean=showBusyIndicator();
	var selectedComp:UIComponentBase=null;
	
	// set Front/Rear view icons as default
	var toggleImages:Array = [FlipIcon2, FlipIcon];
	
	if (SymmController.instance.isAFA() || SymmController.instance.isPM())
	{
		if (component is Viking || component is Voyager)
		{
			// Viking/Voyager has four view sides - Front/Rear/Top/3D
			toggleImages = [FlipIcon2, FlipIcon, FlipIcon3, FlipIcon4];
		}
		else if (component.isConfiguration || component.isBay)
		{
			// Configuration/Bay has 3 sides - Front/Rear/Floor 
			toggleImages = [FlipIcon2, FlipIcon, FloorTopIcon];
		}
	}
	flipButton.toggleImages = toggleImages;
	
	if ((_viewSide == Constants.TOP_VIEW_PERSPECTIVE || _viewSide == Constants.SIDE_3D_VIEW_PERSPECTIVE) && !(component is DAE) && !(currentComponent.componentBase.isBay || currentComponent.componentBase.isConfiguration))
	{
		SymmController.instance.viewPerspective=_viewSide = Constants.FRONT_VIEW_PERSPECTIVE;

		this.flipButton.currentIndex = 0;
	}
	else if (currentComponent && currentComponent.componentBase.isBay)
	{
		if ((_viewSide == Constants.FRONT_VIEW_PERSPECTIVE || _viewSide == Constants.REAR_VIEW_PERSPECTIVE) && (component is Viking || component is Voyager))
		{
			SymmController.instance.viewPerspective = _viewSide=Constants.TOP_VIEW_PERSPECTIVE;
			this.flipButton.currentIndex = 2; //set top perspective;
		}
	}

	_isToggleConnButtonEnabled=SymmController.instance.currentComponent && (SymmController.instance.currentComponent.isConfiguration || SymmController.instance.currentComponent.isBay) && _viewSide != Constants.TOP_VIEW_PERSPECTIVE;

	if (SymmController.instance.keepSelectionBox)
	{
		selectedComp=_selectedComponent;
	}

	if (currentComponent)
	{
		if (parentContainer.contains(currentComponent))
		{
			parentContainer.removeChild(currentComponent);
		}
		currentComponent=null;
	}

	deselectComponent();
	currentComponent=_renderer.renderStage(component, _viewSide);
	currentComponent.cacheAsBitmap=true;

	if (selectedComp)
	{
		for (var i:int=0; i < currentComponent.numChildren; i++)
		{
			if (currentComponent.getChildAt(i) is UIComponentBase)
			{
				var uiCompBase:UIComponentBase=currentComponent.getChildAt(i) as UIComponentBase;
				if (uiCompBase.componentBase == selectedComp.componentBase)
				{
					_renderer.renderSelectionBox(uiCompBase);
					uiCompBase.selected=true;
					_selectedComponent=uiCompBase;
					break;
				}
			}
		}
	}
	updatePropertiesText();

	parentContainer.x=0;
	parentContainer.y=0;
	parentContainer.scaleX=1;
	parentContainer.scaleY=1;

	resizeCentralComponent();

	if (triggeredBusyWait)
	{
		hideBusyIndicator();
	}
	// root component shouldn't have tooltip on drill down selection
	currentComponent.toolTip=null;

	hideBusyIndicator();
}

/**
 * Updates properties text based on current component.
 *
 */
private function updatePropertiesText():void
{
	_propertiesEnabled=false;
	_propEnabled=false;
	if (_selectedComponent && _selectedComponent.componentBase.propertiesEnabled)
	{
		_propertiesEnabled=true;
		_propEnabled=true;

		if (!_disableRefreshProperty && !(SymmController.instance.keepSelectionBox && !_selectedComponent.componentBase is SPS))
		{
			SymmController.instance.propertyTextProvider.getPropertyText(_viewSide, _selectedComponent.componentBase);
		}
		else
		{
			_disableRefreshProperty=false;
		}
	}
	else if ((!_selectedComponent) && (currentComponent) && (currentComponent.componentBase.propertiesEnabled))
	{
		_propertiesEnabled=true;
		_propEnabled=true;
		/*propertiesText.text =*/
		if (!(_disableRefreshProperty || (_parentContainerSelected && !_selectionRemoved) || (SymmController.instance.keepSelectionBox && currentComponent.componentBase.isEngine)))
		{
			SymmController.instance.propertyTextProvider.getPropertyText(_viewSide, currentComponent.componentBase);
		}

		_disableRefreshProperty=false;
		_parentContainerSelected=false;
		_selectionRemoved=false;
	}

	if (!_propertiesEnabled)
	{
		propertiesButton.selected=false;
		propertiesButtom_Toggle(null);
	}
}

/**
 * Resizes the central component to fit into parent container
 *
 */
private function resizeCentralComponent():void
{
	_zoomedComponentSize=null;

	if (!currentComponent)
	{
		return;
	}

	var scale:Number=parentContainer.height / currentComponent.height;

	if (currentComponent.width * scale > parentContainer.width)
	{
		scale=parentContainer.width / currentComponent.width;
	}

	parentContainer.addChild(currentComponent);

	var scaledSize:Point=new Point(currentComponent.width * scale, currentComponent.height * scale);
	_currentComponentSize=scaledSize;

	var move:Move=new Move(currentComponent);
	move.xTo=(parentContainer.width - scaledSize.x) / 2;
	move.yTo=(parentContainer.height - scaledSize.y) / 2;
	move.duration=0;
	move.play();

	var zoom:Zoom=new Zoom(currentComponent);
	zoom.zoomWidthFrom=1;
	zoom.zoomWidthTo=scale;
	zoom.zoomHeightFrom=1;
	zoom.zoomHeightTo=scale;
	zoom.originX=0;
	zoom.originY=0;
	zoom.duration=0;
	zoom.play();

	// drawing transparent surface 
	// so that mouse interactivity is enabled outside of central component
	parentContainer.graphics.beginFill(0xFFFFFF, 0);
	parentContainer.graphics.drawRect(0, 0, parentContainer.width, parentContainer.height);
	parentContainer.graphics.endFill();
}

/**
 * parentContainer resize handler
 */
protected function parentContainer_resizeHandler(event:ResizeEvent):void
{
	resizeCentralComponent();
	invalidateSize();

	showComponentToolTip(event, false);
}

/**
 * click handler for central uicomponent - drill down signal
 */
private function centralComponent_Click(event:MouseEvent):void
{
	if (_eventStarted || _viewSide == Constants.TOP_VIEW_PERSPECTIVE)
		return;

	var sctrl:SymmController=SymmController.instance;

	if (event.target is UIComponentBase)
	{
		var uicomp:UIComponentBase=event.target as UIComponentBase;
		if (!(uicomp.componentBase is EnginePort || uicomp.componentBase is Drive))
		{
			if (uicomp.selected)
			{
				uicomp.removeChildAt(uicomp.numChildren - 1); // remove selection box
				_selectedComponent=uicomp;

				if (uicomp.componentBase is Viking || uicomp.componentBase is Voyager)
				{
					sctrl.configFactory.populateWithDrives(uicomp.componentBase.parentConfiguration as Configuration_VG3R, uicomp.componentBase as DAE);
				}

				sctrl.showComponent(uicomp.componentBase);
			}
			else
			{
				// disable refresh Property while clicking on dispersed line
				if (uicomp.componentBase.isConfiguration && (uicomp.componentBase as sym.objectmodel.common.Configuration).dispersed != 0)
				{
					(_selectedComponent == null) ? _disableRefreshProperty=true : _disableRefreshProperty=false;
				}

				deselectComponent();

				// simulate mouse over/toolTip
				showComponentToolTip(event);

				if (!uicomp.componentBase.isConfiguration)
				{
					_renderer.renderSelectionBox(uicomp);
					uicomp.selected=true;
					_selectedComponent=uicomp;
					if (!(uicomp.componentBase is SPS) && sctrl.keepSelectionBox)
					{
						sctrl.keepSelectionBox=false;
					}

					sctrl.reloadSelectionComponent(_selectedComponent.componentBase);
				}
			}
		}
	}
	else if (event.target is UIComponent)
	{
		if ((event.target as UIComponent).id == CENTRAL_SCREEN_COMPONENT)
		{
			_parentContainerSelected=true;
			deselectComponent();
			if (currentComponent)
			{
				SymmController.instance.reloadSelectionComponent(currentComponent.componentBase);
			}
		}
		else
		{
			_disableRefreshProperty=true;

			showComponentToolTip(event, false);
		}
	}

	updatePropertiesText();
}

/**
 * Deselects currently selected component.
 *
 */
private function deselectComponent():void
{

	if (_selectedComponent)
	{
		_selectedComponent.removeChildAt(_selectedComponent.numChildren - 1); // remove selection box from previously selected component
		_selectedComponent.selected=false;
		_selectedComponent=null;
		_selectionRemoved=true;

		// hide toolTip if exist
		hideComponentToolTip();
	}
}

/**
 * refreshes model after filtering has been done
 */
private function onFilterChanged(event:FilterChangedEvent):void
{
	var triggeredBusyWait:Boolean=showBusyIndicator();
	var sctrl:SymmController=SymmController.instance;

	this.selectionComponent.dataProvider=sctrl.selectionDataProvider;

	var orgId:String="";
	if (sctrl.previousConfiguration)
	{
		orgId=isImported() ? sctrl.lastImportedConfig.id : sctrl.previousConfiguration.id;
	}

	if (parentContainer.numChildren > 1)
	{
		(parentContainer.getChildAt(1) as UIComponent).visible=(parentContainer.getChildAt(1) as UIComponent).includeInLayout=false;
		parentContainer.removeChildAt(1);
	}

	if (sctrl.configurations.length > 0)
	{
		_isImageSaveButtonEnabled=_exportFunctionalityEnabled;
		_propertiesEnabled=true;

		if (sctrl.currentComponent && (sctrl.currentComponent.isConfiguration || sctrl.currentComponent.isBay) && _viewSide != Constants.TOP_VIEW_PERSPECTIVE)
		{
			_isToggleConnButtonEnabled=true;
		}
		_isFlipButtonEnabled=true;

		var cfg:ComponentBase=null;

		// try to find config with same name
		if (_generatedConfig)
		{
			for each (var c:sym.objectmodel.common.Configuration in sctrl.configurations)
			{
				if (c.structureId == _generatedConfig.structureId)
				{
					cfg=c; // sctrl.showComponent(c);
					break;
				}
			}
		}
		

		if (_generatedConfig)
		{
			_generatedConfig=null;
		}
		else
		{
			for each (var cfg1:sym.objectmodel.common.Configuration in sctrl.configurations)
			{
				if (cfg1.id == orgId)
				{
					cfg=cfg1;
					break;
				}
			}
		}

		if (cfg)
		{
			sctrl.showComponent(cfg);
		}
		else
		{
			sctrl.showComponent(sctrl.getMostComplexConfig(sctrl.configurations.toArray())); //sctrl.configurations[sctrl.configurations.length - 1]);
		}
		var componentIndex:int=sctrl.getCurrentSelectedIndex(Constants.CONFIGURATION_TYPE);
		if (componentIndex != -1)
		{
			this.selectionComponent.selectedIndex=componentIndex;
		}
	}
	else
	{
		_isExportXmlButtonEnabled=false;
		_isSaveCfgButtonEnabled=false;
		_isImageSaveButtonEnabled=_exportFunctionalityEnabled;
		_propertiesEnabled=false;
		_isFlipButtonEnabled=false;
		_isToggleConnButtonEnabled=false;

		this.propertiesButton.selected=false;
		propertiesText.visible=false;
		propertiesText.includeInLayout=false;
		mainContainer.paddingRight=MAIN_CONTAINER_PADDING_RIGHT_BIG;
		parentContainer.percentWidth=100;
		NavigationContoller.instance.removeItemsFromIndex(2);		
		NavigationContoller.instance.dispatchEvent(new RefreshNavigationEvent(RefreshNavigationEvent.REFRESH_NAVIGATION, NavigationContoller.instance.breadcrumbDP));

	}

/*	if (!SymmController.instance.isMFamily() && !SymmController.instance.isAFA())
	{
		dispersion.enabled=!(sctrl.configFilter.noEngines == 1 || sctrl.configFilter.noEngines == 2 || this.wizardToggleButton.selected);
	}*/

	if (triggeredBusyWait)
	{
		hideBusyIndicator();
	}
	updateFilterButton(event);
}

/**
 * update filter labels after filtering has been done
 * @param event: event type FilterChangedEvent.FILTER_CHANGED
 */
private function updateFilterButton(event:FilterChangedEvent):void
{
	var filter:ConfigurationFilter=SymmController.instance.configFilter;
	if (!SymmController.instance.isAFA())
	{
		if(!SymmController.instance.isPM())
		{
			if (filter.dispersed == ConfigurationFilter.NO_DISPERSED_DEFAULT)
			{
				dispersion.filterName=getResString('main', "FILTER_DISPERSED");
				dispersion.filterValue=getResString('main', "FILTER_DISPERSED_NO");
			}
			else
			{
				dispersion.filterValue=filter.dispersed.toString();
				dispersion.filterName=getResString('main', "FILTER_DISPERSED");
			}
		}
		else
		{
			if (filter.dispersed_m.length == 1 && filter.dispersed_m[0] == -1)
			{
				dispersion.filterName=getResString('main', "FILTER_DISPERSED");
				dispersion.filterValue=getResString('main', "FILTER_DISPERSED_NO_VG3R");
			}
			else
			{
				dispersion.filterName=getResString('main', "FILTER_DISPERSED");
				dispersion.filterValue=getResString('main', "FILTER_DISPERSED_PM");
			}
		}
	}
	else
	{
		if (filter.dispersed_m.length == 1 && filter.dispersed_m[0] == -1)
		{
			dispersion.filterName=getResString('main', "FILTER_DISPERSED");
			dispersion.filterValue=getResString('main', "FILTER_DISPERSED_NO_VG3R");
		}
		else
		{
			dispersion.filterName=getResString('main', "FILTER_DISPERSED");
			dispersion.filterValue=filter.dispersed_m.toString();
		}
	}

/*	if (filter.daeCount == ConfigurationFilter.NO_DAE_COUNT_DEFAULT)
	{
		daeCount.filterName=getResString('main', "FILTER_DAE_COUNT");
		daeCount.filterValue=getResString('main', "FILTER_DAE_COUNT_ANY");
	}*/
/*	else
	{
		daeCount.filterName=getResString('main', "FILTER_DAE_COUNT");
		daeCount.filterValue=filter.daeCount.toString();
	}*/

/*	if (filter.noStorageBays == ConfigurationFilter.NO_STORAGE_BAYS_DEFAULT)
	{
		noStorageBays.filterName=getResString('main', "FILTER_SBAYS");
		noStorageBays.filterValue=getResString('main', "FILTER_SBAYS_ANY");
	}
	else
	{
		noStorageBays.filterName=getResString('main', "FILTER_SBAYS");
		noStorageBays.filterValue=filter.noStorageBays.toString();
	}*/

	if (filter.noSystemBays == ConfigurationFilter.NO_SYSTEM_BAYS_DEFAULT)
	{
		noSystemBays.filterName=getResString('main', "FILTER_SYSTEM_BAYS");
		noSystemBays.filterValue=getResString('main', "FILTER_SYSTEM_BAYS_ANY");
	}
	else
	{
		noSystemBays.filterName=getResString('main', "FILTER_SYSTEM_BAYS");
		noSystemBays.filterValue=filter.noSystemBays.toString();
	}
	
	if(SymmController.instance.isAFA())
		noEngines.filterName = getResString('main', "FILTER_ENGINES_V_BRICKS");
	else
		noEngines.filterName = getResString('main', "FILTER_ENGINES_POWER_BRICKS");
	
	noEngines.filterValue = filter.noEngines == ConfigurationFilter.NO_ENGINE_DEFAULT ? getResString('main', "FILTER_ENGINES_ANY") : filter.noEngines.toString();
	
	daeType.filterName=getResString('main', (SymmController.instance.isAFA()) ? "FILTER_DAE_TYPE_VG3R" : SymmController.instance.isPM() ? "FILTER_DAE_TYPE_PM" : "FILTER_DAE_TYPE");
	daeType.filterValue = filter.driveType == "0" || filter.driveType == "[object DriveType]" ? getResString('main', "FILTER_DAE_TYPE_ANY") : filter.driveType;
	
	tier.filterName = getResString('main', 'FILTER_NUMBER_OF_DRIVES');
	tier.filterValue = filter.noDrives == ConfigurationFilter.NO_DRIVES_DEFAULT ? getResString('main', "FILTER_NUMBER_OF_DRIVES_ANY") : filter.noDrives.toString();
	
	if(is250F())
	{
		noSystemBays.filterValue = getResString('main', 'FILTER_SYSTEM_BAYS_250F_DEFAULT_VALUE');
		dispersion.filterValue = getResString('main', 'FILTER_DISPERSED_VALUE_250F');
	}
}

/**
 * sets filter button labels to default text
 * @param event: event type FilterChangedEvent.RELOAD_CONFIGS
 */
private function onConfigsReload(event:FilterChangedEvent):void
{
	var filter:ConfigurationFilter=SymmController.instance.configFilter;

	if(SymmController.instance.isAFA())
	{
		noEngines.filterName=getResString('main', "FILTER_ENGINES_V_BRICKS");
		noEngines.filterValue=getResString('main', "FILTER_ENGINES_ANY");
	}
	else
	{
		noEngines.filterName=getResString('main', "FILTER_ENGINES_POWER_BRICKS");
		noEngines.filterValue=getResString('main', "FILTER_ENGINES_ANY");
	}

/*	this.noStorageBays.filterName=getResString('main', 'FILTER_SBAYS');
	this.noStorageBays.filterValue=getResString('main', 'FILTER_SBAYS_ANY');*/

	this.noSystemBays.filterName=getResString('main', 'FILTER_SYSTEM_BAYS');
	this.noSystemBays.filterValue=getResString('main', is250F() ? "FILTER_SYSTEM_BAYS_250F_DEFAULT_VALUE" : "FILTER_SYSTEM_BAYS_ANY");

	this.daeType.filterName=getResString('main', (SymmController.instance.isAFA()) ? "FILTER_DAE_TYPE_VG3R" : SymmController.instance.isPM() ? "FILTER_DAE_TYPE_PM" : "FILTER_DAE_TYPE");
	this.daeType.filterValue=getResString('main', is250F() ? 'FILTER_DAE_TYPE_8' : is450F() || is950F() ? 'FILTER_DAE_TYPE_6' : filter.daeType == ConfigurationFilter.NO_DAE_DEFAULT_MFAMILY ? "FILTER_DAE_TYPE_ANY" : "FILTER_DAE_TYPE_" + filter.daeType);

/*	this.daeCount.filterName=getResString('main', 'FILTER_DAE_COUNT');
	this.daeCount.filterValue=getResString('main', 'FILTER_DAE_COUNT_ANY');*/

/*	this.noDataMovers.filterName=getResString('main', 'FILTER_DATA_MOVER');
	this.noDataMovers.filterValue=String(SymmController.DEFAULT_DATA_MOVER_COUNT);*/

	if (filter.dispersed == ConfigurationFilter.NO_DISPERSED_DEFAULT)
	{
		dispersion.filterName=getResString('main', "FILTER_DISPERSED");
		dispersion.filterValue=getResString('main', is250F() ? "FILTER_DISPERSED_VALUE_250F" :
			is450F() || is950F() ? "FILTER_DISPERSED_NO_VG3R" : "FILTER_DISPERSED_NO");
	}
	else
	{
		dispersion.filterName=getResString('main', "FILTER_DISPERSED");
		dispersion.filterValue=filter.dispersed.toString();
	}

	tier.filterName=getResString('main', 'FILTER_NUMBER_OF_DRIVES');
	tier.filterValue = (SymmController.instance.isAFA() || SymmController.instance.isPM()) ? getResString('main', 'TIER_EFD') : FilterController.instance.tierLabelFunction(filter.tiering);
}

/**
 * creates data provider and opens pop up
 */
private function onFilterButtonClicked(event:MouseEvent):void
{

	popUp=new FilterPopUp();
	_selectedFilter=event.currentTarget as BorderContainer;

	updateFilter(event.currentTarget.name, event.currentTarget, popUp);

	var pt:Point=new Point(mainContainer.x, mainContainer.y);
	pt=mainContainer.localToGlobal(pt);
	pt.y+=mainContainer.height;

	popUp.addEventListener(Event.OPEN, onPopupOpen);
	popUp.visible=false;
	popUp.open(this, true);

	popUp.allowMultipleSelection=event.currentTarget.name == ConfigurationFilter.FILTER_DISPERSED && (SymmController.instance.isAFA());

}

private function onPopupOpen(event:Event):void
{
	calculateSizePopUp();
	callLater(calculateSizePopUp);
	event.target.visible=true;

	var zoom:Zoom=new Zoom(event.target);
	zoom.originX=event.target.width / 2;
	zoom.originY=event.target.height / 2;
	zoom.duration=300;
	zoom.zoomWidthFrom=0;
	zoom.zoomWidthTo=1;
	zoom.zoomHeightFrom=0;
	zoom.zoomHeightTo=1;
	zoom.play();

	(event.target as FilterPopUp).removeEventListener(Event.OPEN, onPopupOpen);
}

/**
 * update filter values
 */
private function updateFilter(filterName:String, target:Object, popUp:FilterPopUp):void
{
	var configFactoryBase:ConfigurationFactoryBase=SymmController.instance.configFactory;

	var result:ArrayCollection=FilterController.instance.generateAllFilterValues(filterName);

	FilterController.instance.filterDataProvider(filterName, result);

	popUp.dataProvider=result;
	if ((SymmController.instance.isAFA() || SymmController.instance.isPM()) && filterName == ConfigurationFilter.FILTER_DISPERSED)
	{
		var tempArr:Vector.<int>=new Vector.<int>();
		var selectedItems:Array=SymmController.instance.configFilter[ConfigurationFilter.FILTER_DISPERSED_M];
		for (var i:int=0; i < selectedItems.length; i++)
		{
			tempArr.push(popUp.dataProvider.getItemIndex(selectedItems[i]));
		}
		popUp.selectedIndices=tempArr;
	}
	else
	{
		popUp.selectedIndex=popUp.dataProvider.getItemIndex(SymmController.instance.configFilter[filterName]) == -1 ? 0 : popUp.dataProvider.getItemIndex(SymmController.instance.configFilter[filterName]);
		popUp.selectedIndices=null;
	}

	popUp.filterBy=filterName;

	popUp.selectedFilterButton=target as Button;

}

/**
 * diagram/realistic toolbar button click handler
 */
private function diagramButtom_Toggle(event:Event):void
{
	// draw diagram
	_renderer.realistic=!diagramButton.selected;
	(_selectedComponent == null) ? _disableRefreshProperty=true : _disableRefreshProperty=false;

	if (currentComponent)
	{
		refreshCentralModel(currentComponent.componentBase);
	}
}

/**
 * Loop toolbar button click handler
 */
private function engineConnButtom_Toggle(event:Event):void
{
	_renderer.renderEngineDAEConnections = this.engineConnButton.selected;
	_disableRefreshProperty = _selectedComponent == null;

	if (currentComponent)
	{
		refreshCentralModel(currentComponent.componentBase);
	}
}

/**
 * flip toolbar button clicked
 */
private function flipButtom_Toggle(event:Event):void
{
	var floorTopViewEnabled:Boolean=(SymmController.instance.isAFA() || SymmController.instance.isPM()) && (currentComponent.componentBase.isConfiguration || currentComponent.componentBase.isBay);

	if (_viewSide == Constants.FRONT_VIEW_PERSPECTIVE)
	{
		SymmController.instance.viewPerspective=_viewSide = Constants.REAR_VIEW_PERSPECTIVE;
	}
	else if (_viewSide == Constants.SIDE_3D_VIEW_PERSPECTIVE)
	{
		SymmController.instance.viewPerspective= _viewSide = Constants.FRONT_VIEW_PERSPECTIVE;
	}
	else if (_viewSide == Constants.REAR_VIEW_PERSPECTIVE)
	{
		if (currentComponent.componentBase is Viking || currentComponent.componentBase is Voyager || floorTopViewEnabled)
		{
			SymmController.instance.viewPerspective = _viewSide = Constants.TOP_VIEW_PERSPECTIVE;
		}
		else
		{
			SymmController.instance.viewPerspective = _viewSide = Constants.FRONT_VIEW_PERSPECTIVE;
		}
	}
	else if (_viewSide == Constants.TOP_VIEW_PERSPECTIVE)
	{
		if (floorTopViewEnabled)
		{
				SymmController.instance.viewPerspective = _viewSide = Constants.FRONT_VIEW_PERSPECTIVE;
	
		}
		else
		{
			SymmController.instance.viewPerspective = _viewSide = Constants.SIDE_3D_VIEW_PERSPECTIVE;
		}

	}

	(_selectedComponent == null) ? _disableRefreshProperty=true : _disableRefreshProperty=false;

	if (currentComponent)
	{
		SymmController.instance.reloadSelectionComponent(currentComponent.componentBase);
		refreshCentralModel(currentComponent.componentBase);
	}
}

/**
 * PRoperties toolbar button click handler
 */
private function propertiesButtom_Toggle(event:Event):void
{
	_propertiesEnabled=false;
	propertiesText.visible=propertiesButton.selected;
	propertiesText.includeInLayout=propertiesButton.selected;
	parentContainer.percentWidth=propertiesButton.selected ? 60 : 100;
	mainContainer.paddingRight=propertiesButton.selected ? MAIN_CONTAINER_PADDING_RIGHT_SMALL : MAIN_CONTAINER_PADDING_RIGHT_BIG;
}

/**
 * Copies central component's bitmapdata to clipboard
 */
private function copyImageToClipboard(event:MouseEvent):void
{
	if (SymmController.instance.currentComponent == null || this.currentComponent == null) //this shouldn't happen
	{
		return;
	}
	try
	{
		copyToClipboardButton.enabled=false;
		var bitmapData:BitmapData=new BitmapData(this.currentComponent.width, this.currentComponent.height);
		bitmapData.draw(this.currentComponent);
		Clipboard.generalClipboard.setData(ClipboardFormats.BITMAP_FORMAT, bitmapData);
	}
	catch (err:Error)
	{
	}
	cpbTimer.start();
}

/**
 * Enable copy to clipboard button
 */
private function copyToClipboardTimerHandler(event:TimerEvent):void
{
	copyToClipboardButton.enabled=_isImageSaveButtonEnabled && !_displayHelp;
	cpbTimer.stop();
}
;

/**
 * save as picture button click
 */
private function saveFile(event:MouseEvent):void
{
	if (SymmController.instance.currentComponent == null)
	{
		return;
	}

	FileSaveUtility.isXml=false;
	FileSaveUtility.justSaveConfig=false;

	if (!_alert)
	{
		_alert=new FileSaveLoadPopup();
		_alert.x=(FlexGlobals.topLevelApplication as DisplayObject).width / 2 - _alert.width / 2;
		_alert.y=(FlexGlobals.topLevelApplication as DisplayObject).height / 2 - _alert.height / 2;
	}
	_alert.title=getResString("main", "EXPORT_AS_PNG");


	_alert.prompt=SymmController.instance.currentComponent.id + ".png";
	
	_alert.isXml=false;
	_alert.open(this, true);
}

/**
 * handles request for opening wizard
 */
private function openWizardRequestHandler(event:FilterWizardEvent):void
{
	wizardToggleButton.selected=true;
	if (event.model != null)
	{
		createFilterWizardPopUp(this, event.model);
	}
	else
	{
		wizardToggleButton_clickHandler(null);
		hideBusyIndicator();
	}
}

/**
 * Wizard button clicked
 */
protected function wizardToggleButton_clickHandler(event:MouseEvent):void
{
	if (wizardToggleButton.selected)
	{
		createFilterWizardPopUp(this);
	}
}

/**
 * Creates new wizard pop up
 * @param value true if DAE type filter value is mixed only, <br/> false otherwise
 * @return created filter wizard pop up
 */
public function createFilterWizardPopUp(container:DisplayObjectContainer, value:Boolean=false):FilterWizardPopUp
{
	wizardPopUp=new FilterWizardPopUp();

	wizardPopUp.addEventListener(PopUpEvent.CLOSE, wizardCloseEvent);
	wizardPopUp.addEventListener(FlexEvent.UPDATE_COMPLETE, wizardUpdateHandler);
	wizardPopUp.disableNonMixed=value;
	wizardPopUp.open(container, true);

	if (SymmController.instance.isAFA() || SymmController.instance.isPM())
	{
		mFamilyFactory.wizardTiering=true;
	}

	if (_cmpToolTip)
		_cmpToolTip.hide();

	return wizardPopUp;
}

/**
 * wizard pop up update complete handler
 * <p>sets central position of pop up</p>
 */
private function wizardUpdateHandler(event:FlexEvent):void
{
	var popUpWidth:Number=FlexGlobals.topLevelApplication.width * ((SymmController.instance.isAFA() || SymmController.instance.isPM()) ? 0.94 : 0.8);
	var popUpHeight:Number=mainContainer.height * ((SymmController.instance.isAFA() || SymmController.instance.isPM()) ? 0.85 : 0.6);

	var skin:FilterWizardPopUpSkin=(event.target as FilterWizardPopUp).skin as FilterWizardPopUpSkin;
	var hdr:Number=skin.headerGroup.width;

	popUpWidth=(popUpWidth > hdr) ? popUpWidth : hdr;

	event.target.x=(FlexGlobals.topLevelApplication.width - popUpWidth) / 2;
	event.target.y=(FlexGlobals.topLevelApplication.height - popUpHeight) / 2;

	event.target.width=popUpWidth;
	event.target.height=popUpHeight;

	skin.vmaxSeria.height=event.target.height * 0.1;
	skin.vmaxSeria.width=(skin.vmaxSeria.height * skin.vmaxSeria.source.width) / skin.vmaxSeria.source.height;

}

private function wizardCloseEvent(event:PopUpEvent):void
{
	if (!event.commit)
	{
		wizardToggleButton.selected=false;
		if (event.data && event.data.length == 2)
		{
			wizardToggleButton.selected=true;
			_generatedConfig=event.data[1] as sym.objectmodel.common.Configuration;
			SymmController.instance.eventHandler.dispatchEvent(new FilterChangeRequestEvent(FilterChangeRequestEvent.REPLACE_REQUEST, null, event.data[0]));
		}
		if (SymmController.instance.isAFA() || SymmController.instance.isPM())
		{
			mFamilyFactory.wizardTiering=false;
		}
	}
	else
	{
		SymmController.instance.eventHandler.dispatchEvent(new FilterChangeRequestEvent(FilterChangeRequestEvent.REPLACE_REQUEST, null, event.data[0]));
	}

	showComponentToolTip(event, false);
}

/**
 * Hides current toolTip or toolTip on selected Component
 *@param event
 */
public function hideComponentToolTip(event:Event=null):void
{
	if (CommonUtility.getOS() == CommonUtility.IOS || CommonUtility.getOS() == CommonUtility.ANDROID)
	{
		if (event && event is ToolTipEvent && event.type == ToolTipEvent.TOOL_TIP_SHOWN)
		{
			CustomToolTip.hideCurrent();
			return;
		}

		if (_cmpToolTip)
		{
			_cmpToolTip.hide();

			if (_cmpToolTip.target is TransparentOverlayComponent)
				// if transparent overlay component is toolTip target
				// border is not visible
				_cmpToolTip.target.setStyle("borderVisible", false);
		}

	}
}

/**
 * Creates and shows component toolTip
 * @param ev indicates one of the events:<br/>
 * <code>MouseEvent.CLICK </code>/MouseEvent.MOUSE_UP/ResizeEvent/ToolTipCustomEvent event
 * @param createNewTip indicates if new toolTip instance should be created. Default value is <code> true </code>
 */
private function showComponentToolTip(ev:Event, createNewTip:Boolean=true):void
{
	if (ev.type != ToolTipCustomEvent.START_TOOLTIP && (CommonUtility.getOS() == CommonUtility.IOS || CommonUtility.getOS() == CommonUtility.ANDROID))
	{
		// if it's toolTip for the same selected component
		// just display it - don't create new instance
		if (!createNewTip)
		{
			if (_selectedComponent)
			{
				CustomToolTip.positionChanged=true;
				_cmpToolTip.display(null, null, this);
			}

			return;
		}

		if (_cmpToolTip)
		{
			_cmpToolTip.destroy();

			_cmpToolTip = null;
		}

		var target:Object=ev is MouseEvent && ev.type == MouseEvent.CLICK ? ev.target : (ev as ToolTipCustomEvent).targetComponent;

		if (ev is ToolTipCustomEvent && ev.type == ToolTipCustomEvent.SHOW_TOOLTIP)
		{
			// set target border
			target.setStyle("borderVisible", true);
		}

		_cmpToolTip = new CustomToolTip(target.toolTip, target, null);

		_cmpToolTip.display(target, target.toolTip, this);

	}
	// non-mobile version
	else if (ev.type == ToolTipCustomEvent.START_TOOLTIP && CommonUtility.getOS() != CommonUtility.IOS && CommonUtility.getOS() != CommonUtility.ANDROID)
	{
		(ev as ToolTipCustomEvent).targetComponent.setStyle("borderVisible", true);
	}
}

private function onResize(event:ResizeEvent):void
{
	if (wizardPopUp && wizardPopUp.isOpen)
	{
		wizardPopUp.calculateWizardWidth();
	}
	else if (popUp && popUp.isOpen)
	{
		calculateSizePopUp();
		callLater(calculateSizePopUp);
	}
	else
	{
		if (propertiesButton && propertiesButton.selected)
		{
			reCalculateSize();
			callLater(reCalculateSize);
		}

		else
		{
			mainContainer.percentHeight=100;

			selectionContainer.percentHeight=18;
			filterContainer.percentHeight=13;
		}

	}

}

private function calculateSizePopUp():void
{
	var optWidth:Number=popUp.labelWidth;
	if (popUp.width < optWidth)
	{
		popUp.width=optWidth;
	}
	var popupHeight:Number=popUp.titleArea.height + popUp.filterList.height + 10;

	if (!popUp.isOpen)
	{
		popUp.height=popupHeight;
	}

	popUp.x=_selectedFilter.x - (popUp.width - _selectedFilter.width) / 2;
	popUp.width=mainContainer.width / 3;
	if (popUp.x < mainContainer.paddingLeft)
	{
		popUp.x=mainContainer.paddingLeft;
	}
	else if ((popUp.x + popUp.width) > (mainContainer.width - mainContainer.paddingRight - this.filterButtonsGroup.gap))
	{
		popUp.x=mainContainer.width - mainContainer.paddingRight - popUp.width;
	}

	var actionBarHeight:Number=FlexGlobals.topLevelApplication.height / ViewConstants.DEFAULT_APP_HEIGHT * ViewConstants.DEFAULT_ACTIONBAR_HEIGHT;
	if (popupHeight > mainContainer.height)
	{
		popUp.y=(mainContainer.y + mainContainer.height + actionBarHeight) - popUp.height + mainContainer.paddingBottom;
	}
	else
	{
		popUp.y=(mainContainer.y + mainContainer.height + actionBarHeight) - popUp.height - mainContainer.paddingBottom;
	}
}

private function reCalculateSize():void
{
	selectionContainer.height=height * 0.14;
	filterContainer.height=height * 0.10;

	mainContainer.height=FlexGlobals.topLevelApplication.height - (selectionContainer.height + filterContainer.height + titleBarComponent.height + toolBarComponent.height);
}

/**
 * Save configuration as xml when Save btn is clicked
 */
private function saveAsXml(event:MouseEvent):void
{
	if (!SymmController.instance.currentComponent.parentConfiguration)
		throw new ArgumentError("Configuration can be saved as xml only if configuration exists");

	showBusyIndicator();

	var symmController:SymmController=SymmController.instance;
	var config:Configuration_VG3R=symmController.currentComponent.parentConfiguration as Configuration_VG3R;

	FileSaveUtility.isXml=true;
	FileSaveUtility.justSaveConfig=true;

	var status:String=FileSaveUtility.storeXmlOnIOS(config.serializeToXML(), config.fileName, true);

	if (status == FileSaveUtility.FILE_STATUS_SAVED)
	{
		// configuration is saved  
		config.saved=true;
		// disable save btn
		_isSaveCfgButtonEnabled=false;

		successfullyStoredMessagePopup();
	}

	hideBusyIndicator();
}

/**
 * export xml file when export xml btn is clicked
 */
private function exportAsXml(event:MouseEvent):void
{
	var symmController:SymmController=SymmController.instance;
	if (symmController.currentComponent.isConfiguration)
	{
		var config:sym.objectmodel.common.Configuration=symmController.currentComponent as sym.objectmodel.common.Configuration;

		FileSaveUtility.isXml=true;
		FileSaveUtility.justSaveConfig=false;

		if (!_alert)
		{
			_alert=new FileSaveLoadPopup();
			_alert.x=(FlexGlobals.topLevelApplication as DisplayObject).width / 2 - _alert.width / 2;
			_alert.y=(FlexGlobals.topLevelApplication as DisplayObject).height / 2 - _alert.height / 2;
		}
		_alert.title=getResString("main", "EXPORT_AS_XML");


		_alert.prompt=config.id + ".xml";
		
		_alert.isXml=true;
		_alert.open(this, true);
	}
}

private function onExportFileRequest(event:ExportFileEvent):void
{
	showBusyIndicator();
	if (event.isXml)
	{
		var status:String=FileSaveUtility.storeXmlOnIOS(SymmController.instance.currentComponent.serializeToXML(), event.filename, false);
		if (status == FileSaveUtility.FILE_STATUS_SAVED && _alert.isOpen)
		{
			successfullyStoredMessagePopup();
//			_alert.close();
		}
		else if (status == FileSaveUtility.FILE_STATUS_NAME_COLLIDE)
		{
			openMessagePopUpCollision(event.filename);
		}
	}
	else
	{
		if (FileSaveUtility.exportPictureOnIOS(this.currentComponent, event.filename, false) == FileSaveUtility.FILE_STATUS_SAVED && _alert.isOpen)
		{
			successfullyStoredMessagePopup();
//			_alert.close();
		}
		else if (FileSaveUtility.exportPictureOnIOS(this.currentComponent, event.filename, false) == FileSaveUtility.FILE_STATUS_NAME_COLLIDE)
		{
			openMessagePopUpCollision(event.filename);
		}
	}
	hideBusyIndicator();
}

/**
 * handles refreshing of selection component data
 */
protected function refreshSelectionComponentData(event:SelectionComponentDataChangedEvent):void
{
	var componentIndex:int=SymmController.instance.getCurrentSelectedIndex(event.dpType);
	if (componentIndex != -1)
	{
		this.selectionComponent.selectedIndex=componentIndex;
	}
}

/**
 * import from xml toolbar button clicked
 */
private function importXml(event:MouseEvent):void
{
	showBusyIndicator();
	FileSaveUtility.importXml();
	hideBusyIndicator();
}

private function onXmlImported(event:XmlImportedEvent):void
{
	var valid:Boolean=false;
	if (event.importedXml)
	{
		valid=ComponentBase.validateXml(event.importedXml);
	}
	if (!valid)
	{
		MessagePopup.open(getResString("main", "ERROR_XML_VALIDATION"), getResString("main", "ERROR_XML_VALIDATION_TITLE"), this, MessagePopup.ERROR_MESSAGE, MessagePopup.BUTTON_OK);
		return;
	}
	var cb:ComponentBase=null;

	try
	{
		// add condition to continue with sizerXML
		if(!event.importedXml.config)	
		var model:String=event.importedXml.@series.toString().length > 0 ? event.importedXml.@series : event.importedXml.child(Configuration_VG3R.MODEL_XML_NAME).toString();

		var factory:ConfigurationFactoryBase= null;

		cb=ComponentBase.deserializeFromXML(event.importedXml, factory);
	}
	catch (ex:Error)
	{
		showMessagePopUp();
	}

/*	SymmController.instance.importedConfigurations.vmaxseria=model;
	(cb as sym.objectmodel.common.Configuration).factory=SymmController.instance.importedConfigurations;
	var exist:Boolean=false;
	for (var i:int=0; i < SymmController.instance.importedConfigurations.configurations.length; i++)
	{
		if ((cb.id == (SymmController.instance.importedConfigurations.configurations[i] as ComponentBase).id) && ((cb as sym.objectmodel.common.Configuration).dispersed == (SymmController.instance.importedConfigurations.configurations[i] as sym.objectmodel.common.Configuration).dispersed))
		{
			exist=true;
			break;
		}
	}*/

	// for(var d15:int = 4; d15 <= 56; d15 += 4){
	//SymmController.instance.importedConfigurations.configurations.push(SymmController.instance.generateMod4StandardMix(4, 40, 24, true));
	// }
	// cb = SymmController.instance.importedConfigurations.configurations[0];

	// var d15DP:Array = FilterController.instance.generate10kMixConfigsD15Values(1, false);
	//  var vangDP:Array = FilterController.instance.generate10kMixConfigsVanguardValues(1, false, 4);

/*	SymmController.instance.lastImportedConfig=cb as sym.objectmodel.common.Configuration;
	if (!exist)
	{
		if (SymmController.instance.vmaxConfiguration != Constants.IMPORTED_CONFIGS)
		{
			removeEventListeners();
			SymmController.instance.eventHandler.dispatchEvent(new VMaxSelectionChangeRequestEvent(VMaxSelectionChangeRequestEvent.CHANGE_REQUEST, Constants.IMPORTED_CONFIGS));
		}
		else
		{
			SymmController.instance.reloadImportedConfigurations((cb as sym.objectmodel.common.Configuration).dispersed, (cb as sym.objectmodel.common.Configuration).daeType);
		}
	}
	else
	{
		MessagePopup.open(getResString("main", "INFO_XML_ALREADY_IMPORTED"), getResString("main", "INFO_XML_ALREADY_IMPORTED_TITLE"), this, MessagePopup.INFO_MESSAGE, MessagePopup.BUTTON_OK);

		if (SymmController.instance.vmaxConfiguration != Constants.IMPORTED_CONFIGS)
		{
			removeEventListeners();
			SymmController.instance.eventHandler.dispatchEvent(new VMaxSelectionChangeRequestEvent(VMaxSelectionChangeRequestEvent.CHANGE_REQUEST, Constants.IMPORTED_CONFIGS));
		}
		else
		{
			SymmController.instance.reloadImportedConfigurations((cb as sym.objectmodel.common.Configuration).dispersed, (cb as sym.objectmodel.common.Configuration).daeType);
		}
	}*/
//	SymmController.instance.showComponent(cb);

}

/**
 * properties text effect end
 * enables properties button
 */
protected function onEffectEnd(event:EffectEvent):void
{

	if (_propEnabled)
	{
		_propertiesEnabled=true;
	}
}

override protected function measure():void
{
	super.measure();

	if (propertiesButton && propertiesButton.selected)
	{
		parentContainer.percentWidth=70;
		propertiesText.percentWidth=30;

		if (currentComponent && currentComponent.componentBase && currentComponent.componentBase.isConfiguration)
		{
			_resX=FlexGlobals.topLevelApplication.width;
			_resY=FlexGlobals.topLevelApplication.height;
			if (_resX < 1400 || _resY < 800)
			{
				parentContainer.percentWidth=60;
				propertiesText.percentWidth=40;
			}
			else
			{
				parentContainer.percentWidth=70;
				propertiesText.percentWidth=30;
			}
		}
		if ((currentComponent && currentComponent.componentBase.parentConfiguration is Configuration_VG3R) && (_selectedComponent && _selectedComponent.componentBase is Engine || currentComponent.componentBase is Engine))
		{
			parentContainer.percentWidth=50;
			propertiesText.percentWidth=50;
		}
	}
	else
	{
		parentContainer.percentWidth=100;
	}

	parentContainer.percentHeight=100;

	selectionContainer.height=0.14 * height;
	filterContainer.height=0.10 * height;

}

/**
 * Updates save xml buttons visibility status.
 * <p> Disables xml export button if current component is not configuration. <p/>
 * <p> Disables save config button if current component is not configuration and if configuration is already saved </p>
 */
private function updateSaveXmlButtons(comp:ComponentBase):void
{
	_isExportXmlButtonEnabled=comp && comp.isConfiguration && _exportFunctionalityEnabled;

	if (SymmController.instance.isAFA() || SymmController.instance.isPM())
		_isSaveCfgButtonEnabled=!(comp.parentConfiguration as Configuration_VG3R).saved;
}

private function onXmlImportError(event:XmlImportErrorEvent):void
{
	showMessagePopUp();
}

private function showMessagePopUp():void
{
	MessagePopup.open(getResString("main", "ERROR_XML_VALIDATION"), getResString("main", "ERROR_XML_VALIDATION_TITLE"), this, MessagePopup.ERROR_MESSAGE, MessagePopup.BUTTON_OK);
	return;
}

private function errorMessagePopUp(event:Event):void
{
	var mess:MessagePopup = new MessagePopup();
	if(is250F())
	{
		mess = MessagePopup.open(getResString("main", "ERROR_DESCRIPTION_250F_XML"), getResString("main", "ERROR_XML_VALIDATION_TITLE"), this, MessagePopup.ERROR_MESSAGE, MessagePopup.BUTTON_OK);
		mess.width = 500;
	}
	else if(is950F())
	{
		mess = MessagePopup.open(getResString("main", "ERROR_DESCRIPTION_950F_XML"), getResString("main", "ERROR_XML_VALIDATION_TITLE"), this, MessagePopup.ERROR_MESSAGE, MessagePopup.BUTTON_OK);
		mess.width = 500;
	}
	else if(isPM2000())
	{
		mess = MessagePopup.open(getResString("main", "ERROR_DESCRIPTION_PM2000_XML"), getResString("main", "ERROR_XML_VALIDATION_TITLE"), this, MessagePopup.ERROR_MESSAGE, MessagePopup.BUTTON_OK);
		mess.width = 500;
	}
	else
	{
		mess = MessagePopup.open(getResString("main", "ERROR_DESCRIPTION_PM8000_XML"), getResString("main", "ERROR_XML_VALIDATION_TITLE"), this, MessagePopup.ERROR_MESSAGE, MessagePopup.BUTTON_OK);
		mess.width = 500;
	}
	
	return;
}

private var _colliedFilename:String="";

/**
 * PopUp displaying successfully file saved message
 */
private function successfullyStoredMessagePopup():void
{
	var filePath:String=FileSaveUtility.isXml ? FileSaveUtility.XML_FILE_PATH : FileSaveUtility.IMG_FILE_PATH;
	var popUpTitle:String=getResString("main", FileSaveUtility.justSaveConfig ? "SAVE_CONFIG" : FileSaveUtility.isXml ? "EXPORT_AS_XML" : "EXPORT_AS_PNG");
	var popup:MessagePopup=MessagePopup.open(FileSaveUtility.justSaveConfig ? getResString("main", "INFO_CONFIG_SAVED") : StringUtil.substitute(getResString("main", "INFO_FILE_SAVE_PATH"), filePath), popUpTitle, this, MessagePopup.INFO_MESSAGE, MessagePopup.BUTTON_OK);
	popup.addEventListener(PopUpEvent.OPEN, onSuccessfullPopupOpened);
}

private function openMessagePopUpCollision(filename:String):void
{
	var popup:MessagePopup=MessagePopup.open(getResString("main", FileSaveUtility.justSaveConfig ? "INFO_CONFIG_SAVE_NAME_COLLISION" : "INFO_FILE_SAVE_NAME_COLLISION"), getResString("main", FileSaveUtility.justSaveConfig ? "INFO_CONFIG_SAVE_COLLISION_TITLE" : "INFO_FILE_SAVE_COLLISION_TITLE"), this, MessagePopup.WARNING_MESSAGE, MessagePopup.BUTTON_YES | MessagePopup.BUTTON_NO | MessagePopup.BUTTON_CANCEL);
	popup.addEventListener(PopUpEvent.CLOSE, onPopupClosed);
	_colliedFilename=filename;
}

private function onSuccessfullPopupOpened(event:PopUpEvent):void
{
	if (_alert && _alert.isOpen)
	{
		_alert.close();
	}
}

private function onPopupClosed(event:PopUpEvent):void
{
	if (event.target.result == MessagePopup.RESULT_OK)
	{
		if (FileSaveUtility.isXml)
		{
			if (FileSaveUtility.storeXmlOnIOS(SymmController.instance.currentComponent.serializeToXML(), _colliedFilename, true) == FileSaveUtility.FILE_STATUS_SAVED && _alert.isOpen)
			{
				_alert.close();
				successfullyStoredMessagePopup();
			}
		}
		else
		{
			if (FileSaveUtility.exportPictureOnIOS(this.currentComponent, _colliedFilename, true) == FileSaveUtility.FILE_STATUS_SAVED && _alert.isOpen)
			{
				_alert.close();
				successfullyStoredMessagePopup();
			}
		}
	}
	else if (event.target.result == MessagePopup.RESULT_NO)
	{
		_alert.isVisible=true;
	}
	else if (event.target.result == MessagePopup.RESULT_CANCEL)
	{
		_alert.close();
	}
}

private function resetAllFilters(event:Event):void
{
	SymmController.instance.resetConfigurationFilter();
}

/**
 * Component Drag Started
 * <p> Highlights slots that can be populated with dragged engine port </p>
 * <p> Display trash can in the central area when dragging config icon </p>
 */
private function componentDragStartHandler(event:ComponentDragDropEvent):void
{
	if (event.component is EnginePort)
	{
		var slots:Array=currentEngine.getAvailableSlots(event.component as EnginePort, dragController.isMoveOrRemoveAction);

		removeBorders(event);

		for each (var slot:int in slots)
		{
			var slotRect1:Rectangle=RenderUtility.createVg3rEngineComponentRect(currentComponent, 9 - slot);
			var slotRect2:Rectangle=RenderUtility.createVg3rEngineComponentRect(currentComponent, 19 - slot);
			var bc:BorderContainer=createComponentBorder(slotRect1.x, slotRect1.y, slotRect1.width, slotRect1.height);

			currentComponent.addChild(bc);
			_highlightedBorders.addItem(bc);

			bc=createComponentBorder(slotRect2.x, slotRect2.y, slotRect2.width, slotRect2.height);
			currentComponent.addChild(bc);
			_highlightedBorders.addItem(bc);
		}
	}

	if (event.component.isVG3Rconfiguration)
	{
		/* play Fade effect (main central area) - from visible to invisible state */
		mainViewFade.alphaFrom=1;
		mainViewFade.alphaTo=0.1;
		mainViewFade.play();

		/* play Fade and Zoom effect for trashCan component */
		trashCanFade.play();

		var zoom:Zoom=new Zoom(configTrashCan);
		zoom.originX=zoom.target.width / 2;
		zoom.originY=zoom.target.height / 2;
		zoom.duration=1000;
		zoom.zoomWidthFrom=0.4;
		zoom.zoomWidthTo=1.2;
		zoom.zoomHeightFrom=0.4;
		zoom.zoomHeightTo=1.2;
		zoom.end();
		zoom.play();

		// trashCan is visible  
		_isConfigTrashCanVisible=true;
		configTrashCan.source=TrashCan;

	}
}

/**
 * <p> Examine if dragged image is over the trash can place holder </p>
 * <p> Used for validation of dropped place for dragged configuration icon. <br/>
 * 	   Used to replace and set new trash icon image. </p>
 * @return <code>True </code> if dragged image is over the trash can, otherwise is <code>False </code>
 */
private function checkDraggedImageIntersection():Boolean
{
	var dragImage:UIComponent=this.dragController.dragImage;

	var dragImgRect:Rectangle=new Rectangle(dragImage.x, dragImage.y, dragImage.width, dragImage.height);

	var trashCanRect:Rectangle=new Rectangle(this.configTrashCan.x, this.configTrashCan.y, this.configTrashCan.width, this.configTrashCan.height);

	return trashCanRect.intersects(dragImgRect);
}

/**
 * Move handler for drag container
 */
private function componentMovedHandler(event:ComponentDragDropEvent):void
{
	if (checkDraggedImageIntersection())
	{
		// when dragged image is over the trash can
		// use "open trash can" image
		configTrashCan.source=TrashCanOpened;
	}
	else
	{
		configTrashCan.source=TrashCan;
	}
}

/**
 * <p>Removes borders from component in which slot borders reside.</p>
 * <p>
 * If dragging process occurs overlay component border will be removed.<br/>
 * Otherwise, highlighted borders will be removed and overlay borders returned to visible state.
 * </p>
 *
 */
private function removeBorders(event:ComponentDragDropEvent):void
{
	var overlayBorders:ArrayCollection=(currentComponent.componentBase as Engine).overlayPorts;

	if (event.type == ComponentDragDropEvent.COMPONENT_DRAG_STARTED)
	{
		if (_highlightedBorders.length > 0)
		{
			_highlightedBorders.removeAll();
		}

		for each (var overlay:TransparentOverlayComponent in overlayBorders)
		{
			overlay.removeEventListeners();
		}
	}
	else
	{
		for each (var border:BorderContainer in _highlightedBorders)
		{
			currentComponent.removeChildAt(currentComponent.getChildIndex(border));
		}

		for each (var ob:TransparentOverlayComponent in overlayBorders)
		{
			ob.addEventListeners();
		}
	}
}

/**
 * Creates component highlight border
 */
private function createComponentBorder(x:Number, y:Number, width:Number, height:Number):BorderContainer
{
	var b:BorderContainer=new BorderContainer();
	b.x=x;
	b.y=y;
	b.width=width;
	b.height=height;
	b.styleName="dropSlotStyle";

	return b;
}

/**
 * Handler when dragged image is droppped.
 * <p> Used for engine ports and configuration icons </p>
 */
private function componentDroppedHandler(event:ComponentDragDropEvent):void
{
	/* Configuration Icon is dropped */
	if (event.component.isVG3Rconfiguration)
	{
		// set trashCan to invisible state
		_isConfigTrashCanVisible=false;

		if (checkDraggedImageIntersection())
		{
			removeConfiguration(new RemoveConfigurationEvent(RemoveConfigurationEvent.DELETE_CONFIG, event.component as Configuration_VG3R));
		}

		/* play Fade effect (main central area) - from invisible state to visible */
		mainViewFade.alphaFrom=0;
		mainViewFade.alphaTo=1;
		mainViewFade.play();

		return;
	}
	/* Engine port is dropped */

	var locToGlob:Point=this.dragContainer.localToGlobal(new Point(event.mouseX, event.mouseY));
	var globToComponent:Point=this.currentComponent.globalToLocal(locToGlob);

	var dropSlot:int=RenderUtility.getVg3rEngineSlotByPoint(globToComponent.x, globToComponent.y, currentComponent);

	removeBorders(event);

	if (_cmpToolTip)
		_cmpToolTip.hide();

	if (dropSlot == -1 || !currentEngine.validateEnginePortSlot(event.component as EnginePort, dropSlot, dragController.isMoveOrRemoveAction))
	{
		if (dragController.isMoveOrRemoveAction && (event.component as EnginePort).isRemovable)
		{
			currentEngine.removeEnginePort(event.component as EnginePort);
			SymmController.instance.showComponent(currentComponent.componentBase, true);
			currentEngine.parentConfiguration.noPortsModulesChanged = true;
		}

		return;
	}
	else if (!dragController.isMoveOrRemoveAction)
	{
		currentEngine.placeEnginePort(event.component as EnginePort, dropSlot);
		currentEngine.parentConfiguration.noPortsModulesChanged = true;
	}

	SymmController.instance.showComponent(currentComponent.componentBase, true);
}

/**
 * Call removeConfiguration method from SymmController. <br/>
 * Delete configuration from filesystem if exists
 * @param event RemoveConfigurationEvent.DELETE_CONFIG
 */
private function removeConfiguration(event:RemoveConfigurationEvent):void
{
	SymmController.instance.removeConfiguration(event.config);

	if (event.config.saved)
	{
		FileSaveUtility.deleteXml(event.config.fileName);
	}
}

public function removeEventListeners():void
{
	if (SymmController.instance.eventHandler.hasEventListener(ComponentSelectionChangedEvent.COMPONENT_SELECTION_CHANGED))
	{
		SymmController.instance.eventHandler.removeEventListener(ComponentSelectionChangedEvent.COMPONENT_SELECTION_CHANGED, refreshCentralModelHandler);
	}
	if (SymmController.instance.eventHandler.hasEventListener(ExportFileEvent.EXPORT_REQUEST))
	{
		SymmController.instance.eventHandler.removeEventListener(ExportFileEvent.EXPORT_REQUEST, onExportFileRequest);
	}
	if (SymmController.instance.eventHandler.hasEventListener(RedrawEvent.REDRAW_EVENT))
	{
		SymmController.instance.eventHandler.removeEventListener(RedrawEvent.REDRAW_EVENT, redrawCentralModelHandler);
	}
	if (SymmController.instance.eventHandler.hasEventListener(XmlImportedEvent.XML_IMPORTED))
	{
		SymmController.instance.eventHandler.removeEventListener(XmlImportedEvent.XML_IMPORTED, onXmlImported);
	}
	if (SymmController.instance.eventHandler.hasEventListener(XmlImportErrorEvent.XML_IMPORT_ERROR))
	{
		SymmController.instance.eventHandler.removeEventListener(XmlImportErrorEvent.XML_IMPORT_ERROR, onXmlImportError);
	}
	if (SymmController.instance.eventHandler.hasEventListener(XmlImportErrorEvent.XML_WRONG_ERROR))
	{
		SymmController.instance.eventHandler.removeEventListener(XmlImportErrorEvent.XML_WRONG_ERROR, errorMessagePopUp);
	}
	if (SymmController.instance.eventHandler.hasEventListener(FilterChangedEvent.RELOAD_CONFIGS))
	{
		SymmController.instance.eventHandler.removeEventListener(FilterChangedEvent.RELOAD_CONFIGS, onConfigsReload);
	}
	if (SymmController.instance.eventHandler.hasEventListener(FilterChangedEvent.FILTER_CHANGED))
	{
		SymmController.instance.eventHandler.removeEventListener(FilterChangedEvent.FILTER_CHANGED, onFilterChanged);
	}
	if (SymmController.instance.eventHandler.hasEventListener(SelectionComponentDataChangedEvent.DATA_SOURCE_CHANGED))
	{
		SymmController.instance.eventHandler.removeEventListener(SelectionComponentDataChangedEvent.DATA_SOURCE_CHANGED, refreshSelectionComponentData);
	}
	if (SymmController.instance.eventHandler.hasEventListener(FilterWizardEvent.FILTER_WIZARD_OPEN_REQUEST))
	{
		SymmController.instance.eventHandler.removeEventListener(FilterWizardEvent.FILTER_WIZARD_OPEN_REQUEST, openWizardRequestHandler);
	}
	if (SymmController.instance.eventHandler.hasEventListener(ToolTipCustomEvent.SHOW_TOOLTIP))
	{
		SymmController.instance.eventHandler.removeEventListener(ToolTipCustomEvent.SHOW_TOOLTIP, showComponentToolTip);
	}
	if (dragController.hasEventListener(ComponentDragDropEvent.COMPONENT_DROPPED))
	{
		dragController.removeEventListener(ComponentDragDropEvent.COMPONENT_DROPPED, componentDroppedHandler);
	}
	if (dragController.hasEventListener(ComponentDragDropEvent.COMPONENT_DRAG_STARTED))
	{
		dragController.removeEventListener(ComponentDragDropEvent.COMPONENT_DRAG_STARTED, componentDragStartHandler);
	}
	if (dragController.hasEventListener(ComponentDragDropEvent.COMPONENT_MOVED))
	{
		dragController.removeEventListener(ComponentDragDropEvent.COMPONENT_MOVED, componentMovedHandler);
	}
	if (SymmController.instance.eventHandler.hasEventListener(RemoveConfigurationEvent.DELETE_CONFIG))
	{
		SymmController.instance.eventHandler.removeEventListener(RemoveConfigurationEvent.DELETE_CONFIG, removeConfiguration);
	}
}

/**
 * drag controller reference
 */
private function get dragController():DragDropController
{
	return SymmController.instance.dragDropController;
}

/**
 * M Family config factory getter
 */
private function get mFamilyFactory():ConfigurationFactoryBase_VG3R
{
	return SymmController.instance.configFactory as ConfigurationFactoryBase_VG3R;
}

/**
 * current Enginne selected component
 */
private function get currentEngine():Engine
{
	return SymmController.instance.currentComponent as Engine;
}
