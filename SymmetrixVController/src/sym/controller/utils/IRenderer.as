package sym.controller.utils
{
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    
    import sym.objectmodel.common.ComponentBase;

    public interface IRenderer
    {
        function get baySpace():int;
        function set renderEngineDAEConnections(value:Boolean):void;
        function set realistic(value:Boolean):void;
        function render(viewSide:String, component:ComponentBase, parentBitmapData:BitmapData, position:Rectangle):void;
        function drawDispersedConnectingLine(bData:BitmapData, position:Rectangle):void;
        function drawSelectionBox(sprite:Sprite, position:Rectangle):void;
        function drawBayMask(bData:BitmapData, position:Rectangle):void;
    }
}