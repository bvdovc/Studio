import flash.events.MouseEvent;

import sym.controller.NavigationContoller;
import sym.controller.model.BreadcrumbItem;

override public function set data(value:Object):void
{
    super.data = value;

    if (data)
    {
        breadcrumbItem.text = data.label;

        breadcrumbItem.useHandCursor = true;
        breadcrumbItem.buttonMode = true;
        breadcrumbItem.addEventListener(MouseEvent.CLICK, breadcrumbItem_clickHandler);
        lblArrow.visible = lblArrow.includeInLayout = !(data as BreadcrumbItem).isLastItem;
    }
}

/**
 * called when breadcrumb item is selected
 */
protected function breadcrumbItem_clickHandler(event:MouseEvent):void
{
    NavigationContoller.instance.navigate(data as BreadcrumbItem);
}
