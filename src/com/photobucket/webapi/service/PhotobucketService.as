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
	import com.photobucket.webapi.interfaces.IAlbum;
	import com.photobucket.webapi.interfaces.IContact;
	import com.photobucket.webapi.interfaces.IMedia;
	import com.photobucket.webapi.interfaces.ITag;
	import com.photobucket.webapi.interfaces.IUser;
	import com.photobucket.webapi.oauth.OAuthBaseService;
	import com.photobucket.webapi.oauth.OAuthRequest;
	import com.photobucket.webapi.oauth.urlEncode;
	import com.photobucket.webapi.objects.Album;
	import com.photobucket.webapi.objects.Contact;
	import com.photobucket.webapi.objects.Media;
	import com.photobucket.webapi.objects.Tag;
	import com.photobucket.webapi.objects.User;
	
	import mx.rpc.IResponder;
	
	/**
	 * Implmentation of the Photobucket Open API.  The PhotobucketService class handles the making of requests to the
	 * Photobucket Open API and will execute the requests via internal channels for both URL and FILE requests. 
	 * @author jlewark
	 * 
	 */
	public class PhotobucketService extends OAuthBaseService
	{
		
		/**
		 * Constructor
		 * The PhotobucketService is implmeented as a singleton and should not be called directly with new.
		 * @param no
		 * 
		 */
		public function PhotobucketService(no:PBRestriction)
		{
			super();
		}
		
		/**
		 * The root URL of the API 
		 */
		public static const API_ROOT:String = "http://api.photobucket.com";
		/**
		 * The root URL of the API 
		 */
		public static const API_USER_LOGIN_URL:String = "http://photobucket.com/apilogin/login";
		
		/**
		 * Static instance variable used to make the service a singleton 
		 */
		private static var instance:PhotobucketService;
		/**
		 *  Channelset object that handels the actual making of requests
		 */	
		protected var channels:PhotobucketChannelSet = new PhotobucketChannelSet();;
		
		/**
		 * Overides the OAuth base string creation so that the servername is always api.photobucket.com instead of 
		 * actual url of the reuest.  This is done because redirections from silo to silo may occur for retriving some data. 
		 * @param url
		 * @return 
		 * 
		 */
		override protected function getEncodedURL(url:String):String {
			var needle:RegExp = /http:\/\/[^\/]*/;
			var photobucketBaseURL:String = urlEncode(url.replace(needle, "http://api.photobucket.com"));
			return photobucketBaseURL;
		}

		public var albumClass:Class = com.photobucket.webapi.objects.Album;
		public var userClass:Class = com.photobucket.webapi.objects.User;
		public var mediaClass:Class = com.photobucket.webapi.objects.Media;
		public var tagClass:Class = com.photobucket.webapi.objects.Tag;
		public var contactClass:Class = com.photobucket.webapi.objects.Contact;
		
		/**
		 * The photobucet API allows us to specify the format of the responce and override the HTTP method so that the default behavior of
		 * the actionscript components do not get in the way too much and we can avoid relying on a proxy.
		 * @param request
		 * 
		 */
		override protected function signRequest(request:OAuthRequest):void {
			request.addParameter("format", "XML");
			request.addParameter("_method", request.method);
			super.signRequest(request);
		}

		/**
		 * Returns the URL we should send the user's browser to authenticate once we have requested a Request token from the API. 
		 * @return 
		 * 
		 */
		public function get userLoginURL():String {
			return API_USER_LOGIN_URL + "?oauth_token="+oauth_token;
		}

		
		/**
		 * Return an instance of the PhotobucketService 
		 * @return 
		 * 
		 */
		public static function getInstance():PhotobucketService {
			if (instance == null) {
				instance = new PhotobucketService(new PBRestriction());
			}
			return instance;
		}
		
		/**
		 * Makes a requests againist the API and can prioritize certian requests either a HIGH, NORMAL and LOW (1,2,3) so that
		 * API's calls indirect responce to user gestures can get priority and provide a better use experience.
		 * @param request
		 * @param responder
		 * @param priority
		 * 
		 */		
		public function makeRequest(request:OAuthRequest, priority:int = 2):void {
			this.signRequest(request);
			channels.queueRequest(request, priority);
		}
		
		/**
		 * Pings the API to see if it is available.  It will hit the root api server if not specified.  All failures and results will be sent to the specefied
		 * IResponder.
		 *
		 * @param responder
		 * @param server
		 * 
		 */		
		public function ping(responder:IResponder, server:String = null):void {
			var request:OAuthRequest = new OAuthRequest();
			request.needsLogin = false;
			if (server == null) {
				request.url = API_ROOT + "/ping";
			} else {
				request.url = server+"/ping";
			}
		}
		
		public function userFactory(url:String = null, data:Object = null):IUser {
			return new userClass(url, data) as IUser;
		}
		
		public function albumFactory(url:String = null, data:Object = null):IAlbum {
			return new albumClass(url, data) as IAlbum;
		}
		
		public function mediaFactory(url:String = null, data:Object = null):IMedia {
			return new mediaClass(url, data) as IMedia;
		}
		
		public function tagFactory(data:Object = null):ITag {
			return new tagClass(data) as ITag;
		}
		
		public function contactFactory(email:String = null, firstName:String = null, lastName:String = null, id:String = null):IContact {
			return new contactClass(email, firstName, lastName, id) as IContact;
		}
		
	}
}

/**
 * Internal class that prevents the PhotobucketService from being created via new PhotobucketSerivce() 
 * @author jlewark
 * 
 */
class PBRestriction {
	
}