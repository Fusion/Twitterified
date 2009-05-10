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
	
	import mx.collections.ArrayCollection;
	
	[Event(name="mediaUpdated", type="flash.events.Event")]
	[Event(name="titleUpdated", type="flash.events.Event")]
	[Event(name="descriptionUpdated", type="flash.events.Event")]
	
	/**
	 * Bindable Interface for acessing a media. 
	 * @author jlewark
	 * 
	 */
	public interface IMedia extends IEventDispatcher
	{
		[Bindable(event="mediaUpdated")]
		function get url():String;
		[Bindable(event="mediaUpdated")]
		function get thumb():String;
		[Bindable(event="mediaUpdated")]
		function get name():String;
		[Bindable(event="mediaUpdated")]
		function get browseURL():String;
		[Bindable(event="mediaUpdated")]
		function get uploaddate():String;		
		[Bindable(event="mediaUpdated")]
		function get type():String;
		[Bindable(event="titleUpdated")]
		function get title():String;
		function set title(value:String):void;
		[Bindable(event="descriptionUpdated")]
		function get description():String;
		function set description(value:String):void;
		function get album():IAlbum;
		function set album(value:IAlbum):void;
		[Bindable(event="mediaUpdated")]
		function get tags():ArrayCollection;
		function addTag(tag:ITag):void;
		function moveMedia(toAlbum:IAlbum):void;
		function deleteMedia():void;
		function commit():void;
	}
}