package sym.controller.events
{
    import flash.events.Event;

    import mx.collections.ArrayCollection;

    /**
     * holds breadcrumb data provider for updating
     */
    public class RefreshNavigationEvent extends Event
    {
        public static const REFRESH_NAVIGATION:String = "refresh navigation event";

        private var _breadcrumbDataProvider:ArrayCollection = new ArrayCollection();

        public function RefreshNavigationEvent(type:String, bdp:ArrayCollection)
        {
            super(type);
            _breadcrumbDataProvider = bdp;
        }

        public function get breadcrumbDataProvider():ArrayCollection
        {
            return _breadcrumbDataProvider;
        }

        public override function clone():Event
        {
            return new RefreshNavigationEvent(type, _breadcrumbDataProvider);
        }
    }
}
