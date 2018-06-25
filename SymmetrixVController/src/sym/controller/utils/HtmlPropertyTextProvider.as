package sym.controller.utils
{ 
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;
	import mx.utils.StringUtil;
	
	import spark.formatters.NumberFormatter;
	
	import sym.controller.SymmController;
	import sym.controller.events.PropertiesLoadEvent;
	import sym.controller.model.BulletItem;
	import sym.controller.model.DataRow;
	import sym.controller.model.DataTable;
	import sym.controller.model.PropertiesPanelItems;
	import sym.controller.model.PropertyItem;
	import sym.objectmodel.common.Bay;
	import sym.objectmodel.common.ComponentBase;
	import sym.objectmodel.common.Configuration;
	import sym.objectmodel.common.Configuration_VG3R;
	import sym.objectmodel.common.Constants;
	import sym.objectmodel.common.D15;
	import sym.objectmodel.common.DAE;
	import sym.objectmodel.common.DriveGroup;
	import sym.objectmodel.common.Engine;
	import sym.objectmodel.common.EnginePort;
	import sym.objectmodel.common.EthernetSwitch;
	import sym.objectmodel.common.IPowerTypeManager;
	import sym.objectmodel.common.InfinibandSwitch;
	import sym.objectmodel.common.KVM;
	import sym.objectmodel.common.MIBE;
	import sym.objectmodel.common.Nebula;
	import sym.objectmodel.common.PDU_VG3R;
	import sym.objectmodel.common.PortConfiguration;
	import sym.objectmodel.common.SPS;
	import sym.objectmodel.common.Server;
	import sym.objectmodel.common.Tabasco;
	import sym.objectmodel.common.UPS;
	import sym.objectmodel.common.Vanguard;
	import sym.objectmodel.common.Viking;
	import sym.objectmodel.common.Voyager;
	import sym.objectmodel.utils.CapacityNumberFormatter;
	
	public class HtmlPropertyTextProvider extends EventDispatcher implements IPropertyTextProvider
	{   
		private static const UNDEFINED_PROPERTY:String = "N\\A";
		
		private var loader:URLLoader = new URLLoader();
		private var lastComponent:ComponentBase = null;
		private var lastPerspective:String;
		
		public var isSistemBayDisplayed:Boolean = false;
		
		public function getPropertyText(viewSide:String, component:ComponentBase):String
		{ 
			if(lastComponent != null && !(component is Bay || component is Configuration_VG3R))
			{
				if(lastComponent.equals(component))
				{	
						return "";
				}
			}
			lastComponent = component;
			lastPerspective = viewSide;
			// selected configuration property 

			if(component is sym.objectmodel.common.Configuration_VG3R)
			{
				switch( (component as Configuration_VG3R).factory)
				{
					case SymmController.instance.configFactory250F:
						parse(ResourceManager.getInstance().getString("component", (component as Configuration_VG3R).isSizerImported ? "CONFIGURATION_250F_XML_IMPORTED" : "CONFIGURATION_250F_XML"));
						break;
					case SymmController.instance.configFactory450F:
						parse(ResourceManager.getInstance().getString("component", "CONFIGURATION_450F_XML"));
						break;
					case SymmController.instance.configFactory950F:
						parse(ResourceManager.getInstance().getString("component", (component as Configuration_VG3R).isSizerImported ? "CONFIGURATION_950F_XML_IMPORTED" : "CONFIGURATION_950F_XML"));
						break;
					case SymmController.instance.configFactoryPM2000:
						parse(ResourceManager.getInstance().getString("component", (component as Configuration_VG3R).isSizerImported ? "CONFIGURATION_PM2000_XML_IMPORTED" : "CONFIGURATION_PM2000_XML"));
						break;
					case SymmController.instance.configFactoryPM8000:
						parse(ResourceManager.getInstance().getString("component", (component as Configuration_VG3R).isSizerImported ? "CONFIGURATION_PM8000_XML_IMPORTED" : "CONFIGURATION_PM8000_XML"));
						break;
					default:
						parse(ResourceManager.getInstance().getString("component", "NOT_AVAILABLE_XML"));
						break;
				}
				return "";
			}
			// DAE property
			if (component is DAE)
			{		
				if (component is Viking)
				{
					parse(ResourceManager.getInstance().getString("component", "VIKING_DAE"));  //for now back/front are same
					return "";
				}
				
				if (component is Voyager)
				{
					parse(ResourceManager.getInstance().getString("component", "VOYAGER_DAE"));  //for now back/front are same
					return "";
				}
				if (component is Tabasco)
				{
					parse(ResourceManager.getInstance().getString("component", "TABASCO_DAE"));
					return "";
				}
				if (component is Nebula)
				{
					parse(ResourceManager.getInstance().getString("component", "NEBULA_DAE"));
					return "";
				}
			}
			// Bay property
			if (component is Bay)
			{
					// Titan storage bay
				if (component.type == Bay.TYPETITANSTGBAY)
				{					
					//currently same for all views, if needed, split this for each view side (@param viewSide)
					if(component.parentConfiguration is Configuration_VG3R)
					{
						switch(component.parentConfiguration.factory)
						{
							default:
								parse(ResourceManager.getInstance().getString("component", "NOT_AVAILABLE_XML"));
								break;
						}
						return "";
					}
				}
					// Titan system bay
				else if (component.type == Bay.TYPETITANSYSBAY)		
				{
							
					if(component.parentConfiguration is sym.objectmodel.common.Configuration_VG3R)
					{
						var sysBayIndex:int = (component as Bay).positionIndex + 1;
						if(isSistemBayDisplayed)
							sysBayIndex++;
						if(sysBayIndex == 0)  //something is wrong?!? 
						{ 
							parse(ResourceManager.getInstance().getString("component", "NOT_AVAILABLE_XML"));
						}
						else if(sysBayIndex == 1)
						{ 
							if(isPM2000())
							{
								parse(ResourceManager.getInstance().getString("component", "POWERMAX_2000_SYSTEM_BAY"));
								return "";
							}
							
							if(isPM8000() && !isSistemBayDisplayed)
							{
								parse(ResourceManager.getInstance().getString("component", "POWERMAX_8000_SYSTEM_BAY_1"));
								isSistemBayDisplayed = true;
								return "";
							}
							
							SymmController.instance.isAFA() ? is250F() ? parse(ResourceManager.getInstance().getString("component", "TITAN_SYSTEM_250F_XML")) : parse(ResourceManager.getInstance().getString("component", "TITAN_SYSTEM_AFA_XML")) :
								parse(ResourceManager.getInstance().getString("component", "TITAN_SYSTEM_VG3R_XML"));
						}
						else
						{
							if(isPM8000())
							{
								if(component.parentConfiguration.noEngines < 5)
									parse(ResourceManager.getInstance().getString("component", "POWERMAX_8000_SYSTEM_BAY_1"));
								else
								{
									parse(ResourceManager.getInstance().getString("component", "POWERMAX_8000_SYSTEM_BAY_2"));
									isSistemBayDisplayed = false;
								}
								return "";
							}
							
							SymmController.instance.isAFA() ? parse(ResourceManager.getInstance().getString("component", "TITAN_SYSTEM_AFA_FORMAT_XML")) :
								parse(ResourceManager.getInstance().getString("component", "TITAN_SYSTEM_FORMAT_VG3R_XML"));
						}
						
						return "";
					}
				}
			}
			if (component is EthernetSwitch)
			{
				if(SymmController.instance.isPM())
				{
					parse(ResourceManager.getInstance().getString("component", "ETHERNET_SWITCH_POWERMAX_SERIES"));
					return "";	
				}
				
				parse(ResourceManager.getInstance().getString("component", "ETHERNET_SWITCH"));
				return "";
			}
			if (component is InfinibandSwitch)
			{
				if(SymmController.instance.isAFA())
				{
					parse(ResourceManager.getInstance().getString("component", "INTERCONNECT_18_AFA"));
					return "";
					
				}
				parse(ResourceManager.getInstance().getString("component", component.type == InfinibandSwitch.TYPE_DINGO ? "INTERCONNECT_12" : "INTERCONNECT_18"));
				return "";
			}
			// SPS property 
			if (component is SPS)
			{	
				if (component.parentConfiguration is Configuration_VG3R && 
					(component.parentConfiguration.factory as IPowerTypeManager).getCurrentSPSType() == SPS.TYPE_LION)
				{
					parse(ResourceManager.getInstance().getString("component", "SPS_LION_VG3R"));
					return "";  
				}
			}
			if (component is PDU_VG3R)
			{
				//ingore viewside for now
				parse(ResourceManager.getInstance().getString("component", "PDU_VG3R_XML"));
				return "";
			}
			//UPS property
			if (component is UPS)
			{
				// front view
				if (viewSide == Constants.FRONT_VIEW_PERSPECTIVE)
				{
					parse(ResourceManager.getInstance().getString("component", "UPS_XML"));
					return "";
				}
					// rear view TBD 
				else
				{
					parse(ResourceManager.getInstance().getString("component", "UPS_XML"));
					return "";
				}
			}
			// Engine property
			if (component.isEngine)
			{				
				if(component.parentConfiguration is Configuration_VG3R)
				{
					switch(component.parentConfiguration.factory)
					{
						case SymmController.instance.configFactory250F:
							parse(ResourceManager.getInstance().getString("component", "ENGINE_250F_XML"));
							break;
						case SymmController.instance.configFactory450F:
							parse(ResourceManager.getInstance().getString("component", "ENGINE_450F_XML"));
							break;
						case SymmController.instance.configFactory950F:
							parse(ResourceManager.getInstance().getString("component", "ENGINE_450F_XML"));
							break;
						case SymmController.instance.configFactoryPM2000:
							parse(ResourceManager.getInstance().getString("component", "ENGINE_PM2000_XML"));
							break;
						case SymmController.instance.configFactoryPM8000:
						{
							if(component.parentConfiguration.noEngines > 1)
								parse(ResourceManager.getInstance().getString("component", "ENGINE_PM8000_MULTI_ENGINE_XML"));
							else
								parse(ResourceManager.getInstance().getString("component", "ENGINE_PM8000_SINGLE_ENGINE_XML"));
							break;
						}
						default:
							parse(ResourceManager.getInstance().getString("component", "NOT_AVAILABLE_XML"));
							break;
					}
					return "";
				}
			}
			// KVM property
			if (component is KVM)
				// front view
				if (viewSide == Constants.FRONT_VIEW_PERSPECTIVE)
				{
					parse(ResourceManager.getInstance().getString("component", "KVM_XML"));
					return "";
				}
					// rear view TBD 
				else
				{
					parse(ResourceManager.getInstance().getString("component", "KVM_XML"));
					return "";
				}
			// Server property
			if (component is Server)
				// front view
				if (viewSide == Constants.FRONT_VIEW_PERSPECTIVE)
				{
					parse(ResourceManager.getInstance().getString("component", "SERVER_XML"));
					return "";
				}
					// rear view
				else
				{
					parse(ResourceManager.getInstance().getString("component", "SERVER_XML"));
					return "";
				}
			// MIBE property
			if (component is MIBE)
				// front view
				if (viewSide == Constants.FRONT_VIEW_PERSPECTIVE)
				{
					parse(ResourceManager.getInstance().getString("component", "MIBE_XML"));
					return "";
				}
					// rear view TBD
				else
				{
					parse(ResourceManager.getInstance().getString("component", "MIBE_XML"));
					return "";
				}
			// Engine Port property
			if (component is EnginePort)
			{
				// rear view
				if (viewSide == Constants.REAR_VIEW_PERSPECTIVE)
				{
					// 4-Port Fibre Channel 
					if (component.type == EnginePort.FC_4)
					{
						parse(ResourceManager.getInstance().getString("component", "4_PORT_FC_XML"));
						return "";
					}
					// 2-Port Fibre Channel 
					if (component.type == EnginePort.FC_2_SRDF_1 || component.type == EnginePort.FC_16GB_2)
					{
						switch(SymmController.instance.vmaxConfiguration)
						{
							default: 
								break;
						}		
					}
					// 2-Port 10Gb Ethernet 
					if (component.type == EnginePort.ETH_2)
					{
						parse(ResourceManager.getInstance().getString("component", "2_PORT_10_ETH_XML"));
						return "";
					}
					// 2-Port 1Gb Ethernet 
					if (component.type == EnginePort.ETH_1_GIGE_1)
					{
						parse(ResourceManager.getInstance().getString("component", "2_PORT_1_ETH_XML"));
						return "";
					}
					// 2-Port FiCON
					if (component.type == EnginePort.FICON_2)
					{
						switch(SymmController.instance.vmaxConfiguration)
						{
							default: 
								break;
						}		
					}
					// DX port configuration 
					if (component.type == EnginePort.DX_2_FC_2 || component.type == EnginePort.DX_4)
					{
						switch (SymmController.instance.configFactory.getCurrentPortConfiguration().type)
						{
							case PortConfiguration.CONFIG23:
								parse(ResourceManager.getInstance().getString("component", "DX_PORT_XML"));
								return "";
							default: 
							{
								parse(ResourceManager.getInstance().getString("component", "DX_FX_PORT_XML"));
								return "";
							}
						}
					}
					// TBD ?
					if (component.type == EnginePort.SRDF_2)
					{
						
					}
				} 
			}
			
			// if none of the above, returns empty property
			parse(ResourceManager.getInstance().getString("component", "NOT_AVAILABLE_XML"));
			return "";
		}  
		
		/**
		 * parses xml file
		 * @returns collection of PropertyItem instances
		 */
		private function parse(xmlPath:String):void
		{
			loader.addEventListener(Event.COMPLETE, loadingCompleted);
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, loadingFailed);
			loader.addEventListener(ErrorEvent.ERROR, loadingFailed)
			
			loader.load(new URLRequest(xmlPath)); 
		}
		
		protected function loadingFailed(evt:Event):void{ 
			dispatchEvent(new PropertiesLoadEvent(PropertiesLoadEvent.PROPERTY_LIST_LOADED, null)); 
		}
		
		/**
		 * xml loaded handler
		 */
		protected function loadingCompleted(evt:Event):void
		{
			var data:XML = XML(prepareXmlString(lastComponent, String(loader.data)));
			
			dispatchEvent(new PropertiesLoadEvent(PropertiesLoadEvent.PROPERTY_LIST_LOADED, parseXML(data)));
		}
		
		/**
		 * Parse Property XML 
		 * @param data
		 * @return 
		 * 
		 */        
		public static function parseXML(data:XML):PropertiesPanelItems
		{
			var propertiesPanelItems:PropertiesPanelItems = new PropertiesPanelItems();
			propertiesPanelItems.title = data.title.toString();
			var properties:ArrayCollection = new ArrayCollection();
			delete data.title;
			
			for each (var span:XML in data.children() as XMLList)
			{
				var property:PropertyItem = new PropertyItem();
				
				property.image = String(span.img.@src);
				property.imageRatio = Number(span.img.@ratio);
				property.imageHeight = Number(span.img.@heigth);
				property.heading = span.h.toString();
				property.paragraph = span.p.toString();
				property.bullets = extractBullets(span);
				property.table = extractTable(span);
				
				properties.addItem(property);
			} 
			
			propertiesPanelItems.properties = properties;
			return propertiesPanelItems;
		}
		
		/**
		 * extracts bullets from ul tag
		 */
		private static function extractBullets(span:XML):ArrayCollection
		{
			var result:ArrayCollection = new ArrayCollection();
			
			for each (var li:XML in span.ul.children())
			{
				var indent:int = int(li.@indent);
				
				result.addItem(new BulletItem(li.toString(), indent));
			}
			
			if (result.length == 0)
			{
				return null;
			}
			return result;
		}
		
		/**
		 * extract data from table tag and creates DataTable instance
		 */
		private static function extractTable(span:XML):DataTable
		{
			var rows:ArrayCollection = new ArrayCollection();
			
			var maxCols:int = 0;
			for each (var tr:XML in span.table.children())
			{
				var cols:int = 0;
				var row:ArrayCollection = new ArrayCollection();
				for each (var td:XML in tr.children())
				{
					cols++;
					if (cols > maxCols)
					{
						maxCols = cols;
					}
					row.addItem(td.toString());
				}
				rows.addItem(row);
			}
			
			var table:DataTable = new DataTable(maxCols);
			for each (var dataRow:ArrayCollection in rows)
			{
				var dr:DataRow = table.createRow();
				var index:int = 0;
				for each (var item:Object in dataRow)
				{
					dr.addItemAt(item, index++);
				}
			}
			
			if (table.rows == 0)
				return null;
			
			return table;
		} 
		
		/**
		 * substitues xml variable fields
		 */
		private function prepareXmlString(component:ComponentBase, xmlString:String):String{
			var result:String = xmlString;
			if(component is sym.objectmodel.common.Configuration){
				var cfg:sym.objectmodel.common.Configuration = component as sym.objectmodel.common.Configuration;
				if (cfg is Configuration_VG3R)
				{
					var cfg1:sym.objectmodel.common.Configuration_VG3R = component as sym.objectmodel.common.Configuration_VG3R;
					var raidLevel:String = cfg1.driveGroups[0].driveDef.raid.name;
					result = StringUtil.substitute(result, cfg.formattedCapacity(cfg.osUsableCapacity) == "0" ? "" : cfg.formattedCapacity(cfg.osUsableCapacity), cfg.noEngines, cfg.totalDaeNumber, cfg.maxDrivesNumber-cfg.activesAndSpares, cfg.formattedCapacity(cfg.mfUsableCapacity) == "0" ? "" : cfg.formattedCapacity(cfg.mfUsableCapacity), cfg.activesAndSpares, cfg.enginePorts, raidLevel);
				}
				else
				{
					result = StringUtil.substitute(result, cfg.noEngines, cfg.totalDaeNumber, cfg.maxDrivesNumber);
				}
			}
			else if(component.parentConfiguration is sym.objectmodel.common.Configuration_VG3R && 
				component is sym.objectmodel.common.Bay &&
				(component as sym.objectmodel.common.Bay).isSystemBay)
			{
				var sysBayIndex:int = (component as Bay).positionIndex + 1;
				
				if(sysBayIndex > 1)
				{
					result = StringUtil.substitute(result, sysBayIndex);
				}
			}
			
			return result;
		}
	}
}