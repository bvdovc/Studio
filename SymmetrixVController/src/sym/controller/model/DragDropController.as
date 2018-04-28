package sym.controller.model
{

    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    
    import mx.collections.ArrayCollection;
    import mx.core.UIComponent;
    
    import spark.components.Group;
    import spark.components.Image;
    
    import sym.controller.events.ComponentDragDropEvent;
    import sym.objectmodel.common.ComponentBase;

    /**
     * Controller that manages drag drop functionality
     */
    public class DragDropController extends EventDispatcher
    {
        /**
         * Enable drag drop functionality
         */
        public var dragEnabled:Boolean;

        /**
         * Container that holds dragged ui component (image)
         */
        public var container:Group;

        /**
         * ComponentBase being dragged
         */
        public var component:ComponentBase;

        /**
         * Dragged ui compoennt (Image is currently used)
         */
        public var dragImage:UIComponent;
		
		/**
		 * highlighted slot borders for dragged component
		 */		
		public var highlightedBorders:ArrayCollection = new ArrayCollection(); 
		
        /**
         * Determines if draggins is in progress
         */
        public var isDragging:Boolean;
        
        /**
         * True when user starts dragging component from engine slot (Move/Swap or Remove action) 
         */        
        public var isMoveOrRemoveAction:Boolean;

        /**
         * Start dragging
         * @param image indicates dragging component image
         * @param component indicates dragging component
         * @param isMoveOrRemove indicates swap or remove action. Default is <code>false</code> - remove action
         *
         */
        public function startDrag(image:Image, component:ComponentBase, isMoveOrRemove:Boolean = false):void
        {
            isDragging = true;
            isMoveOrRemoveAction = isMoveOrRemove;
            dragImage = image;
            dragImage.x = container.mouseX - dragImage.width / 2;
            dragImage.y = container.mouseY - dragImage.height / 2;
            this.component = component;
            container.removeAllElements();
            container.addElement(dragImage);
            container.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			container.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);

            dragImage.x = container.mouseX - dragImage.width / 2;
            dragImage.y = container.mouseY - dragImage.height / 2;

			dispatchEvent(new ComponentDragDropEvent(ComponentDragDropEvent.COMPONENT_DRAG_STARTED, component, isMoveOrRemoveAction));
			
            dragImage.startDrag();
        }

		/**
		 * While dragging, check drag image position
		 * @param ev MouseEvent.MOUSE_MOVE
		 * 
		 */		
		private function mouseMoveHandler(ev:MouseEvent):void
		{
			this.dispatchEvent(new ComponentDragDropEvent(ComponentDragDropEvent.COMPONENT_MOVED, component, isMoveOrRemoveAction, NaN, NaN));
		}
		
        /**
         * Stop drag when mouse is up
         * @param event
         *
         */
        private function mouseUpHandler(event:MouseEvent):void
        {
            stopDrag();
        }

        /**
         * Stop dragging method
         * <p>Dispatches ComponentDragDropEvent.COMPONENT_DROPPED event if dragging is finished</p>
         */
        public function stopDrag():void
        {
            if (isDragging)
            {
                isDragging = false;

                container.removeAllElements();

                dispatchEvent(new ComponentDragDropEvent(ComponentDragDropEvent.COMPONENT_DROPPED, component, isMoveOrRemoveAction, container.mouseX, container.mouseY));

			}
        }
		
    }
}
