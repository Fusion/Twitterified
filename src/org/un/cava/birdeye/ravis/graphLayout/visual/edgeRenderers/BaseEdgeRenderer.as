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
package org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers {
	
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IEdgeRenderer;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	import org.un.cava.birdeye.ravis.utils.Geometry;

	/**
	 * This is the default edge renderer, which draws the edges
	 * as straight lines from one node to another.
	 * */
	public class BaseEdgeRenderer implements IEdgeRenderer {
		
		/* since the graphics object would hardly change
		 * we can implement it as an attribute
		 */
		
		protected var _g:Graphics;
		
		/**
		 * Constructor sets the graphics object (required).
		 * @param g The graphics object to be used.
		 * */
		public function BaseEdgeRenderer(g:Graphics):void {
			_g = g;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get graphics():Graphics {
			return _g;
		}
		
		/**
		 * @private
		 * */
		public function set graphics(g:Graphics):void {
			_g = g;
		}
		
		
		/**
		 * The draw function, i.e. the main function to be used.
		 * Draws a straight line from one node of the edge to the other.
		 * The edge style can be specified as XML attributes to the Edge XML Tag
		 * 
		 * @inheritDoc
		 * */
		public function draw(vedge:IVisualEdge):void {
			
			/* first get the corresponding visual object */
			var fromNode:IVisualNode = vedge.edge.node1.vnode;
			var toNode:IVisualNode = vedge.edge.node2.vnode;
			
			/* apply the line style */
			applyLineStyle(vedge);
			
			/* now we actually draw */
			_g.beginFill(uint(vedge.lineStyle.color));
			_g.moveTo(fromNode.viewCenter.x, fromNode.viewCenter.y);			
			_g.lineTo(toNode.viewCenter.x, toNode.viewCenter.y);
			_g.endFill();
				
			/* if the vgraph currently displays edgeLabels, then
			 * we need to update their coordinates */
			if(vedge.vgraph.displayEdgeLabels) {
				vedge.setEdgeLabelCoordinates(labelCoordinates(vedge));
				//trace("BER: drawing edgelabel at:"+labelCoordinates(vedge).toString());
			}
		}
		
		/**
		 * @inheritDoc
		 * 
		 * In this simple implementation we put the label into the
		 * middle of the straight line between the two nodes.
		 * */
		public function labelCoordinates(vedge:IVisualEdge):Point {
			return Geometry.midPointOfLine(
				vedge.edge.node1.vnode.viewCenter,
				vedge.edge.node2.vnode.viewCenter
			);
		}
		
		/**
		 * Applies the linestyle stored in the passed visual Edge
		 * object to the Graphics object of the renderer.
		 * @param ve The VisualEdge object that the line style is taken from.
		 * */
		public function applyLineStyle(ve:IVisualEdge):void {
			/* apply the style to the drawing */
			if(ve.lineStyle != null) {
				_g.lineStyle(
					Number(ve.lineStyle.thickness),
					uint(ve.lineStyle.color),
					Number(ve.lineStyle.alpha),
					Boolean(ve.lineStyle.pixelHinting),
					String(ve.lineStyle.scaleMode),
					String(ve.lineStyle.caps),
					String(ve.lineStyle.joints),
					Number(ve.lineStyle.miterLimits)
				);
			}
		}
		
		/**
		 * This is a helper function for debugging, it marks
		 * the given spot with a small circle.
		 * @param p The location to be marked given as a Point.
		 * */
		public function markPoint(p:Point):void {
			//_g.beginFill(0);
			_g.drawCircle(p.x,p.y,10);
			//_g.endFill();
		}
		
	}
}