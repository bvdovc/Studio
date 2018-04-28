package sym.controller.utils
{
    import sym.controller.components.TransparentOverlayComponent;
    import sym.objectmodel.common.ComponentBase;

    public interface IToolTipProvider
    {
        function getToolTip(viewSide:String, component:ComponentBase, overlayComponent:TransparentOverlayComponent = null):String;
    }
}