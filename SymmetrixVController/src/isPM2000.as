package {
	
	import sym.controller.SymmController;
	import sym.objectmodel.common.Constants;
	
	public  function isPM2000():Boolean
	{
		return SymmController.instance.vmaxConfiguration == Constants.PowerMax_2000;
	}
	
}