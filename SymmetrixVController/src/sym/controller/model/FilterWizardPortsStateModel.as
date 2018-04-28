package sym.controller.model
{
	import mx.resources.ResourceManager;

	public class FilterWizardPortsStateModel extends FilterWizardStateModel
	{
		private var _fileCapacityEnabled:Boolean = true;
		private var _fileCapacitySelected:Boolean = false;
		private var _selectedProtocol:Object;
		
		// TODO: module view should be enabled for Trinity release
		private var _portViewModel:Boolean = true;
		
		// host protocol labels
		public static const FC_PROTOCOL:String = "FC";
		public static const FICON_PROTOCOL:String = "FICON";
		public static const ISCSI_PROTOCOL:String = "iSCSI";
		
		// Grid view types
		public static const PORT_VIEW:String = ResourceManager.getInstance().getString("main", "STATE_ENGINE_PORTS_GRID__PORT_VIEW");
		public static const MODULE_VIEW:String = ResourceManager.getInstance().getString("main", "STATE_ENGINE_PORTS_GRID_MODULE_VIEW");
		// Grid view data provider
		public static var GRID_VIEW_TYPES:Array = [ResourceManager.getInstance().getString("main", "STATE_ENGINE_PORTS_GRID_MODULE_VIEW"), ResourceManager.getInstance().getString("main", "STATE_ENGINE_PORTS_GRID__PORT_VIEW")];
		
		// host protocl providers
		public static const HOST_PROTOCOLS:Object = {
			OS: [FC_PROTOCOL, ISCSI_PROTOCOL],
			MF: [FICON_PROTOCOL],
			Mixed: [FC_PROTOCOL, ISCSI_PROTOCOL, FICON_PROTOCOL]
		};
		
		public static const DEFAULT_HOST_PROTOCOL:Object = {
			OS: [FC_PROTOCOL],
			MF: [FICON_PROTOCOL],
			Mixed: [FC_PROTOCOL, FICON_PROTOCOL]
		};
		
		public function FilterWizardPortsStateModel()
		{
			super();
		}

		/**
		 * Chcecks if File Capacity is enabled 
		 * @return True if File is Enabled
		 * 
		 */		
		public function get fileCapacityEnabled():Boolean
		{
			return _fileCapacityEnabled;
		}

		public function set fileCapacityEnabled(value:Boolean):void
		{
			_fileCapacityEnabled = value;
		}

		/**
		 * Chcecks if File Capacity is selected 
		 * @return True if File is Enabled
		 * 
		 */		
		public function get fileCapacitySelected():Boolean
		{
			return _fileCapacitySelected;
		}

		public function set fileCapacitySelected(value:Boolean):void
		{
			_fileCapacitySelected = value;
		}

		/**
		 * Checks what Engine (Port/Module) view model is displayed.<br/>
		 * Default is Port view  
		 * @return True if Port view model
		 * 
		 */		
		public function get portViewModel():Boolean
		{
			return _portViewModel;
		}

		public function set portViewModel(value:Boolean):void
		{
			_portViewModel = value;
		}

		/**
		 * Gets which host protocol is selected FC/iSCSI/FICON
		 * @return 
		 * 
		 */		
		public function get selectedProtocol():Object
		{
			return _selectedProtocol;
		}

		public function set selectedProtocol(value:Object):void
		{
			_selectedProtocol = value;
		}



	}
}