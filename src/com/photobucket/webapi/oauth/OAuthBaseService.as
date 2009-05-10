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

	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.hash.HMAC;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import mx.utils.UIDUtil;

	/**
	 * Class that contains the nessecary mechanisms to sign OAuthRequest objects and convert them to URLReqeustObjects. Most API implemations will extend this class and override its
	 * properties for its own unique variations from the OAuth1.0 spec.  There are several areas in the OAuth1.0 spec that are open to interpitation and so these specific funcitons
	 * mught actually requre that an override be needed.  It extends the EventDispatcher to allow for several different styles of a service to be implmented from this class.
	 * 
	 * In regards to areas open to interpitation of the 
	 *  * This implementation only supports HMAC-SHA1 signatures.
	 *  * This implmeentaiton does not include the Content-Disposition elements of the file being uploaded as apart of the OAuthSignature. 
	 * 
	 * This pakage depends on "As3 Crypto Framework 1.3" that can be found at http://crypto.hurlant.com/
	 * 
	 * @author jlewark
	 * 
	 */
	public class OAuthBaseService extends EventDispatcher
	{
		/**
		 * Consumer Key:  A value used by the Consumer to identify itself to the Service Provider.
		 */
		public var oauth_consumer_key:String;
		/**
		 * Consumer Secret: A secret used by the Consumer to establish ownership of the Consumer Key.
		 */
		public var oauth_consumer_secret:String;
		/** 
		 * Acess Token/Reuest Token:
		 * 
		 * Access Token: A value used by the Consumer to gain access to the Protected Resources on behalf of the User, instead of using the User’s Service Provider credentials.
		 * Request Token: A value used by the Consumer to obtain authorization from the User, and exchanged for an Access Token.
		 * 
		 */
		public var oauth_token:String = "";
		/**
		 *  Token Secret: A secret used by the Consumer to establish ownership of a given Token.
		 */		
		public var oauth_token_secret:String = "";
		/**
		 *  Version:  The version of the oauth potocol that us being used
		 *  This libary only supports 1.0
		 */
		protected var oauth_version:String = "1.0";
		/**
		 *  Signature Method:  The Consumer declares a signature method in the oauth_signature_method parameter, generates a signature, and stores it in the oauth_signature parameter.
		 *  OAuth does not mandate a particular signature method, as each implementation can have its own unique requirements. The protocol defines three signature methods: HMAC-SHA1, RSA-SHA1, 
		 *  and PLAINTEXT, but Service Providers are free to implement and document their own methods. Recommending any particular method is beyond the scope of this specification.  
		 * 
		 *  This Library supports only HMAC-SHA1
		 */
		protected var oauth_signature_method:String = "HMAC-SHA1";
			
		/**
		 * Nonce: The Consumer SHALL then generate a Nonce value that is unique for all requests with that timestamp. 
		 * A nonce is a random string, uniquely generated for each request. The nonce allows the Service Provider to verify that a 
		 * request has never been made before and helps prevent replay attacks when requests are made over a non-secure channel (such as HTTP).
		 * @return  
		 * 
		 */
		protected function get oauth_nonce():String {
			return UIDUtil.createUID().replace(/-/g,"");
		}
		
		/**
		 * Timestamp:  Unless otherwise specified by the Service Provider, the timestamp is expressed in the number of seconds since January 1, 1970 00:00:00 GMT. 
		 * The timestamp value MUST be a positive integer and MUST be equal or greater than the timestamp used in previous requests.
		 * @return 
		 * 
		 */
		protected function get oauth_timestamp():String {
			var date:Date = new Date();
			var sec:String = int(date.time * 0.001).toString();
			return sec;
		}
		
		/**
		 * getEncoded URL: encodes the URL of the request to meet the reqiurements of the API as it is used as part of the BaseString to generate the oauth_signature.
		 * Some large service providers might have some additional requirments around how this URL needs be formated as the API may traverse multiple domains.  In which
		 * case override the URL encoding function to accomplish this task.
		 * @param url
		 * @return 
		 * 
		 */
		protected function getEncodedURL(url:String):String {
			return urlEncode(url);		
		} 


		/**
		 * signRequest:  The purpose of signing requests is to prevent unauthorized parties from using the Consumer Key and Tokens when making Token requests or Protected Resources requests. 
		 * The Service Provider verifies the signature as specified in each method. When verifying a Consumer signature, the Service Provider SHOULD check the request nonce to ensure
		 *  it has not been used in a previous Consumer request.
		 * 
		 * No parameters should be added to the request once it has been signed
		 * 
		 * @param request
		 * 
		 */
		protected function signRequest(request:OAuthRequest):void {
			request.addParameter("oauth_consumer_key", oauth_consumer_key);
			request.addParameter("oauth_timestamp", oauth_timestamp);
			request.addParameter("oauth_nonce", oauth_nonce);
			request.addParameter("oauth_version", oauth_version);
			request.addParameter("oauth_signature_method", oauth_signature_method);
			if (oauth_token != null) {
				if ((oauth_token.length > 0)&&(request.needsLogin)) {
					request.addParameter("oauth_token", oauth_token);
				}
			}
			request.sortByKey();
			var signature:String = getSignature(request);
			request.addParameter("oauth_signature", signature);			
		}

		/**
		 * Generates the base string for the signature process
		 * @param request
		 * @return 
		 * 
		 */
		protected function getBaseString(request:OAuthRequest):String {
			request.sortByKey();
			var baseString:String = urlEncode(request.method)+"&"+getEncodedURL(request.url)+"&"+urlEncode(request.parameterString);
			return baseString;
		}

		/**
		 * The function generates the signature of the request for a given method.  This function only implements HMAC-SHA1 currently.
		 * 
		 * The HMAC-SHA1 signature method uses the HMAC-SHA1 signature algorithm as defined in [RFC2104] 
		 * (Krawczyk, H., Bellare, M., and R. Canetti, “HMAC: Keyed-Hashing for Message Authentication,” .) 
		 * where the Signature Base String is the text and the key is the concatenated values (each first encoded per 
		 * Parameter Encoding (Parameter Encoding)) of the Consumer Secret and Token Secret, separated by an ‘&’ character 
		 * (ASCII code 38) even if empty.
		 * 
		 * If this is not a protected resource the TokenSecret is treated as an empty string.
		 * 
		 * @param request
		 * @return 
		 * 
		 */
		protected function getSignature(request:OAuthRequest, method:String = 'HMAC-SHA1'):String {
			var baseString:String = getBaseString(request);
			var hmac:HMAC = Crypto.getHMAC("sha1");
			var keydata:ByteArray;
			if (request.needsLogin) {
				keydata = Hex.toArray(Hex.fromString(oauth_consumer_secret+"&"+oauth_token_secret));
			} else {
				keydata = Hex.toArray(Hex.fromString(oauth_consumer_secret+"&"));
			}
			var data:ByteArray = Hex.toArray(Hex.fromString(baseString));
			var result:ByteArray = hmac.compute(keydata, data);
			var resultString:String = Base64.encodeByteArray(result);
			return resultString;
		}

	}
}