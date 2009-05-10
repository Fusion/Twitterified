package com.voilaweb.tfd.api {
	import com.photobucket.webapi.interfaces.IAlbum;
	import com.photobucket.webapi.interfaces.IUser;
	import com.photobucket.webapi.objects.LoginAir;
	
	import flash.events.*;
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	public class PhotoBucketWrapper extends EventDispatcher
	{
		private static const KEY:String = '149826527';
		private static const SECRET:String = '28469cfc3b2086594d7961ee15261065';
		public static const PB_ALBUM_NAME:String = 'Twitterified';
		public static const TFD_TMP_JPG_FILE:String = 'twitterified.tmp.jpg';
		private var pbUser:IUser; // PhotoBucket user
		
		function PhotoBucketWrapper() 
		{
		}
		
		private function cleanup(event:Event, callee:Function):void
		{
			event.target.removeEventListener(event.type, callee);			
		}
		
		public function login(cb:Function):void
		{
			if(!pbUser)
			{
				var login:LoginAir = new LoginAir();
				login.setConsumer(KEY, SECRET);
				pbUser = login.loginUser();
				pbUser.addEventListener(
					Event.COMPLETE,
					function(event:Event):void
					{
						cleanup(event, arguments.callee);
						cb(event);
					},
					false);
			}
			else
			{
				cb(null);
			}	
		}
		
		public function getTopLevelAlbum():IAlbum
		{
			return pbUser.getRootAlbum();
		}
		
		public function getAlbumChildren(dadAlbum:IAlbum, name:String, cb:Function):void
		{
			dadAlbum.addEventListener(
				'subAlbumsUpdated',
				function(event:Event):void
				{
					cleanup(event, arguments.callee);
					var foundTfdAlbum:IAlbum = null;
					for(var i:int=0; i<subAlbums.length; i++)
					{
						if(IAlbum(subAlbums.getItemAt(i)).name == name)
						{
							foundTfdAlbum = subAlbums.getItemAt(i) as IAlbum;
							break;
						}
					}
					cb(foundTfdAlbum);			
				},
				false);
			var subAlbums:ArrayCollection = dadAlbum.sub_albums;						
		}
		
		public function createChildAlbum(dadAlbum:IAlbum, name:String, cb:Function):void
		{
			dadAlbum.addEventListener(
				'subAlbumCreated',
				function(event:Event):void
				{
					cleanup(event, arguments.callee);
					var foundTfdAlbum:IAlbum = null;
					var subAlbums:ArrayCollection = dadAlbum.sub_albums;
					for(var i:int=0; i<subAlbums.length; i++)
					{
						if(IAlbum(subAlbums.getItemAt(i)).name == name)
						{
							foundTfdAlbum = subAlbums.getItemAt(i) as IAlbum;
							break;
						}
					}
					cb(foundTfdAlbum);			
				},
				false);
			dadAlbum.createSubAlbum(name);
		}
		
		public function uploadFile(album:IAlbum, localFile:File, type:String, title:String, comment:String, cb:Function):void
		{
			album.addEventListener(
				'fileUploaded',
				function(event:Event):void
				{
					cleanup(event, arguments.callee);
					cb(event);
				},
				false);
			album.uploadFile(localFile, type, title, comment);		
		}		
	}
}