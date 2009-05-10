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
 
package com.photobucket.webapi.service
{
	import com.photobucket.webapi.oauth.OAuthRequest;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	
	import mx.controls.Alert;
	
	/**
	 * Class that will make a URL request using an internal URLLoader or a FileReference if supplied.  It will handle the events and respond to the provided responder with
	 * the contents of the responce or a PhotopbucketException if an Error occurs. 
	 * @author jlewark
	 * 
	 */
	public class PhotobucketChannel extends EventDispatcher
	{
		private var loader:URLLoader;
		private var _request:OAuthRequest;
		private var lastResponceCode:int;
		
		/**
		 * Load the specified request and respond to the provided responder.  Use the file if specified otherwise use an internal URLLoader 
		 * @param request
		 * @param responder
		 * @param file
		 * 
		 */
		 HTTPStatusEvent.HTTP_STATUS;
		 
		public function load(request:OAuthRequest):void {
			try {
				lastResponceCode = 0;
				_request = request;
				if (_request.file == null) {
					if (loader == null) {
						loader = new URLLoader();
						loader.addEventListener(Event.COMPLETE, onComplete);
						loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus, false, 1);
						loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
						loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
					}
					loader.load(request.getURLRequest());
				} else {
					_request.file.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
					_request.file.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus, false, 0, true);
					_request.file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);
					_request.file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onDataComplete, false, 0, true);
					_request.file.upload(request.getURLRequest(), "uploadfile");
				}
			} catch(error:Error) {
				onFault(new PhotobucketException(0, error.errorID, error.message));
				this.dispatchEvent(Event.COMPLETE);
			}

		}
		
		protected function onResult(object:Object):void {
			_request.result(object);
			_request = null;
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function onFault(fault:PhotobucketException):void {
			_request.fault(fault);
			_request = null;
			this.dispatchEvent(new Event(Event.COMPLETE));
		}

		protected function onData(object:Object):void {
			try {
				var xml:XML = new XML(object);
			} catch (error:Error) {
				Alert.show(object.toString(), "Error");
				onFault(new PhotobucketException(lastResponceCode, error.errorID, error.message));
				_request = null;
			}	
			if (xml.status == "OK") {
				var content:XMLList = xml.child("content");
				onResult(XML(content[0]));
			} else {
				onFault(new PhotobucketException(lastResponceCode, xml.code, xml.message));
			}
		
		}
	
		protected function onDataComplete(event:DataEvent):void {
			if (_request.file != null) {
				_request.file.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_request.file.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
				_request.file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				_request.file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onDataComplete);
			}
			onData(event.data);
		}
		
		protected function onComplete(event:Event):void {
			var oauth:RegExp = /oauth_token=.*&oauth_token_secret=.*/;
			if (oauth.test(loader.data.toString())) {
				onResult(loader.data);				
			} else {
				onData(loader.data);
			}
		}
		
		protected function onHTTPStatus(event:HTTPStatusEvent):void {
			lastResponceCode = event.status;
		}
		
		protected function onIOError(event:IOErrorEvent):void {
			onFault(new PhotobucketException(lastResponceCode, 100, event.text));
			
		}
		
		protected function onSecurityError(event:SecurityErrorEvent):void {
			onFault(new PhotobucketException(lastResponceCode, 100, event.text));
		}

	}
}