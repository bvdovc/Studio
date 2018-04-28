package sym.controller.events
{
	import flash.events.Event;
	
	public class XmlImportErrorEvent extends Event
	{
		public static const XML_IMPORT_ERROR:String = "xml_import_error";
		public static const XML_WRONG_ERROR:String = "xml_wrong_error";
		
		public function XmlImportErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}