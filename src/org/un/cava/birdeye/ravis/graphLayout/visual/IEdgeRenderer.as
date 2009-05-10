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
package org.un.cava.birdeye.ravis.graphLayout.visual {

	import flash.display.Graphics;
	import flash.geom.Point;
	
	/**
	 * Interface for any Edge renderers,
	 * basically this is very simple as it just
	 * requires a draw() method.
	 * */
	public interface IEdgeRenderer {
		
		
		/**
		 * Access to the graphics object on which all 
		 * drawing takes place. Previously this was passed
		 * to draw(), but since that would hardly
		 * change at all, it makes more sense
		 * to implement it as an attribute of the
		 * edge renderers.
		 * @param g The graphics object to be used with the edge renderer.
		 * */
		function set graphics(g:Graphics):void;
		
		/**
		 * @private
		 * */
		function get graphics():Graphics;
		
		
		/**
		 * Draws an edge.
		 * Colours and linestyle can be provided through the XML object associated
		 * with the (v)edge.
		 * flexible.
		 * @param vedge The edge to draw, it needs to provide all the information required, i.e. locations.
		 * */
		function draw(vedge:IVisualEdge):void;
		
		/**
		 * Returns the coordinates of the label for the given edge.
		 * Different edge renderers might want to specify a different
		 * place where to put the label.
		 * @param edge The Edge where the label coordinates should refer to.
		 * @returns The coordinates where the edge renderer wants to place the label
		 * */
		function labelCoordinates(vedge:IVisualEdge):Point;
		
	}
}