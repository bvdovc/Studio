package sym.objectmodel.common
{
    import sym.objectmodel.driveUtils.DriveDef;
    import sym.objectmodel.driveUtils.enum.DriveRaidLevel;
    import sym.objectmodel.driveUtils.enum.DriveType;
    import sym.objectmodel.driveUtils.enum.HostType;
	
    /**
     * Represents one drive group entry (tier for quick tiers)  
     * <p>There can be more than one Drive Group with the same DriveDef, though spare count will depend on total drive count of these groups</p>
     */    
	[Bindable]
    public class DriveGroup
    {
		public static const XML_TAG_NAME:String = "Volume_request";
		public static const DRIVE_COUNT_XML_NAME:String = "drive_count";
		public static const DRIVE_SIZE_XML_NAME:String = "Thin_Slot";
		
        /** 
         *  Object that uniquely identifies drive composition (drive type, raid and drive size)   
         */
        public var driveDef:DriveDef;
        
        /**
         * Percent of total usable capacity 
         * <p>
         * <i>used for quick tiers only</i>
         * </p> 
         */
        public var percent:Number; 
        
        /**
        * Number of active drives
        * <i>
        * <p>
        * This value will be entered:
        * <p>
        * <ul>
        * <li>
        * In Custom config wizard, user input value
        * </li>
        * <li>
        * In Quick tier wizard whenever usable capacity value is entered
        * </li>
        * </ul> 
        * </i>
        */
        public var activeCount:int;   
        
        public function DriveGroup()
        {
            
        }
        
        /**
         * Factory method for creating DriveGroup 
         * @param driveDef
         * @param percent
         * @param activeCount
         * @return 
         * 
         */        
        public static function create(driveDef:DriveDef, percent:Number = NaN, activeCount:int = 0):DriveGroup
        {
            var dd:DriveGroup = new DriveGroup();
            dd.driveDef = driveDef;
            dd.percent = percent;
            dd.activeCount = activeCount;
            
            return dd;
        }
		
		public function serializeToXML():XML
		{
			var xml:XML = new XML(<{XML_TAG_NAME}> 
										<{DriveRaidLevel.VMAX_XML_NAME}/>
										<{DRIVE_COUNT_XML_NAME} />
										<{DriveType.DRIVE_CAPACITY_XML_NAME} />
										<{DriveType.DRIVE_SPEED_XML_NAME} />
										<{HostType.XML_TAG_NAME} />
										<{DriveGroup.DRIVE_SIZE_XML_NAME} />
									</{XML_TAG_NAME}>);
			
			xml.child(DriveRaidLevel.VMAX_XML_NAME).setChildren(this.driveDef.raid.name);
			xml.child(DriveGroup.DRIVE_COUNT_XML_NAME).setChildren(this.activeCount);
			xml.child(DriveType.DRIVE_CAPACITY_XML_NAME).setChildren(this.driveDef.type.capacity);
			xml.child(DriveType.DRIVE_SPEED_XML_NAME).setChildren(this.driveDef.type.speed);
			xml.child(HostType.XML_TAG_NAME).setChildren(HostType.OpenSystems.name);
			xml.child(DriveGroup.DRIVE_SIZE_XML_NAME).setChildren(this.driveDef.size == DAE.Viking || this.driveDef.size == DAE.Tabasco ? "Yes" : "No");
			
			return xml;
		}
		
		/**
		 * Clones drive group instance
		 * @return 
		 * 
		 */		
		public function cloneDG():DriveGroup
		{
			var newDg:DriveGroup = new DriveGroup();
			newDg.activeCount = this.activeCount;
			newDg.driveDef = this.driveDef;
			newDg.percent = this.percent;
			
			return newDg;
		}
    }
}