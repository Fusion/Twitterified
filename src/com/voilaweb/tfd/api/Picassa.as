package com.voilaweb.tfd.api {

	import com.adobe.serialization.json.JSON;
	import com.voilaweb.tfd.Logger;
	
	import flash.events.*;
	import flash.net.*;
	import flash.xml.*;
	
	import mx.controls.Alert;	
	
	public class Picassa extends EventDispatcher
	{
		private static const AUTH:String = "auth";
		private static const UPLOAD:String = "upload";
		
		private static const AUTH_URL:String = 
			"https://www.google.com/accounts/ClientLogin?accountType=GOOGLE&Email=$email&Passwd=$password&service=lh2&source=VoilaWeb-Twitterified-v1.0";
		private static const UPLOAD_URL:String = 
			"http://picasaweb.google.com/data/feed/api/user/$user/album/$album";

		// internal variables
		private var loaders:Array;
		
		function Picassa() 
		{
			loaders = [];
			this.addLoader(AUTH, authHandler);
			this.addLoader(UPLOAD, uploadHandler);
		}
	
		// Public API
		
		public function auth(name:String, password:String):void
		{
			Logger.info("Authenticating "+name);
			var authLoader:URLLoader = this.getLoader(AUTH);
			var urlStr:String = AUTH_URL.replace("$email", name).replace("$password", password);
			var request:URLRequest = picassaRequest(urlStr);
			request.requestHeaders.push(new URLRequestHeader("Content-Type", "application/x-www-form-urlencoded"));
			authLoader.load(request);			
		}
		
		public function upload(user:String, album:String, name:String, content:String):void
		{
			Logger.info("Uploading "+name);
			var uploadLoader:URLLoader = this.getLoader(UPLOAD);
			var urlStr:String = UPLOAD_URL.replace("$user", user).replace("$album", album);
			var request:URLRequest = picassaRequest(urlStr);
			request.requestHeaders.push(new URLRequestHeader("Content-Type", "image/jpeg"));
			request.requestHeaders.push(new URLRequestHeader("Content-Length", content.length.toString()));
			request.requestHeaders.push(new URLRequestHeader("Slug", name)); 
			request.data = content;
			uploadLoader.load(request);
		}

		private function authHandler(e:Event):void
		{
			var obj:Object = this.getLoader(AUTH).data;	
		}
		
		private function uploadHandler(e:Event):void
		{
			var json:Object = JSON.decode(this.getLoader(UPLOAD).data);
			if(json.diag!='OK')
			{
				Alert.show("Picassa API Error: "+json.error);
				return;
			}
		}


		private function errorHandler (errorEvent : IOErrorEvent) : void
		{
			trace (errorEvent.text);
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
		
		private function picassaRequest(URL : String):URLRequest
		{
			var r:URLRequest = new URLRequest (URL);			
			return r;
		}
	}
}