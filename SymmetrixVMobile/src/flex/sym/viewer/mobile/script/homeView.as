import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.FileFilter;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import mx.collections.ArrayCollection;
import mx.controls.ToolTip;
import mx.core.UIComponent;
import mx.events.FlexEvent;
import mx.managers.ToolTipManager;
import mx.resources.ResourceManager;
import mx.utils.StringUtil;

import spark.components.Button;
import spark.events.IndexChangeEvent;
import spark.events.PopUpEvent;

import sym.configurationmodel.common.ConfigurationFactoryBase_VG3R;
import sym.configurationmodel.utils.AllFlashArrayUtility;
import sym.controller.SymmController;
import sym.controller.events.FilterChangedEvent;
import sym.controller.events.VMaxSelectionChangeRequestEvent;
import sym.controller.events.VMaxSelectionChangedEvent;
import sym.controller.events.XmlImportErrorEvent;
import sym.controller.events.XmlImportedEvent;
import sym.objectmodel.common.ComponentBase;
import sym.objectmodel.common.Constants;
import sym.viewer.mobile.utils.CommonUtility;
import sym.viewer.mobile.utils.FileSaveUtility;
import sym.viewer.mobile.utils.Settings;
import sym.viewer.mobile.views.ConfigurationView;
import sym.viewer.mobile.views.components.popups.FileSaveLoadPopup;
import sym.viewer.mobile.views.components.popups.MessagePopup;
import sym.viewer.mobile.views.components.popups.ReadMorePopup;

private static var file:File;
private static const WHITE_LINE_COLOR:uint = 0x000000;

[Bindable]
private var isDesktopVersion:Boolean = true;

private function openFolder(event:Event):void
{
	var filter:FileFilter = new FileFilter("xmlFiles", "*.xml");
	file = File.documentsDirectory;
	file.addEventListener(Event.SELECT, onSelectImportXML);
	file.browseForOpen("Open file", [filter]);
}

private function onSelectImportXML(event:Event):void
{
	var stream:FileStream = new FileStream();
	stream.open(file, FileMode.READ);
	SymmController.instance.eventHandler.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false));
	
	try{
		
		var myXml:XML = XML(stream.readUTFBytes(stream.bytesAvailable));
		var isValid:Boolean = false;

		if(myXml.children().length() == 2)
		{
			var myXML:String = myXml.toString();
			var xmlReg:RegExp;
			var model:Number;
			var newXmlWithoutNamespaces:String;
			var newXML:XML;
			
			xmlReg = new RegExp("xmlns[^\"]*\"[^\"]*\"| xsi[^\"]*\"[^\"]*\"", "gi");
			newXmlWithoutNamespaces = myXML.replace(xmlReg, "");
			newXML = new XML(newXmlWithoutNamespaces);
			
			isValid = ComponentBase.validateXml(newXML);
			
			if (!isValid)
				return errorMessage();
			
			var seriaName:String = newXML.config.make;
			var model:Number = newXML.config.model;
			var seriaModel:String = seriaModel(seriaName, model);
			
			changeVMax(seriaModel);
			SymmController.instance.eventHandler.dispatchEvent(new XmlImportedEvent(XmlImportedEvent.XML_FILES_IMPORTED, newXML, null));
		}else
			return errorMessage();
	}
	catch(er:Error){
		if(myXml == null)
			return errorMessage();
			
		SymmController.instance.eventHandler.dispatchEvent(new XmlImportErrorEvent(XmlImportErrorEvent.XML_IMPORT_ERROR));
	}
	
}

private function seriaModel(seriaName, model):String
{
	var seriaModel:String;
	switch(model)
	{
		case 250:
			seriaModel = seriaName + "-" + model.toString() + "F";
			break;
		case 950:
			seriaModel = seriaName + "-" + model.toString() + "F/FX";
			break;
		case 2000:
			seriaModel = "PowerMax" + "-" + model.toString();
			break;
		case 8000:
			seriaModel = "PowerMax" + "-" + model.toString();
			break;
	}
	
	return seriaModel;
}

