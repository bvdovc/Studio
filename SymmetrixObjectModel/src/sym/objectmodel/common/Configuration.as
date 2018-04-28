package sym.objectmodel.common
{
	
	import sym.objectmodel.utils.CapacityNumberFormatter;
	
	/**
	 * represents single symm configuration
	 */
	public class Configuration extends ComponentBase
	{ 
		protected var _factory:Object;
		public var daeType:int = 0;		
		protected var _noEngines:int = 0;
		protected var _dispersed:int = -1;
		protected var _dispersed_m:Array = [-1];
		protected var _noStorageBay:int = 0;
		protected var _tierSolution:int = 0;
		protected var _totCapacity:Number = 0;
		
		protected var _driveType:String;
		protected var _numberOfDrives:int = 0;
		
		protected var _osUsableCapacity:Number = 0;
		protected var _mfUsableCapacity:Number = 0;
		protected var _activesAndSpares:int = 0;
		protected var _enginePorts:int = 0;
		protected var _engineModules:int = 0;
		
		protected var _noD15:int = 0;
		protected var _noVanguard:int = 0;
		
		protected var _noVoyager:int = 0;
		protected var _noViking:int = 0;
		protected var _noTabasco:int = 0;
		protected var _noNebula:int = 0;
		
		protected var _noPortsModulesChanged:Boolean = true; //holds true or false depends if number of Ports and Modules is changed
			
		public function Configuration(id:String)
		{
			super(id, null, null);
		}
		
		public function get osUsableCapacity():Number{
			return _osUsableCapacity;
		}
		
		public function set osUsableCapacity(value:Number):void{
			_osUsableCapacity = value;
		}
		
		public function get mfUsableCapacity():Number{
			return _mfUsableCapacity;
		}
		
		public function set mfUsableCapacity(value:Number):void{
			_mfUsableCapacity = value;
		}
					
		/**
		 * Provides information for number of actual drives
		 * @return toal drive count
		 * 
		 */		
		public function get activesAndSpares():int{
			return _activesAndSpares;
		}
		
		public function set activesAndSpares(value:int):void{
			_activesAndSpares = value;
		}
		
		public function get enginePorts():int{
			return _enginePorts;
		}
		
		public function set enginePorts(value:int):void{
			_enginePorts = value;
		}
		// driveType
		public function get driveType():String{
			return _driveType;
		}
		
		public function set driveType(value:String):void{
			_driveType = value;
		}
		// numberOfDrives
		public function get numberOfDrives():int{
			return _numberOfDrives;
		}
		
		public function set numberOfDrives(value:int):void{
			_numberOfDrives = value;
		}
			
		public function get engineModules():int{
			return _engineModules;
		}
		
		public function set engineModules(value:int):void{
			_engineModules = value;
		}
		
		public function get totalDaeNumber():int
		{
			return noD15 + noVanguard;
		}
		
		public function get noEngines():int {
			return _noEngines;
		}
		
		public function set noEngines(value:int):void {
			_noEngines = value;
		}
		
		public function get dispersed():int
		{
			return _dispersed;
		} 
		
		public function set dispersed(d:int):void
		{
			_dispersed=d;
		}
		
		public function get dispersed_m():Array
		{
			return _dispersed_m;
		} 
		
		public function set dispersed_m(d:Array):void
		{
			_dispersed_m=d;
		}
		
		public function get tierSolution():int
		{
			return _tierSolution;
		}
		
		public function set totCapacity(value:Number):void
		{
			_totCapacity = value;
		}
		
		public function get totCapacity():Number
		{
			return _totCapacity;
		}
		
		public function set tierSolution(value:int):void
		{
			_tierSolution = value;
		}
		
		public function get factory():Object{
			return _factory;
		}
		
		public function set factory(fact:Object):void{
			_factory = fact;
		}
		/**
		 * Getter and setter that return true or false if port configuration is changed
		 */
		public function get noPortsModulesChanged():Boolean
		{
			return _noPortsModulesChanged;
		}
	
		public function set noPortsModulesChanged(value:Boolean):void
		{
			_noPortsModulesChanged = value;
		}
		
		/**
		 * Gets usable capacity in apropriate format
		 */
		public function  formattedCapacity(value:Number):String
		{
			var capacityFormatter:CapacityNumberFormatter = new CapacityNumberFormatter();
			
			return capacityFormatter.format(value);
		}
		
		/**
		 * Calculates max drives number in configuration 
		 * @return 
		 * 
		 */		
		public function get maxDrivesNumber():int {
			return  noD15 * Drive.D15_DRIVES_NUMBER + noVanguard * Drive.VANGURAD_DRIVES_NUMBER;
		}
		
		public function get noD15():int{
			if(_noD15 > 0) return _noD15;
			
			for each(var b:Bay in children){
				for each(var child:ComponentBase in b.children){
					if(child is D15){
						_noD15++;
					}
				}
			}
			return _noD15;
		}
		
		public function set noD15(d15Number:int):void{
			_noD15 = d15Number;
		}
		
		public function get noVanguard():int{
			if(_noVanguard > 0) return _noVanguard;
			
			for each(var b:Bay in children){
				for each(var child:ComponentBase in b.children){
					if(child is Vanguard){
						_noVanguard++;
					}
				}
			}
			return _noVanguard;
		}
		
		public function set noVanguard(vanguardNumber:int):void{
			_noVanguard = vanguardNumber;
		}
		
		public function get noVoyager():int{
			if(_noVoyager > 0) return _noVoyager;
			
			for each(var b:Bay in children){
				for each(var child:ComponentBase in b.children){
					if(child is Voyager){
						_noVoyager++;
					}
				}
			}
			return _noVoyager;
		}
		
		public function set noVoyager(voyagerNumber:int):void{
			_noVoyager = voyagerNumber;
		}
		
		public function set noTabasco(tabascoNumber:int):void{
			_noTabasco = tabascoNumber;
		}
		
		public function get noTabasco():int
		{
			if(_noTabasco > 0) return _noTabasco;
			
			for each(var b:Bay in children)
			{
				for each(var child:ComponentBase in b.children){
					if(child is Tabasco){
						_noTabasco++;
					}
				}
				
			}
			return _noTabasco;
		}
		
		public function set noNebula(nebulaNumber:int):void{
			_noNebula = nebulaNumber;
		}
		
		public function get noNebula():int
		{
			if(_noNebula > 0)
				return _noNebula;
			
			for each(var b:Bay in children)
			{
				for each(var child:ComponentBase in b.children)
				{
					if(child is Nebula){
						_noNebula++;
					}
				}
			}
			return _noNebula;
		}
		
		public function get noViking():int{
			if(_noViking > 0) return _noViking;
			
			for each(var b:Bay in children){
				for each(var child:ComponentBase in b.children){
					if(child is Viking){
						_noViking++;
					}
				}
			}
			return _noViking;
		}
		
		public function set noViking(vikingNumber:int):void{
			_noViking = vikingNumber;
		}
		
		public function get countStorageBay():int {
			var cStorageBay:int=0;
			
			for each (var bay:Bay in children)
			{
				if (bay.isStorageBay)
				{
					cStorageBay++;
				}
			}
			
			return cStorageBay;
		}
		
		public function get countSystemBay():int {
			var cSystemBay:int=0;
			
			for each (var bay:Bay in children)
			{
				if (bay.isSystemBay)
				{
					cSystemBay++;
				}
			}
			
			return cSystemBay;
		}
		
		public function set noStorageBay(value:int):void
		{
			_noStorageBay = value;
		}
		
		public function get noStorageBay():int
		{
			return _noStorageBay;
		}
		
		/**
		 * gets bay by <code>id</code> and <code>index</code> position
		 * @param id of bay
		 * @param index of bay, use for system bay
		 * @return bay or null if not found
		 * 
		 */
		public function findBay(id:String, index:int = 0):Bay
		{
			var sBay:Bay = null;
			if (countStorageBay > 0)
			{
				for each (var bay1:Bay in this.children)
				{
					if (bay1.id == id)
					{
						sBay=bay1;
						break;
					}
				}
			}
			else
			{
				for each (var bay2:Bay in this.children)
				{
					if (bay2.id == id && bay2.position.index == index)
					{
						sBay=bay2;
						break;
					}
				}
			}
			
			return sBay;
		}
		
		public function get calculatedId():String 
		{ 
			var calcId:String = "";
			for each (var bay:Bay in children) 
			{
				calcId += bay.countDAEs + "_";
			}
			calcId += noEngines;
			
			return calcId;
		}
		
		public function get structureId():String{
			return calculatedId + "_" + noD15 + "_" + noVanguard + "_" + countStorageBay + "_" + dispersed;
		}
		
		/**
		 * Gets all DAEs behind given engine
		 * @param engineIndex
		 * @return dae array
		 */        
		public function getDAEsBehindEngine(engineIndex:int, daeType:int = 0):Array
		{
			var daeArray:Array = new Array();
			for each(var ch:ComponentBase in children)
			{
				if(ch is Bay)
				{
					for each(var dae:ComponentBase in ch.children)
					{
						if(dae is DAE && (dae as DAE).parentEngine == engineIndex && (daeType == 0 || dae.type == daeType))
						{
							daeArray.push(dae);
						}
					}
				}
			}
			return daeArray;
		}
		
		/**
		 * Gets specific Engine by given index
		 * @param index indicates engine index
		 * @return Engine component
		 * 
		 */		
		public function getEngineByIndex(index:int):ComponentBase
		{
			for each (var bay:Bay in this.children)
			{
				for each (var childComp:ComponentBase in bay.children)
				{
					if (childComp.isEngine && childComp.id == index.toString())
					{
						return childComp;
					}
				}
				
			}
			// not supposed to happen 
			// case when engine with specified index is not found
			return null;
		}
	} 
}  
