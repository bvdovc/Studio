package sym.controller.utils
{
    import mx.resources.ResourceManager;
    import mx.utils.StringUtil;
    
    import sym.controller.SymmController;
    import sym.objectmodel.common.ComponentBase;
    import sym.objectmodel.common.EnginePort;
    import sym.objectmodel.common.PDU;
    import sym.objectmodel.common.PortConfiguration;
    import sym.objectmodel.common.SPS;

    public class ComponentNameProvider implements IComponentNameProvider
    {
        /**
        * gets components user friendly name
        * Dummy impl, needs gettering from resource strings etc.
        */
        public function getUserFriendlyName(component:ComponentBase):String
        {
            if (!component)
            {
                return "";
            }

            if (component is PortConfiguration)
            {
				var portCfgID:String = (!SymmController.instance.isAFA() || !SymmController.instance.isPM()) ? component.type.toString() : "";
                return StringUtil.substitute(ResourceManager.getInstance().getString('main', 'PORT_CONFIGURATION_GENERIC'), portCfgID, 
                    ResourceManager.getInstance().getString("main", "PORT_CONFIGURATION_" + component.type));
            }
            else if (component is PDU)
            {
                var phaseType:int = component.type;
                return phaseType == PDU.TYPE3PHASE ? ResourceManager.getInstance().getString('main', 'POWER3PHASE') : ResourceManager.getInstance().getString('main', 'POWER1PHASE');
            }
            else if (component is SPS)
            {
                var spsType:int = component.type;
                return spsType == SPS.TYPE_STANDARD ? ResourceManager.getInstance().getString('main', 'SPS_STANDARD') : ResourceManager.getInstance().getString('main', 'SPS_LION');
            } 
	/*		else if(component is sym.objectmodel.v10ke.Configuration)
			{
				var config:sym.objectmodel.v10ke.Configuration = component as sym.objectmodel.v10ke.Configuration;
                return config.vmax10kName;
				/*if(config.noEngines > 1)
				{
					return StringUtil.substitute(ResourceManager.getInstance().getString('main', 'CONFIGURATION_NAME_V10KE_MORE_ENGINES'), config.noEngines, config.noD15, config.noVanguard);
				}
				else
				{
					return StringUtil.substitute(ResourceManager.getInstance().getString('main', 'CONFIGURATION_NAME_V10KE_ONE_ENGINE'), config.noEngines, config.noD15, config.noVanguard);
				}
			}*/
            else if(component is EnginePort)
            {
				return (component as EnginePort).enginePortName;
            }
            else 
            {
                return component.id;
            }
        }
    }
}
