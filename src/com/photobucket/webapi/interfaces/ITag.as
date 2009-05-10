/* 
The License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 */
 
package com.photobucket.webapi.interfaces
{
	import flash.events.IEventDispatcher;
	
	/**
	 * Interface for accessing a Tag 
	 * @author jlewark
	 * 
	 */
	public interface ITag extends IEventDispatcher
	{
		
		function get id():String;
		function get tag():String;
		function set tag(value:String):void;
		function get top():Number;
		function set top(value:Number):void;
		function get left():Number;
		function set left(value:Number):void;
		function get right():Number;
		function set right(value:Number):void;
		function get bottom():Number;
		function set bottom(value:Number):void;
		function get url():String;
		function set url(value:String):void;
		function get contact():IContact;
		function get media():IMedia;
		function set media(value:IMedia):void;
		function commit():void;

	}
}