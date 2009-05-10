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
	import flash.net.FileReference;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * Bindable interface for an album object.  It is possbile that more then one album implmentation is available. 
	 * @author jlewark
	 * 
	 */
	public interface IAlbum extends IEventDispatcher
	{

		[Bindable(event="complete")]
		function get url():String;
		[Bindable(event="complete")]
		function get name():String;
		[Bindable(event="complete")]
		function get photo_count():int;
		[Bindable(event="complete")]
		function get subalbum_count():int;
		[Bindable(event="complete")]
		function get video_count():int;
		[Bindable(event="subAlbumsUpdated")]
		function get sub_albums():ArrayCollection;
		[Bindable(event="complete")]
		function get media():ArrayCollection;
		[Bindable(event="complete")]
		function get images():ArrayCollection;
		[Bindable(event="complete")]
		function get video():ArrayCollection;
		[Bindable(event="privacyUpdated")]
		function get privacy():String;
		function set privacy(value:String):void;
		[Bindable(event="complete")]
		function get path():String;
		function get parent():IAlbum;
		function set parent(value:IAlbum):void;
		[Bindable(event="fileUploaded")]
		function uploadFile(file:FileReference, type:String = "image", title:String = null, description:String = null):void;
		[Bindable(event="subAlbumCreated")]
		function createSubAlbum(name:String):void;
		function commit():void;
	}
}