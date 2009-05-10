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
package org.un.cava.birdeye.ravis.components.renderers.nodes {
	
	import flash.events.Event;
	
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.ravis.components.renderers.RendererIconFactory;
	
	/**
	 * This a basic icon itemRenderer for a node. 
	 * Images are sourced by directory path and file name.
	 * Based on icons by Paul Davey aka Mattahan (http://mattahan.deviantart.com/).
	 * All rights reserved. 
	 * */
	public class IconNodeRenderer extends EffectBaseNodeRenderer  {
		
		/**
		 * Default constructor
		 * */
		public function IconNodeRenderer() {
			super();
			//initZoom();
		}
	
		/**
		 * @inheritDoc
		 * */
		override protected function initComponent(e:Event):void {
			
			var img:UIComponent;

			/* initialize the upper part of the renderer */
			initTopPart();
			
			/* add an icon as specified in the XML, this should
			 * be checked */
			img = RendererIconFactory.createIcon(this.data.data.@nodeIcon,32);
			img.toolTip = this.data.data.@name; // needs check
			this.addChild(img);
						
			/* now add the filters to the circle */
			reffects.addDSFilters(img);
			 
			/* now the link button */
			initLinkButton();
		}
		
		/**
		 * We want to use a different effect here, so we
		 * override the initialisation.
		 * */
		/* we first test if it does not work with the
		 * plain ole zoom 
		override protected function initZoom():void {
			_zoom = new Resize();
			_zoom.widthFrom = 32;
			_zoom.heightFrom = 32;
			_zoom.widthTo = 64;
			_zoom.heightTo = 64;
		}
		*/
	}
}