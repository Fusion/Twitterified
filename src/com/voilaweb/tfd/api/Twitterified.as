package com.voilaweb.tfd.api {

	import com.voilaweb.tfd.Logger;	
	import com.adobe.serialization.json.JSON;
	import com.voilaweb.tfd.api.data.TwitterifiedStatus;
	import com.voilaweb.tfd.api.events.TwitterifiedEvent;
	
	import flash.events.*;
	import flash.net.*;
	import flash.xml.*;
	
	import mx.controls.Alert;	
	
	public class Twitterified extends EventDispatcher
	{
		private static const RETRIEVE:String = "retrieve";
		private static const UPDATE:String = "update";
		
		private static const RETRIEVE_URL:String = 
			"http://twitterified.com/index.php/api/retrieve/?source=Twitterified&ids=$ids";
		private static const UPDATE_URL:String = 
			"http://twitterified.com/index.php/api/update/?source=Twitterified&type=$type&ref=$ref&link=$link&uid=$uid&status=$status&extra=$extra";

		public static const RESERVED:Array = new Array(
		{
			'on':		true,
			'off':		true,
			'stop':		true,
			'quit':		true, 
			'follow':	true, 
			'leave':	true, 
			'whois':	true, 
			'get':		true,
			'nudge':	true, 
			'fav':		true, 
			'stats':	true, 
			'invite':	true
		});
		
		public var msg:String;
		public var kwrd:String;
		public var dest:String;
		public var sendAsIs:Boolean;
				
		// internal variables
		private var loaders:Array;
		
		function Twitterified() 
		{
			loaders = [];
			this.addLoader(RETRIEVE, retrieveHandler);
			this.addLoader(UPDATE, updateHandler);
		}
	
		// Public API
		
		public function retrieve(ids:String):void
		{
			Logger.info("Loading "+ids);
			var retrieveLoader:URLLoader = this.getLoader(RETRIEVE);
			var urlStr:String = RETRIEVE_URL.replace("$ids", ids);
			retrieveLoader.load(twitterifiedRequest(urlStr));
		}

		public function update(type:String, ref:int, link:String, uid:String, status:String, extra:String):void
		{
			msg = status;
			var updateLoader:URLLoader = this.getLoader(UPDATE);
			var urlStr:String = 
				UPDATE_URL.
					replace("$type", type).
					replace("$ref", ref.toString()).
					replace("$link", link).
					replace("$uid", uid).
					replace("$status", encodeURIComponent(status)).
					replace("$extra", encodeURIComponent(extra));
			updateLoader.load(twitterifiedRequest(urlStr));
		}		
		
		private function retrieveHandler(e:Event):void
		{
			var json:Object = JSON.decode(this.getLoader(RETRIEVE).data);
			if(json.diag!='OK')
			{
				Alert.show("Twitterified API Error: "+json.error);
				return;
			}
			// contents is an array of objects: link => link, type, text, extra, direct, subtype
			var statusArray:Array = new Array();
			var status:Object;
			for each(status in json.contents)
			{
				var twitterifiedStatus:TwitterifiedStatus = new TwitterifiedStatus(status);
				Logger.info("RETURNED "+twitterifiedStatus.text+":"+twitterifiedStatus.extra);
				statusArray.push(twitterifiedStatus);
				// CFR: Awesome! I cannot believe it!
				// When adding entries the associative way (no "push"), array.length remains stuck at zero
				// therefore it is not possible to know an associative array's length.
				// Am I missing something here?
			}
			var r:TwitterifiedEvent = new TwitterifiedEvent (TwitterifiedEvent.ON_RETRIEVE_RESULT);
			r.data = statusArray;			
			dispatchEvent (r);
		}
			
		private function updateHandler(e:Event):void
		{
			var json:Object = JSON.decode(this.getLoader(UPDATE).data);
			if(json.diag!='OK')
			{
				Alert.show("Twitterified API Error: "+json.error);
				return;
			}
			var r:TwitterifiedEvent = new TwitterifiedEvent (TwitterifiedEvent.ON_DELEGATE_UPDATE);
			switch(json.type)
			{
				case 'i':
				case 'e':
					r.data = buildUpdateLink('pic', msg, 'View', json.url, kwrd, dest);		
					break;
				case 'v':
					r.data = buildUpdateLink('vid', msg, 'Watch', json.url, kwrd, dest);		
					break;
				default:
					r.data = buildUpdateLink('txt', msg, 'Read', json.url, kwrd, dest);		
			}
			dispatchEvent (r);
		}

		private function errorHandler (errorEvent : IOErrorEvent) : void
		{
			trace (errorEvent.text);
		}
		
		// private helper methods
		private function buildUpdateLink(code:String, lMsg:String, action:String, url:String, lKwrd:String, lDest:String):String	
		{
			// len: '[pic] '.length + '\nRead: '.length + ret.url.length)
			// len: 12 + ret.url.length
			var bu:String;
			url = unescape(url);
			var len:int = 139 - (16 + url.length);
			if(lDest)
				len -= (lKwrd.length + lDest.length+1);
			var excerpt:String = lMsg.substr(0, len);
			if(lDest)
				bu = lKwrd+lDest+' ['+code+'] '+excerpt+"... "+action+': '+url;
			else
				bu = '['+code+'] '+excerpt+'... '+action+': '+url;
			return bu;			
		}

		private function addLoader(name:String, completeHandler:Function):void
		{
			var loader:URLLoader = new URLLoader();
			
			loader.addEventListener(Event.COMPLETE, completeHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			this.loaders[name] = loader;
		}
		
		private function getLoader(name:String):URLLoader
		{
			return this.loaders[name] as URLLoader;
		}
		
		private function twitterifiedRequest (URL : String):URLRequest
		{
			var r:URLRequest = new URLRequest (URL);
			return r;
		}
	}
}