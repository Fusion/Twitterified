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
	import com.photobucket.webapi.interfaces.IMedia;
	import com.photobucket.webapi.oauth.OAuthRequest;
	import com.photobucket.webapi.oauth.urlEncode;
	import com.photobucket.webapi.oauth.OAuthRequestMethod;
	import com.photobucket.webapi.service.PhotobucketService;
	import flash.events.Event;
	
	
	import mx.collections.ArrayCollection;
	
	/**
	 * Search Object: provides basic search functionality on photobucket 
	 * @author jlewark
	 * 
	 */
	public class Search extends PhotobucketRemoteObject
	{
		public function Search(_numberOfResults:int = 20)
		{
			super();
			numberOfResults = _numberOfResults;			
		}
		
		public var numberOfResults:int;
		private var secondaryResults:int = 0;
		
		public function recent(type:String = "images"):ArrayCollection {
			var media:ArrayCollection = new ArrayCollection();
			var request:OAuthRequest = new OAuthRequest();
			request.url = PhotobucketService.API_ROOT + "/search";
			if (numberOfResults != 20) {
				request.addParameter("num", numberOfResults.toString())
			}
			request.addParameter("type", type);
			request.fault = this.fault;
			request.result = function (value:Object):void {
				var results:XML = value as XML;
				for each (var mediaXML:XML in results..media) {
					var mediaObj:IMedia = pbservice.mediaFactory(null, mediaXML);
					media.addItem(mediaObj);
				}
			}
			pbservice.makeRequest(request);
			return media;
		}

		public function search(term:String, type:String = "image", page:int = 1):ArrayCollection {
			var media:ArrayCollection = new ArrayCollection();
			var request:OAuthRequest = new OAuthRequest();
			request.url = PhotobucketService.API_ROOT + "/search/"+urlEncode(term);
			if (numberOfResults != 20) {
				request.addParameter("perpage", numberOfResults.toString())
			}
			if (page != 20) {
				request.addParameter("page", page.toString())
			}			
			request.addParameter("secondaryperpage", secondaryResults.toString());
			request.addParameter("type", type);
			request.fault = this.fault;
			request.result = function (value:Object):void {
				var results:XML = value as XML;
				for each (var mediaXML:XML in results..media) {
					var mediaObj:IMedia = pbservice.mediaFactory(null, mediaXML);
					media.addItem(mediaObj);
				}
			}
			pbservice.makeRequest(request);			
			return media;
		}

		public function user(username:String, type:String = "image", page:int = 1):ArrayCollection {
			var request:OAuthRequest = new OAuthRequest();
			request.method = OAuthRequestMethod.GET;
			if (type != "all") {
				request.addParameter("type", type);
			}
			if (page != 1) {
				request.addParameter("page", page.toString());
			}
			if (numberOfResults != 20) {
				request.addParameter("perpage", numberOfResults.toString());
			}
			var mediaList:ArrayCollection = new ArrayCollection();
			request.url = PhotobucketService.API_ROOT + '/user/' + urlEncode(username) + "/search";
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

	}
}