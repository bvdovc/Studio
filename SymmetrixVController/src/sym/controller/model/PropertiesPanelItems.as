package sym.controller.model
{
	import mx.collections.ArrayCollection;

	public class PropertiesPanelItems
	{
		private var _title:String;
		private var _properties:ArrayCollection;
		
		public function PropertiesPanelItems(){}
		
		public function get properties():ArrayCollection
		{
			return _properties;
		}

		public function set properties(value:ArrayCollection):void
		{
			_properties = value;
		}

		public function get title():String
		{
			return _title;
		}

		public function set title(value:String):void
		{
			_title = value;
		}

	}
}