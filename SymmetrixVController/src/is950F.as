// ActionScript file

package {
	
	import sym.controller.SymmController;
	import sym.objectmodel.common.Constants;
	
	public  function is950F():Boolean
	{
		return SymmController.instance.vmaxConfiguration == Constants.VMAX_950F;
	}
	
}