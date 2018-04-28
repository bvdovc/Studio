package sym.viewer.mobile.validation
{
	import flash.geom.Point;
	
	import mx.controls.ToolTip;
	import mx.core.FlexGlobals;
	import mx.core.IUIComponent;
	import mx.managers.ToolTipManager;
	
	import spark.components.TextInput;
	import spark.components.gridClasses.IGridItemEditor;
	
	import sym.objectmodel.common.EnginePort;
	import sym.viewer.mobile.views.ConfigurationView;
	import sym.viewer.mobile.views.components.selectionList.SelectionComponentItemRenderer;
	
	/**
	 * Class provides force displaying of custom toolTips   
	 * 
	 */	
	public class CustomToolTip extends ToolTip
	{
		// flag toolTip position is changed
		public static var positionChanged:Boolean = false;
		
		public static const NORMAL_TIP:uint = 1;
		public static const ERROR_TIP:uint = 2;
		
		// error tip border style
		public static const ERROR_TIP_RIGHT:String = "errorTipRight";
		public static const ERROR_TIP_ABOVE:String = "errorTipAbove";
		public static const ERROR_TIP_BELOW:String = "errorTipBelow";
		
		private var _toolTip:ToolTip = null;
		
		private var _type:int = -1;
		
		private var _target:Object;
		
		/**
		 * Creates an toolTip instance of CustomToolTip class with specified text message and specified position to be placed in.<br/>
		 * Error toolTip isn't visible until appropriate display mettod is called.
		 * @param msg indicates text to display as toolTip message
		 * @param errorTipBorderStyle indicates the border style of an toolTip. 
		 * If set this is an Error toolTip. Default value is <code> errorTipRight </code> which positions toolTip right of the error target
		 * @param target indicates object on which the ToolTip appears
		 * @param itemEditor indicates item editor if user is in DataGrid edit mode
		 * 
		 */		
		public function CustomToolTip(msg:String,
								 target:Object,
								 errorTipBorderStyle:String = ERROR_TIP_RIGHT,
								 itemEditor:IGridItemEditor = null)
		{
			super();
			
			_type = errorTipBorderStyle ? ERROR_TIP : NORMAL_TIP;
			_target = target;
			
			var position:Point = startPosition(target, itemEditor);
			
			// cretaes new ToolTip instance
			_toolTip = ToolTipManager.createToolTip(
				msg, 
				position.x, 
				position.y, 
				errorTipBorderStyle, 
				IUIComponent(target)) as ToolTip;
			
			if (_type == ERROR_TIP)
				_toolTip.visible = false;
		}

		/**
		 * Gets toolTip type - error/normal tip 
		 * @return 
		 * 
		 */		
		public function get type():int
		{
			return _type;
		}

		public function get target():Object
		{
			return _target;
		}
		
		public function get currentToolTip():ToolTip
		{
			return  _toolTip;
		}
		
		/**
		 * ToolTip start position  
		 * @param target indicates object for which tip is associated
		 * @param itemEditor indicates DataGrid item editor
		 * @return new Point instance
		 * 
		 */		
		private function startPosition(target:Object, itemEditor:IGridItemEditor = null):Point
		{
			var point:Point;
			
			if (itemEditor)
			{
				point = itemEditor.dataGrid.localToGlobal(new Point(itemEditor.x, itemEditor.y));
			}
			else 
			{
				point = target.localToGlobal(new Point());
			}
			
			point = FlexGlobals.topLevelApplication.globalToLocal(point);
			
			if (type == ERROR_TIP)
			{
				if (itemEditor)
				{
					point.x += target.x;
					point.y -= itemEditor.dataGrid.scroller.verticalScrollBar.viewport.verticalScrollPosition;
				}
				else
				{
					point.x += target.width + 5;
				}
			}
			
			return point;
		}
		
		/**
		 * Displays custom toolTip .<br/>
		 * @param currentTarget indicates target component
		 * @param message indicates text to be displayed
		 * @param view indicates main app view - Configuration View reference
		 *
		 */
		public function display(currentTarget:Object = null, message:String = null, view:ConfigurationView = null):void
		{
			if (positionChanged)
			{
				if (currentTarget)
					_target = currentTarget;
					
				reSetPosition(target);
				
				positionChanged = false;
			}
			
			currentToolTip.visible = true;
			
			if (message)
				currentToolTip.text = message;
			
			// just for normal tip
			if (type == NORMAL_TIP)
			{
				var startPosition:Point = new Point(currentToolTip.x, currentToolTip.y);
				var mainContainerPos:Point = view.mainContainer.localToGlobal(new Point());
				var fitWithinBorder:Boolean = true;
				
				// Engine Module toolTip
				if (target is SelectionComponentItemRenderer)
				{
					// place toolTip in the top-middle of engine module
					currentToolTip.x += (target.width - currentToolTip.width) / 2;
					
					// if label can't fit within module
					if (currentToolTip.width > 0.5 * target.width || currentToolTip.height > 0.5 * target.height)
					
						// move above 
						currentToolTip.y -= currentToolTip.height;
					
					// if some part of toolTip content isn't visible right of the module
					if (currentToolTip.x + currentToolTip.width > view.parentContainer.width + view.mainContainer.gap + view.mainContainer.paddingRight)
					{
						// move to the left side
						currentToolTip.x = startPosition.x - currentToolTip.width;
						currentToolTip.y = startPosition.y + (target.height - currentToolTip.height) / 2;
					}
					// if some part of toolTip content isn't visible left of the module
					else if (currentToolTip.x < mainContainerPos.x)
					{
						// move to the right side
						currentToolTip.x = startPosition.x + target.width;
						currentToolTip.y = startPosition.y + (target.height - currentToolTip.height) / 2;			
					}
					
					return;
				}
				
				// if selected target component is out of display stage
				// hide toolTip
				if (startPosition.y + target.height * view.currentComponent.scaleY < view.titleBarComponent.height + view.toolBarComponent.height ||
					startPosition.x + target.width * view.currentComponent.scaleX < mainContainerPos.x ||
					startPosition.x >= view.parentContainer.width + view.mainContainer.gap + view.mainContainer.paddingRight ||
					startPosition.y >= view.titleBarComponent.height + view.toolBarComponent.height + view.mainContainer.height)
				{
					hide();
				}
				
				// place toolTip in the top-middle of selected border
				currentToolTip.x += (target.width * view.currentComponent.scaleX - currentToolTip.width) / 2;
				
				// if label can't fit within selection border
				if (currentToolTip.width > 0.5 * target.width * view.currentComponent.scaleX || 
					currentToolTip.height > 0.5 * target.height * view.currentComponent.scaleY)
				{
					// move above the border
					currentToolTip.y -= currentToolTip.height;
					fitWithinBorder = false;
				}
				
				// if some part of toolTip content is above main container
				if (currentToolTip.y <= view.titleBarComponent.height + view.toolBarComponent.height)
				{
					if (fitWithinBorder)
					{
						// move to the first point on target component at which all toolTip content is visible
						currentToolTip.y = view.titleBarComponent.height + view.toolBarComponent.height;
					}
					else
					{
						// move to bottom, beneath the selected border
						currentToolTip.x = startPosition.x + (target.width * view.currentComponent.scaleX - currentToolTip.width) / 2;
						currentToolTip.y = startPosition.y + target.height * view.currentComponent.scaleY;
					}
				}
				
				// if some part of toolTip content isn't visible right of the border
				if (currentToolTip.x + currentToolTip.width > view.parentContainer.width + view.mainContainer.gap + view.mainContainer.paddingRight)
				{
					// move to the left side of the selected border
					currentToolTip.x = startPosition.x - currentToolTip.width;
					currentToolTip.y = startPosition.y + (target.height * view.currentComponent.scaleY - currentToolTip.height) / 2;
				}
					// if some part of toolTip content isn't visible left of the border
				else if (currentToolTip.x < mainContainerPos.x)
				{
					// move to the right side of the selected border
					currentToolTip.x = startPosition.x + target.width * view.currentComponent.scaleX;
					currentToolTip.y = startPosition.y + (target.height * view.currentComponent.scaleY - currentToolTip.height) / 2;			
				}
			}
		}
		
		/**
		 * Sets new position for toolTip
		 * @param target indicates object on which toolTip appears
		 * 
		 */		
		public function reSetPosition(target:Object):void
		{			
			var start:Point = startPosition(target);
			
			currentToolTip.x = start.x;
			currentToolTip.y = start.y;
		}
		
		/**
		 * Hides toolTip from being displayed
		 * @param target indicates object on which toolTip appears. If set, removes red border around object indicating error
		 */		
		public function hide(target:TextInput = null):void
		{
			if (this.currentToolTip && this.currentToolTip.visible)
				this.currentToolTip.visible = false;
			
			// optional - removes red border around target object
			if (target)
				target.errorString = null;
		}
		
		/**
		 * Destroys toolTip instance
		 */		
		public function destroy():void
		{
			if (this.currentToolTip)
				ToolTipManager.destroyToolTip(this.currentToolTip);
		}
		
		/**
		 * Force hidding current toolTip on the display stage 
		 * 
		 */		
		public static function hideCurrent():void
		{
			(ToolTipManager.currentToolTip as ToolTip).visible = false;
		}
	}
}