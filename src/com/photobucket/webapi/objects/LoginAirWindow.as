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
	import flash.events.Event;
	
	import mx.controls.HTML;
	import mx.core.Window;
	import mx.events.FlexEvent;
	import mx.rpc.IResponder;
	import com.photobucket.webapi.service.PhotobucketException;

	/**
	 * Login Window that handles the track of the user authorization process and is used by LoginAir 
	 * @author jlewark
	 * 
	 */
	public final class LoginAirWindow extends Window
	{
		private var _url:String;
		private var html:HTML;
		public var result:Function;
		public var fault:Function;
		
		public function LoginAirWindow(url:String)
		{
			super();
			_url = url;
			this.title = "Welcome to Photobucket";
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreateComplete);
		}
	
		override public function open(openWindowActive:Boolean=true):void {
			this.width = this.windowWidth;
			this.height = this.windowHeight;
			this.visible = false;
			super.open(openWindowActive);
		}
		
		private function onCreateComplete(event:Event):void {
			html = new HTML();
			this.addChild(html);
			html.percentHeight = 100;
			html.percentWidth = 100;
			html.addEventListener(Event.LOCATION_CHANGE, onLocationChange);
			html.addEventListener(Event.COMPLETE, onHTMLComplete);
			callLater(later);
		}

		private function onHTMLComplete(event:Event):void {
			if (html.location.indexOf("status=done") < 0) {
				this.visible = true;
			}
		}

		private function later():void {
			html.location = _url;	
		}
		
		private function onLocationChange(event:Event):void {
			html.visible = true;
			if (html.location.indexOf("status=denied") > 0) {
				fault(new PhotobucketException(0, 500, "User Denied Applicaiton"));
				this.close();
				return;
			}
			if (html.location.indexOf("status=done") > 0) {
				result("applicationAuthorized");
				this.close();
				return;
			}
		}
		
		private function get windowWidth():int {
			return 1000;
		} 

		private function get windowHeight():int {
			return 500;
		}
		
	}
}