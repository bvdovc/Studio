package sym.controller.events
{
	import flash.events.Event;
	
	import sym.objectmodel.common.Configuration_VG3R;
	
	/**
	 * Used to remove configurations from selection list and from File System if exists
	 * @author nmilic
	 * 
	 */	
	public class RemoveConfigurationEvent extends Event
	{
		public static const DELETE_CONFIG:String = "delete_configuration_event";
		
		private var _cfg:Configuration_VG3R;
		
		public function RemoveConfigurationEvent(type:String, cfg:Configuration_VG3R)
		{
			super(type);
			
			_cfg = cfg;
		}
		
		public function get config():Configuration_VG3R
		{
			return _cfg;
		}

		public function set config(value:Configuration_VG3R):void
		{
			_cfg = value;
		}
		
		public override function clone():Event
		{
			return new RemoveConfigurationEvent(type, config);
		}

	}
}