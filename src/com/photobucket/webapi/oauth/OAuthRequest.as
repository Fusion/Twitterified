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
	import flash.net.FileReference;
	import flash.net.URLVariables;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	/**
	 * OauthRequest
	 * 
	 * Container for all parameters nessecary to make an OAuthRequest and the log nessecary to sort the parameters correctly.
	 * @author jlewark
	 * 
	 */	
	public class OAuthRequest
	{
		
		/**
		 * URL of the Request this should not include GET parameters
		 */
		public var url:String;

		/**
		 *  The HTTP method of the request.  
		 *  @default GET
		 *  @see com.photobucket.webapi.oauth.OAuthRequestMethod
		 */
		public var method:String = OAuthRequestMethod.GET;
		
		
		/**
		 *  This flag sets if request needs to be signed with the oauth_token_secret
		 *  this is provided as for most APIs it requires extra work to verify the 
		 *  user has authorized the consumer.  No need to make the API do exta work.
		 */
		public var needsLogin:Boolean = false;

		/**
		 *  Holder for the FileReference if there is one
		 */
		private var _file:FileReference;
		
		/**
		 * Parameters Array Collection to store the OAuthParameter objects that are used 
		 * internally.  An array collection is easier to sort accorting to the OAuth spec 
		 */
		private var parameters:ArrayCollection = new ArrayCollection();


		/**
		 * Function to be called on sucessful result from the service. This can be a closure that be used to clean up
		 * the async behavior of a process
		 */
		public var result:Function;

		/**
		 *  Function to be called on an unsucessful result from the service or a transmission error.  This can be a closure 
		 *  so you can clean up some messy event handler code.
		 */
		public var fault:Function;


		/**
		 * Constructor
		 * 
		 * Basically does nothing
		 */
		public function OAuthRequest()
		{

		}
		/**
		 * Set File to upload with this request.  This can handle both the FileReference Object from the Flash API
		 * and the File object from AIR that extends it.  This function will also set the method to POST and add
		 * the mystery parameters added by the Flash and AIR runtimes. 
		 * 
		 * @param value FileReference Object to upload
		 * 
		 */		
		public function set file(value:FileReference):void {
			addParameter("Filename", value.name);
			addParameter("Upload", "Submit Query");
			_file = value;
		}
		
		public function get file():FileReference {
			return _file;
		}
		
				
		/**
		 * Parameter string that can be used as part of the oauth base string 
		 * @return 
		 * 
		 */
		public function get parameterString():String {
			var first:Boolean = true;
			var strParam:String = "";
			for each (var parameter:OAuthParameter in parameters) {
				if (!first) {
					strParam = strParam + "&" + urlEncode(parameter.key) + "=" + urlEncode(parameter.value); 
				} else {
					strParam = urlEncode(parameter.key) + "=" + urlEncode(parameter.value); 
					first = false;
				}
			}
			return strParam;
		}

		/**
		 * Sorts the parameters according to the oauth spec and prior to getting the parameter string 
		 * does not need to be called out side of the OAuthBaseService for making of the parameter string
		 */
		internal function sortByKey():void {
			var sort:Sort = new Sort();
			sort.fields = [new SortField("key", false), new SortField("value", false)];
			parameters.sort = sort;
			parameters.refresh();;			
		}

		/**
		 * Returns a URLVariables object of request in it's current state.  This can be added to URLRequest object's
		 * data property in order to sign it. 
		 * @return 
		 * 
		 */
		public function get urlVariables():URLVariables {
			var variables:URLVariables = new URLVariables();
			for each (var parameter:OAuthParameter in parameters) {
				variables[parameter.key] = parameter.value;
			}
			return variables;
		}
		
		/**
		 * Creates a URLRequest object based on OAuthRequest object 
		 * @param request
		 * @return 
		 * 
		 */
		public function getURLRequest():URLRequest {
			var urlRequest:URLRequest = new URLRequest(this.url);
			var urlVariables:URLVariables = this.urlVariables;
			urlRequest.data = urlVariables;
			urlRequest.method = this.method;
			return urlRequest;
		}
		/**
		 * Adds a parameter to the request and they should be key value pairs of strings.  It is not recommeded that 
		 * these be escaped in any way prior to being added to the request.
		 * @param key
		 * @param value
		 * 
		 */
		public function addParameter(key:String, value:String):void {	
			var newParam:OAuthParameter = new OAuthParameter(key, value);
			parameters.addItem(newParam);
		}

		
	}
}
/**
 * Internal class for storing OAuth parameter key value pairs.  There should be no need for this class outside of the
 * OAuth request. It is used to faciliate the ordering and storage of key value pairs.
 * @author jlewark
 * 
 */
class OAuthParameter
{
	
	public function OAuthParameter(oauthKey:String, oauthValue:String) {
		key = oauthKey;
		value = oauthValue;
	}
	
	public var key:String;
	public var value:String;
}