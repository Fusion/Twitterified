/* 
 * The MIT License
 *
 * Copyright (c) 2007 The SixDegrees Project Team
 * (Jason Bellone, Juan Rodriguez, Segolene de Basquiat, Daniel Lang).
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

package org.un.cava.birdeye.ravis.graphLayout.layout {

	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.data.IGraph;
	import org.un.cava.birdeye.ravis.graphLayout.data.Graph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.data.IGTree;
	import org.un.cava.birdeye.ravis.graphLayout.visual.VisualGraph;
	import org.un.cava.birdeye.ravis.utils.Geometry;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.MouseEvent;
	
	/**
	 * This is an implementation of the circular layout -
	 * all visible nodes are arranged in a circle
	 * 
	 * @author Nitin Lamba
	 * */
	public class CircularLayouter extends AnimatedBaseLayouter {
		/**
		 * The radius of the layout
		 */
		private var _radius:Number = 200;
		
		/* The initial starting angle of the layout
	   */
		private var _phi:Number = 0;
		
		/**
		 * this holds the data for a layout drawing.
		 * */
		private var _currentDrawing:BaseLayoutDrawing;
		
		/**
		 * The constructor only initialises some data structures.
		 * @inheritDoc
		 * */
		public function CircularLayouter(vg:IVisualGraph = null):void {
			super(vg);
			animationType = ANIM_RADIAL; // inherited
			_currentDrawing = null;
			
			/* Reset the origin */
			(vg as VisualGraph).origin.x = 0;
			(vg as VisualGraph).origin.y = 0;
			
			initDrawing();
		}

		/**
		 * @inheritDoc
		 * */
		override public function resetAll():void {
			super.resetAll();
			initDrawing();
			_layoutChanged = true;			
		}

		/**
		 * This main interface method computes and
		 * and executes the new layout.
		 * @return Currently the return value is not set or used.
		 * */
		override public function layoutPass():Boolean {
			//trace("layoutPass called");
			
			if(!_vgraph) {
				trace("No Vgraph set in CircularLayouter, aborting...");
				return false;
			}
			
			/* nothing to do if we have no nodes */
			if(_graph.noNodes < 1) {
				return false;
			}
			
			/* if there is a timer, we have to stop it to
			 * prevent inconsistencies */
			killTimer();
								
			/* need to see where how we could get a clear
			 * list of situation how to deal with hab
			 * if the layout was changed (or any parameter)
			 * we have to reinit the model */
			if(_layoutChanged) {
				initDrawing();
			}

			/* this is complicated. */
			if(_autoFitEnabled) {
				/* we calculate the best radius of the circle */
				calculateAutoFit();
			}

			/* do a calculation pass */
			calculateNodes()
		
			/* reset animation cycle */
			resetAnimation();
			
			/* start the animation, does also the commit */
			startAnimation();		
		
			//_vgraph.refresh();
			_layoutChanged = true;
			return true;
		}
	
		/**
		 * @inheritDoc
		 * */
		[Bindable]
		override public function get linkLength():Number {
			return _radius;
		}
		/**
		 * @private
		 * */
		override public function set linkLength(rr:Number):void {
			_radius = rr;
		}
		
		/**
		 * Access the starting angle of the layout
		 * */
		[Bindable]
		public function get phi():Number {
			return _phi
		}
		/**
		 * Set the starting angle of the layout. Modifying this 
		 * value rotates the layout by a given angle
		 * */
		public function set phi(p:Number):void {
			_phi = p;
		}
		
		/* private methods */
		 
		/**
		 * @internal
		 * Create a new layout drawing object, which is required
		 * on any root change (and possibly during other occasions)
		 * and intialise various parameters of the drawing.
		 * */
		private function initDrawing():void {
			_currentDrawing = new BaseLayoutDrawing();
			
			/* Also set the object also in the BaseLayouter */
			super.currentDrawing = _currentDrawing;
			
			_currentDrawing.originOffset = _vgraph.origin;
			_currentDrawing.centerOffset = _vgraph.center;
			_currentDrawing.centeredLayout = true;
		}
		
		/**
		 * @internal
		 * Calculate the polar angles of the nodes */
		private function calculateNodes():void {
			
			/* needed for the calculation */
			var phi:Number;
			var vn:IVisualNode;
			var ni:INode;
			
			var visVNodes:Dictionary;
			var i:int;
			
			visVNodes = _vgraph.visibleVNodes;
			var nn:int = _vgraph.noVisibleVNodes;
			i = 1;
			for each(vn in visVNodes) {
				
				/* position only visible nodes */
				if(vn == null) {
					throw Error("Node was null");
				}
				
				/* position only visible nodes */
				if(vn.isVisible) {
        			phi = _phi + (360 * i) / nn;
					phi = Geometry.normaliseAngleDeg(phi);
					
					/* set the values */
					ni = vn.node;
					_currentDrawing.setPolarCoordinates(ni, _radius, phi);
					//trace("CircularLayouter: node set to (r, phi) = " + _radius + ", " + phi);
				
					/* set the orientation into the visual node */
					vn.orientAngle = phi;
				}
				i += 1;
			}
			//trace("CircularLayouter: nodes set to new (r, phi)...");
			return;
		}


		/**
		 * @internal
		 * Do all the calculations required for autoFit
		 * */
		private function calculateAutoFit():void {
			_radius = Math.min(_vgraph.width,_vgraph.height) / 2.0 - DEFAULT_MARGIN;
		}
	}
}