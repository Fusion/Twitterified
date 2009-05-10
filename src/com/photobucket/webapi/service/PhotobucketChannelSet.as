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
	import com.photobucket.webapi.oauth.OAuthRequest;
	
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	
	/**
	 * This object distributes requests over several channels so that the order is relatively controlled but allowing for more then one request to occur simultaniusly.  
	 * Although you can't be sure the exact order of repsonces you make some assumptions.  This is because more then one channel can make reuests at a time.
	 * 
	 * For a series of requests a->b->c->d->e  you can not besure that the responce for b will not be returned before a but there is a very good chance a will be recieved before 
	 * d if the MAX_CONCURRENT_REQUESTS is small.
	 * @author jlewark
	 * 
	 * TODO: Prioritize based on Priority provided
	 */
	public class PhotobucketChannelSet
	{
		
		/**
		 * Max Concurrent Requests:  This is set to two as we will likly be downloading images as part of any application
		 * and there for want those images not to have to wait on API requests. 
		 */
		public static const MAX_CONCURRENT_REQUESTS:int = 2;
		public static const PRIORITY_HIGH:int = 1;
		public static const PRIORITY_NORMAL:int = 2;
		public static const PRIORITY_LOW:int = 3
		
		private var channels:ArrayCollection = new ArrayCollection();
		private var freeChannels:ArrayCollection = new ArrayCollection();
		private var queue:ArrayCollection = new ArrayCollection();
		
		/**
		 * Constructor: Create the channels that this channel set will initially maintain. 
		 * 
		 */
		public function PhotobucketChannelSet()
		{
			for (var i:int=0; i < MAX_CONCURRENT_REQUESTS; i++) {
				var newChannel:PhotobucketChannel = new PhotobucketChannel();
				newChannel.addEventListener(Event.COMPLETE, onChannelComplete);
				channels.addItem(newChannel);
				freeChannels.addItem(newChannel);
			}
		}

		/**
		 * Ad a reuest to the queue if all channels are busy.  If there are channels currently available use them imediately and remove them from the 
		 * list of free channels
		 * @param request
		 * @param responder
		 * @param priority
		 * @param file
		 * @param filename
		 * 
		 */
		public function queueRequest(request:OAuthRequest, priority:int):void {
			if (freeChannels.length > 0) {
				var channelToUse:PhotobucketChannel = freeChannels.removeItemAt(0) as PhotobucketChannel;
				channelToUse.load(request);
			} else { 
				queue.addItem(new RequestToken(request, priority));
			}
			
		}
		
		/**
		 * When a channel completes it task add the next item from the queue or return the channel to the free channels list 
		 * @param event
		 * 
		 */
		protected function onChannelComplete(event:Event):void {
			if (queue.length > 0) {
				var token:RequestToken = queue.removeItemAt(0) as RequestToken;
				PhotobucketChannel(event.target).load(token.request);
			} else {
				freeChannels.addItem(event.target);
			}
		}



	}
}
	import mx.rpc.IResponder;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import com.photobucket.webapi.oauth.OAuthRequest;
	

/**
 * Internal Class to track items in the queue 
 * @author jlewark
 * 
 */
class RequestToken {
	
	public var request:OAuthRequest;
	public var priority:int;
	public var file:FileReference;
	public var filename:String;

	public function RequestToken(_request:OAuthRequest, _priority:int) {
		request = _request;
		priority = _priority;
	}
}	
