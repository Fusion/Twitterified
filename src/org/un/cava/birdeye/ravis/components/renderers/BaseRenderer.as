/*
 * The MIT License
 *
 * Copyright (c) 2008
 * United Nations Office at Geneva
 * Center for Advanced Visual Analytics
 * http://cava.unog.ch
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package org.un.cava.birdeye.ravis.components.renderers {
	
	// Flash classes
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.containers.VBox;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.LinkButton;
	import mx.controls.Spacer;
	import mx.core.ContainerCreationPolicy;
	import mx.core.IDataRenderer;
	import mx.events.FlexEvent;
	
	/**
	 * This is the basic renderer class that more
	 * specific renderers (nodes or edgeLabels)
	 * can be derived from
	 * */
	public class BaseRenderer extends VBox {
	
		/**
		 * spacer component of this renderer
		 * */
		protected var sp:Spacer;
	
		/**
		 * potentical icon component
		 * */
		protected var rendIcon:Image;
		
		/**
		 * link button component
		 * */
		protected var lb:LinkButton;
		
		/**
		 * label component
		 * */
		protected var ll:Label;
	
	
		/**
		 * Base Constructor
		 * */
		public function BaseRenderer() {
			//super();
			this.creationPolicy = ContainerCreationPolicy.ALL;
			this.addEventListener(FlexEvent.CREATION_COMPLETE,initComponent);
			//this.addEventListener(FlexEvent.INIT_COMPLETE,adjustCoordinates);
			
			super();
		}
			
		/**
		 * Sets various values in the GlobalParams class
		 * to make them available for detail display in a separate
		 * area. Basically this gets executed when a node is selected
		 * This requires this item (being an IDataRenderer) to have meaningful
		 * data in its 'data' field. Specifically it requires that the object
		 * in data is a VisualNode, which in turn has a data property which
		 * then must contain the corresponding XML object from the Node
		 * definition.
		 * 
		 * However in this base class we only check the basics, no node
		 * or edge XML specifics.
		 * @param e The event that this handler was triggered from. Unused.
		 * */
		protected function getDetails(e:Event):void {
			// trace("Show Details");
			
			/* check if we have a data object */
			if(this.data == null) {
				trace("Data object of this Renderer is null. This should not happen, probably wrong usage");
				return;
			}
			
			/* if yes, it should be an IVisualNode, but actually we don't care
			 * we just need to make sure it also has a data object */
			if(!(this.data is IDataRenderer)) {
				trace("Data object is no IDataRenderer");
				return;
			}
			
			/* and it should not be null */
			if(this.data.data == null) {
				trace("Data object of data object is null");
				return;
			} 
		}
		
		/**
		 * Full initialisation of the renderer component, triggered
		 * after reception of the creation complete event.
		 * This method should be overriden by NodeRenderers
		 * which are more specific.
		 * @param e the creation complete event (unused).
		 * */
		protected function initComponent(e:Event):void {
			
			/* initialize the upper part of the renderer */
			initTopPart();
			
			/* in between could be other components added
			 * like images */
			 
			/* now the link button */
			initLinkButton();
			
			/* or the label both would be overkill */
			//initLabel();
		}

		/**
		 * This method initialises the "upper" part of
		 * the renderer and the general parts, spacer 
		 * */
		protected function initTopPart():void {
			
			/* set styles */
			this.setStyle("horizontalAlign","center");
			
			/* create and add a spacer */
			sp = new Spacer();
			sp.height = 18;
			this.addChild(sp);
		}

		/**
		 * This method is required to readjust the coordinates
		 * after initialised if we have a centered renderer
		 * parent object.
		 * This should only be called through the initComponent
		 * event handler.
		 * */
		/*
		protected function adjustCoordinates(e:Event):void {
			if(this.data is IVisualItem) {
				if((this.data as IVisualItem).centered) {
					this.x -= (this.width / 2.0);
					this.y -= (this.height / 2.0);
				}
			}
		}
		*/

		/**
		 * this methods initialises and adds a 
		 * link button to the renderer
		 * */
		protected function initLinkButton():LinkButton {

			lb = new LinkButton();
			
			lb.width = 100;

			lb.toolTip = "Click to View Details";
			lb.setStyle("fontWeight","normal");
			lb.setStyle("rollOverColor",0xcccccc);
			
			lb.addEventListener(MouseEvent.CLICK, getDetails);
			
			this.addChild(lb);
			return lb;
		}
		
		/**
		 * this methods initialises and adds a label
		 * with visible text, if the node is selected
		 * */
		protected function initLabel():Label {

			ll = new Label();

			/* some hardcoded values for now */
			ll.width = 75;
			ll.height = 11;
			ll.setStyle("textAlign","center");
			ll.setStyle("fontSize",10);
			
			this.addChild(ll);
			
			/* not sure yet how to incoroporate this
			if (GlobalParams.visualNodeLabel.selected==true){
				nodeText.visible=true
			} else {
				nodeText.visible=false
			}
			*/
			return ll;
		}
	}
}

