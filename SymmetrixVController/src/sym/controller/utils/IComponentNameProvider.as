package sym.controller.utils
{
    import sym.objectmodel.common.ComponentBase;
    /**
    * provides methods for retrieving component name
    * Used in Selection Component Item Renderer...
    */
    public interface IComponentNameProvider
    {
         function getUserFriendlyName(component:ComponentBase):String;
    }
}