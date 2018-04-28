package sym.controller.utils
{
    import flash.events.IEventDispatcher;
    
    import sym.objectmodel.common.ComponentBase;

    public interface IPropertyTextProvider extends IEventDispatcher
    {
        function getPropertyText(viewSide:String, component:ComponentBase):String;
    }
}