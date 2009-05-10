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
	import com.photobucket.webapi.interfaces.ITag;
	import com.photobucket.webapi.oauth.OAuthRequest;
	import com.photobucket.webapi.oauth.OAuthRequestMethod;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	[Event(name="mediaUpdated", type="flash.events.Event")]
	[Event(name="titleUpdated", type="flash.events.Event")]
	[Event(name="descriptionUpdated", type="flash.events.Event")]
	
	
	/**
	 * Represents a media object on photobucket and the associated methods and properties with a piece of media
	 * @author jlewark
	 * 
	 */
	public class Media extends PhotobucketRemoteObject implements IMedia
	{
		
		private var _url:String;
		private var _browseURL:String;
		private var _thumb:String;
		private var _description:String;
		private var _title:String;
		private var _type:String;
		private var _uploaddate:String;
		private var _filename:String;
		private var titleInvalid:Boolean = false;
		private var oldTitle:String;
		private var descriptionInvalid:Boolean = false;
		private var oldDescription:String;
		private var _album:IAlbum;
		private var _tags:ArrayCollection;
		
		/**
		 * Creates a media object from a url or object 
		 * @param url
		 * @param data
		 * 
		 */
		public function Media(url:String = null, data:Object = null)
		{
			if (url != null) {
				_url = url;
				server = url;
				id = url;
			} 
			if (data != null) {
				this.data = data;
			}
		}

		
		[Bindable(event='mediaUpdated')]
		/**
		 * The URL of the prmiary meida object 
		 * @return 
		 * 
		 */
		public function get url():String {
			return _url;
		}

		[Bindable(event='mediaUpdated')]
		/**
		 * The filename of the prmiary meida object 
		 * @return 
		 * 
		 */		
		public function get name():String {
			if (_filename == null) {
				var filenameRegex:RegExp = /[^\/]\.[a-zA-Z]{3}/;
				var matches:Array = filenameRegex.exec(url);
				if (matches != null) {
					_filename = matches[0];
				}
			}
			return _filename;
		}
		

		[Bindable(event='mediaUpdated')]
		/**
		 * The URL of the thumbnail of this media object it is a 160x160 pixel max image
		 * that can be used to load faster then loading the fullsize image. 
		 * @return 
		 * 
		 */		
		public function get thumb():String {
			if (_thumb == null) {
				this.getMediaInfo();
			}
			return _thumb;
		}
		
		[Bindable(event='mediaUpdated')]		
		/**
		 * The browseURL is the recommend URL for viewing the media from the photobucket site
		 * @return 
		 * 
		 */
		public function get browseURL():String {
			if (_browseURL == null) {
				this.getMediaInfo();
			}
			return _browseURL;
		}

		[Bindable(event='mediaUpdated')]
		/**
		 * The timestamp this media was uploaded
		 * @return 
		 * 
		 */		 
		public function get uploaddate():String {
			if (_uploaddate == null) {
				this.getMediaInfo();
			}
			return _uploaddate;
		}

		[Bindable(event='mediaUpdated')] 		
		/**
		 * The type of media this media object represents 
		 * @return 
		 * 
		 */
		public function get type():String {
			if (_type == null) {
				this.getMediaInfo();
			}
			return _type;
		}
		
		[Bindable(event='titleUpdated')]
		
		/**
		 * The title of the media given to it by the user 
		 * @return 
		 * 
		 */
		public function get title():String {
			if (_type == null) {
				this.getMediaInfo();
			}
			return _title;
		}
		
		[Bindable]
		
		/**
		 * Sets the media objects title to something. Call commit to save this 
		 * title to photobucket. 
		 * @param value
		 * 
		 */
		public function set title(value:String):void {
			if (url == null) {
				throw new Error("Object not intialized");
			}
			if (_title != value) {
				if (!titleInvalid) {
					oldTitle = _title;
				}
				titleInvalid = true;
				_title = value;
			}


		}
		
		[Bindable(event='descriptionUpdated')]
		/**
		 * Gets the description of the media as discribed by the user
		 * @return 
		 * 
		 */
		public function get description():String {
			if (_type == null) {
				this.getMediaInfo();
			}
			return _description;
		}
		
		[Bindable]
		/**
		 * Sets the description of the media to the value.  Use the commit
		 * method to set the description on photobucket.com
		 * @param value
		 * 
		 */
		public function set description(value:String):void {
			if (url == null) {
				throw new Error("Object not intialized");
			}
			if (_description != value) {
				if (!descriptionInvalid) {
					oldDescription = _description;
				}
				descriptionInvalid = true;
				_description = value;
			}
		}
		
		/**
		 * Loads the media object parameters from the API this can be
		 * called once you have set the url and would like to have more 
		 * information.
		 * 
		 */
		public function getMediaInfo():void {
			if (url == null) {
				throw new Error("Object not intialized");
			}
			if (_tags != null) {
				_tags.removeAll();
			}
			var request:OAuthRequest = new OAuthRequest();
			request.method = OAuthRequestMethod.GET;
			request.url = server + "/media/"+ id;
			request.fault = this.fault;
			request.result = function (result:Object):void {
				data = result;
			}
			pbservice.makeRequest(request);
		}
		
		/**
		 * Deletes this media from the photobucket servers.  This cannot be undone
		 * and should not be called unless the user is made aware of this.  
		 * 
		 * Be carefull not to call this accientially.
		 * 
		 */
		public function deleteMedia():void {
			var request:OAuthRequest = new OAuthRequest();
			request.method = OAuthRequestMethod.DELETE;
			request.needsLogin = true;
			request.url = server + "/media/" + id;
			request.fault = this.fault;
			request.result = function (value:Object):void {
				_url = null;
				_id = null;
				_browseURL = null;
				_thumb = null;
				_title = null;
				_description = null;
			}
			pbservice.makeRequest(request);
		}
		
		/**
		 * Searches photobucket.com for media that is similar
		 * @return 
		 * 
		 */
		public function getRelatedMedia(numberOfResults:int, type:String = null):ArrayCollection {
			if (type == null) {
				type = this.type;
			}
			return null;
		}
		
		
		/**
		 * 
		 * @param toAlbum
		 * 
		 */
		public function moveMedia(toAlbum:IAlbum):void {
			
		}
		
		/**
		 * Gets an album object representing the media's current album
		 * @return 
		 * 
		 */
		public function get album():IAlbum {
			if (_album == null) {
				_album = pbservice.albumFactory(url);
			}
			return _album;
		}
		
		/**
		 * Sets the current album of the media objext.  Usually set the the album retriving the media 
		 * @param value
		 * 
		 */
		public function set album(value:IAlbum):void {
			_album = value;
		}
		
		
		/**
		 * Returns an array collection of the tags associated with this media 
		 * @return 
		 * 
		 */
		public function get tags():ArrayCollection {
			if (_tags == null) {
				this.getMediaInfo();
			}
			return _tags;
		}
		
		
		public function addTag(tag:ITag):void {
				var request:OAuthRequest = new OAuthRequest();
				tag.media = this;
				request.method = OAuthRequestMethod.POST;
				request.needsLogin = true;
				request.url = server + "/media/"+ id +"/tag";
				request.addParameter("tag", tag.tag);
				request.addParameter("topleftx", tag.left.toString());
				request.addParameter("toplefty", tag.top.toString());
				request.addParameter("bottomrightx", tag.right.toString());
				request.addParameter("bottomrighty", tag.bottom.toString());
				if (tag.contact != null) {
					if (tag.contact.id != null) {
						request.addParameter("contact", tag.contact.id);
					} else {
						request.addParameter("contact", tag.contact.emailAddress);
					}
				}
				if (tag.url != null) {
					request.addParameter("tagurl", tag.url);
				}
				request.fault = function (result:Object):void {
					sendError();
					tag.media = null;
				};
				request.result = function (result:Object):void {
					if (_tags != null) {
						_tags.addItem(tag);
					}
				}
				pbservice.makeRequest(request);
		}
		
		
		/**
		 *  Commits any meta data changes to this media on photobucket if something has changed.  
		 * 
		 */
		public function commit():void {
			if (titleInvalid) {
				var request:OAuthRequest = new OAuthRequest();
				request.method = OAuthRequestMethod.POST;
				request.needsLogin = true;
				request.url = server + "/media/"+ id +"/title";
				request.addParameter("title", title);
				request.fault = function (result:Object):void {
					_title = oldTitle;
					titleInvalid = false;
					sendError()
					dispatchEvent(new Event('titleUpdated'));
				};
				request.result = function (value:Object):void {
					sendComplete();
					titleInvalid = false;
				}
				pbservice.makeRequest(request);
			}
			if (descriptionInvalid) {
				var request2:OAuthRequest = new OAuthRequest();
				request2.method = OAuthRequestMethod.POST;
				request2.needsLogin = true;
				request2.url = server+ "/media/"+id+"/description";
				request2.addParameter("description", description);
				request2.fault = function (result:Object):void {
					_description = oldDescription;
					sendError();
					descriptionInvalid = false;
					dispatchEvent(new Event('descriptionUpdated'));				
				}
				request2.result = function (value:Object):void {
					sendComplete();
					descriptionInvalid = false;
				}
				pbservice.makeRequest(request2);
			}
		}
		

		
		override internal function set data(value:Object):void {
			//var sdfasD:Alert = Alert.show(value.toString());
			super.data = value;
			if (data.hasOwnProperty("browseurl")) {
				_browseURL = data.browseurl;
			}
			if (data.hasOwnProperty("url")) {
				_url = data.url;
				server = data.url;
				id = data.url;
			}
			if (data.hasOwnProperty("@name")) {
				_filename = data.@name;
			}
			if (data.hasOwnProperty("@type")) {
				_type = data.@type;
			}
			if (data.hasOwnProperty("@uploaddate")) {
				_uploaddate = data.@uploaddate;
			}
			if (data.hasOwnProperty("thumb")) {
				_thumb = data.thumb;
			}
			if (data.hasOwnProperty("thumb")) {
				_thumb = data.thumb;
			}
			if (data.hasOwnProperty("title")) {
				_title = data.title;
				this.dispatchEvent(new Event('titleUpdated'));
			}
			if (data.hasOwnProperty("description")) {
				_description = data.description;
				this.dispatchEvent(new Event('descriptionUpdated'));
			}
			if (data.isPrototypeOf(XML)) {
				if (_tags == null) {
					_tags = new ArrayCollection();
				}
				for each (var tagXML:XML in XML(data)..tag) {
					var newTag:ITag = pbservice.tagFactory(tagXML);
					newTag.media = this;
					_tags.addItem(newTag);
				}
			}
			this.dispatchEvent(new Event('mediaUpdated'));
		} 


	}
}