import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.core.UIComponent;
import mx.effects.Move;
import mx.effects.Zoom;
import mx.graphics.codec.JPEGEncoder;
import mx.graphics.codec.PNGEncoder;

import spark.events.IndexChangeEvent;

import sym.configurationmodel.common.ConfigurationFactoryBase;
import sym.configurationmodel.common.ConfigurationFilter;
import sym.configurationmodel.v100k.ConfigurationFactory;
import sym.configurationmodel.v10ke.Configuration10kFactory;
import sym.configurationmodel.v10ke.ConfigurationVNX10kFactory;
import sym.configurationmodel.v200k.ConfigurationFactory;
import sym.configurationmodel.v20k.ConfigurationFactory;
import sym.configurationmodel.v400k.ConfigurationFactory;
import sym.configurationmodel.v40k.ConfigurationFactory;
import sym.controller.components.UIComponentBase;
import sym.controller.utils.DrawingRenderer;
import sym.controller.utils.RenderUtility;
import sym.controller.utils.ToolTipProvider;
import sym.helper.IconRenderUtility;
import sym.objectmodel.common.ComponentBase;
import sym.objectmodel.common.Configuration;


private var _configFactory:ConfigurationFactoryBase = null;
private var _configurations:ArrayCollection = null;
private var _configFilter:ConfigurationFilter = null;
private var _renderer:RenderUtility = new RenderUtility(new DrawingRenderer(), new ToolTipProvider());
private var _iconRenderer:IconRenderUtility = new IconRenderUtility();
private var _currentComponent:UIComponentBase = null;
private var _currentIcon:UIComponent = null;

public static const PNG:String=".png";
public static const JPEG:String=".jpg";

private static const VMAX10K:String = "10k Enhanced";
private static const VMAX10K_UNIFIED:String = "10k Unified";
private static const VMAX20K:String = "20k";
private static const VMAX40K:String = "40k";
private static const VMAX10M:String = "10m Lapis";
private static const VMAX20M:String = "20m Alexandrite";
private static const VMAX40M:String = "40m Ruby";

[Bindable]
private var _configPlatformDP:ArrayCollection = new ArrayCollection([VMAX10K, VMAX10K_UNIFIED, VMAX20K, VMAX40K, VMAX10M, VMAX20M, VMAX40M]);

protected function configFactorySelector_changeHandler(event:IndexChangeEvent):void
{
    switch (event.newIndex) {
        case 0:
            _configFactory = new sym.configurationmodel.v10ke.Configuration10kFactory();
            break;
		case 1:
			_configFactory = new sym.configurationmodel.v10ke.ConfigurationVNX10kFactory();
			break;
        case 2:
            _configFactory = new sym.configurationmodel.v20k.ConfigurationFactory();
            break;
        case 3:
            _configFactory = new sym.configurationmodel.v40k.ConfigurationFactory();
            break;
        case 4:
            _configFactory = new sym.configurationmodel.v100k.ConfigurationFactory();
            break;
        case 5:
            _configFactory = new sym.configurationmodel.v200k.ConfigurationFactory
            break;
        case 6:
            _configFactory = new sym.configurationmodel.v400k.ConfigurationFactory
            break;
    }
    _configurations = new ArrayCollection();
    var obj:Object = null;
    for each (var cfg:Configuration in _configFactory.getAllConfigurations()) {
        obj = new Object();
        obj.label = cfg.id;
        if (cfg.dispersed != -1) {
            // skip dispersed ones
            continue;
        }
        obj.value = cfg;
        
        _configurations.addItem(obj);
    }
    configSelector.dataProvider = _configurations;
}

protected function configSelector_changeHandler(event:IndexChangeEvent):void
{
    if (event.newIndex == -1) {
        return;
    }
    
    renderWireframe();
    renderIcon(_currentComponent.componentBase);

    var cfg:Configuration = _currentComponent.componentBase as Configuration;
    calcId.text = cfg.calculatedId;
}

private function renderWireframe():void {
    var comp:ComponentBase = null;
    
    comp = configSelector.selectedItem.value as ComponentBase;
    
    if (!comp) {
        return;
    }
    
    if (_currentComponent)
    {
        if (mainContainer.contains(_currentComponent))
        {
            mainContainer.removeElement(_currentComponent);
        }
        _currentComponent = null;
    }
    
    _currentComponent = _renderer.renderStage(comp);
    
    var scale:Number = mainContainer.height / _currentComponent.height;
    
    if (_currentComponent.width * scale > mainContainer.width)
    {
        scale = mainContainer.width / _currentComponent.width;
    }
    
    mainContainer.addElement(_currentComponent);
    
    var scaledSize:Point = new Point(_currentComponent.width * scale, _currentComponent.height * scale);
    
    var move:Move = new Move(_currentComponent);
    move.xTo = (mainContainer.width - scaledSize.x) / 2;
    move.yTo = (mainContainer.height - scaledSize.y) / 2;
    move.duration = 0;
    move.play();
    
    var zoom:Zoom = new Zoom(_currentComponent);
    zoom.zoomWidthFrom = 1;
    zoom.zoomWidthTo = scale;
    zoom.zoomHeightFrom = 1;
    zoom.zoomHeightTo = scale;
    zoom.originX = 0;
    zoom.originY = 0;
    zoom.duration = 0;
    zoom.play();

}

