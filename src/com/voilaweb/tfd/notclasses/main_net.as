
private function main_twitterifiedUpdate(msg:String):void
{
	var ref:int = 0;
	var link:String = '';
	
	if(twitterified.kwrd && twitterified.kwrd=='@' && preferences['conversations'])
	{
		/** @todo Conversations */
		ref = 0;
		link = '';	
	}
	
	if(twitterified.dest)
		msg = twitterified.kwrd + twitterified.dest + ' ' + msg;
		
	twitterified.update('t', ref, link, preferences['secretkey'], msg, '');
}

private function main_twitterifiedImageUpdate(msg:String):void
{
	var ref:int = 0;
	var link:String = '';
	
	if(twitterified.kwrd && twitterified.kwrd=='@' && preferences['conversations'])
	{
		/** @todo Conversations */
		ref = 0;
		link = '';	
	}
	
	if(twitterified.dest)
		msg = twitterified.kwrd + twitterified.dest + ' ' + msg;
		
	twitterified.update('i', ref, link, preferences['secretkey'], msg, tweet_imageurl.text);
}

private function main_twitterifiedImageWebcamUpdate(msg:String):void
{
	var bytes:ByteArray = new JPEGEncoder(90).encode(imgSnapshot);
	// Now, store this guy to disk
	var fl:File = File.userDirectory.resolvePath(PhotoBucketWrapper.TFD_TMP_JPG_FILE);
	var fs:FileStream = new FileStream();
	try
	{
		if(fl.exists)
			fl.deleteFile();
		fs.open(fl, FileMode.WRITE);
		fs.writeBytes(bytes);
		fs.close();
	}
	catch(e:Error)
	{
		Logger.info("Unable to write file");
		throw new Error("Unable to create temporary file :(");
	}
	main_uploadPic(msg);
	//picassa.auth('militate@gmail.com', 'g00gl3+');
	//twitterified.update('e', ref, link, preferences['secretkey'], msg, encoder.flush());
//	twitterified.update('e', ref, link, preferences['secretkey'], msg, 'kwak');
}

private function main_uploadPic(msg:String):void
{
	spinner.play();
	photoBucket.login(function(event:Event):void
	{
		var tlAlbum:IAlbum = photoBucket.getTopLevelAlbum();
		photoBucket.getAlbumChildren(tlAlbum, PhotoBucketWrapper.PB_ALBUM_NAME, function(album:IAlbum):void
		{
			// Do we need to create this album?
			if(!album)
			{
				photoBucket.createChildAlbum(tlAlbum, PhotoBucketWrapper.PB_ALBUM_NAME, function(album:Album):void
				{
					if(!album)
					{
						Alert.show("Sorry, I was not able to create a PhotoBucket album called 'Twiterified'");
						spinner.stop();
						return;
					}
					main_uploadFile(
						msg,
						album,
						File.userDirectory.resolvePath(PhotoBucketWrapper.TFD_TMP_JPG_FILE),
						MediaType.IMAGE,
						'Webcam',
						'A Webcam image uploaded using the Twitterified client.');
				});
			}
			else
			{
				main_uploadFile(
					msg,
					album,
					File.userDirectory.resolvePath(PhotoBucketWrapper.TFD_TMP_JPG_FILE),
					MediaType.IMAGE,
					'Webcam',
					'A Webcam image uploaded using the Twitterified client.');
			}	
		});
	});
}

private function main_uploadFile(msg:String, album:IAlbum, localFile:File, type:String, title:String, comment:String):void
{
	photoBucket.uploadFile(
		album,
		localFile,
		type,
		title,
		comment,
		function(event:Event):void
		{
			// Now, retrieve information on this little dude
			var result:XML = DynamicEvent(event).result;
			var children:XMLList = XML(result).child('url');
			if(children.length()!=1); // @todo
			var url:String = children[0].toString();
			children = XML(result).child('browseurl');
			var browseurl:String = children[0].toString();
			
			var ref:int = 0;
			var link:String = '';
			
			if(twitterified.kwrd && twitterified.kwrd=='@' && preferences['conversations'])
			{
				/** @todo Conversations */
				ref = 0;
				link = '';	
			}
			
			if(twitterified.dest)
				msg = twitterified.kwrd + twitterified.dest + ' ' + msg;
			
			twitterified.update('i', ref, link, preferences['secretkey'], msg, '|u:' + url + '|b:' + browseurl);			
			main_status("Picture saved.", true);
		});						
}

