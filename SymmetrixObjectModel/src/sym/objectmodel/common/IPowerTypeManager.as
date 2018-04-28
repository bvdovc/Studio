package sym.objectmodel.common
{
    public interface IPowerTypeManager
    {
        function getCurrentPowerType():int;
        function setCurrentPowerType(type:int):void;
        function getCurrentSPSType():int;
        function setCurrentSPSType(type:int):void;
        
        function isPDPVisible(pdp:PDP):Boolean;
        function isPDUVisible(pdu:PDU):Boolean;
    }
}