package summize.api {
	
	import com.adobe.serialization.json.JSON;
	
	import flash.events.*;
	import flash.net.*;
	import flash.xml.*;
	
	import summize.api.data.SummizeStatus;
	import summize.api.events.SummizeEvent;
	
	// An interesting piece of information regarding summize.com:
	// among other things, it returns a 'next_page' variable and its value
	// is something like '?page=2&max_id=....&q=query'
	public class Summize extends EventDispatcher
	{
		private static const SEARCH:String = "search";
		
		private static const SEARCH_URL:String = 
			"http://search.twitter.com/search.json?q=$query";
		
		// internal variables
		private var loaders:Array;
		
		function Summize() 
		{
			loaders = [];
			this.addLoader(SEARCH, searchHandler);
		}
	
		// Public API
		
		public function search(query:String):void
		{
			var searchLoader:URLLoader = this.getLoader(SEARCH);
			var urlStr:String = SEARCH_URL.replace("$query", escape(query));
			searchLoader.load(summizeRequest(urlStr));
		}
		
		private function searchHandler(e:Event):void {
			var json:Object = JSON.decode(this.getLoader(SEARCH).data);
			var statusArray:Array = new Array();
			var status:Object;
			for each(status in json.results)
			{
				var summizeStatus:SummizeStatus = new SummizeStatus(status);
				statusArray.push(summizeStatus);
			}
			var r:SummizeEvent = new SummizeEvent (SummizeEvent.ON_SEARCH_RESULT);
			r.data = statusArray;
			dispatchEvent (r);
		}
			
		private function errorHandler (errorEvent : IOErrorEvent) : void
		{
			trace (errorEvent.text);
		}
		
		// private helper methods
		
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
		
		private function summizeRequest (URL : String):URLRequest
		{
			var r:URLRequest = new URLRequest (URL);
			return r;
		}
	}
}