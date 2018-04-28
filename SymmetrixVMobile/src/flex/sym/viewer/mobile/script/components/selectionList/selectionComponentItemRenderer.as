import flash.desktop.Icon;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.Timer;

import mx.core.ScrollPolicy;
import mx.core.UIComponent;
import mx.effects.MaskEffect;
import mx.events.FlexEvent;
import mx.events.ResizeEvent;
import mx.events.ToolTipEvent;
import mx.states.OverrideBase;

import spark.components.Image;
import spark.components.List;
import spark.core.IGraphicElement;
import spark.events.PopUpEvent;

import images.SelectionIcons;
import images.icons.oldVmax.ConfigurationIcons;

import sym.controller.NavigationContoller;
import sym.controller.SymmController;
import sym.controller.events.ComponentDragDropEvent;
import sym.controller.events.RemoveConfigurationEvent;
import sym.controller.events.ToolTipCustomEvent;
import sym.controller.model.DragDropController;
import sym.controller.utils.ImageRenderer;
import sym.controller.utils.RenderUtility;
import sym.objectmodel.common.ComponentBase;
import sym.objectmodel.common.Configuration;
import sym.objectmodel.common.Configuration_VG3R;
import sym.objectmodel.common.EnginePort;
import sym.objectmodel.common.PDU;
import sym.objectmodel.common.PortConfiguration;
import sym.objectmodel.common.SPS;
import sym.objectmodel.driveUtils.DictionaryExt;
import sym.viewer.mobile.utils.CommonUtility;
import sym.viewer.mobile.utils.FileSaveUtility;
import sym.viewer.mobile.views.ConfigurationView;
import sym.viewer.mobile.views.components.popups.MessagePopup;

import symm.icon.utils.IconRenderUtility;


public static const DRAG_START_DELAY:int=200;
public static const DRAG_ICON_ID:String = "_d";

[Bindable]
private var _model:ComponentBase;

[Bindable]
private var _label:String;

[Bindable]
private var _borderVisible:Boolean=false;

private var _componentCreated:Boolean=false;
private var _startDrag:Boolean=false;
private var _timer:Timer=new Timer(DRAG_START_DELAY, 1);
private var _cfgRemoveButtonWidth:Number=0;
private var _cfgRemoveButtonHeight:Number=0;
private var _cfgRemoveButtonX:Number=0;
private var _cfgRemoveButtonY:Number=0;

/**
 * date setter tries to draw component if caled after component creation complete
 */
public override function set data(value:Object):void
{
	super.data=value;
	_model=value as ComponentBase;
	
	if((is250F() || SymmController.instance.isPM()) && _model is PDU)
		return;
	
	_label=SymmController.instance.componentNameProvider.getUserFriendlyName(_model);
	
	if (_model is EnginePort)
	{
		this.toolTip=NavigationContoller.instance.toolTipProvider.getToolTip(SymmController.instance.viewPerspective, _model);
	}
	else
	{
		this.toolTip=null;
	}

	iconImage.source=getIconSource();
}

/**
 * handles click event
 * sends selection change request
 */
protected function onClick(event:Event):void
{
	if (SymmController.instance.selectionEnabled)
	{
		SymmController.instance.selectComponent(_model);
	}

	if (_model is EnginePort && this.toolTip != null)
	{
		// show engine module toolTip
		SymmController.instance.eventHandler.dispatchEvent(new ToolTipCustomEvent(ToolTipCustomEvent.SHOW_TOOLTIP, this));
	}
}

private function getIconSource():Object
{
	if (!_model)
	{
		return null;
	}

	iconImage.percentWidth=100;
	iconImage.percentHeight=100;

	if (_model is Configuration)
	{
		var cfg:Configuration=_model as Configuration;
		var source:String="Icon_" + SymmController.instance.configFactory.getCalculatedId(cfg);

		if (cfg is Configuration_VG3R)
		{
			generateIcon(cfg as Configuration_VG3R);

			return SymmController.instance.vg3rConfigIcons[cfg.calculatedId];
		}
		else
		{
			return images.icons.oldVmax.ConfigurationIcons[source];
		}

	}
	else if (_model is PortConfiguration)
	{
		return SelectionIcons["Port_" + _model.type];
	}
	else if (_model is PDU)
	{
		return SelectionIcons["Phase_" + _model.type];
	}
	else if (_model is SPS)
	{
		return SelectionIcons["SPS_" + _model.type];
	}
	else if (_model is EnginePort)
	{
		var enginePort:EnginePort=_model as EnginePort;

		switch (enginePort.type)
		{
			case EnginePort.FC_4_GLACIER:
				return ImageRenderer["REALISTIC_BACK_PORT_FC4_GLACIER"];
			case EnginePort.FC_4_RAINFALL:
				return ImageRenderer["REALISTIC_BACK_PORT_FC4_RAINFALL"];
			case EnginePort.GIGE_2PORT_10GB_ELNINO:
				return ImageRenderer["REALISTIC_BACK_PORT_10GBE"];
			case EnginePort.GIGE_2PORT_10GB_ERRUPTION:
				return ImageRenderer["REALISTIC_BACK_PORT_10GBE_ERRUPTION"];
			case EnginePort.GIGE_2PORT_10GB_HEATWAVE:
				return ImageRenderer["REALISTIC_BACK_PORT_10GBE_HEATWAVE"];
			case EnginePort.GIGE_2PORT_1GB_THUNDERBOLT:
				return ImageRenderer["REALISTIC_BACK_PORT_1GBE_THUNDERBOLT"];
			case EnginePort.GIGE_4PORT_1GB_THUNDERCHILD:
				return ImageRenderer["REALISTIC_BACK_PORT_1GBE_THUNDERCHILD"];
			case EnginePort.COMPRESSION_ASTEROID:
				return ImageRenderer["REALISTIC_BACK_COMPRESSION_ASTERIOD"];
			case EnginePort.VAULT_FLASH_WIRLWIND:
				return ImageRenderer["REALISTIC_BACK_FLASH_VAULT_WIRLWIND"];
			case EnginePort.GIGE_4PORT_10GB_RAINSTORM:
				return ImageRenderer["REALISTIC_BACK_PORT_10GBE_RAINSTORM"];
			case EnginePort.FICON_4_PORT:
				return ImageRenderer["REALISTIC_BACK_PORT_FICON4"];
		}
	}

	return null;
}

