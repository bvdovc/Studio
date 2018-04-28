// ActionScript file


package {
	
	import sym.controller.SymmController;
	import sym.objectmodel.common.Constants;
	
	public  function is250F():Boolean
	{
		return SymmController.instance.vmaxConfiguration == Constants.VMAX_250F;
	}
	
}