// ActionScript file

package {
	import sym.controller.SymmController;
	import sym.objectmodel.common.Constants;
	
	public  function isImported():Boolean{
		return SymmController.instance.vmaxConfiguration == Constants.IMPORTED_CONFIGS;
	}
}