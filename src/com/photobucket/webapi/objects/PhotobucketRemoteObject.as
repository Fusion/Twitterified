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
	/*
	Base Data Acess Object for the Photobucket API
	*/

	import com.photobucket.webapi.oauth.urlEncode;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.photobucket.webapi.service.PhotobucketException;
	import com.photobucket.webapi.service.PhotobucketService;


	[Event(name="error", type="flash.events.Event")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="idUpdated", type="flash.events.Event")]
	[Event(name="serverUpdated", type="flash.events.Event")]
	/**
	 * Base Object for Photobucket Remote Object Clases that represent objects on the photobucket site.
	 * @author jlewark
	 * 
	 */
	public class PhotobucketRemoteObject extends EventDispatcher
	{
		public static const ERROR_EVENT:String = "error";
		
		protected var pbservice:PhotobucketService;
		protected var _data:Object;
		protected var exception:PhotobucketException;
		public var resultHandler:Function;
		public var faultHandler:Function;
		protected var _server:String;
		protected var _owner:String;
		protected var _id:String;

		/**
		 * Constructor
		 * 
		 * Creates an instance of pbservice that all remote objects use for
		 * their communication to the server 
		 * 
		 */
		public function PhotobucketRemoteObject() {
			super();
			pbservice = PhotobucketService.getInstance();			
		}
		
		
		/**
		 * Returns and sets the id of the remote object.  May be overwritten
		 * @return 
		 * 
		 */
		[Bindable(event="idUpdated")]
		public function get id():String {
			return urlEncode(_id);
		}
		
		public function set id(value:String):void {
			_id = value;
			dispatchEvent(new Event("idUpdated"));
		}
		
		[Bindable(event="serverUpdated")]
		/**
		 * Gets and Sets the server for the api of the remote object.  Takes a URL 
		 * @return 
		 * 
		 */
		public function get server():String {
			if (_server != null) {
				return _server;
			} else {
				return PhotobucketService.API_ROOT;
			}
		}
		
		
		public function set server(value:String):void {
			var urlparse:RegExp = /^http:\/\/[a-z]+(?P<silo>[0-9]+|mg).photobucket.com\/(albums|groups)\/(?P<vee>[^\/]*)\/(?P<username>[^\/]*)/;
			var values:Array = urlparse.exec(value);
			if (values) {
				_server = "http://api"+values.silo+".photobucket.com";
				_owner = values.username;
			}
			dispatchEvent(new Event("serverUpdated"));	
		}
		
		/**
		 * Returns the owners username 
		 * @return 
		 * 
		 */
		public function get owner():String {
			return _owner;
		}
		
		/**
		 * Generic hook into for parent obects to insert values into an
		 * object that is already known.  This can sometimes prevent an extra call
		 * to the server.  There is no need for this hack to be exposed beyond this package level
		 * @param value
		 * 
		 */
		internal function set data(value:Object):void {
			_data = value;
		} 
		
		internal function get data():Object {
			return _data;
		}
	
		/**
		 * Assigns a property from the XML to the object if that property exists in the  
		 * @param property
		 * @param xmlProperty
		 * 
		 */
		internal function setPropertyFromData(property:String, xmlProperty:String = null):void {
			if (xmlProperty == null) {
				xmlProperty = property;
			}
			if (data.hasOwnProperty(xmlProperty)) {
				Object(this)[property] = data[xmlProperty]
			}
		}
	
		/**
		 * Lazy method for dispatching a complete event 
		 * 
		 */
		protected function sendComplete():void {
			if (resultHandler != null) {
				resultHandler();
			}
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Lazy method for dispatching an error event 
		 * 
		 */		
		protected function sendError():void {
			if (faultHandler != null) {
				faultHandler();
			}
			this.dispatchEvent(new Event(ERROR_EVENT));
		}
	
		/**
		 * Defult responder implmentation for a fault that will trigger 
		 * and error event. 
		 * @param value
		 * 
		 */
		 
		 protected function fault(value:Object):void {
		 	sendComplete();	
		 }
		 
		 protected function result(value:Object):void {
		 	this.sendError();
		 }
		
				/**
		 * Convinence method to set the comsumer key and secret. This only has to be done once and could very well
		 * be on the PhotobucketService object directly.
		 * @param consumer_key
		 * @param consumer_secret
		 * 
		 */
		public function setConsumer(consumer_key:String, consumer_secret:String):void {
			pbservice.oauth_consumer_key = consumer_key;
			pbservice.oauth_consumer_secret = consumer_secret;
		}
		
		
	}
}