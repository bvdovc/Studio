package sym.objectmodel.common
{
    import mx.collections.ArrayCollection;

    public interface IPortConfigurationManager
    {
        function getCurrentPortConfiguration():PortConfiguration;
        function getAllowedPortConfigurations():ArrayCollection;
        function setCurrentPortConfiguration(portConfig:int):void;
    }
}
