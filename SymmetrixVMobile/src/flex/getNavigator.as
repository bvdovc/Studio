// ActionScript file

package{
    import mx.core.FlexGlobals;
    
    import spark.components.ViewNavigator;
    
    /**
    * gets app navigator
    * Sometimes navigator instance from homepage is null referenced so please use instead
    */
    public function getNavigator():ViewNavigator{
        return FlexGlobals.topLevelApplication.navigator;
    }
}