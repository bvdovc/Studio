package sym.controller.model
{
	import mx.collections.ArrayCollection;

	/**
	 * holds data for Tier wizard component binding
	 */	
	[Bindable]
	public class FilterWizardTierStateModel extends FilterWizardStateModel
	{
		private var _selectedOScapacity:Number;
		private var _selectedMFcapacity:Number = 0;
		
		private var _selectedTiers:ArrayCollection;
		
		public function FilterWizardTierStateModel()
		{
			super();
		}
		
		/**
		 * Holds OpenSystems capacity user input value if quick tier option is selected.<br/> 
		 * Otherwise for custom tier option, capacity will be calculated
		 * @return capacity value
		 * 
		 */		
		public function get selectedOScapacity():Number
		{
			return _selectedOScapacity;
		}

		public function set selectedOScapacity(value:Number):void
		{
			_selectedOScapacity = value;
		}

		/**
		 * Mainframe capacity value for predefined Drive mix options.<br/>
		 * Otherwise for custom tier option, MF capacity will be calculated
		 * @return capacity value
		 * 
		 */		
		public function get selectedMFcapacity():Number
		{
			return _selectedMFcapacity;
		}

		/**
		 * Calculates and sets Mainframe capacity based on the input Percent value. </br>
		 * Alos, the new OS capacity value is set.
		 * @param percentVal indicates input MF capacity percent value 
		 * 
		 */		
		public function set selectedMFcapacity(percentVal:Number):void
		{
			var percent:int = int(percentVal);
			
			// total usable capacity before calculation changes 	
			var totCap:Number = this.totUsableCapacity;
			
			// set MF capacity
			_selectedMFcapacity = Number(((percent * totCap) / 100).toFixed(1));
			
			// set new OS capacity
			_selectedOScapacity = Number((totCap - selectedMFcapacity).toFixed(1));
		}

		/**
		 * Holds tier <code> DataGrid <code/> values  
		 * @return 
		 * 
		 */		
		public function get selectedTiers():ArrayCollection
		{
			return _selectedTiers;
		}

		public function set selectedTiers(value:ArrayCollection):void
		{
			_selectedTiers = value;
		}
		
		/**
		 * Gets total Usable Capacity (OS + MF)
		 * @return capacity value
		 * 
		 */		
		public function get totUsableCapacity():Number
		{
			return _selectedOScapacity + _selectedMFcapacity;
		}

	}
}