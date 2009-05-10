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
	import com.photobucket.webapi.oauth.OAuthRequest;
	import com.photobucket.webapi.oauth.OAuthRequestMethod;

	/**
	 * Represents a photobucket contact 
	 * @author jlewark
	 * 
	 */
	public class Contact extends PhotobucketRemoteObject implements IContact
	{
		
		private var _email:String;
		private var _firstName:String;
		private var _lastName:String;
		private var invalid:Boolean;
		
		public function Contact(email_address:String = null, first_Name:String = null, last_Name:String = null, id:String = null)
		{
			_email = email_address;
			_firstName = first_Name;
			_lastName = last_Name;
			if (id != null) {
				this.id = id;
				invalid = false;
			} else {
				invalid = true;
			}
			
		}
		
		
		public function get emailAddress():String
		{
			return _email;
		}
		
		public function set emailAddress(value:String):void
		{
			if (value != _email) {
				invalid = true;
				_email = value;
			}	
		}
		
		public function get firstName():String {
			return _lastName;
		}
		
		public function set firstName(value:String):void {
			if (value != _firstName) {
				invalid = true;
				_firstName = value;
			}			
		}

		public function get lastName():String {
			return _lastName;	
		}
				
		public function set lastName(value:String):void {
			if (value != _lastName) {
				invalid = true;
				_lastName = value;
			}			
		}
		
		public function commit():void {
			//if (invalid) {
			//	var request:OAuthRequest = new OAuthRequest();
			//	request.method = OAuthRequestMethod.POST;
			//	request.needsLogin = true;
			//}
		}
		
	}
}