package sym.controller.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * Event class responsible for importing xml (saved) file(s)
	 * @author nmilic
	 * 
	 */	
	public class XmlImportedEvent extends Event
	{
		public static const XML_IMPORTED:String = "xml_imported";
		public static const XML_FILES_IMPORTED:String = "xml_files_imported";
		
		private var _importedXml:XML;
		private var _importedXMLs:ArrayCollection;
		
		public function XmlImportedEvent(type:String, importedXml:XML, importedXMLs:ArrayCollection)
		{
			super(type);
			this._importedXml = importedXml;
			this._importedXMLs = importedXMLs;
		}
		
		public function get importedXml():XML
		{
			return _importedXml;
		}

		/**
		 * Gets collection containing objects with xml and its saved name
		 * @return
		 * 
		 */		
		public function get importedXMLs():ArrayCollection
		{
			return _importedXMLs;
		}
		
		public override function clone():Event
		{
			return new XmlImportedEvent(type, importedXml, importedXMLs);
		}
	}
}