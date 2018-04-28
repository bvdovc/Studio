package sym.viewer.mobile.utils
{
    import flash.desktop.NativeApplication;
    import flash.system.Capabilities;
    
    public final class CommonUtility
    {
        public static const IOS:String = "IOS";
        public static const ANDROID:String = "ANDROID";
        public static const BB:String = "BB";
        
        [Bindable]
        public static var OPERATING_SYSTEM:String = getOS();
        
        [Bindable]
        public static var APP_VERSION:String = getApplicationVersion();
        
        [Bindable]
        public static var INCLUDE_UNIFIED:Boolean = includeUnified();
		
		[Bindable]
		public static var INCLUDE_K_SERIES:Boolean = includeKSeries();

		[Bindable]
		public static var INCLUDE_M_SERIES:Boolean = includeMSeries();
		
		[Bindable]
		public static var INCLUDE_AFA_SERIES:Boolean = includeAFASeries();
		
		[Bindable]
		public static var INCLUDE_PM_SERIES:Boolean = includePMSeries();
        
        public static function getOS():String
        {   
            var version:String = Capabilities.version;
            OS::desktop{ 
                version = "";
            }
            switch (true)
            { 
                case (version.indexOf('IOS') > -1):
                {
                    return IOS;
                    break;
                }
                case (version.indexOf('QNX') > -1):
                {
                    return BB;
                    break;
                }
                case (version.indexOf('AND') > -1):
                {
                    return ANDROID;
                    break;
                }
                default:
                    return "";
                    break;
            }
        }
        
        /**
        * gets application version from descriptor
        */
        public static function getApplicationVersion():String{
            var descriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
            var ns:Namespace = descriptor.namespace();
//            return descriptor.ns::versionNumber;
            return descriptor.ns::versionLabel;
        }
        
        /**
         * deteremine if unified configs should be enabled 
         * @return boolean
         */        
        private static function includeUnified():Boolean{
            INCLUDE::unified{
                return true;
            }
            return false;
        }
		
		private static function includeKSeries():Boolean{
			SERIES::k_series{
				return true;
			}
			return false;
		}

		private static function includeMSeries():Boolean{
			SERIES::m_series{
				return true;
			}
			return false;
		}
		
		private static function includeAFASeries():Boolean{
			SERIES::afa_series{
				return true;
			}
			return false;
		}
		
		private static function includePMSeries():Boolean
		{
			SERIES::pm_series{
				return true;
			}
				return false;
		}
		
    }
}