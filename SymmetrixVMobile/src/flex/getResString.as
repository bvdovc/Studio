// ActionScript file

package{
    import mx.resources.ResourceManager;
    
    /**
    * gets string from resource files
    */
    public function getResString(bundle:String, resource:String):String{
        return ResourceManager.getInstance().getString(bundle, resource);
    }
}