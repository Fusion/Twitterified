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

	[Event(name="userUpdated", type="flash.events.Event")]	
	/**
	 * Bindable interface for accessing a user 
	 * @author jlewark
	 * 
	 */
	public interface IUser extends IEventDispatcher
	{
		[Bindable(event="userUpdated")]
		function get id():String;
		function get server():String;
		[Bindable(event="userUpdated")]
		function get username():String;
		[Bindable(event="userUpdated")]
		function get album_url():String;
		function get defaultImageUploadSize():String;
		function set defaultImageUploadSize(value:String):void;
		function get contacts():ArrayCollection;
		function getRecentMedia(type:String = "all", number:Number = 20, page:Number = 1):ArrayCollection;
		function getRootAlbum():IAlbum;
	}
}