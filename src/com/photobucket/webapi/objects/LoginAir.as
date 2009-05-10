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
	import com.photobucket.webapi.oauth.OAuthRequest;
	import com.photobucket.webapi.oauth.OAuthRequestMethod;
	
	/**
	 * Login Class for use with AIR. 
	 * @author jlewark
	 * 
	 */
	public class LoginAir extends Login
	{
		private var _loginWindow:LoginAirWindow;
				
		override protected function onLoginRequest():void {
				_loginWindow = new LoginAirWindow(pbservice.userLoginURL);
				_loginWindow.fault = this.fault;
				_loginWindow.result = function result(object:Object):void {
					accessRequest();
				}
				_loginWindow.open(true);
		}
	
 
	}
}