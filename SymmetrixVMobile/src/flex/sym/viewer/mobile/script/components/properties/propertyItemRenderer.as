import mx.core.ScrollPolicy;
import mx.events.FlexEvent;

import sym.controller.model.PropertyItem;
import sym.viewer.mobile.views.components.properties.DataTableComponent;

[Bindable]
private var property:PropertyItem;

public override function set data(value:Object):void
{
    super.data = value;
    if (value is PropertyItem)
    { 
        property = value as PropertyItem;
        if(property.hasTable && table)
        { 
            (this.table as DataTableComponent).dataProvider = property.table.data;
        }
    }
}

protected function table_creationCompleteHandler(event:FlexEvent):void
{
    if (property && property.hasTable)
    { 
        (this.table as DataTableComponent).dataProvider = property.table.data;
    }
}

protected function bullets_creationCompleteHandler(event:FlexEvent):void
{
    this.bullets.setStyle("verticalScrollPolicy", ScrollPolicy.OFF);
    this.bullets.setStyle('horizontalScrollPolicy', ScrollPolicy.OFF);
}