private function main_twitterifiedVideoUpdate(msg:String):void
{
	var ref:int = 0;
	var link:String = '';
	
	if(twitterified.kwrd && twitterified.kwrd=='@' && preferences['conversations'])
	{
		/** @todo Conversations */
		ref = 0;
		link = '';	
	}
	
	if(twitterified.dest)
		msg = twitterified.kwrd + twitterified.dest + ' ' + msg;
		
	twitterified.update('v', ref, link, preferences['secretkey'], msg, tweet_videoembedcode.text);
}



private function main_onUserTimelineResult(event:TwitterEvent):void
{
	Logger.info("Got user timeline");
	main_displayResult(user_timeline, event.data as Array);
	main_status("Timeline Updated.", true);
}

private function main_onFriendsTimelineResult(event:TwitterEvent):void
{
	Logger.info("Got friends timeline");
	main_displayResult(friends_timeline, event.data as Array);
	main_status("Timeline Updated.", true);
}

private function main_onRepliesTimelineResult(event:TwitterEvent):void
{
	Logger.info("Got replies timeline");
	main_displayResult(friends_timeline, event.data as Array);
	main_status("Timeline Updated.", true);
}

private function main_onDirectMessagesTimelineResult(event:TwitterEvent):void
{
	Logger.info("Got direct messages timeline");
	main_displayResult(friends_timeline, event.data as Array);
	main_status("Timeline Updated.", true);
}

private function main_onPublicTimelineResult(event:TwitterEvent):void
{
	Logger.info("Got public timeline");
	main_displayResult(public_timeline, event.data as Array);
	main_status("Timeline Updated.", true);
}

private function main_onSentDirectMessagesTimelineResult(event:TwitterEvent):void
{
	Logger.info("Got sent direct messages timeline");
	main_displayResult(public_timeline, event.data as Array);
	main_status("Timeline Updated.", true);
}

private function main_onFriendsResult(event:TwitterEvent):void
{
	Logger.info("Got friends list");
	people[FRIENDS_LS] = event.data as Array;
	main_displayPeople('friends', friends_results, event.data as Array);
	main_status("Friends List Updated.", true);	
}

private function main_onFollowersResult(event:TwitterEvent):void
{
	Logger.info("Got followers list");
	people[FOLLOWERS_LS] = event.data as Array;
	main_displayPeople('followers', followers_results, event.data as Array);
	main_status("Followers List Updated.", true);	
}

private function main_onSearchResult(event:SummizeEvent):void
{
	Logger.info("Got search result");
	main_displayResult(search_results, event.data as Array);
	main_status("Search Complete.", true);
}

private function main_onRetrieveResult(event:TwitterifiedEvent):void
{
	Logger.info("Got delegated result");
	var store:Storage = resultsStorage[processing];
	
	var data:Array = event.data as Array;
	var l:int = data.length;
	for each(var entry:TwitterStatus in store.entries)
	{
		for(var i:int=0; i<l; i++)
		{
			var tupple:TwitterStatus = data[i] as TwitterStatus;
			if(tupple.link == entry.link)
			{
				entry.text = data[i].text;
				entry.extra = data[i].extra;
				entry.type = data[i].type;
				entry.subType = data[i].subType;
				entry.direct = data[i].direct;
			}
		}
	}
	main_fullUpdate(store.area, store.entries);
	main_unqueue();	
}

private function main_onUpdateResult(event:TwitterEvent):void
{
	Logger.info("Got update result");
	statusArea.text = StatusPrompt;
	showedTab[USER_TL] = 0; // force refresh
	main_showUserTimeline();
}

private function main_onRateLimitStatus(event:TwitterEvent):void
{
	var data:XML = event.data as XML;
	var remainingHits:int = data.child('remaining-hits');
	if(remainingHits >= 0) return; // not the issue here...

	var hourlyLimit:int = data.child('hourly-limit');
	var resetTimeInSeconds:int = data.child('reset-time-in-seconds');
	var now:Date = new Date();	
	var delay:int = Math.ceil((resetTimeInSeconds - (now.valueOf() / 1000 + now.timezoneOffset)) / 60);
	Alert.show(
		"Oops. Try again in " + delay + " minutes.\n\n" +
		"Twitter is overheating! Currently, a maximum " +
		" of " + hourlyLimit + " requests per hour is allowed.\n" +
		"We exceeded this number by " + (-1 * remainingHits) + " requests..."
	);
}