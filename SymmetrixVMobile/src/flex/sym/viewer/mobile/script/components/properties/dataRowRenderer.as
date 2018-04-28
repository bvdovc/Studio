import mx.collections.IList;

import spark.components.Label;

import sym.controller.model.DataRow;
import sym.viewer.mobile.views.components.properties.DataTableComponent;

/**
 * adds row data
 */
public override function set data(value:Object):void
{
    super.data = value;
    
    this.createRowItems();
}

protected function createRowItems():void
{
    if (data && data is DataRow)
    {
        this.content.removeAllElements();
        
        var dr:DataRow = data as DataRow;
        var itemWidthPercent:Number = 100 / dr.data.length;
        var table:DataTableComponent = this.owner as DataTableComponent;
        var isFirstRow:Boolean = (table.dataProvider as IList).getItemIndex(data) == 0;
        if(table.maxColumnIndexAutoWidth > -1)
        {
            itemWidthPercent = 100/ (dr.data.length - table.maxColumnIndexAutoWidth - 1);
        }
        
        for (var i:int = 0; i < dr.data.length; i++)
        {
            var lblItem:Label = new Label();
            lblItem.text = dr.data[i];
            if(table.maxColumnIndexAutoWidth < i)
                lblItem.percentWidth = itemWidthPercent;
            else
            {
                lblItem.percentWidth = table.autoSizeColumnPercentWidth;
            }
            
            if(isFirstRow && table.higlightFirstRow)
            {
                lblItem.styleName = "propertyTableHeader";
            }
            else
            {
                lblItem.styleName = "propertyParagraph";
            }
            this.content.addElement(lblItem);
        }
    }  
}