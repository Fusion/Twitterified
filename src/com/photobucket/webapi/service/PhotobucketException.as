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
	/**
	 * Simple PhotobucketException object that is used to carry and error from the API back to the IResponder
	 * fault function of the request that triggered the error. 
	 * @author jlewark
	 * 
	 */
	public class PhotobucketException
	{
		
		public var HTTPStatusCode:int;
		public var errorID:int;
		public var message:String;
		
		/**
		 * 
		 * @param statusCode
		 * @param error
		 * @param msg
		 * 
		 */
		public function PhotobucketException(statusCode:int, error:int, msg:String)
		{
			HTTPStatusCode = statusCode;
			errorID = error;
			message = msg;
		}
		
		public function toString():String {
			return HTTPStatusCode +" #"+errorID+": "+message;
		}		

	}
}