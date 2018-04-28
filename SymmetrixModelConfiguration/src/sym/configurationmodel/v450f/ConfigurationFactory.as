package sym.configurationmodel.v450f
{
	
	
	import mx.collections.ArrayCollection;
	
	import sym.configurationmodel.common.ConfigurationFactoryBase_VG3R;
	import sym.objectmodel.common.Configuration_VG3R;
	import sym.objectmodel.common.Constants;
	import sym.objectmodel.common.DAE;
	import sym.objectmodel.common.PortConfiguration;
	
	public class ConfigurationFactory extends ConfigurationFactoryBase_VG3R
	{
		public static const FACTORY_NAME:String = "450f_Factory";
		public static const SERIES_NAME:String = "450F_";
		
		private static const NO_ENGINES:int = 4;
		private static const NO_SYSTEM_BAYS:int = 2;
		private static const DISPERSED_VALUES:Array = [2];
		public static const TOTAL_USABLE_CAPACITY:Number = 2000; // TBu
//		private static const ENGINE_IOPS:Object = {1: 255830, 2: 213147};
		
		public function ConfigurationFactory()
		{
			super();
			
			_currentPortConfig = PortConfiguration.CONFIG_ALL_FLASH;
		}
		
		public override function get seriesName():String
		{
			return SERIES_NAME;
		}
		
		public override function get modelName():String
		{
			return Constants.VMAX_450F;
		}
		
		protected override function factoryName():String
		{
			return FACTORY_NAME;
		}
		
		public override function get noEngines():int
		{
			return NO_ENGINES;
		}
		
		public override function get noSystemBays():int
		{
			return NO_SYSTEM_BAYS;
		}
	
		public override function get dispersed_m():Array
		{
			return DISPERSED_VALUES;
		}
		
		public override function get totCapacity():Number
		{
			return TOTAL_USABLE_CAPACITY;
		}

		public override function get daeType():Array
		{
			return [DAE.Viking];
		}

		public override function get sysBayType():Array
		{
			return [Configuration_VG3R.DUAL_ENGINE_BAY];
		}
		
		/**
		 * gets allowed port configurations
		 */
		public override function getAllowedPortConfigurations():ArrayCollection{
			var portconfigs:ArrayCollection = new ArrayCollection();
			portconfigs.addAll(new ArrayCollection(PORT_CONFIGS_ALL_FLASH));
			return portconfigs;
		}
	}
}