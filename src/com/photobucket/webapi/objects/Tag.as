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

package com.photobucket.webapi.objects
{
	import com.photobucket.webapi.interfaces.IContact;
	import com.photobucket.webapi.interfaces.IMedia;
	import com.photobucket.webapi.interfaces.ITag;

	/**
	 * Represents a Tag on photobucket 
	 * @author jlewark
	 * 
	 */
	public class Tag extends PhotobucketRemoteObject implements ITag
	{
		
		private var _tag:String;
		private var _top:Number;
		private var _left:Number;
		private var _right:Number;
		private var _bottom:Number;
		private var _url:String;
		private var _contact:IContact;
		private var _media:IMedia;
		private var invalid:Boolean;
		private var invalidContact:Boolean;
		
		public function Tag(data:XML)
		{
			super();
			_tag = data.@id;
			_tag = data.@tag;
			_left = data.@top_left_x;
			_top = data.@top_left_y;
			_bottom = data.@bottom_right_y;
			_right = data.@bottom_right_x;
			_url = data.@url;
		}
		
		public function get tag():String
		{
			return _tag;
		}

		
		public function set tag(value:String):void
		{
			if (value != _tag) {
				invalid = true;
				_tag = value;
			}	
		}
		
		
		public function get media():IMedia {
			return _media;
		}
		
		public function set media(value:IMedia):void {
			_media = value;		
		}
		
		public function get top():Number
		{
			return _top;
		}
		
		public function set top(value:Number):void
		{
			if (value != _top) {
				invalid = true;
				_top = value;
			}	
		}
		
		public function get left():Number
		{
			return _left;
		}
		
		public function set left(value:Number):void
		{
			if (value != _left) {
				invalid = true;
				_left = value;
			}	
		}
		
		public function get right():Number
		{
			return _right;
		}
		
		public function set right(value:Number):void
		{
			if (value != _right) {
				invalid = true;
				_right = value;
			}	
		}
		
		public function get bottom():Number
		{
			return _bottom;
		}
		
		public function set bottom(value:Number):void
		{
			if (value != _bottom) {
				invalid = true;
				_bottom = value;
			}	
		}
		
		public function get url():String
		{
			return _url;
		}
		
		public function set url(value:String):void
		{
			if (value != _url) {
				invalid = true;
				_url = value;
			}	
		}
		
		public function get contact():IContact
		{
			return _contact;
		}
		
		public function set contact(value:IContact):void {
			if (value != _contact) {
				invalidContact = true;
				invalid = true;
				_contact = value;
			}	
		}
		
		public function deleteTag():void {
			
		}
		
		public function commit():void {
			
		}
		
	}
}