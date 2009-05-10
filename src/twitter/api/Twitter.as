/*
Twitter Library 2.0
CFR Note:
When Twitter is down, this is what is returned: "Twitter is down for maintenance. It will return in about an hour."
After this line: var xml:XML = new XML(this.getLoader(FRIENDS_TIMELINE).data);

This is what is returned in xml:
<error reason="maintenance" deadline="about an hour">
  Twitter is down for maintenance. It will return in about an hour.
</error>

and it gets lost so I need to throw an error in that case!
*/
package twitter.api {
	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.ByteArray;
	import flash.xml.*;
	
	import mx.utils.Base64Encoder;
	
	import twitter.api.data.*;
	import twitter.api.events.TwitterEvent;
	
	/**
	 * This is a wrapper class around the Twitter public API.
	 * The pattern for all of the calls is to:
	 * 1.) Use XML for the format
	 * 2.) Internally handle the event from the REST call
	 * 3.) Parse the XML into a strongly typed object
	 * 4.) Publish a TwitterEvent whose payload is the type object from above
	 */ 
	public class Twitter extends EventDispatcher
	{
		// constatns used for loaders
		private static const FRIENDS:String = "friends";
		private static const FRIENDS_TIMELINE:String = "friendsTimeline";
		private static const PUBLIC_TIMELINE:String = "timeline";
		private static const USER_TIMELINE:String = "userTimeline";
		private static const SET_STATUS:String = "setStatus";
		private static const FOLLOW_USER:String = "follow";
		private static const BEFRIEND_USER:String = "befriend";
		private static const SHOW_STATUS:String = "showStatus";
		private static const REPLIES_TIMELINE:String = "replies";
		private static const DIRECT_MESSAGES_TIMELINE:String = "direct_messages";
		private static const DESTROY:String = "destroy";
		private static const FOLLOWERS:String = "followers";
		private static const FEATURED:String = "featured";
		private static const BLOCK_USER:String = "block";
		private static const RATE_LIMIT_STATUS:String = "rateLimitStatus";
		
		public static const TWITTER_SERVER:String =
			"http://twitter.com/";		
			
		private static const LOAD_FRIENDS_URL:String = 			
			"statuses/friends/$userId.xml";
		private static const LOAD_FRIENDS_TIMELINE_URL:String = 
// LATER			"statuses/friends_timeline/$userId.xml";
			"statuses/friends_timeline.xml";			
		private static const PUBLIC_TIMELINE_URL:String = 
			"statuses/public_timeline.xml"
		private static const LOAD_USER_TIMELINE_URL:String = 
			"statuses/user_timeline/$userId.xml"
		private static const FOLLOW_USER_URL:String = 
			"notifications/follow/$userId.xml";
		private static const BEFRIEND_USER_URL:String = 
			"friendships/create/$userId.xml";
		private static const SET_STATUS_URL:String = 
			"statuses/update.xml";
		private static const SHOW_STATUS_URL:String = 
			"statuses/show/$id.xml";
		private static const REPLIES_TIMELINE_URL:String = 
			"statuses/replies.xml";
		private static const DIRECT_MESSAGES_TIMELINE_URL:String = 
			"direct_messages.xml";
		private static const DESTROY_URL:String = 
			"statuses/destroy/$id.xml";
		private static const FOLLOWERS_URL:String = 
			"statuses/followers.xml";
		private static const FEATURED_USERS_URL:String = 
			"statuses/featured.xml";
		private static const BLOCK_USER_URL:String = 
			"blocks/create/$userId.xml";
		private static const RATE_LIMIT_STATUS_URL:String = 
			"account/rate_limit_status.xml";
		private static const LITE:String = "?lite=true";
		
		// Alternate server?
		private var _server:String;
		// internal variables
		private var loaders:Array;
		// username and password currently not used, just rely on HTTP auth
		private var _username:String;
		private var _password:String;
		
		function Twitter(reqServer:String, reqUsername:String, reqPassword:String) 
		{
			_server = reqServer;
			setAuth(reqUsername, reqPassword);			
			loaders = [];
			this.addLoader(FRIENDS, friendsHandler);
			this.addLoader(FRIENDS_TIMELINE, friendsTimelineHandler);
			this.addLoader(PUBLIC_TIMELINE, publicTimelineHandler);
			this.addLoader(USER_TIMELINE, userTimelineHandler);
			this.addLoader(SET_STATUS, setStatusHandler);
			this.addLoader(FOLLOW_USER, followUserHandler);
			this.addLoader(BEFRIEND_USER, friendCreatedHandler);
			this.addLoader(SHOW_STATUS, showStatusHandler);
			this.addLoader(REPLIES_TIMELINE, repliesTimelineHandler);
			this.addLoader(DIRECT_MESSAGES_TIMELINE, directMessagesTimelineHandler);
			this.addLoader(DESTROY, destroyHandler);
			this.addLoader(FOLLOWERS, followersHandler);
			this.addLoader(FEATURED, featuredHandler);
			this.addLoader(BLOCK_USER, blockHandler);
			this.addLoader(RATE_LIMIT_STATUS, rateLimitStatusHandler);
		}
			
		// Public API
		public function get unique():String
		{
			return _server + '$' + _username;
		}
		public function get server():String
		{
			return _server;
		}
		public function get username():String
		{
			return _username;
		}
		
		/**
		* Loads a list of Twitter friends and (optionally) their statuses. 
		 * Authentication required for private users.
		*/
		public function loadFriends(userId:String, lite:Boolean = true):void
		{
			var friendsLoader:URLLoader = this.getLoader(FRIENDS);
			var urlStr:String = server + LOAD_FRIENDS_URL.replace("$userId", userId);
			if (lite){
				urlStr += LITE;
			}
			friendsLoader.load(twitterRequest(urlStr));
		}
		/**
		* Loads the timeline of all friends on Twitter. Authentication required for private users.
		*/
		public function loadFriendsTimeline(userId:String):void
		{			
			var friendsTimelineLoader:URLLoader = this.getLoader(FRIENDS_TIMELINE);
			friendsTimelineLoader.load(twitterRequest(server + LOAD_FRIENDS_TIMELINE_URL.replace("$userId",userId)));
		}
		/**
		* Loads the timeline of all public users on Twitter.
		*/
		public function loadPublicTimeline():void
		{
			var publicTimelineLoader:URLLoader = this.getLoader(PUBLIC_TIMELINE);
			publicTimelineLoader.load(twitterRequest(server + PUBLIC_TIMELINE_URL));
		}
		/**
		* Loads the timeline of a specific user on Twitter. Authentication required for private users.
		*/
		public function loadUserTimeline(userId:String):void
		{
			var userTimelineLoader:URLLoader = this.getLoader(USER_TIMELINE);
			userTimelineLoader.load(twitterRequest(server + LOAD_USER_TIMELINE_URL.replace("$userId", userId)));
		}
		
		/**
		 * Follows a user.
		 */
		public function follow(userId:String):void
		{
			var req:URLRequest = twitterRequest(server + FOLLOW_USER_URL.replace("$userId",userId));
			req.method = "POST";
			this.getLoader(FOLLOW_USER).load(req);
		}

		/**
		 * Befriends a user. Right now this uses the /friendships/create/user.format
		 */
		public function befriend(userId:String):void
		{
			var req:URLRequest = twitterRequest(server + BEFRIEND_USER_URL.replace("$userId",userId));
			req.method = "POST";
			this.getLoader(BEFRIEND_USER).load(req);
		}

		/**
		* Sets user's Twitter status. Authentication required.
		*/
		public function setStatus(statusString:String):void
		{
			if (statusString.length <= 140)
			{
				var request : URLRequest = twitterRequest (server + SET_STATUS_URL);
				request.method = "POST"
				var variables : URLVariables = new URLVariables ();
				variables.status = statusString;
				request.data = variables;
				try
				{
					this.getLoader(SET_STATUS).load (request);
				} catch (error : Error)
				{
					trace ("Unable to set status");
				}
			} else 
			{
				trace ("STATUS NOT SET: status limited to 140 characters");
			}
		}
		
		/**
		 * Returns a single status, specified by the id parameter below.  
		 * The status's author will be returned inline.
		 */
		public function showStatus(id:String):void
		{
			var showStatusLoader:URLLoader = this.getLoader(SHOW_STATUS);
			showStatusLoader.load(twitterRequest(server + SHOW_STATUS_URL.replace("$id",id)));
		}
		
		/**
		 * Loads the most recent replies for the current authenticated user
		 */
		public function loadRepliesTimeline():void
		{
			var repliesLoader:URLLoader = this.getLoader(REPLIES_TIMELINE);
			repliesLoader.load(twitterRequest(server + REPLIES_TIMELINE_URL));
		}
		
		public function loadDirectMessagesTimeline():void
		{
			var directMessagesLoader:URLLoader = this.getLoader(DIRECT_MESSAGES_TIMELINE);
			directMessagesLoader.load(twitterRequest(server + DIRECT_MESSAGES_TIMELINE_URL));
		}

		public function loadFollowers(lite:Boolean=true):void
		{
			var followersLoader:URLLoader = this.getLoader(FOLLOWERS);
			var urlStr:String = server + FOLLOWERS_URL;
			if (lite){
				urlStr += LITE;
			}
			followersLoader.load(twitterRequest(urlStr));
		}
		
		public function loadFeatured():void
		{
			var featuredLoader:URLLoader = this.getLoader(FEATURED);
			featuredLoader.load(twitterRequest(server + FEATURED_USERS_URL));
		}
		
		public function block(userId:String):void
		{
			var req:URLRequest = twitterRequest(server + BLOCK_USER_URL.replace("$userId",userId));
			req.method = "POST";
			this.getLoader(BLOCK_USER).load(req);
		}		
		
		public function rateLimitStatus():void
		{
			var req:URLRequest = twitterRequest(server + RATE_LIMIT_STATUS_URL);
			req.method = "POST";
			this.getLoader(RATE_LIMIT_STATUS).load(req);
		}		

		// currently unused
		/**
		*  setAuth should be called before any methods that require authentication. PLEASE USE WITH CAUTION, Twitter user information should NOT be hardcoded in applications that are publicly available
		*/
		public function setAuth (username:String, password:String):void
		
		{	
			_username = username;
			_password = password;
		}		
		
		// private handlers for the events coming back from twitter
		
		private function friendsHandler(e:Event):void {
			try {
				var xml:XML = new XML(this.getLoader(FRIENDS).data);
				var userArray:Array = new Array();
	            for each (var tempXML:XML in xml.children()) {
					var twitterUser:TwitterUser = new TwitterUser(tempXML);
	                userArray.push(twitterUser);
	            }
				var r:TwitterEvent = new TwitterEvent (TwitterEvent.ON_FRIENDS_RESULT);
				r.identity(server, username);
				r.data = userArray;			
				dispatchEvent (r);
			} catch (error : Error) {
				unhandledErrorHandler(error, TwitterEvent.ON_FRIENDS_RESULT);
			}			
		}
			
		private function friendsTimelineHandler(e:Event):void {
			try {
				var xml:XML = new XML(this.getLoader(FRIENDS_TIMELINE).data);
				var statusArray:Array = new Array();
	            for each (var tempXML:XML in xml.children()) {
					var twitterStatus:TwitterStatus = new TwitterStatus (tempXML);
					twitterStatus.identity(server, username);
					twitterStatus.interaction = TwitterEvent.ON_FRIENDS_TIMELINE_RESULT;
	                statusArray.push(twitterStatus );
	            }
				var r:TwitterEvent = new TwitterEvent (TwitterEvent.ON_FRIENDS_TIMELINE_RESULT);
				r.identity(server, username);
				r.data = statusArray;
				dispatchEvent (r);
			} catch (error : Error) {
				unhandledErrorHandler(error, TwitterEvent.ON_FRIENDS_TIMELINE_RESULT);
			}
		}
		
		private function publicTimelineHandler(e:Event) :void{
			try {
				var xml:XML = new XML(this.getLoader(PUBLIC_TIMELINE).data);
				var statusArray:Array = new Array();
	            for each (var tempXML:XML in xml.children()) {
					var twitterStatus:TwitterStatus = new TwitterStatus (tempXML);
					twitterStatus.identity(server, username);
					twitterStatus.interaction = TwitterEvent.ON_PUBLIC_TIMELINE_RESULT;
	                statusArray.push(twitterStatus );
	            }
				var r:TwitterEvent = new TwitterEvent (TwitterEvent.ON_PUBLIC_TIMELINE_RESULT);
				r.identity(server, username);
				r.data = statusArray;
				dispatchEvent (r);
			} catch (error : Error) {
				unhandledErrorHandler(error, TwitterEvent.ON_PUBLIC_TIMELINE_RESULT);
			}			
		}
		
		private function userTimelineHandler(e:Event):void {
			try {
				var xml:XML = new XML(this.getLoader(USER_TIMELINE).data);
				var statusArray:Array = new Array();
	            for each (var tempXML:XML in xml.children()) {
					var twitterStatus:TwitterStatus = new TwitterStatus (tempXML)
					twitterStatus.identity(server, username);
					twitterStatus.interaction = TwitterEvent.ON_USER_TIMELINE_RESULT;
	                statusArray.push(twitterStatus );
	            }
				var r:TwitterEvent = new TwitterEvent (TwitterEvent.ON_USER_TIMELINE_RESULT);
				r.identity(server, username);
				r.data = statusArray;
				dispatchEvent (r);
			} catch (error : Error) {
				unhandledErrorHandler(error, TwitterEvent.ON_USER_TIMELINE_RESULT);
			}			
		}
		
		
		private function setStatusHandler (e : Event) : void{
			var r:TwitterEvent = new TwitterEvent (TwitterEvent.ON_SET_STATUS);
			r.identity(server, username);
			r.data = "success";
			dispatchEvent (r);
		}
		
		private function followUserHandler (e:Event) : void{
			trace("Following user " + this.getLoader(FOLLOW_USER).data);
		}

		private function friendCreatedHandler (e:Event) : void{
			trace("Friend created " + this.getLoader(BEFRIEND_USER).data);
		}
		
		private function showStatusHandler(e:Event):void
		{
			try {
				var xml:XML = new XML(this.getLoader(SHOW_STATUS).data);
				var twitterStatus:TwitterStatus = new TwitterStatus(xml);
				twitterStatus.identity(server, username);
				var twitterEvent:TwitterEvent = new TwitterEvent(TwitterEvent.ON_SHOW_STATUS);
				twitterEvent.identity(server, username);
				twitterEvent.data = twitterStatus as Object;
				dispatchEvent(twitterEvent);
			} catch (error : Error) {
				unhandledErrorHandler(error, TwitterEvent.ON_SHOW_STATUS);
			}			
		}
		
		private function repliesTimelineHandler(e:Event):void
		{
			try {
				var xml:XML = new XML(this.getLoader(REPLIES_TIMELINE).data);
				var statusArray:Array = [];
				for each(var reply:XML in xml.children())
				{
					var twitterStatus:TwitterStatus = new TwitterStatus(reply);
					twitterStatus.identity(server, username);
					twitterStatus.interaction = TwitterEvent.ON_REPLIES_TIMELINE_RESULT;
					statusArray.push(twitterStatus);
				}
				var twitterEvent:TwitterEvent = new TwitterEvent(TwitterEvent.ON_REPLIES_TIMELINE_RESULT);
				twitterEvent.identity(server, username);
				twitterEvent.data = statusArray;
				dispatchEvent(twitterEvent);
			} catch (error : Error) {
				unhandledErrorHandler(error, TwitterEvent.ON_REPLIES_TIMELINE_RESULT);
			}			
		}
		
		private function directMessagesTimelineHandler(e:Event):void
		{
			try {
				var xml:XML = new XML(this.getLoader(DIRECT_MESSAGES_TIMELINE).data);
				var statusArray:Array = [];
				for each(var directMessage:XML in xml.children())
				{
					var twitterStatus:TwitterStatus = new TwitterStatus(directMessage);
					twitterStatus.identity(server, username);
					twitterStatus.interaction = TwitterEvent.ON_DIRECT_MESSAGES_TIMELINE_RESULT;
					statusArray.push(twitterStatus);
				}
				var twitterEvent:TwitterEvent = new TwitterEvent(TwitterEvent.ON_DIRECT_MESSAGES_TIMELINE_RESULT);
				twitterEvent.identity(server, username);
				twitterEvent.data = statusArray;
				dispatchEvent(twitterEvent);
			} catch (error : Error) {
				unhandledErrorHandler(error, TwitterEvent.ON_DIRECT_MESSAGES_TIMELINE_RESULT);
			}			
		}

		private function destroyHandler(e:Event):void
		{
			var r:TwitterEvent = new TwitterEvent (TwitterEvent.ON_DESTROY);
			r.identity(server, username);
			r.data = "success";
			dispatchEvent (r);
		}
		
		private function unhandledErrorHandler(error:Error, where:String):void
		{
				trace("Unhandled Error: " + error.toString());
				var r:TwitterEvent = new TwitterEvent (where);
				r.identity(server, username);
				r.data = null;
				dispatchEvent (r);
		}
		
		private function errorHandler (errorEvent : IOErrorEvent) : void
		{
			trace ("errorHandler: " + errorEvent.text);
			var r:TwitterEvent = new TwitterEvent(TwitterEvent.ON_ERROR);
			r.identity(server, username);
			r.data = errorEvent;
			dispatchEvent(r);
		}
		private function ioErrorHandler (errorEvent : HTTPStatusEvent) : void
		{
			trace ("ioErrorHandler: " + errorEvent.status);
			var r:TwitterEvent = new TwitterEvent(TwitterEvent.ON_ERROR);
			r.identity(server, username);
			r.data = errorEvent;
			dispatchEvent(r);
		}
		
		private function followersHandler(e:Event):void
		{
			try {			
				var xml:XML = new XML(this.getLoader(FOLLOWERS).data);
				var userArray:Array = new Array();
	            for each (var tempXML:XML in xml.children()) {
					var twitterUser:TwitterUser = new TwitterUser(tempXML);
	                userArray.push(twitterUser);
	            }
				var r:TwitterEvent = new TwitterEvent (TwitterEvent.ON_FOLLOWERS);
				r.identity(server, username);
				r.data = userArray;
				dispatchEvent (r);
			} catch (error : Error) {
				unhandledErrorHandler(error, TwitterEvent.ON_FOLLOWERS);
			}			
		}
		
		private function featuredHandler(e:Event):void
		{
			try {
				var xml:XML = new XML(this.getLoader(FEATURED).data);
				var userArray:Array = new Array();
	            for each (var tempXML:XML in xml.children()) {
					var twitterUser:TwitterUser = new TwitterUser(tempXML);
	                userArray.push(twitterUser);
	            }
				var r:TwitterEvent = new TwitterEvent (TwitterEvent.ON_FEATURED);
				r.identity(server, username);
				r.data = userArray;
				dispatchEvent (r);
			} catch (error : Error) {
				unhandledErrorHandler(error, TwitterEvent.ON_FEATURED);
			}			
		}
		
		private function blockHandler(e:Event) : void
		{
			trace("Blocking user " + this.getLoader(BLOCK_USER).data);
		}
		
		private function rateLimitStatusHandler(e:Event):void
		{
			try {
				var xml:XML = new XML(this.getLoader(RATE_LIMIT_STATUS).data);
				var r:TwitterEvent = new TwitterEvent(TwitterEvent.ON_RATE_LIMIT_STATUS);
				r.identity(server, username);
				r.data = xml;
				dispatchEvent(r);			
			} catch (error : Error) {
				unhandledErrorHandler(error, TwitterEvent.ON_RATE_LIMIT_STATUS);
			}			
		}
		
		// private helper methods
		
		private function addLoader(name:String, completeHandler:Function):void
		{
			var loader:URLLoader = new URLLoader();
			
			loader.addEventListener(Event.COMPLETE, completeHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			// See these two guys below? Listening to them means no unwanted 'error 20xx' message dialog
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, ioErrorHandler);
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, ioErrorHandler);
			this.loaders[name] = loader;
		}
		
		private function getLoader(name:String):URLLoader
		{
			return this.loaders[name] as URLLoader;
		}
		
		private function twitterRequest (URL : String):URLRequest
		{
			var r:URLRequest = new URLRequest(URL);
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(_username + ":" + _password);
			var encoder:Base64Encoder = new Base64Encoder();
			encoder.encodeBytes(bytes);
			// NO: Replaced 'authorization' with 'HTTP_AUTHORIZATION' because Mr. Web said so. @todo Figure it out.
			// Later: when did I go back to 'authorization'? Anyway...it works.
			r.requestHeaders.push(new URLRequestHeader("authorization", "Basic " + encoder.flush()));
			return r;
		}
	}
}