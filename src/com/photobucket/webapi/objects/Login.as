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
	import com.photobucket.webapi.interfaces.IUser;
	
	import com.photobucket.webapi.oauth.OAuthRequest;
	import com.photobucket.webapi.oauth.OAuthRequestMethod;
	import com.photobucket.webapi.service.PhotobucketService;
	import com.photobucket.webapi.objects.User;
	
	import flash.events.Event;
	
	
	[Event(name="promptForLogin", type="flash.events.Event")]
	/**
	 * ABSTRACT: Base class for login functions.  onLoginRequest must be implemented by the specific application in otder to prodive the
	 * means by which the user can authorize the application.  An exampe if provided for Adobe Air see LoginAir. 
	 * @author jlewark
	 * 
	 */
	public class Login extends PhotobucketRemoteObject
	{
		protected var _user:IUser;
		
		
		public static const PROMPT_FOR_LOGIN:String = "promptForLogin";
		
		/**
		 * Logs in the user.  The user object is returned by this function and will trigger the COMPLETE event once it has been
		 * logged in. 
		 * @return 
		 * 
		 */		
		public function loginUser():IUser {
			if (_user) {
				throw new Error("login in process");
			}
			_user = pbservice.userFactory();
			this.loginRequest();
			return _user;
		}
		
		/**
		 * Function makes a loginRwquest to the API 
		 * 
		 */
		protected function loginRequest():void {
			pbservice = PhotobucketService.getInstance();
			var request:OAuthRequest = new OAuthRequest();
			request.method = OAuthRequestMethod.POST;
			request.url = PhotobucketService.API_ROOT + '/login/request';
			request.result = function (result:Object):void {
				var responceString:String = result.toString();
				var params:Array = responceString.split("&");
				for each (var paramString:String in params) {
					var parameter:Array = paramString.split("=");
					switch (parameter[0]) {
						case "oauth_token":
							pbservice.oauth_token = parameter[1];
							break;
						case "oauth_token_secret": 
							pbservice.oauth_token_secret = parameter[1];
							break;
					}
				}

				onLoginRequest();				
			}
			request.fault = this.fault;
			pbservice.makeRequest(request);
			
		}
		
		/**
		 * ABSTRACT:  This function needs to be overwritten to handle the specific user authoriztion needs of the
		 * application or an event handler could be used
		 * 
		 */
		protected function onLoginRequest():void {
			this.dispatchEvent(new Event(PROMPT_FOR_LOGIN));
		}

		public function get userLoginURL():String {
			return pbservice.userLoginURL;
		}

		/**
		 * Makes the request to the api to get the token and token secret for the authroized user.  Also grabs the usname and home url
		 * and feeds that to the inital user object. 
		 * 
		 */
		protected function accessRequest():void {
			var request:OAuthRequest = new OAuthRequest();
			request.method = OAuthRequestMethod.POST;
			request.needsLogin = true;
			request.url = PhotobucketService.API_ROOT + '/login/access';
			request.result = function (result:Object):void {
				var responceString:String = result.toString();
				var params:Array = responceString.split("&");
				var userData:Object = new Object();
				for each (var paramString:String in params) {
					var parameter:Array = paramString.split("=");
					switch (parameter[0]) {
						case "oauth_token":
							pbservice.oauth_token = parameter[1];
							break;
						case "oauth_token_secret": 
							pbservice.oauth_token_secret = parameter[1];
							break;
						case "username":
							userData.username = parameter[1];
							break;
						case "subdomain": 
							userData.subdomain = parameter[1];
							break;
						case "homeurl":
							userData.album_url = unescape(parameter[1]);
							//_user.homeURL();
							break;
					}
				}
				User(_user).data = userData;
			}
			request.fault = this.fault;
			pbservice.makeRequest(request);
		}
		

	}
}