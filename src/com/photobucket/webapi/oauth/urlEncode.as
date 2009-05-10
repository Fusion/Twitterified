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
 
package com.photobucket.webapi.oauth
{
		
	/**
	* urlEncode
	*
	* Function that URL encodes according to RFC3986 which is slightly different then 
	* what the Actionscript escape() function will do by default.
	* 
	* The differences become problematic with forward slash and space charaters. This is extremely important when 
	* encoding the URL and parameters in the base string of oauth_signature and when indentifiers in a REST API 
	* can include characters that are outide the list of allowed charcters allowed by this API. 
	*  
	* @param str String to be encoded to RFC3986
	*/
	public function urlEncode(str:String):String
	{
		const RFC3986_ENCODE:RegExp = /[^a-zA-Z0-9_.~-]/g;
		var convert:Object = new Object;
		convert.encode = function():String {
				return String("%"+String(arguments[0]).charCodeAt().toString(16)).toUpperCase();
			}
		return str.replace(RFC3986_ENCODE, convert.encode );
	}
}