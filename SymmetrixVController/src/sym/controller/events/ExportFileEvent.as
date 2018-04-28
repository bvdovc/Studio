package sym.controller.events
{
	import flash.events.Event;
	
	public class ExportFileEvent extends Event
	{
		public static const EXPORT_REQUEST:String = "export_request";
		private var _filename:String;
		private var _isXml:Boolean;
		
		public function ExportFileEvent(type:String, filename:String, isXml:Boolean)
		{
			super(type);
			this._filename = filename;
			this._isXml = isXml;
		}

		public function get filename():String
		{
			return _filename;
		}
		
		public function get isXml():Boolean
		{
			return _isXml;
		}

		public override function clone():Event
		{
			return new ExportFileEvent(type, filename, isXml);
		}
	}
}