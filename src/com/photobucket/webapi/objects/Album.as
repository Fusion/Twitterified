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
	import com.photobucket.webapi.interfaces.IAlbum;
	import com.photobucket.webapi.interfaces.IMedia;
	import com.photobucket.webapi.oauth.OAuthRequest;
	import com.photobucket.webapi.oauth.OAuthRequestMethod;
	
	import flash.events.Event;
	import flash.net.FileReference;
	
	import mx.collections.ArrayCollection;
	import mx.events.DynamicEvent;
	
	/**
	 * Represents a album on photobucket and all the associated actions that can be taken
	 * @author jlewark
	 * 
	 */
	public class Album extends PhotobucketRemoteObject implements IAlbum
	{
		
		protected var _albumURL:String;

		protected var _privacy:String;
		protected var _photo_count:int = 0;
		protected var _subalbum_count:int = 0;
		protected var _video_count:int = 0;
		protected var _name:String;
		protected var _mediaTypes:Object = new Object();
		protected var _media:ArrayCollection;
		protected var subAlbums:ArrayCollection;
		protected var subAlbumsLoaded:Boolean = false;
		protected var _parent:IAlbum;
		protected var invalid:Boolean = false;
		
		/**
		 * Constructor:  Optionally takes the URL and/or the data repesenation of the XML 
		 * @param albumURL
		 * @param owner
		 * 
		 */
		public function Album(albumURL:String = null, data:Object = null) {
			super();
			_albumURL = unescape(albumURL);
			server = _albumURL;
			id = _albumURL;
			_name = unescape(id).match(/[^\/]+$/)[0];
			this.data = data;
			dispatchEvent(new Event("urlUpdated"));
		}

		[Bindable(event="urlUpdated")]
		/**
		 * Returns the URL that can be used to access the album 
		 * @return 
		 * 
		 */
		public function get url():String {
			return _albumURL.replace(/\/$/, "");			
		}

		[Bindable(event="complete")]
		/**
		 * Returns the name of the album 
		 * @return 
		 * 
		 */
		public function get name():String {
			return _name;
		}
		
		[Bindable(event="complete")]
		/**
		 * Gets the photo_count in the current album if it has been retrived by the api 
		 * @return 
		 * 
		 */		
		public function get photo_count():int {
			return _photo_count;
		}

		[Bindable(event="complete")]		
		/**
		 * gets the sub album count of the current ablum if it has been retrived by the api 
		 * @return 
		 * 
		 */
		public function get subalbum_count():int {
			return _subalbum_count;
		}
		
		[Bindable(event="complete")]
		/**
		 * gets the video count of the current album if it has been retrived by the api 
		 * @return 
		 * 
		 */
		public function get video_count():int {
			return _video_count;
		}
		


		/**
		 * Sets the id of the album based on the url or directly. The ID is the 
		 * username + path of the album
		 * @param value
		 * 
		 */		
		override public function set id(value:String):void {
			try {
				if (value.indexOf("http") >= 0) {
					var pathParse:RegExp = /^([^\/]*\/){5}(?P<path>[^?]+[^\/\?]($)?)((\/[^\/]+\.[a-zA-Z]{3,4}(\?[^\?]*$|$))|\/$|\?$|\/\?|$)+/;
					var values:Array = pathParse.exec(value);
					super.id = values.path;
				} else {
					super.id = value;
				}
			} catch (error:Error) {
				var i:int = 0;
				i++;
				i++;
			}
		}
		
		[Bindable(event="subAlbumsUpdated")]	
		/**
		 * Returns an Array Collection of the current album's subalbums
		 * @return 
		 * 
		 */
		public function get sub_albums():ArrayCollection {
			if (subAlbums == null) {
					subAlbums = new ArrayCollection();
			}
			if (subAlbumsLoaded == false) {
				subAlbumsLoaded = true;
				var subAlbumParent:IAlbum = this;
				var request:OAuthRequest = new OAuthRequest();
				request.url = server+"/album/" + id;
				request.addParameter("media", "none");
				request.result = function (value:Object):void {
					data = value;
					var results:XML = value as XML;
					for each (var subAlbumXML:XML in results.album..album) {
						var newAlbum:IAlbum = pbservice.albumFactory(url+"/"+subAlbumXML.@name, subAlbumXML);
						newAlbum.parent= subAlbumParent;
						subAlbums.addItem(newAlbum);
					}
					dispatchEvent(new Event("subAlbumsUpdated"));
					subAlbumsLoaded = true;
				}
				request.fault = this.fault
				pbservice.makeRequest(request);				
			} 
			return subAlbums;
		}
		
		
		/**
		 * Gets the media of the secific type in an array collection.  This collection will populate as the result is returned.  It will
		 * trigger the COLLECTION_CHANGED event as items are added.   We can also populate the sub album list if its not there already because
		 * we get that info anyway.
		 * @param type
		 * @return 
		 * 
		 */		
		public function getMedia(type:String = "image"):ArrayCollection {
			if (type == "all") {
				if (_mediaTypes.hasOwnProperty("image")&&_mediaTypes.hasOwnProperty("video")) {
					return _media;
				}
			}
			if (subAlbums == null) {
				subAlbums = new ArrayCollection();
			}
			if (_mediaTypes.hasOwnProperty(type)) {
				return _mediaTypes[type];
			} else {
				if (_media == null) {
					_media = new ArrayCollection();
					dispatchEvent(new Event("mediaChanged"));
				}
				var parentRef:IAlbum = this;
				var request:OAuthRequest = new OAuthRequest();
				request.needsLogin = true;
				request.url = server+"/album/" + id;
				request.addParameter("media", type);
				request.result = function (value:Object):void {
					data = value;
					var results:XML = value as XML;
					for each (var mediaXML:XML in results..media) {
						var mediaObj:IMedia = pbservice.mediaFactory(null, mediaXML);
						mediaObj.album = parentRef;
						_media.addItem(mediaObj);
						if (_mediaTypes.hasOwnProperty(mediaObj.type) == false) {
							_mediaTypes[mediaObj.type] = new ArrayCollection();
							dispatchEvent(new Event(mediaObj.type + "Changed"));
						}
						ArrayCollection(_mediaTypes[mediaObj.type]).addItem(mediaObj);
					}
					if (subAlbumsLoaded == false) {
						for each (var subAlbumXML:XML in results.album..album) {
							var newAlbum:IAlbum = pbservice.albumFactory(url+"/"+subAlbumXML.@name, subAlbumXML);
							newAlbum.parent = parentRef;
							subAlbums.addItem(newAlbum);
						}
						subAlbumsLoaded = true;
						dispatchEvent(new Event("subAlbumsUpdated"));
					}
				}
				request.fault = this.fault
				pbservice.makeRequest(request);
			}
			if (type == "all") {
				return _media;
			}
			return _mediaTypes[type] as ArrayCollection;
		}
		
		[Bindable(event="mediaChanged")]
		/**
		 * Returns all media for the album that is available though the API 
		 * @return 
		 * 
		 */
		public function get media():ArrayCollection {
			return this.getMedia("all");
		}
		
		
		/**
		 * Lasy function for returning just the images from an album 
		 * @see getMedia
		 * @return 
		 * 
		 */
		[Bindable(event="imageChanged")]
		public function get images():ArrayCollection {
			return this.getMedia("image");
		}
		
		/**
		 * Lasy function for return just the videos from an album
		 * @see getMedia
		 * @return 
		 * 
		 */		
		[Bindable(event="videoChanged")]
		public function get video():ArrayCollection {
			return this.getMedia("video");
		}
		

		[Bindable(event='privacyUpdated')]
		/**
		 * Returns the current privacy level of the album 
		 * @return 
		 * 
		 */		
		public function get privacy():String {
			if (_privacy == null) {
				var request:OAuthRequest = new OAuthRequest();
				request.url = server+"/album/" + id +"/privacy";
				request.fault = this.fault;
				request.result = function (result:Object):void {
					_privacy = result.privacy.toString();
					dispatchEvent(new Event('privacyUpdated'));
				}
				pbservice.makeRequest(request);
			}
			return _privacy;
		}
		
		/**
		 * Set the album to public or private 
		 * @param value
		 * 
		 */		
		public function set privacy(value:String):void {
			if (_privacy != value) {
				if ((value == "private") || (value == "public")) {
					invalid = true;
					_privacy = value;
				}
			}
		}

		[Bindable(event="subAlbumCreated")]
		/**
		 * Creates a subalum in the current album with the name given.  It will add it to the subalbum collection
		 * if it has already been retrived 
		 * @param name
		 * 
		 */
		public function createSubAlbum(name:String):void {
			var request:OAuthRequest = new OAuthRequest();
			request.method = OAuthRequestMethod.POST;
			request.needsLogin = true;
			request.addParameter("name", name);
			request.url = server+"/album/" + id;
			request.fault = this.fault;
			request.result = function (result:Object):void {
				if (subAlbumsLoaded) {
					var newAlbum:IAlbum = pbservice.albumFactory(url + "/"+name);
					subAlbums.addItem(newAlbum);
				}
				dispatchEvent(new Event("subAlbumCreated"));//CFR
			}
			pbservice.makeRequest(request);
		}
		
		/**
		 * Renames the current album... all children of the album are now invalid as their links will
		 * no longer function.  It is recommed you re-retrive the album again.
		 * @param newName
		 * 
		 */
		public function rename(newName:String):void {
			var request:OAuthRequest = new OAuthRequest();
			request.method = OAuthRequestMethod.PUT;
			request.needsLogin = true;
			request.addParameter("name", newName);
			request.url = server+"/album/" + id;
			request.fault = this.fault;
			request.result = function (result:Object):void {
				id = id.replace(name, newName);
				_albumURL = _albumURL.replace(name, newName);
				_name = newName;
				dispose();
			}
			pbservice.makeRequest(request);
		}
				
		[Bindable(event="fileUploaded")]		
		/**
		 * Uploads a FileReference or File object up to the server.
		 * @param file
		 * @param type
		 * @param title
		 * @param description 
		 */
		public function uploadFile(file:FileReference, type:String = "image", title:String = null, description:String = null):void {
			var request:OAuthRequest = new OAuthRequest();
			request.url = server+"/album/" + id +"/upload";
			request.file = file;
			request.addParameter("type", type);
			if (title != null) {
				request.addParameter("title", title);
				request.addParameter("description", description);
			}
			request.needsLogin = true;
			request.method = OAuthRequestMethod.POST;
			request.fault = this.fault;
			request.result = function (result:Object):void {
				if (_mediaTypes.hasOwnProperty(type)) {
					var newMedia:IMedia = pbservice.mediaFactory(null, result);
					//newMedia.data = result;
					_media.addItemAt(newMedia, 0);
					_mediaTypes[type].addItemAt(newMedia, 0);
				}
				var event:DynamicEvent = new DynamicEvent('fileUploaded');
				event.result = result as XML;
				dispatchEvent(event);//CFR
			}
			pbservice.makeRequest(request);
		}
		
		/**
		 * Disposes of the Album Object clearing any children that might sill have
		 * references from this object.  
		 * 
		 */
		public function dispose():void {
			for each (var album:IAlbum in subAlbums) {
				album.parent = null;
			}
			subAlbums.removeAll();
			subAlbumsLoaded = false;
			for each (var mediaObj:IMedia in _media) {
				mediaObj.album = null;
			}
			media.removeAll();
			for each (var p:Object in _mediaTypes) {
				ArrayCollection(p).removeAll();
			}
			_mediaTypes = new Object();
		}

		[Bindable(event="complete")]
		/**
		 * Returns a displayable path 
		 * @return 
		 * 
		 */
		public function get path():String {
			return unescape(id);
		}
		
		/**
		 * gets the pararent album of this album
		 * @return 
		 * 
		 */
		public function get parent():IAlbum {
			return _parent;
		}
		/**
		 * sets the parent album of this abum 
		 * @param value
		 * 
		 */		
		public function set parent(value:IAlbum):void {
			_parent = value;
		}
		

		public function commit():void {
				if (invalid) {
					var request:OAuthRequest = new OAuthRequest();
					request.method = OAuthRequestMethod.PUT;
					request.needsLogin = true;
					request.addParameter("privacy", privacy);
					request.url = server+"/album/" + id +"/privacy";
					request.fault = this.fault;
					request.result = function (result:Object):void {
						_privacy = XML(result).privacy;
						dispatchEvent(new Event('privacyUpdated'));
					}
					pbservice.makeRequest(request);
				}			
		}
		
		
		override internal function set data(value:Object):void {
			if (value) {
				if (value.hasOwnProperty("@name")) {
					_name = value.@name;
				}
				if (value.hasOwnProperty("@photo_count")) {
					_photo_count = int(value.@photo_count); 
				} 
				if (value.hasOwnProperty("@subalbum_count")) {
					_subalbum_count = int(value.@subalbum_count); 
				}
				if (value.hasOwnProperty("@video_count")) {
					_video_count = int(value.@video_count); 
				}
				if (value.hasOwnProperty("@privacy")) {
					_privacy = value.@privacy;
					this.dispatchEvent(new Event("privacyUpdated"));
				}
				super.data = value;
			}
		}


		
	}
}