private function renderIcon(comp:ComponentBase):void {
    if (!comp) {
        return;
    }
    
    if (_currentIcon)
    {
        if (iconContainer.contains(_currentIcon))
        {
            iconContainer.removeElement(_currentIcon);
        }
        _currentIcon= null;
    }

    _currentIcon = _iconRenderer.render(comp);
    
    if (!_currentIcon) {
        return;
    }
    
    var scale:Number = (iconContainer.height - 10) / _currentIcon.height;
    
    if (_currentIcon.width * scale > (iconContainer.width - 10))
    {
        scale = (iconContainer.width - 10) / _currentIcon.width;
    }
    iconContainer.addElement(_currentIcon);
    
    var scaledSize:Point = new Point(_currentIcon.width * scale, _currentIcon.height * scale);
    
    var move:Move = new Move(_currentIcon);
    move.xTo = (iconContainer.width - scaledSize.x) / 2;
    move.yTo = (iconContainer.height - scaledSize.y) / 2;
    move.duration = 0;
    move.play();
    
    var zoom:Zoom = new Zoom(_currentIcon);
    zoom.zoomWidthFrom = 1;
    zoom.zoomWidthTo = scale;
    zoom.zoomHeightFrom = 1;
    zoom.zoomHeightTo = scale;
    zoom.originX = 0;
    zoom.originY = 0;
    zoom.duration = 0;
    zoom.play();
}

protected function generateSelected_clickHandler(event:MouseEvent):void
{
    if (!_currentIcon || !_currentComponent) {
        return;
    }
    
    var cfg:Configuration = _currentComponent.componentBase as Configuration;
    
    trace("saving " + _currentComponent.componentBase.id + " as " + cfg.calculatedId);
    saveImage(_currentIcon, targetDir.text, cfg.calculatedId, JPEG);
}

private function saveImage(component:UIComponent, path:String, fileName:String, type:String):void
{
    var bitmapData:BitmapData=new BitmapData(component.width, component.height);
    bitmapData.draw(component, new Matrix());
    var imagePath:File = new File(path);
    
    if (!imagePath.exists)
    {
        imagePath.createDirectory();
    }            
    
    imagePath = new File(path + "\\" + fileName + type);

    var ba:ByteArray;
    var fs:FileStream = new FileStream();
    
    if (type == PNG)
    {
        var pngEncoder:PNGEncoder=new PNGEncoder();
        ba=pngEncoder.encode(bitmapData);
    }
    else if (type == JPEG)
    {
        var jpegEncoder:JPEGEncoder=new JPEGEncoder();
        ba=jpegEncoder.encode(bitmapData);
    }

    fs.open(imagePath, FileMode.WRITE);
    fs.writeBytes(ba, 0, ba.length);
    fs.close();
}

private function generateAllIcons(targetDir:String, configs:Array):void {
    for each (var cfg:Configuration in configs) {
        renderIcon(cfg);
        saveImage(_currentIcon, targetDir, cfg.calculatedId, JPEG);
    }
}

protected function generateAll_clickHandler(event:MouseEvent):void
{
    // generate all configs
    var configs:ArrayCollection = null;

	/*var configFactory:ConfigurationFactoryBase = null;

	// 10ke
	configFactory = new sym.configurationmodel.v10ke.Configuration10kFactoryBase();
	configs = new ArrayCollection();
	for each (var cfg:Configuration in configFactory.getAllConfigurations()) {
		if (cfg.dispersed == -1) {
			// skip dispersed ones
			continue;
		}
		configs.addItem(cfg);
	}

	generateAllIcons(targetDir.text, configs.source);

	// 20k
	configs = new ArrayCollection();
	configFactory = new sym.configurationmodel.v20k.ConfigurationFactory();
	for each (cfg in configFactory.getAllConfigurations()) {
		if (cfg.dispersed != -1) {
			// skip dispersed ones
			continue;
		}
		configs.addItem(cfg);
	}

	generateAllIcons(targetDir.text, configs.source);

	// 40k
	configs = new ArrayCollection();
	configFactory = new sym.configurationmodel.v40k.ConfigurationFactory();
	for each (cfg in configFactory.getAllConfigurations()) {
		if (cfg.dispersed != -1) {
			// skip dispersed ones
			continue;
		}
		configs.addItem(cfg);
	}

	generateAllIcons(targetDir.text, configs.source);*/

	configs=new ArrayCollection();
	for each (var cfg:Configuration in _configFactory.getAllConfigurations())
	{
		if (cfg.dispersed != -1)
		{
			// skip dispersed ones
			continue;
		}
		configs.addItem(cfg);
	}
	
	generateAllIcons(targetDir.text, configs.source);
}