/**
 * Generates configuration icon
 * @param cfg indicates configuration
 */
public function generateIcon(cfg:Configuration_VG3R):void
{

	if (!cfg)
	{
		throw new ArgumentError("Configuration must be supplied in order to generate appropriate icon");
	}

	// don't render icon if it's already generated and stored in dictionary
	if (!SymmController.instance.vg3rConfigIcons.containsKey(cfg.calculatedId))
	{
		IconRenderUtility.generateIcon(cfg);
		//IconRenderUtility.currentIcon.removeChildAt(2);
		var currentIcon:UIComponent = IconRenderUtility.currentIcon;
		
		if (currentIcon)
		{
			/*
			* In Purpose of correct displaying icon in selection component list
			* First, place icon as uicomponent into existing container.
			* Then, update(validate) its position and layout so that icon can be redrawn if necessary
			* Without this rendering icon will not be possible!
			*/
			//				parentContainer.addChild(currentIcon);
			(getNavigator().activeView as ConfigurationView).parentContainer.addChild(currentIcon);
			currentIcon.validateNow();
			currentIcon.includeInLayout = false;
			currentIcon.visible = false;

			// store icon's bitmap in dictionary map

			var bitmapData:BitmapData=new BitmapData(currentIcon.width, currentIcon.height);
			bitmapData.draw(currentIcon, new Matrix());
			SymmController.instance.vg3rConfigIcons[cfg.calculatedId] = new Bitmap(bitmapData);
			
			// first, remove "X" child from icon
			currentIcon.removeChildAt(currentIcon.numChildren - 1);
			(getNavigator().activeView as ConfigurationView).parentContainer.addChild(currentIcon);
			currentIcon.validateNow();
			currentIcon.includeInLayout = false;
			currentIcon.visible = false;

			var bitmapData2:BitmapData=new BitmapData(currentIcon.width, currentIcon.height);
			bitmapData2.draw(currentIcon, new Matrix());
			SymmController.instance.vg3rConfigIcons[cfg.calculatedId + DRAG_ICON_ID] = new Bitmap(bitmapData2);
		}

	}
}

override protected function stateChanged(oldState:String, newState:String, recursive:Boolean):void
{
	super.stateChanged(oldState, newState, recursive);
	if (newState.toString() == "selected")
	{
		_borderVisible=true;
	}
	else
	{
		_borderVisible=false;
	}
}

/**
 * Hide default toolTip for Desktop Mouse over functionality
 */
private function toolTipShownHandler(ev:ToolTipEvent):void
{
	SymmController.instance.eventHandler.dispatchEvent(ev);
}

/**
 * Mouse Down Handler
 * <p>Starts timer which starts dragging after 200ms</p>
 */
