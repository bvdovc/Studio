import flash.events.MouseEvent;

import mx.events.FlexEvent;

import sym.controller.NavigationContoller;
import sym.controller.model.BreadcrumbItem;

[Bindable]
private var _item:BreadcrumbItem;

[Bindable]
private var _lblValue:String;

[Bindable]
private var _colorIndex:int;

private static const HOME_COLOR:uint = 0x479bd0;
private static const DEFAULT_COLOR:uint = 0xFFFFFF;

public function set colorIndex(cIndex:int):void{
    _colorIndex = cIndex;
}


public function set navigationNode(node:BreadcrumbItem):void{
    _item = node;
} 

/**
 * called when breadcrumb item is selected
 */
protected function breadcrumbItem_clickHandler(event:MouseEvent):void
{
    NavigationContoller.instance.navigate(_item as BreadcrumbItem);
}