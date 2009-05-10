package twitter.api {
	
	import flash.events.*;
	import flash.net.*;
	import flash.xml.*;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	
	import twitter.api.data.*;
	import twitter.api.events.*;
	
	public class MultiTwitter extends EventDispatcher
	{
		private var replyCounter:int = 0;
		private var replyCeiling:int = 0;
		private var curTwitterEvent:TwitterEvent;
		private var curTwitterIds:Array;
		private var twittersList:ArrayCollection = new ArrayCollection();
	
		function MultiTwitter() 
		{
			var account:Array;
			for each(account in Application.application.accountsList)
			{
				var twitter:Twitter = new Twitter(mapServer(account['service'], account['server']), account['username'], account['password']); 
				twitter.addEventListener(TwitterEvent.ON_USER_TIMELINE_RESULT, onUserTimelineResult);
				twitter.addEventListener(TwitterEvent.ON_FRIENDS_TIMELINE_RESULT, onFriendsTimelineResult);
				twitter.addEventListener(TwitterEvent.ON_REPLIES_TIMELINE_RESULT, onRepliesTimelineResult);
				twitter.addEventListener(TwitterEvent.ON_DIRECT_MESSAGES_TIMELINE_RESULT, onDirectMessagesTimelineResult);				
				twitter.addEventListener(TwitterEvent.ON_PUBLIC_TIMELINE_RESULT, onPublicTimelineResult);
				twitter.addEventListener(TwitterEvent.ON_FRIENDS_RESULT, onFriendsResult);
				twitter.addEventListener(TwitterEvent.ON_FOLLOWERS, onFollowersResult);
				twitter.addEventListener(TwitterEvent.ON_SET_STATUS, onUpdateResult);	
				twitter.addEventListener(TwitterEvent.ON_ERROR, reportError);
				twitter.addEventListener(TwitterEvent.ON_RATE_LIMIT_STATUS, onRateLimitStatus);	
				twittersList.addItem(twitter);
			}
		}
		
		public function mapServer(service:String, server:String):String
		{
			switch(service)
			{
				case 'Twitter':
					return 'http://twitter.com/';
				case 'Identi.ca':
					return 'http://identi.ca/api/';
				case 'Twit Army':
					return 'http://army.twit.tv/api/';
				case 'Linux Infusion':
					return 'http://laconica.linuxinfusion.com/api/';
				case 'Present.ly':
					return 'https://presently.presentlyapp.com/api/twitter/';
				default:
					return server;					
			}
		}
		
		public function findTwitterByUnique(unique:String):Twitter
		{
			var twitter:Twitter;
			for each(twitter in twittersList)
			{
				if(twitter.unique == unique)
					return twitter;
			}
			return null;			
		}
		
		private function prepare(queries:int = 1):void
		{
			replyCounter    = 0;
			replyCeiling    = twittersList.length * queries;
			curTwitterEvent = null;			
		}
		
		/** @todo In the future a different uid may be passed because we care about
		 * someone else's friend - we will have to fix this code then
		 */	
		public function loadFriends():void
		{
			trace("Loading friends list");
			prepare();
			var twitter:Twitter;
			for each(twitter in twittersList)
			{
				twitter.loadFriends(twitter.username);
			}			
		}
		public function loadFriendsTimeline():void
		{			
			trace("Loading friends timelines");
			prepare(2);
			var twitter:Twitter;
			for each(twitter in twittersList)
			{
				twitter.loadFriendsTimeline(twitter.username);
				twitter.loadDirectMessagesTimeline();
			}
		}
		public function loadUserTimeline():void
		{
			trace("Loading user timelines");
			prepare();
			var twitter:Twitter;
			for each(twitter in twittersList)
			{
				twitter.loadUserTimeline(twitter.username);
			}
		}
		public function loadPublicTimeline():void
		{
			trace("Loading public timelines");
			prepare();
			// Hey we only need to read once per service...no mas!
			var services:Array = new Array();
			var servicesCount:int = 0;			
			var twitter:Twitter;
			for each(twitter in twittersList)
			{
				if(!services[twitter.server])
				{
					services[twitter.server] = true;
					servicesCount ++;
				}
			}
			replyCeiling = servicesCount;
			services = new Array();			
			for each(twitter in twittersList)
			{
				if(!services[twitter.server])
				{
					services[twitter.server] = true;
					trace("..." + twitter.server);			
					twitter.loadPublicTimeline();
				}
			}
			trace("Done loading public timelines.");
		}
		public function follow(unique:String, userId:String):void
		{
			var twitter:Twitter = findTwitterByUnique(unique);
			twitter.follow(userId);			
		}
		public function befriend(unique:String, userId:String):void
		{
			var twitter:Twitter = findTwitterByUnique(unique);
			twitter.befriend(userId);			
		}
		public function setStatus(unique:String, statusString:String):void
		{
			var twitter:Twitter = findTwitterByUnique(unique);
			twitter.setStatus(statusString);
		}
		public function showStatus(unique:String, id:String):void
		{
			var twitter:Twitter = findTwitterByUnique(unique);
			twitter.showStatus(id);			
		}
		public function loadRepliesTimeline():void
		{
			prepare();
			var twitter:Twitter;
			for each(twitter in twittersList)
			{
				twitter.loadRepliesTimeline();
			}			
		}
		public function loadDirectMessagesTimeline():void
		{
			prepare();
			var twitter:Twitter;
			for each(twitter in twittersList)
			{
				twitter.loadDirectMessagesTimeline();
			}			
		}
		public function loadFollowers(lite:Boolean=true):void
		{
			trace("Loading followers list");
			prepare();
			var twitter:Twitter;
			for each(twitter in twittersList)
			{
				twitter.loadFollowers();
			}						
		}
		public function loadFeatured():void
		{
		}
		public function block(unique:String, userId:String):void
		{
			var twitter:Twitter = findTwitterByUnique(unique);
			twitter.block(userId);
		}		
		public function rateLimitStatus(unique:String):void
		{
			var twitter:Twitter = findTwitterByUnique(unique);
			twitter.rateLimitStatus();
		}		

		// private handlers for the events coming back from twitter
		private function reportError(event:TwitterEvent):void
		{
			dispatchEvent(event);
		}
		
		private function tallyEvents(event:TwitterEvent):void
		{
			if(!curTwitterEvent)
			{
				curTwitterEvent      = new TwitterEvent(event.type, event.bubbles, event.cancelable);
				curTwitterEvent.data = new Array();
				curTwitterIds        = new Array();
			}
			var data:Object;
			for each(data in event.data)
			{
				if(curTwitterIds[data.id])
					continue;
				curTwitterIds[data.id] = true;
				// After having weeded out redundant ids, let's store this victorious tweet!
				curTwitterEvent.data.push(data);
			}
			replyCounter ++;
			if(replyCounter >= replyCeiling)
			{
				trace("Got "+replyCounter+" replies, thus dispatching event");
				dispatchEvent(curTwitterEvent);
			}			
		}
		
		private function onUserTimelineResult(event:TwitterEvent):void
		{
			trace("MultiTwitter::onUserTimelineResult");
			tallyEvents(event);
		}	
		private function onFriendsTimelineResult(event:TwitterEvent):void
		{
			trace("MultiTwitter::onFriendsTimelineResult");
			tallyEvents(event);
		}
		private function onRepliesTimelineResult(event:TwitterEvent):void
		{
			trace("MultiTwitter::onRepliesTimelineResult");
			tallyEvents(event);
		}
		private function onDirectMessagesTimelineResult(event:TwitterEvent):void
		{
			trace("MultiTwitter::onDirectMessagesTimelineResult");
			tallyEvents(event);
		}
		private function onPublicTimelineResult(event:TwitterEvent):void
		{
			trace("MultiTwitter::onPublicTimelineResult");
			tallyEvents(event);
		}
		private function onFriendsResult(event:TwitterEvent):void
		{
			trace("MultiTwitter::onFriendsResult");
			tallyEvents(event);
		}		
		private function onFollowersResult(event:TwitterEvent):void
		{
			trace("MultiTwitter::onFollowersResult");
			tallyEvents(event);
		}		
		private function onUpdateResult(event:TwitterEvent):void
		{
			trace("MultiTwitter::onUpdateResult");
			dispatchEvent(event);
		}		
		private function onRateLimitStatus(event:TwitterEvent):void
		{
			trace("MultiTwitter::onRateLimitStatus");
			dispatchEvent(event);
		}	
	}
}