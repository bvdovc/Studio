package sym.controller.utils
{
    
    import mx.collections.ArrayCollection;
    import mx.collections.Sort;
    import mx.resources.ResourceManager;
    import mx.utils.StringUtil;
    
    import spark.collections.SortField;
    
    import sym.controller.SymmController;
    import sym.controller.components.TransparentOverlayComponent;
    import sym.objectmodel.common.Bay;
    import sym.objectmodel.common.ComponentBase;
    import sym.objectmodel.common.Configuration;
    import sym.objectmodel.common.Configuration_VG3R;
    import sym.objectmodel.common.Constants;
    import sym.objectmodel.common.ControlStation;
    import sym.objectmodel.common.D15;
    import sym.objectmodel.common.DAE;
    import sym.objectmodel.common.DataMover;
    import sym.objectmodel.common.Drive;
    import sym.objectmodel.common.Engine;
    import sym.objectmodel.common.EnginePort;
    import sym.objectmodel.common.EthernetSwitch;
    import sym.objectmodel.common.InfinibandSwitch;
    import sym.objectmodel.common.KVM;
    import sym.objectmodel.common.MIBE;
    import sym.objectmodel.common.PDP;
    import sym.objectmodel.common.PDU;
    import sym.objectmodel.common.PDU_VG3R;
    import sym.objectmodel.common.PortConfiguration;
    import sym.objectmodel.common.Position;
    import sym.objectmodel.common.SPS;
    import sym.objectmodel.common.Tabasco;
    import sym.objectmodel.common.TransparentOverlayConstants;
    import sym.objectmodel.common.UPS;
    import sym.objectmodel.common.Vanguard;
    import sym.objectmodel.common.Viking;
    import sym.objectmodel.common.Voyager;
    
    /**
     * Provides tooltip strings. 
     */
    public class ToolTipProvider implements IToolTipProvider
    {
		private static const UNDEFINED_TOOLTIP:String = "";
		private static const SPACE_TOOLTIP:String = " ";
		private static const NEW_LINE_TOOLTIP:String = "\n";
		private static const A_CHAR_ASCII:int = 65;
		private static const B_CHAR_ASCII:int = 66;
		
        public function ToolTipProvider()
        {
        }
        
        /**
         * Provides tooltip string for supplied component. 
         */
        public function getToolTip(viewSide:String, component:ComponentBase, overlayComponent:TransparentOverlayComponent = null):String
        {
			// DAE tooltip
			if (component is DAE && overlayComponent == null)
			{
				// front/rear view
				var index:int = component.position.index;
				var daeParent:Bay = component.parent as Bay;
				switch (component.position.type)
				{
					// horizontal positioning
					case Position.BAY_ENCLOSURE:
						// 100/200/400K or 450/850F
						if (SymmController.instance.isAFA() || SymmController.instance.isPM())
						{
							return (component as DAE).daeName;
						}
					// vertical positioning
					case Position.LOWERHALFBAYVERTICAL:
					case Position.UPPERHALFBAYVERTICAL:	
						var posLower:int = 0;
						var posUpper:int = 0;
						if (index < 4)
						{
							posLower = index + 5;
							posUpper = index + 13;								
						}
						if (index > 3)
						{
							posLower = index - 3;
							posUpper = index + 5;									
						}
						return component.position.type == Position.LOWERHALFBAYVERTICAL ? ResourceManager.getInstance().getString("component", "DAE_TOOLTIP") + SPACE_TOOLTIP + posLower : 
																				  		  ResourceManager.getInstance().getString("component", "DAE_TOOLTIP") + SPACE_TOOLTIP + posUpper;
						break;
					default:
						return UNDEFINED_TOOLTIP;
				}
			}
			if (component is PDU && (SymmController.instance.isPM()|| is250F()))
			{
				if(component.position.index == 6)
				{
					var str:String = StringUtil.substitute(ResourceManager.getInstance().getString("component", "PDU_VG3R_TOOLTIP"), 
						String.fromCharCode(A_CHAR_ASCII));
				}
				else
				{
					var str:String = StringUtil.substitute(ResourceManager.getInstance().getString("component", "PDU_VG3R_TOOLTIP"), 
						String.fromCharCode(B_CHAR_ASCII));
				}
				return str;
			}
			// DAE overlay component tooltip
			if (component is DAE && overlayComponent != null) 
			{
				if ((SymmController.instance.isAFA() || SymmController.instance.isPM()) && overlayComponent.type == TransparentOverlayConstants.DAE_VG3R_COOLING_FAN)
				{
					return StringUtil.substitute(ResourceManager.getInstance().getString("component", "DAE_FAN_TOOLTIP"), overlayComponent.order % 5);
				}
				else if (component is Viking && viewSide == Constants.REAR_VIEW_PERSPECTIVE)
				{
					if (overlayComponent.type == TransparentOverlayConstants.DAE_POWER_SUPPLY)
					{
						return StringUtil.substitute(ResourceManager.getInstance().getString("component", "DAE_POWER_SUPPLY_TOOLTIP"), (overlayComponent.order == 0 || overlayComponent.order == 1) ? 
							String.fromCharCode(B_CHAR_ASCII) : String.fromCharCode(A_CHAR_ASCII));
					}
					if (overlayComponent.type == TransparentOverlayConstants.DAE_LCC)
					{
						return StringUtil.substitute(ResourceManager.getInstance().getString("component", "DAE_LCC_TOOLTIP"), overlayComponent.order == 4 ? String.fromCharCode(B_CHAR_ASCII) : String.fromCharCode(A_CHAR_ASCII));
					}
				}
				else if (component is Voyager && viewSide == Constants.REAR_VIEW_PERSPECTIVE)
				{
					if (overlayComponent.type == TransparentOverlayConstants.DAE_POWER_SUPPLY)
					{
						return StringUtil.substitute(ResourceManager.getInstance().getString("component", "DAE_POWER_SUPPLY_TOOLTIP"), overlayComponent.order < 3 ? String.fromCharCode(B_CHAR_ASCII) : 
							String.fromCharCode(A_CHAR_ASCII)); 
					}
					if (overlayComponent.type == TransparentOverlayConstants.DAE_LCC)
					{
						return StringUtil.substitute(ResourceManager.getInstance().getString("component", "DAE_LCC_TOOLTIP"), overlayComponent.order == 0 ? String.fromCharCode(B_CHAR_ASCII) : String.fromCharCode(A_CHAR_ASCII));
					}
				}
				else if (component is Voyager && overlayComponent.type == TransparentOverlayConstants.DAE_LCC)
				{
					return StringUtil.substitute(ResourceManager.getInstance().getString("component", "DAE_LCC_TOOLTIP"), overlayComponent.order == 3 ? String.fromCharCode(B_CHAR_ASCII) : String.fromCharCode(A_CHAR_ASCII));
				}
				else if (component is Vanguard || component is D15 || component is Tabasco)
				{
					if (overlayComponent.order == 0 || overlayComponent.order == 3)
						return StringUtil.substitute(ResourceManager.getInstance().getString("component", "DAE_POWER_SUPPLY_TOOLTIP"), overlayComponent.order == 0 ? String.fromCharCode(B_CHAR_ASCII) : String.fromCharCode(A_CHAR_ASCII));
					if (overlayComponent.order == 1 || overlayComponent.order == 2)
						return StringUtil.substitute(ResourceManager.getInstance().getString("component", "DAE_LCC_TOOLTIP"), overlayComponent.order == 1 ? String.fromCharCode(B_CHAR_ASCII) : String.fromCharCode(A_CHAR_ASCII));
				}
                else if(overlayComponent.type == TransparentOverlayConstants.VIKING_SSC)
                {
                    return ResourceManager.getInstance().getString("component", "VIKING_SSC");
                }
			}
			
			// Bay tooltip
			if (component is Bay)
			{			
				// Storage Bay
				if ((component as Bay).isStorageBay)
				{
					if (component.parentConfiguration is sym.objectmodel.common.Configuration && SymmController.instance.isAFA())
					{
						if(component.id == Bay.ID_SBAY1A){
							return ResourceManager.getInstance().getString("component", "STGBAY_TOOLTIP") + SPACE_TOOLTIP + 1 + String.fromCharCode(A_CHAR_ASCII);
						}
						else if(component.id == Bay.ID_SBAY2A){
							return ResourceManager.getInstance().getString("component", "STGBAY_TOOLTIP") + SPACE_TOOLTIP + 2 + String.fromCharCode(A_CHAR_ASCII);
						}
						else if(component.id == Bay.ID_SBAY3A){
							return ResourceManager.getInstance().getString("component", "STGBAY_TOOLTIP") + SPACE_TOOLTIP + 3 + String.fromCharCode(A_CHAR_ASCII);
						}
						else if(component.id == Bay.ID_SBAY4A){
							return ResourceManager.getInstance().getString("component", "STGBAY_TOOLTIP") + SPACE_TOOLTIP + 4 + String.fromCharCode(A_CHAR_ASCII);
						}
					}
					else
					{
						return UNDEFINED_TOOLTIP;
					}
				}
				// System Bay
				else if ((component as Bay).isSystemBay)
				{
					if(component.parentConfiguration is sym.objectmodel.common.Configuration_VG3R)
					{
						if(is250F())
						{
							return ResourceManager.getInstance().getString("component", "SYSBAY_TOOLTIP");						
						}
						return ResourceManager.getInstance().getString("component", "SYSBAY_TOOLTIP") + SPACE_TOOLTIP + ((component as Bay).positionIndex + 1);
					}
					else
					{
						return UNDEFINED_TOOLTIP;
					}
				}
				// unknown bay type
				else
				{
					return UNDEFINED_TOOLTIP;
				}
					
			}
			//PDU_VG3R tooltip
			if(component is PDU_VG3R && overlayComponent == null)
			{
				return StringUtil.substitute(ResourceManager.getInstance().getString("component", "PDU_VG3R_TOOLTIP"), 
					String.fromCharCode(component.position.type == Position.BAY_HALF_ENCLOSURE_LEFT ? A_CHAR_ASCII : B_CHAR_ASCII));
			}
			//Ethernet Swich tooltip
			if(component is EthernetSwitch && overlayComponent == null)
			{
				return StringUtil.substitute(ResourceManager.getInstance().getString("component", "ETHERNET_SWITCH_TOOLTIP"), 
					String.fromCharCode(component.position.type == Position.BAY_HALF_ENCLOSURE_LEFT ? A_CHAR_ASCII : B_CHAR_ASCII));
			}
			//InfinibandSwitch tooltip
			if(component is InfinibandSwitch && overlayComponent == null)
			{
				return ResourceManager.getInstance().getString("component", component.type == InfinibandSwitch.TYPE_DINGO ? "INFINIBAND_SWITCH_DINGO" : "INFINIBAND_SWITCH_STINGRAY");
			}
			// SPS tooltip
			if (component is SPS && overlayComponent == null)
			{
					switch (component.position.type)
					{
						case Position.MIDDLEBAYVERTICAL:
							var ind:int = component.position.index;
							return ResourceManager.getInstance().getString("component", "SPS_TOOLTIP") + ++ind;	
							break;
						case Position.BAY_HALF_ENCLOSURE_LEFT:
						case Position.BAY_HALF_ENCLOSURE_RIGHT:	
							var parentBay:ComponentBase = component.parent;
							var spsPosition:int = 0;
							var spsLeftSide:ArrayCollection = new ArrayCollection();
							var spsRightSide:ArrayCollection = new ArrayCollection();
							for (var k:int = 0; k < parentBay.children.length; k++)
							{
								if (parentBay.children[k] is SPS && (parentBay.children[k].position.type == Position.ENGINESIDE_SPS_LEFT || parentBay.children[k].position.type == Position.BAY_HALF_ENCLOSURE_LEFT))
								{
									spsLeftSide.addItem({data:parentBay.children[k], pos:parentBay.children[k].position.index});
								}
								if (parentBay.children[k] is SPS && (parentBay.children[k].position.type == Position.ENGINESIDE_SPS_RIGHT || parentBay.children[k].position.type == Position.BAY_HALF_ENCLOSURE_RIGHT))
								{
									spsRightSide.addItem({data:parentBay.children[k], pos:parentBay.children[k].position.index});
								}
							}
							var sortField:SortField = new SortField("pos");
							var sort:Sort = new Sort();
							sortField.descending = false;
							sort.fields = [sortField];
							spsLeftSide.sort = sort;
							spsRightSide.sort = sort;
							
							spsLeftSide.refresh();
							spsRightSide.refresh();
							
							if (component.position.type == Position.ENGINESIDE_SPS_LEFT || component.position.type == Position.BAY_HALF_ENCLOSURE_LEFT)
							{
								for (var pos1:int = 0; pos1 < spsLeftSide.length; pos1++)		
								{
									if (component == spsLeftSide[pos1].data)
									{
										spsPosition = pos1;	
										break;
									}
								}
								return ResourceManager.getInstance().getString("component", "SPS_TOOLTIP") + ++spsPosition + String.fromCharCode(A_CHAR_ASCII)								
							}
							if (component.position.type == Position.ENGINESIDE_SPS_RIGHT || component.position.type == Position.BAY_HALF_ENCLOSURE_RIGHT)
							{
								for (var pos2:int = 0; pos2 < spsRightSide.length; pos2++)
								{
									if (component == spsRightSide[pos2].data)
									{
										spsPosition = pos2;	
										break;
									}
								}
								return ResourceManager.getInstance().getString("component", "SPS_TOOLTIP") + ++spsPosition + String.fromCharCode(B_CHAR_ASCII);
							}
							
							break;
                        
                        case Position.ENGINESIDE_SPS_LEFT:
                            return ResourceManager.getInstance().getString("component", "SPS_TOOLTIP") + component.position.index + String.fromCharCode(A_CHAR_ASCII);
                        case Position.ENGINESIDE_SPS_RIGHT: 
                            return ResourceManager.getInstance().getString("component", "SPS_TOOLTIP") + component.position.index + String.fromCharCode(B_CHAR_ASCII);
						default:
							return ResourceManager.getInstance().getString("component", "SPS_TOOLTIP"); 
					}
				
			}
			// SPS overlay component tooltip
			if (component is SPS && overlayComponent != null) {
				switch (overlayComponent.type) {
					case TransparentOverlayConstants.SPS_INTERNAL_CHECK_LED:
						return ResourceManager.getInstance().getString("component", "SPS_INTERNAL_CHECK_LED_TOOLTIP");
						break;
					case TransparentOverlayConstants.SPS_ON_BATTERY_LED:
						return ResourceManager.getInstance().getString("component", "SPS_ON_BATTERY_LED_TOOLTIP");
						break;
					case TransparentOverlayConstants.SPS_ON_LINE_ENABLED_CHARGING_LED:
						return ResourceManager.getInstance().getString("component", "SPS_ON_LINE_LED_TOOLTIP");
						break;
					case TransparentOverlayConstants.SPS_REPLACE_BATTERIES_LED:
						return ResourceManager.getInstance().getString("component", "SPS_REPLACE_BATTERIES_LED_TOOLTIP");
						break;
					default:
						return UNDEFINED_TOOLTIP;
				}
			}
			// Engine tooltip
			if (component.isEngine && overlayComponent == null)
			{
				// front(rear) view
				return ResourceManager.getInstance().getString("component", "ENGINE_TOOLTIP") + SPACE_TOOLTIP + component.id;
			}
			// Engine overlay component tooltip - front view
			if (component.isEngine && overlayComponent != null && viewSide == Constants.FRONT_VIEW_PERSPECTIVE) {
				switch (overlayComponent.type) {
					case TransparentOverlayConstants.ENGINE_ODD_DIRECTOR_POWER_SUPPLY:
						return ResourceManager.getInstance().getString("component", "ENGINE_ODD_DIRECTOR_POWER_SUPPLY") + SPACE_TOOLTIP + String.fromCharCode(A_CHAR_ASCII) + overlayComponent.order;
						break;
					case TransparentOverlayConstants.ENGINE_EVEN_DIRECTOR_POWER_SUPPLY:
						return ResourceManager.getInstance().getString("component", "ENGINE_EVEN_DIRECTOR_POWER_SUPPLY") + SPACE_TOOLTIP + String.fromCharCode(B_CHAR_ASCII) + (overlayComponent.order - 2);
						break;
					case TransparentOverlayConstants.ENGINE20K40K_POWER_SUPPLY:
						return overlayComponent.order == 0 ? StringUtil.substitute(ResourceManager.getInstance().getString("component", "ENGINE_POWER_SUPPLY"), String.fromCharCode(A_CHAR_ASCII)) :
							StringUtil.substitute(ResourceManager.getInstance().getString("component", "ENGINE_POWER_SUPPLY"), String.fromCharCode(B_CHAR_ASCII));	
						break;
					case TransparentOverlayConstants.ENGINE20K40K_COOLING_FAN:
						return StringUtil.substitute(ResourceManager.getInstance().getString("component", "ENGINE_COOLING_FAN"),  String.fromCharCode(64 + overlayComponent.order));
						break;
					case TransparentOverlayConstants.ENGINE_VG3R_COOLING_FAN:
						return StringUtil.substitute(ResourceManager.getInstance().getString("component", "ENGINE_VG3R_COOLING_FAN"), String.fromCharCode(overlayComponent.order < 5 ? B_CHAR_ASCII : A_CHAR_ASCII), 
							String.fromCharCode(overlayComponent.order < 5 ? B_CHAR_ASCII : A_CHAR_ASCII) + overlayComponent.order % 5);
						break;
					case TransparentOverlayConstants.ENGINE_VG3R_POWER_SUPPLY:
						return StringUtil.substitute(ResourceManager.getInstance().getString("component", "ENGINE_VG3R_POWER_SUPPLY"), String.fromCharCode(overlayComponent.order < 12 ? B_CHAR_ASCII: A_CHAR_ASCII),
							String.fromCharCode((overlayComponent.order == 11 || overlayComponent.order == 13) ? B_CHAR_ASCII: A_CHAR_ASCII));
                    case TransparentOverlayConstants.ENGINE_VG3R_FLASH_DRIVE:
                        var director:String = String.fromCharCode(overlayComponent.order == 15 ? B_CHAR_ASCII: A_CHAR_ASCII);
                        return StringUtil.substitute(ResourceManager.getInstance().getString("component", "ENGINE_VG3R_FLASH_DRIVE"), director);
					default: 
						return UNDEFINED_TOOLTIP;
				}
			}
			// Engine overlay component tooltip - rear view
			if (component.isEngine && overlayComponent != null && viewSide == Constants.REAR_VIEW_PERSPECTIVE) {
				var order:int = overlayComponent.order;
				const DIRECTOR_1:String = String.fromCharCode(A_CHAR_ASCII);
				const DIRECTOR_2:String = String.fromCharCode(B_CHAR_ASCII);
                const VG3R_ENGINE_VAR_MAX_PORT:int = 10;
                const vg3rVarSlot:int =  sym.objectmodel.common.Engine.getSlotNumberByPosition(order) ;
				
				switch (overlayComponent.type) 
				{
					case TransparentOverlayConstants.ENGINE_MANAGEMENT_MODULE:
						if (component is sym.objectmodel.common.Engine)
						{
							return StringUtil.substitute(component.id == "1"? ResourceManager.getInstance().getString("component", "ENGINE_VGR3_MMCS"):
                                ResourceManager.getInstance().getString("component", "ENGINE_VGR3_MANAGEMENT_MODULE"), 
                                order == 4 ? DIRECTOR_2 : DIRECTOR_1, order == 4 ? DIRECTOR_2 : DIRECTOR_1);
						}
					case TransparentOverlayConstants.ENGINE_BACK_END_MODULE:
						if (component is sym.objectmodel.common.Engine)
						{
							return StringUtil.substitute(ResourceManager.getInstance().getString("component", "ENGINE_BACKEND_MODULE"), (order == 8 || order == 10) ? DIRECTOR_2 : DIRECTOR_1, (order == 8 || order == 9) ? 4 : 5); 
						}
					case TransparentOverlayConstants.ENGINE_POWER_CONNECTOR:
                        switch(overlayComponent.order)
                        {
                            case 16:
                            case 18: 
                                return ResourceManager.getInstance().getString("component", "ENGINE_POWER_CONNECTOR_B");
                            case 17:
                            case 19: 
                                return ResourceManager.getInstance().getString("component", "ENGINE_POWER_CONNECTOR_A");
                            default:
                                return ResourceManager.getInstance().getString("component", "ENGINE_POWER_CONNECTOR");
                        }
					case TransparentOverlayConstants.ENGINE_VG3R_FABRIC:
					case TransparentOverlayConstants.UNKNOWN_TYPE:	
						return StringUtil.substitute(ResourceManager.getInstance().getString("component", overlayComponent.type == TransparentOverlayConstants.ENGINE_VG3R_FABRIC ? "ENGINE_FABRIC_MODULE" : "ENGINE_PORT_DEFAULT"), order == 14 ? DIRECTOR_2 : DIRECTOR_1, 10); 
					case TransparentOverlayConstants.ENGINE_FRONT_END_MODULE:
						for each(var port:EnginePort in component.children) {
							if (order == port.position.index){
								var portDescription:String;
								var slot:int = 0;
								var indexPos:Number = port.position.index;
								switch (port.type){
									// 4-Port Fibre Channel 
									case EnginePort.FC_4:
										portDescription = ResourceManager.getInstance().getString("component", "4_PORT_FIBRE_CHANNEL");
										break;
									case EnginePort.FC_4_GLACIER:
										portDescription = StringUtil.substitute(ResourceManager.getInstance().getString("component", "4_PORT_FC_GLACIER"), 
											order < VG3R_ENGINE_VAR_MAX_PORT ? DIRECTOR_2 : DIRECTOR_1, 
											vg3rVarSlot);
										break;
									case EnginePort.FC_4_RAINFALL:
										portDescription = StringUtil.substitute(ResourceManager.getInstance().getString("component", "4_PORT_FC_RAINFALL"), 
											order < VG3R_ENGINE_VAR_MAX_PORT ? DIRECTOR_2 : DIRECTOR_1, 
											vg3rVarSlot);
										break;
									// 2-Port Fibre Channel 
									case EnginePort.FC_2_SRDF_1: 
									case EnginePort.FC_16GB_2:
										portDescription = ResourceManager.getInstance().getString("component", "2_PORT_FIBRE_CHANNEL");
										break;	
									// 2-Port 10Gb Ethernet 
									case EnginePort.ETH_2:
										portDescription = ResourceManager.getInstance().getString("component", "2_PORT_10GB_ETHERNET");
										break;
									// 2-Port 1Gb Ethernet 
									case EnginePort.ETH_1_GIGE_1:
										portDescription = ResourceManager.getInstance().getString("component", "2_PORT_1GB_ETHERNET");
										break;
									// 2-Port FiCON
									case EnginePort.FICON_2:
										switch(SymmController.instance.vmaxConfiguration)
										{
											default:
												portDescription = UNDEFINED_TOOLTIP;
										}
										break;
									// 4-port 16Gb FICON
									case EnginePort.FICON_4_PORT:
										portDescription = StringUtil.substitute(ResourceManager.getInstance().getString("component", "4_PORT_FICON"), 
											order < VG3R_ENGINE_VAR_MAX_PORT ? DIRECTOR_2 : DIRECTOR_1, 
											vg3rVarSlot);
										break;
									// DX port configuration 
									case EnginePort.DX_2_FC_2:
									case EnginePort.DX_4:
										switch (SymmController.instance.configFactory.getCurrentPortConfiguration().type)
										{
											case PortConfiguration.CONFIG23:
												portDescription = ResourceManager.getInstance().getString("component", "DX_PORT_CONFG");
												break;
											default: 
												portDescription = ResourceManager.getInstance().getString("component", "DX_FX_PORT_CONFG");
										}
										break;
                                    case EnginePort.COMPRESSION_ASTEROID:
                                        portDescription = StringUtil.substitute(ResourceManager.getInstance().getString("component", "COMPRESSION_ASTEROID_TOOLTIP"), 
                                            (order < VG3R_ENGINE_VAR_MAX_PORT) ? DIRECTOR_2 : DIRECTOR_1, vg3rVarSlot);
                                        break;
                                    case EnginePort.GIGE_2PORT_10GB_ELNINO:
                                        portDescription = StringUtil.substitute(ResourceManager.getInstance().getString("component", "GIGE_2PORT_10GB_ELNINO_TOOLTIP"), 
                                            (order < VG3R_ENGINE_VAR_MAX_PORT) ? DIRECTOR_2 : DIRECTOR_1, vg3rVarSlot);
                                        break;
                                    case EnginePort.GIGE_2PORT_10GB_ERRUPTION:
                                        portDescription = StringUtil.substitute(ResourceManager.getInstance().getString("component", "GIGE_2PORT_10GB_ERRUPTION_TOOLTIP"), 
                                            (order < VG3R_ENGINE_VAR_MAX_PORT) ? DIRECTOR_2 : DIRECTOR_1, vg3rVarSlot);
                                        break;
                                    case EnginePort.GIGE_2PORT_10GB_HEATWAVE:
                                        portDescription = StringUtil.substitute(ResourceManager.getInstance().getString("component", "GIGE_2PORT_10GB_HEATWAVE_TOOLTIP"), 
                                            (order < VG3R_ENGINE_VAR_MAX_PORT) ? DIRECTOR_2 : DIRECTOR_1, vg3rVarSlot);
                                        break;
                                    case EnginePort.GIGE_2PORT_1GB_THUNDERBOLT:
                                        portDescription = StringUtil.substitute(ResourceManager.getInstance().getString("component", "GIGE_4PORT_1GB_THUNDERBOLT_TOOLTIP"), 
                                            (order < VG3R_ENGINE_VAR_MAX_PORT) ? DIRECTOR_2 : DIRECTOR_1, vg3rVarSlot);
                                        break;
                                    case EnginePort.GIGE_4PORT_1GB_THUNDERCHILD:
                                        portDescription = StringUtil.substitute(ResourceManager.getInstance().getString("component", "GIGE_4PORT_1GB_THUNDERCHILD_TOOLTIP"), 
                                            (order < VG3R_ENGINE_VAR_MAX_PORT) ? DIRECTOR_2 : DIRECTOR_1, vg3rVarSlot);
                                        break;
                                    case EnginePort.GIGE_4PORT_10GB_RAINSTORM:
                                        portDescription = StringUtil.substitute(ResourceManager.getInstance().getString("component", "GIGE_4PORT_10GB_RAINSTORM_TOOLTIP"), 
                                            (order < VG3R_ENGINE_VAR_MAX_PORT) ? DIRECTOR_2 : DIRECTOR_1, vg3rVarSlot);
                                        break;
                                    case EnginePort.VAULT_FLASH_WIRLWIND:
                                        portDescription = StringUtil.substitute(ResourceManager.getInstance().getString("component", "VAULT_FLASH_WIRLWIND_TOOLTIP"), 
                                            (order < VG3R_ENGINE_VAR_MAX_PORT) ? DIRECTOR_2 : DIRECTOR_1, vg3rVarSlot);
                                        break;
									default: 
										portDescription = StringUtil.substitute(ResourceManager.getInstance().getString("component", "ENGINE_PORT_DEFAULT"), 
											(order < VG3R_ENGINE_VAR_MAX_PORT) ? DIRECTOR_2 : DIRECTOR_1, vg3rVarSlot);
								}
 
                                (indexPos == 0 || indexPos == 2) ? (slot = 4) :
									(slot = 5);
								return component is sym.objectmodel.common.Engine ? portDescription : 
									ResourceManager.getInstance().getString("component", (indexPos == 0 || indexPos == 1) ? "ENGINE_PORT_EVEN_DIRECTOR" : "ENGINE_PORT_ODD_DIRECTOR") + portDescription + SPACE_TOOLTIP + slot;
							}
						}
						
					default: 
						return UNDEFINED_TOOLTIP;
				}
			}
			
			if (component is EnginePort)
			{
				switch((component as EnginePort).type)
				{
					case EnginePort.FC_4_RAINFALL:
						return ResourceManager.getInstance().getString("component", "4_PORT_FC_RAINFALL_SHORT");
					case EnginePort.FC_4_GLACIER:
						return ResourceManager.getInstance().getString("component", "4_PORT_FC_GLACIER_SHORT");
					case EnginePort.GIGE_4PORT_10GB_RAINSTORM:
						return ResourceManager.getInstance().getString("component", "GIGE_4PORT_10GB_RAINSTORM_TOOLTIP_SHORT");
					case EnginePort.GIGE_2PORT_10GB_HEATWAVE:
						return ResourceManager.getInstance().getString("component", "GIGE_2PORT_10GB_HEATWAVE_TOOLTIP_SHORT");
					case EnginePort.GIGE_2PORT_1GB_THUNDERBOLT:
						return ResourceManager.getInstance().getString("component", "GIGE_4PORT_1GB_THUNDERBOLT_TOOLTIP_SHORT");
					case EnginePort.GIGE_2PORT_10GB_ELNINO:
						return ResourceManager.getInstance().getString("component", "GIGE_2PORT_10GB_ELNINO_TOOLTIP_SHORT");
					case EnginePort.GIGE_2PORT_10GB_ERRUPTION:
						return ResourceManager.getInstance().getString("component", "GIGE_2PORT_10GB_ERRUPTION_TOOLTIP_SHORT");
					case EnginePort.GIGE_4PORT_1GB_THUNDERCHILD:
						return ResourceManager.getInstance().getString("component", "GIGE_4PORT_1GB_THUNDERCHILD_TOOLTIP_SHORT");
					case EnginePort.FICON_4_PORT:
						return ResourceManager.getInstance().getString("component", "4_PORT_FICON_SHORT");
					default:
						return null;
				}
			}
			
			// MIBE tooltip
			if (component is MIBE && overlayComponent == null)
				// front view
				if (viewSide == Constants.FRONT_VIEW_PERSPECTIVE)
				{
					return ResourceManager.getInstance().getString("component", "MIBE_TOOLTIP");
				}
				// rear view 
				else
				{
					return ResourceManager.getInstance().getString("component", "MIBE_BACK_TOOLTIP");					
				}
			// MIBE overlay component tooltip 
			if (component is MIBE && overlayComponent != null) {
				var mibe_tooltip:String = ResourceManager.getInstance().getString("component", "MIBE_DEFAULT_TOOLTIP");
				switch (overlayComponent.type) {
					case TransparentOverlayConstants.MIBE_POWER_SUPPLY:
						var power_supply_tooltip:String = ResourceManager.getInstance().getString("component", "MIBE_POWER_SUPPLY_TOOLTIP");
						if (overlayComponent.order < 2) 
							return overlayComponent.order == 0 ? mibe_tooltip + SPACE_TOOLTIP + String.fromCharCode(A_CHAR_ASCII) + NEW_LINE_TOOLTIP + power_supply_tooltip + SPACE_TOOLTIP + String.fromCharCode(A_CHAR_ASCII) :
																				  mibe_tooltip + SPACE_TOOLTIP + String.fromCharCode(A_CHAR_ASCII) + NEW_LINE_TOOLTIP + power_supply_tooltip + SPACE_TOOLTIP + String.fromCharCode(B_CHAR_ASCII);
						else
							return overlayComponent.order == 2 ? mibe_tooltip + SPACE_TOOLTIP + String.fromCharCode(B_CHAR_ASCII) + NEW_LINE_TOOLTIP + power_supply_tooltip + SPACE_TOOLTIP + String.fromCharCode(A_CHAR_ASCII) :
																				  mibe_tooltip + SPACE_TOOLTIP + String.fromCharCode(B_CHAR_ASCII) + NEW_LINE_TOOLTIP + power_supply_tooltip + SPACE_TOOLTIP + String.fromCharCode(B_CHAR_ASCII); 
						break;
					case TransparentOverlayConstants.MIBE_ASSEMBLY:
						var mibe_assembly_tooltip:String = ResourceManager.getInstance().getString("component", "MIBE_ASSEMBLY_TOOLTIP");
						return overlayComponent.order == 0 ? mibe_tooltip + SPACE_TOOLTIP + String.fromCharCode(B_CHAR_ASCII) + SPACE_TOOLTIP + mibe_assembly_tooltip : 
																		      mibe_tooltip + SPACE_TOOLTIP + String.fromCharCode(A_CHAR_ASCII) + SPACE_TOOLTIP + mibe_assembly_tooltip;	
						break;
					default:
						return UNDEFINED_TOOLTIP;
				}
			}
			// UPS tooltip
			if (component is UPS && overlayComponent != null) {
				var upsToolTip:String = "";
				switch (overlayComponent.type) {
					case TransparentOverlayConstants.UPS_MAIN_INPUT_LED:
						upsToolTip = ResourceManager.getInstance().getString("component", "UPS_MAIN_INPUT_LED");
						break;
					case TransparentOverlayConstants.UPS_ON_BATTERY_LED:
						upsToolTip = ResourceManager.getInstance().getString("component", "UPS_ON_BATTERY_LED");
						break;
					case TransparentOverlayConstants.UPS_AUX_INPUT_LED:
						upsToolTip = ResourceManager.getInstance().getString("component", "UPS_AUX_INPUT_LED");
						break;
					case TransparentOverlayConstants.UPS_REPLACE_BATTERY_LED:
						upsToolTip = ResourceManager.getInstance().getString("component", "UPS_REPLACE_BATTERY_LED");
						break;
				}
				return upsToolTip;
			}
			// Data Mover
			if (component is DataMover) 
			{
				return ResourceManager.getInstance().getString("component", "DATA_MOVER_TOOLTIP");
			}
			// Control Station
			if (component is ControlStation)
			{
				return ResourceManager.getInstance().getString("component", "CONTROL_STATION_TOOLTIP");
			}
			
			// Drive
			if (component is Drive)
			{
				return (component as Drive).id;
			}
			
			// KVM
			if (component is KVM)
			{
				return ResourceManager.getInstance().getString("component", "KVM_TOOLTIP");
			}
			
			// if none of the above, returns empty tooltip
			return UNDEFINED_TOOLTIP;
        }
		
    }
}