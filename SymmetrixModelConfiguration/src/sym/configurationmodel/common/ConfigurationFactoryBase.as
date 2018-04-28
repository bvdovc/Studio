package sym.configurationmodel.common
{
    import mx.collections.ArrayCollection;
    
    import sym.objectmodel.common.Configuration;
    import sym.objectmodel.common.Configuration_VG3R;
    import sym.objectmodel.common.DAE;
    import sym.objectmodel.common.IPortConfigurationManager;
    import sym.objectmodel.common.IPowerTypeManager;
    import sym.objectmodel.common.KVM;
    import sym.objectmodel.common.PDP;
    import sym.objectmodel.common.PDU;
    import sym.objectmodel.common.PortConfiguration;
    import sym.objectmodel.common.SPS;


    /**
     * Base class for sym configuration factories. All other factories (master, 10k, 20k, 40k) are derived from it.
     */
    public class ConfigurationFactoryBase implements IPortConfigurationManager, IPowerTypeManager
    {        
        /**
         * list of all configurations for particual factory.
         */
        protected var _configurations:Array = [];
		
        protected var _currentPortConfig:int = PortConfiguration.CONFIG1; 
        protected var _currentPowerType:int = PDU.TYPE1PHASE;
        protected var _currentSPSType:int = SPS.TYPE_STANDARD;
		protected var _currentTierSolution:int;
        
        public function ConfigurationFactoryBase()
        {
            initializeCache();
        }
        
        public function getAllConfigurations():Array{
            return _configurations;
        }
		
		public function get currentTier():int
		{
			return _currentTierSolution;
		}

		public function set currentTier(value:int):void
		{
			_currentTierSolution = value;
		}
		
        /**
         * Find and return all configurations that match suplied filter
         */
        public function filter(filter:ConfigurationFilter):Array
        {
            return [];
        }

        public function get noEngines():int
        {
            return 0;
        }

        public function get noStorageBays():int
        {
            return 0;
        }
		
		public function get noSystemBays():int
		{
			return 0;
		}

        public function get dispersed():Array
        {
            return null;
        }

        public function get daeType():Array
        {
            return null;
        } 
		
		public function get noDataMovers():Array
		{
			return null;
		} 
		
		public function get sysBayType():Array
		{
			return null;
		}
		
		public function getConfigurationByID(id:String):sym.objectmodel.common.Configuration
		{
			for each(var cfg:sym.objectmodel.common.Configuration in _configurations){
				if(cfg.id == id){
					return cfg;
				}
			}
			
			return null;
		}

        public function getCalculatedId(cfg:sym.objectmodel.common.Configuration):String
        {
            if (cfg.dispersed == -1)
            {
                return cfg.calculatedId;
            }

            for each (var tmpCfg:sym.objectmodel.common.Configuration in _configurations)
            {
                if (tmpCfg.id == cfg.id)
                {
                    return tmpCfg.calculatedId;
                }
            }

            return cfg.calculatedId;
        }

        public function getCurrentPortConfiguration():PortConfiguration
        {
            var pc:ArrayCollection = getAllowedPortConfigurations();		
            for each (var port:PortConfiguration in pc) {
                if (port.type == _currentPortConfig) {
                    return port;
                }
            }
            
            return null;
        }

        public function getAllowedPortConfigurations():ArrayCollection
        {
            return new ArrayCollection([]);
        }

        public function setCurrentPortConfiguration(portConfig:int):void
        {
            _currentPortConfig = portConfig;
        }
		
		/**
		 * Populate all configuration DAEs or just populate DAE (and DAEs behind same engine) with Drives when user drills down to DAE level.<br/>
		 * If only configuration is specified then populate all DAEs in configuration. Otherwise, just specific DAEs.
		 * @param config indicates current configuration
		 * @param dae indicates specific DAE component
		 * <p>If dae contains already populated children, this method does nothing</p>
		 */	
		public function populateWithDrives(config:Configuration_VG3R, dae:DAE = null):void
		{
		}	
			

        /** 
        * gets current power Type
        */
        public function getCurrentPowerType():int{
            return _currentPowerType;
        }
        
        /**
        * sets current power type
        */
        public function setCurrentPowerType(type:int):void{
            _currentPowerType = type;
        }
        
        /**
        * gets sps type
        */
        public function getCurrentSPSType():int{
            return _currentSPSType;
        }
        
        /**
        * sets sps type for all configurations in series
        */
        public function setCurrentSPSType(type:int):void{
            _currentSPSType = type;
        }
 
        public function isPDPVisible(pdp:PDP):Boolean {
            // factory must override
            return false;
        }
        
        public function isPDUVisible(pdu:PDU):Boolean {
            // factory must override
            return false;
        } 

		public function isKVMvisible(kvm:KVM, viewSide:String):Boolean 
		{
            return true;
        } 
            
        public function initializeCache():void{}
        
        /**
        * appends new configuration into list
        */
        public function appendConfiguration(config:sym.objectmodel.common.Configuration):Boolean{
            for each(var c:sym.objectmodel.common.Configuration in _configurations){
                if(c.structureId == config.structureId){
                    return false;
                }
            }
            _configurations.push(config);
            return true;
        }
    }
}
