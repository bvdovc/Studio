package sym.controller.model
{
	import mx.collections.ArrayCollection;
	
	/**
	 * holds data for wizardPopUp component binding
	 */ 
	[Bindable]
	public class FilterWizardStateModel
	{
		private var _dataProvider:ArrayCollection;
		private var _selectedItem:Object;
		private var _stateType:String;
		
		public function FilterWizardStateModel()
		{
		}
		
		public function get selectedItem():Object
		{
			return _selectedItem;
		}

		public function set selectedItem(value:Object):void
		{
			_selectedItem = value;
		}

		public function get dataProvider():ArrayCollection
		{
			return _dataProvider;
		}

		public function set dataProvider(value:ArrayCollection):void
		{
			_dataProvider = value;
		}

		public function get stateType():String
		{
			return _stateType;
		}

		public function set stateType(value:String):void
		{
			_stateType = value;
		}
		

	}
}