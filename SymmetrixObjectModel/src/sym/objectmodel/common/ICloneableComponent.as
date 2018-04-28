package sym.objectmodel.common
{
    public interface ICloneableComponent
    {
        function clone(parent:ComponentBase = null):ComponentBase;
    }
}