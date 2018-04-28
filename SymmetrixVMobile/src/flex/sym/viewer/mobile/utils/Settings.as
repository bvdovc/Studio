package sym.viewer.mobile.utils
{
    import flash.events.EventDispatcher;
    
    import mx.core.ByteArrayAsset;

    /**
    * Global settings cache
    * Execute load method to fill dynamic content with data from settings.xml
    * Note: This is not fully dynamic logic. Some code should be added in method "onSettingsLoaded" if settings.xml containes new nodes.  
    */
    public dynamic  class Settings extends EventDispatcher
    {
        private static var inst:Settings = new Settings();
        private var _loaded:Boolean = false;
        private var _currentLanguage:String;
        
        
        [Embed(source="/settings.xml", mimeType="application/octet-stream")] 
        private var settingsXML:Class; 
        
        /**
        * Singleton getter
        */
        public static function get instance():Settings{
            return inst;
        }

        public function Settings()
        { 
        }
        
        /**
        * loads xml data
        */
        public function load():void{ 
            var ba:ByteArrayAsset = ByteArrayAsset(new settingsXML());
            var xml:XML = new XML(ba.readUTFBytes(ba.length));
            
            for each(var child:XML in xml.children() as XMLList){
                if(child.name() == "languages"){
                    var languages:Array = new Array();
                    for each(var lang:XML in child.children() as XMLList){
                        var language:Object = {enabled: lang.@enabled.toString() == "true", 
                            code: lang.@code.toString(), 
                            label: lang.toString(), 
                            isDefault: (lang.@isDefault ? lang.@isDefault.toString() == "true" : false)};
                        languages.push(language);
                    }
                    this["languages"] = languages;
                }
            }
            //... Add other settings ...
            _loaded = true;
        }
        
        /**
        * returns true if settings.xml has been loaded
        */
        public function get loaded():Boolean{
            return _loaded;
        }
        
        /**
        * current language code
        */
        public function get currentLanguage():String{
            return _currentLanguage;
        }
        
        /**
         * current language code
         */
        public function set currentLanguage(language:String):void{
            _currentLanguage = language;
        }
    }
}