private function mouseDownHandler(event:MouseEvent):void
{
	if (dragController.dragEnabled)
	{
		_startDrag=true;

		if (!_timer.hasEventListener(TimerEvent.TIMER))
		{
			_timer.addEventListener(TimerEvent.TIMER, timerHandler);
		}
		_timer.start();
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
public function timerHandler(event:TimerEvent):void
{
	_timer.stop();

	var bitmap:Image = new Image();

	var size:Rectangle = ConfigurationView.getDraggedComponentSize();

	if (this.data is Configuration_VG3R)
	{
		var dictionaryIcons:DictionaryExt = SymmController.instance.vg3rConfigIcons;
		bitmap.source = dictionaryIcons[(this.data as Configuration_VG3R).calculatedId + DRAG_ICON_ID];

		if (CommonUtility.OPERATING_SYSTEM == CommonUtility.IOS || CommonUtility.OPERATING_SYSTEM == CommonUtility.ANDROID || CommonUtility.OPERATING_SYSTEM == CommonUtility.BB)
		{
			bitmap.width = bitmap.source.width * 0.2;
			bitmap.height = bitmap.source.height * 0.2;
		}
		else
		{
			bitmap.width = bitmap.source.width * 0.1;
			bitmap.height= bitmap.source.height * 0.1;
		}
	}
	else
	{
		bitmap.source = ImageRenderer.getComponentSmallImage((data as ComponentBase).type);
		bitmap.source = ImageRenderer.getComponentSmallImage((data as ComponentBase).type);
		bitmap.width = size.width;
		bitmap.height = size.height;
	}

	list.setStyle('horizontalScrollPolicy', ScrollPolicy.OFF);

	stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);

	SymmController.instance.dragDropController.startDrag(bitmap, this.data as ComponentBase);
}

/**
 * Stage mouse up handler - stops dragging
 */
private function mouseUpHandler(event:MouseEvent):void
{
	if (dragController.dragEnabled)
	{
		stopDragging();

		// hide engine module toolTip
		SymmController.instance.eventHandler.dispatchEvent(new ToolTipCustomEvent(ToolTipCustomEvent.HIDE_TOOLTIP, this));
	}
}

/**
 * Mouse move handler, stops dragging if owner list is currently scrolling
 */
private function mouseMoveHandler(event:MouseEvent):void
{
	if (dragController.dragEnabled && list.scroller.horizontalScrollBar && !dragController.isDragging)
	{
		stopDragging();
		if (this.toolTip != null)
		{
			// show engine module toolTip
			SymmController.instance.eventHandler.dispatchEvent(new ToolTipCustomEvent(ToolTipCustomEvent.SHOW_TOOLTIP, this));
		}
	}
}

/**
 * Stops drag functionality - timer and dragging
 */
private function stopDragging():void
{
	list.setStyle('horizontalScrollPolicy', ScrollPolicy.AUTO);
	_timer.stop();
	if (_startDrag)
	{
		dragController.stopDrag();
		_startDrag=false;

		if (this.stage)
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
	}
}

/**
 * Gets owner list
 */
private function get list():List
{
	return this.owner as List;
}

/**
 * Drag drop controller reference
 */
private function get dragController():DragDropController
{
	return SymmController.instance.dragDropController;
}

/**
 * Creation complete handler
 */
protected function onCreationCompleted(event:FlexEvent):void
{
	this.addEventListener(ToolTipEvent.TOOL_TIP_SHOWN, toolTipShownHandler);
}

/**
 * Configuration removed icon click handler
 */
private function onConfigurationVG3RClicked(event:MouseEvent):void
{
	if (visible && includeInLayout && event.localX > _cfgRemoveButtonX && (event.localX < _cfgRemoveButtonX + _cfgRemoveButtonWidth) && event.localY > _cfgRemoveButtonY && (event.localY < _cfgRemoveButtonY + _cfgRemoveButtonHeight))
	{
		var popup:MessagePopup=MessagePopup.open(getResString("main", "REMOVE_CONFIGURATION_APPROVAL"), getResString("main", "REMOVE_CONFIGURATION_APPROVAL_TITLE"), this, MessagePopup.WARNING_MESSAGE, MessagePopup.BUTTON_YES | MessagePopup.BUTTON_NO);
		popup.addEventListener(PopUpEvent.CLOSE, onPopupClosed);
	}
}

/**
 * Configuration approval popup close handler
 */
private function onPopupClosed(event:PopUpEvent):void
{
	if (event.target.result == MessagePopup.RESULT_OK)
	{
		SymmController.instance.eventHandler.dispatchEvent(new RemoveConfigurationEvent(RemoveConfigurationEvent.DELETE_CONFIG, _model as Configuration_VG3R));
	}
}

/**
 * Recalulate position of configuration remove icon based on position and size of configuration image
 * @param iconImageWidth width property of configuration icon image
 * @param iconImageHeight height property of configuration icon image
 * @param iconXOffset horizontal offset of configuration icon image
 * @param iconYOffset vertical offset of configuration icon image
 */
private function recalculateCfgRemoveButtonPosition(iconImageWidth:Number, iconImageHeight:Number, iconXOffset:Number, iconYOffset:Number):void
{
	_cfgRemoveButtonWidth=iconImageWidth * IconRenderUtility.CFG_REMOVE_BUTTON_WIDTH_RATIO;
	_cfgRemoveButtonHeight=iconImageHeight * IconRenderUtility.CFG_REMOVE_BUTTON_HEIGHT_RATIO;
	_cfgRemoveButtonX=iconXOffset + iconImageWidth * IconRenderUtility.CFG_REMOVE_BUTTON_X_OFFSET_RATIO;
	_cfgRemoveButtonY=iconYOffset + iconImageHeight * IconRenderUtility.CFG_REMOVE_BUTTON_Y_OFFSET_RATIO;

}

/**
 * Icon image resized handler. On each resized event, recalculation of configuration remove button position and measures should be performed.
 */
private function onIconImageResized(event:ResizeEvent):void
{
	recalculateCfgRemoveButtonPosition(iconImage.height, iconImage.height, (iconImage.width - iconImage.height) / 2, 0);
}