private function errorMessage():void
{
	MessagePopup.open(getResString("main", "ERROR_XML_VALIDATION"), getResString("main", "ERROR_XML_VALIDATION_TITLE"), this, MessagePopup.ERROR_MESSAGE, MessagePopup.BUTTON_OK);
	return;
}


/**
 * Handler when VMax is selected
 */
protected function changeVMax(vmax:String):void
{
    SymmController.instance.eventHandler.dispatchEvent(new VMaxSelectionChangeRequestEvent(VMaxSelectionChangeRequestEvent.CHANGE_REQUEST, vmax));
}
  
/**
 * Preinitialize event handler
 */
protected function homeView_preinitializeHandler(event:FlexEvent):void
{
	if(CommonUtility.getOS() == CommonUtility.ANDROID || CommonUtility.getOS() == CommonUtility.IOS)
	{
		isDesktopVersion = false;
	}
    Settings.instance.load();
    if (!SymmController.instance.eventHandler.hasEventListener(VMaxSelectionChangedEvent.SELECTION_CHANGED))
    {
        SymmController.instance.eventHandler.addEventListener(VMaxSelectionChangedEvent.SELECTION_CHANGED, onVMaxChanged);
    }
}

protected function onLanguageListCreation(event:FlexEvent):void
{
    if (!Settings.instance.loaded)
    {
        Settings.instance.load();
    }

    var lans:ArrayCollection = new ArrayCollection();
    var defaultLanguage:Object = null;
    for each (var lang:Object in Settings.instance.languages)
    {
        if (lang.enabled)
        {
            lans.addItem(lang); 
            if ((Settings.instance.currentLanguage != null && Settings.instance.currentLanguage == lang.code) || (!Settings.instance.currentLanguage && lang.isDefault))
            {
                defaultLanguage = lang;
                Settings.instance.currentLanguage = lang.code;
            }
        }
    }
    languageList.dataProvider = lans;
    if (defaultLanguage)
    {
        languageList.selectedIndex = lans.getItemIndex(defaultLanguage);
    }
}

/**
 * language change handler
 */
private function onLanguageChange(event:IndexChangeEvent):void
{
	if (event.newIndex != -1 && languageList.selectedItem)
    {
        Settings.instance.currentLanguage = languageList.selectedItem.code;
        ResourceManager.getInstance().localeChain = [languageList.selectedItem.code];
    }
} 

/**
 * Handler for VMaxSelectionChangedEvent
 * Navigate to second view ConfigurationView
 */
private function onVMaxChanged(event:VMaxSelectionChangedEvent):void
{
    getNavigator().pushView(ConfigurationView, event.currentVmax);
}

private function openReadMorePopUp(event:String):void
{
	var popup:ReadMorePopup;
	
	if(event == Constants.PowerMax_2000)
	{
		popup = ReadMorePopup.open(getResString("main", "DESCRIPTION_MESSAGE_PM2000"), getResString("main", "DESCRIPTION_MESSAGE_TITLE_PM2000"), this, ReadMorePopup.NORMAL_MESSAGE, ReadMorePopup.BUTTON_OK);
	}
	
	if(event == Constants.PowerMax_8000)
	{
		popup = ReadMorePopup.open(getResString("main", "DESCRIPTION_MESSAGE_PM8000"), getResString("main", "DESCRIPTION_MESSAGE_TITLE_PM8000"), this, ReadMorePopup.NORMAL_MESSAGE, ReadMorePopup.BUTTON_OK);
	}
	if(event == Constants.VMAX_250F)
	{
		popup = ReadMorePopup.open(getResString("main", "DESCRIPTION_MESSAGE_VMAX_250F"), getResString("main", "DESCRIPTION_MESSAGE_TITLE_VMAX_250F"), this, ReadMorePopup.NORMAL_MESSAGE, ReadMorePopup.BUTTON_OK);
	}
	if(event == Constants.VMAX_950F)
	{
		popup = ReadMorePopup.open(getResString("main", "DESCRIPTION_MESSAGE_VMAX_950F"), getResString("main", "DESCRIPTION_MESSAGE_TITLE_VMAX_950F"), this, ReadMorePopup.NORMAL_MESSAGE, ReadMorePopup.BUTTON_OK);
	}
	popup.width = 600;
	popup.height = 350;
	
	return;
}





