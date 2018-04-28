package {
	
	import sym.controller.SymmController;
	import sym.objectmodel.common.Constants;
	
	public  function isPM8000():Boolean
	{
		return SymmController.instance.vmaxConfiguration == Constants.PowerMax_8000;
	}
	
}// ActionScript file