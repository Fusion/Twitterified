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
	import com.photobucket.webapi.interfaces.IAlbum;
	import com.photobucket.webapi.interfaces.IContact;
	import com.photobucket.webapi.interfaces.IMedia;
	import com.photobucket.webapi.interfaces.IUser;
	import com.photobucket.webapi.oauth.OAuthRequest;
	import com.photobucket.webapi.oauth.OAuthRequestMethod;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	[Event(name="userUpdated", type="flash.events.Event")]
	/**
	 * Reperents a user and their preferences on photobucket 
	 * @author jlewark
	 * 
	 */
	public class User extends PhotobucketRemoteObject implements IUser
	{

		protected var _username:String;
		protected var _pro:Boolean;
		protected var _album_url:String;
		protected var _total_pictures:int;
		protected var _preferedPictureSize:int;
		
		public function User(url:String = null, data:Object = null)
		{
			//_username = user;
			if (url != null) {
				this.server = url;
				_username = owner;
			}
			if (data != null) {
				this.data = data; 
			}
			super();
		}
		
		[Bindable(event='userUpdated')]
		/**
		 * The username of the user 
		 * @return 
		 * 
		 */		
		public function get username():String {
			return _username;
		}
		
		[Bindable(event='userUpdated')]		
		/**
		 * Returns if this user is pro or not. 
		 * @return 
		 * 
		 */
		public function get isPro():Boolean {
			return _pro;
		}
		
		[Bindable(event='userUpdated')]		
		/**
		 * The url of the users root album 
		 * @return 
		 * 
		 */
		public function get album_url():String {
			return _album_url;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getRootAlbum():IAlbum {
			var album:IAlbum = pbservice.albumFactory(album_url);
			return album;
		}
		
		/**
		 *  Makes a request to the server to populate some of the user's parameters 
		 * 
		 */
		public function getUserInfo():void {
			var request:OAuthRequest = new OAuthRequest();
			request.method = OAuthRequestMethod.GET;
			request.needsLogin = true;
			request.url = server + '/user/' + id;
			request.fault = this.fault;
			request.result = function (object:Object):void {			
					data = object;
			}
			pbservice.makeRequest(request);			
		}
				
		/**
		 * Get Recent Media from a user 
		 * @param type Type of media
		 * @param number Number of Media
		 * @param page Page offset for pagination
		 * 
		 */
		public function getRecentMedia(type:String = "all", number:Number = 20, page:Number = 1):ArrayCollection {
			var request:OAuthRequest = new OAuthRequest();
			request.method = OAuthRequestMethod.GET;
			request.needsLogin = true;
			if (type != "all") {
				request.addParameter("type", type);
			}
			if (page != 1) {
				request.addParameter("page", page.toString());
			}
			if (number != 20) {
				request.addParameter("perpage", number.toString());
			}
			var mediaList:ArrayCollection = new ArrayCollection();
			request.url = server + '/user/' + id + "/search";
			request.result = function (value:Object):void {
				var results:XML = value as XML;
				for each (var mediaXML:XML in results..media) {
					var media:IMedia = pbservice.mediaFactory(null, mediaXML);
					mediaList.addItem(media);
				}
				mediaList.dispatchEvent(new Event(Event.COMPLETE));
			}
			request.fault = function (value:Object):void {
				mediaList.dispatchEvent(new Event(Event.COMPLETE));
			}
			pbservice.makeRequest(request);		
			return mediaList;	
		}
		
		/**
		 * Internal function for setting the values of the user from an xml response most often called
		 * from a closuer in one of the other remote objects;
		 * @param value
		 * 
		 */
		override internal function set data(value:Object):void {
			super.data = value;
			if (data.hasOwnProperty("username")) {
				_username = data.username;
				id = username;
			}
			if (data.hasOwnProperty("subdomain")) {
				_server = "http://"+data.subdomain;
				_album_url = "http://"+data.subdomain+"/albums/"+username;
			}
			if (data.hasOwnProperty("album_url")) {
				_album_url = data.album_url;
				server = _data.album_url;
			}
			if (data.hasOwnProperty("premium")) {
				_pro = Boolean(data.premium);
			}
			if (data.hasOwnProperty("preferred_picture_size")) {
				_preferedPictureSize = data.preferred_picture_size;
			}
			this.dispatchEvent(new Event("userUpdated"));
			sendComplete();
		}

		[Bindable(event='userUpdated')]		
		/**
		 * The user's perferred upload size.  This is a number that 
		 * represents the width in pixels.
		 * Bindable 
		 * @return 
		 * 
		 */
		public function get defaultImageUploadSize():String {
			return _preferedPictureSize.toString();
		}
		
		/**
		 * Sets the users perfered upload size.  This is a number that
		 * corresponds to the width in pixels of the final upload.  Note each width has
		 * a corresponding height; 
		 * @param value
		 * 
		 */
		public function set defaultImageUploadSize(value:String):void {
			if (_preferedPictureSize.toString() != value) {
				var oldValue:int = _preferedPictureSize;
				_preferedPictureSize = int(value);
				var request:OAuthRequest = new OAuthRequest();
				request.url = server + "/user/"+ id +"/uploadoption";
				request.method = OAuthRequestMethod.PUT;
				request.needsLogin = true;
				request.addParameter("defaultimagesize", value);
				request.fault = this.fault;
				request.result = this.result;
				pbservice.makeRequest(request);
			}
		}

		public function get contacts():ArrayCollection {
			var contactList:ArrayCollection = new ArrayCollection();
			var request:OAuthRequest = new OAuthRequest();
			request.url = server + "/user/"+ id +"/contact";
			request.needsLogin = true;
			request.method = OAuthRequestMethod.GET;
			request.fault = this.fault;
			request.result = function (result:Object):void {
				for each (var contactXML:XML in result..contact) {
					var newContact:IContact = pbservice.contactFactory(contactXML.primary_email, contactXML.first, contactXML.last, contactXML.id);
					contactList.addItem(newContact);
				}				
			}
			pbservice.makeRequest(request);
			return contactList;		
		}
		
	}
}