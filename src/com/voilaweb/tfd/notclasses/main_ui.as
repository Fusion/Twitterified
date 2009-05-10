// -----------------------------------------------------------------------------------
// UI
// -----------------------------------------------------------------------------------

private function main_addTitleBar():void
{
	var imgObj2:BitmapAsset = new titlebarImage() as BitmapAsset;
	var image2:Image = new Image();
	image2.source = imgObj2;
	image2.x = 16;
	image2.y = 4;
	this.addChild(image2);
	var imgObj:BitmapAsset = new appIcon() as BitmapAsset;
	var image:Image = new Image();
	image.source = imgObj;
	image.x = 10;
	image.y = 0;
	this.addChild(image);
	var text:Text = new Text();
	text.htmlText = '<b><font color="#2784C2" size="14">Twitterified</font><b>';
	text.x = 36;
	text.y = 2;
	this.addChild(text);
}

private function main_addAdditionalTitleBarElements():void
{
	var b1:LinkButton = new LinkButton();
	b1.label = '_';
	b1.x = 530;
	b1.y = 2;
	/* TODO IN NEXT RELEASE
	this.addChild(b1);	
	b1.addEventListener(MouseEvent.CLICK, main_onIconify);
	*/
	var b2:LinkButton = new LinkButton();
	b2.label = '?';
	b2.x = 550;
	b2.y = 2;
	this.addChild(b2);	
	b2.addEventListener(MouseEvent.CLICK, main_quickHelp);
}

private function main_addMoveHandle():void
{
	var s:Sprite = new Sprite(); 
	s.graphics.beginFill(0x555555); 
	s.graphics.drawRect(0, 0, 560, 20); 
	s.graphics.endFill();
	s.x=10;
	s.y=0;
	var moveHandle:UIComponent = new UIComponent();
	moveHandle.alpha = 0;
	moveHandle.addChild(s);
	this.addChild(moveHandle);
	moveHandle.addEventListener(MouseEvent.MOUSE_DOWN, main_onStartMove);	
}
public function main_onStartMove(event:MouseEvent):void 
{ 
	stage.nativeWindow.startMove(); 
} 

private function main_addResizeHandle():void
{
	
}

private function main_mouseStatus(event:MouseEvent):void
{
	//stage.nativeWindow.startMove();
	stage.nativeWindow.x = 500;
	Logger.info("+50");
}

private function main_displayPeople(where:String, area:UIComponent, data:Array):void
{
	var count:int = 0;
	var entry:TwitterUser;
	for each(entry in data)
	{
		var peopleRow:PeopleRow = new PeopleRow(this, entry);
		area.addChild(peopleRow);
		count ++;
	}
	switch(where)
	{
		case 'friends':
			friends_screen_title.text   = "Your Friends (" + count + ")";
			break;
		case 'followers':
			followers_screen_title.text = "Your Followers (" + count + ")";
			break;
	}
	main_unqueue();
}

private function main_displayResult(area:Container, data:Array):void
{
	var nData:Array = new Array();
	var entry:TwitterStatus;
	var comma:String = '';
	var twoOhOnes:String = '';
	var somethingNew:Boolean = false;
	var processedUniques:Array = new Array();
	var newTopEntry:Array = new Array();
/*
	var unique:String;
	if(data.length < 1)
		unique = 'bogus'; 
	else
		unique = data[0].unique;
	if(!topIdTab[unique])
		topIdTab[unique] = new Array();				
*/	
/*
	// Weed out entries that were previously retrieved except when search_results
	if(area.id == 'search_results')
		topIdTab[unique][area.id] = 0;
	else if(!topIdTab[unique][area.id])
		topIdTab[unique][area.id] = 0;
*/		
	for each(entry in data)
	{
		if(!topIdTab[entry.unique])
			topIdTab[entry.unique] = new Array();
		if(!topIdTab[entry.unique][entry.interaction])
			topIdTab[entry.unique][entry.interaction] = new Array();
		if(!processedUniques[entry.unique])
			processedUniques[entry.unique] = new Array();
		if(!processedUniques[entry.unique][entry.interaction])
		{
			processedUniques[entry.unique][entry.interaction] = true;
			// Weed out entries that were previously retrieved except when search_results
			if(area.id == 'search_results')
				topIdTab[entry.unique][entry.interaction][area.id] = 0;
			else if(!topIdTab[entry.unique][entry.interaction][area.id])
				topIdTab[entry.unique][entry.interaction][area.id] = 0;			
			// Formerly known as 'newTopEntry:int'
			if(!newTopEntry[entry.unique])
				newTopEntry[entry.unique] = new Array();
			newTopEntry[entry.unique][entry.interaction] = topIdTab[entry.unique][entry.interaction][area.id];
			trace("Add results for unique = " + entry.unique + ":" + entry.interaction + ", oldtopid = " + newTopEntry[entry.unique][entry.interaction]);	
		}
		if(entry.id > topIdTab[entry.unique][entry.interaction][area.id])
		{
			nData.push(entry);
			if(entry.id > newTopEntry[entry.unique][entry.interaction])
			{
				newTopEntry[entry.unique][entry.interaction] = entry.id;
			}
			somethingNew = true;
		}
	}
	var nteUnique:String, nteUniqueInteraction:String;
	for(nteUnique in newTopEntry)
	{
		for(nteUniqueInteraction in newTopEntry[nteUnique])
		{
			topIdTab[nteUnique][nteUniqueInteraction][area.id] = newTopEntry[nteUnique][nteUniqueInteraction];
		}
	}
	
	// Look for Twitterified material
	for each(entry in nData)
	{
		//Logger.info("Adding " + entry.id);
		var text:String = entry.text;
		if(!text || text.length < 5)
			continue;
		var special:String = main_lookup20x(text);
		if(special=='[txt]' || special=='[pic]' || special=='[vid]')
		{
			var matches:Array = text.match(/\/index\/(\w+)/);
			if(matches)
			{
				entry.link = matches[1];
				twoOhOnes += comma + matches[1];
				comma = ',';
			}
		}
	}
	
	if(twoOhOnes.length > 0)
	{
		main_store(area, nData);
		twitterified.retrieve(twoOhOnes);
	}
	else
	{
		main_fullUpdate(area, nData);
		main_unqueue();
	}
	
	if(somethingNew)
		main_notifyOfSomethingNew();
}

private function main_toggleUserPaneStatuses(container:Container, name:String, shallIgnore:Boolean):void
{
	var children:Array = container.getChildren();
	var statusRow:StatusRow;
	for each(statusRow in children)
	{
		if(StatusRow(statusRow).status.user.screenName == name)
			StatusRow(statusRow).opened = !shallIgnore;
	}			
}

private function main_toggleUserStatuses(name:String):void
{
	var shallIgnore:Boolean = (ignoredList[currentUser.screenName] ? false : true);
	if(!main_ignoreUser(name, shallIgnore)) return;	
	main_toggleUserPaneStatuses(friends_timeline, name, shallIgnore);
	main_toggleUserPaneStatuses(user_timeline,    name, shallIgnore);
	main_toggleUserPaneStatuses(public_timeline,  name, shallIgnore);	
}

/**
 * Ask all statuses displayed in the current panel to update their 'cool dates'
 * to reflect how much time has really elapsed.
 */
private function main_refreshStatuses(container:Container):void
{
	var children:Array = container.getChildren();
	var statusRow:StatusRow;
	for each(statusRow in children)
	{
		StatusRow(statusRow).updateCoolDate();
	}	
}

private function main_fullUpdate(container:Container, statusArray:Array):void
{
	// First, update displayed elapsed times
	main_refreshStatuses(container);
	
	// Then, add new data
	var entry:TwitterStatus;

	statusArray.sort(main_sortData);

	var ids:String = '', comma:String='';	
	for each(entry in statusArray)
	{
		ids += comma + entry.id;
		comma = ',';
	}
	var readList:Array = main_getMarkedReadList(ids);
	
	for each(entry in statusArray)
	{
		main_update(
			container,
			entry,
			(readList[entry.id] ? true : false));
	}	
}

private function main_update(container:Container, status:TwitterStatus, markRead:Boolean = false):void
{
	container.styleName = 'timeline';
	var statusRow:StatusRow = new StatusRow(this, status, markRead);
	statusRow.addEventListener(TfdEvent.ON_ANYTHING, main_onStatusAction);
	container.addChildAt(statusRow, 0);
}

private function main_growl(text:String):void
{
}

private function main_notifyOfSomethingNew():void
{
	if(NativeApplication.supportsDockIcon)
	{
		var dock:DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
		dock.bounce(NotificationType.INFORMATIONAL);
	}	
	else if(NativeApplication.supportsSystemTrayIcon)
	{
		stage.nativeWindow.notifyUser(NotificationType.INFORMATIONAL);
	}	
}

private function main_statusButtonFocused():void
{
	if(statusArea.text == StatusPrompt)
		statusArea.text = '';
}

private function main_inputInStatusArea():void
{
	//var text:Object = "Chars: " + statusArea.data.valueOf();
	var count:int = statusArea.text.length;
	var text:String = "Length: ";
	if(count > 140)
	{
		statusText.text = text + "140 + " + (count - 140);
		statusText.toolTip = count + " chars: your Tweet will be available through Twitterified";
		statusTextIcon.setStyle("icon", this["smallerAppIcon"]);
	} 
	else
	{
		statusText.text = text + count;
		statusText.toolTip = count + " chars: standard Tweet, available at twitter.com";
		statusTextIcon.setStyle("icon", null);
	}
}

private function main_onIconify(event:Event):void
{
	var menu:NativeMenu = new NativeMenu();
	var cmd:NativeMenuItem = menu.addItem(new NativeMenuItem('Come back!'));
	cmd.addEventListener(Event.SELECT, function(event:Event):void {
		if(NativeApplication.supportsDockIcon)
		{
			stage.nativeWindow.visible = true;
			var dock:DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
			dock.menu = null;
		}
	});
	if(NativeApplication.supportsDockIcon)
	{
		var dock:DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
		dock.menu = menu;
		stage.nativeWindow.visible = false;
	}
	else if(NativeApplication.supportsSystemTrayIcon)
	{

		//SystemTrayIcon(NativeApplication.nativeApplication .icon).menu = createSystrayRootMenu();
		SystemTrayIcon(NativeApplication.nativeApplication .icon).tooltip = "Systray test application";
		//SystemTrayIcon(NativeApplication.nativeApplication .icon).addEventListener(MouseEvent.CLICK, undock);
		
	}	
}

/**
 * Ask AIR to go away
 */
private function main_closeApplication(event:Event):void
{
	stage.nativeWindow.close();
}

private function main_reportError(event:TwitterEvent):void
{
	if(event.data is HTTPStatusEvent)
	{
		var encEvent:HTTPStatusEvent = event.data as HTTPStatusEvent;
		if(encEvent.status == 200) return; // No wait, t'was OK!
		if(encEvent.status == 400)
		{
			// Could be a rate-limit status problem...let's check
			twitter.rateLimitStatus(event.unique);
		}
		else
		{
			var prefix:String = "Service (" + event.unique + ") ";
			switch(event.data.status)
			{
				case 403:
					Alert.show(prefix + "is rejecting this operation :(");
					break;
				default:
					Alert.show(prefix + "is returning this error: " + event.data.status);
			}
		}
	}
	else
		Alert.show(event.data.text);
	main_unqueue();
}

private function onUpdaterError(error:ErrorEvent):void
{
	Alert.show("Oops, unable to check for newer version.");
}

private function main_changeSkin(event:Event):void
{
// @todo	StyleManager.loadStyleDeclarations('');	
}

private function main_changeOpacity(event:Event):void
{
	var children:Array = wideContainer.getChildren();
	var child:DisplayObject;
	for each(child in children)
	{
		child.alpha = cfg_opacity.value / 100;
	}
}

private function main_enumSoundThemes():void
{
	var appDir:File = File.applicationDirectory;
	var themesDir:File = appDir.resolvePath('sounds');

	var list:Array = themesDir.getDirectoryListing();
	var dir:File;
	for each(dir in list)
	{
		soundThemes.push(dir.name);
	}
}

private function main_changeSoundTheme(event:Event):void
{
	preferences['soundtheme'] = event.currentTarget.selectedItem;
}

private function main_playSound(soundName:String):void
{
	var soundFactory:Sound = new Sound();
	soundFactory.load(new URLRequest('app:/sounds/' + preferences['soundtheme'] + '/' + soundName + '.mp3'));
	soundFactory.play(); 
}

private function main_changeWinHeight(event:Event):void
{
	preferences['winheight'] = event.currentTarget.value;
	var timer:Timer = new Timer(100, 1);
	timer.addEventListener(TimerEvent.TIMER, main_revealNewHeight);
	timer.start();
}

private function main_revealNewHeight(event:TimerEvent):void
{
	stage.nativeWindow.height = preferences['winheight'];
	var resize:Resize = new Resize(this);
	resize.heightFrom = this.height;
	resize.heightTo   = preferences['winheight'];
	resize.play();		
}

private function main_changeWinWidth(newWidth:int):void
{
	this.width = newWidth;
	stage.nativeWindow.width = this.width;
	mainPanel.width = 600;
}

public function main_curHeight():int
{
	return mainPanel.height;	
}

public function main_curWidth():int
{
	return mainPanel.width;	
}

public function main_curContainerHeight():int
{
	return wideContainer.height;	
}

public function main_curContainerWidth():int
{
	return wideContainer.width;	
}

public function main_curDrawerWidth():int
{
	if(!_drawer)
		return 0;
	return _drawer.width;	
}


public function main_status(text:String, effect:Boolean=false):void
{
	statusTextIcon.setStyle("icon", null);
	statusText.text = text;	
	if(effect)
	{
		spinner.stop();
		bounceEffect.play([statusBox]);
	}
}


public function main_revealMoreOptions(event:Event):void
{
	// My odious hack: if presently then not all features are available.	
	var isPresently:Boolean = (null != _currentStatus.server && -1 < _currentStatus.server.indexOf(".presentlyapp.com"));
	// First, display background
	fold_panel.fold();
	// Now, refresh it
	user_panel.removeAllChildren();
	var t1:Text = new Text();
	t1.htmlText = '<b><u>' + currentUser.name + '</u><b>';
	t1.percentWidth = 90;
	user_panel.addChild(t1);
	var b1:Button = new Button();
	b1.label = "Follow";
	b1.percentWidth = 90;
	b1.addEventListener(MouseEvent.CLICK, main_onFollowRequest);
	user_panel.addChild(b1);			
	var ignoreButton:Button = new Button();
	ignoreButton.label = (ignored[currentUser.screenName] ? "Un-ignore" : "Ignore");
	ignoreButton.setStyle("icon", this["btnCollapseImage"]);
	ignoreButton.percentWidth = 90;
	ignoreButton.addEventListener(MouseEvent.CLICK, main_onUserIgnoreToggle);
	user_panel.addChild(ignoreButton);
	var b2:Button = new Button();
	b2.label = "Reply";
	b2.setStyle("icon", this["btnReplyImage"]);
	b2.percentWidth = 90;
	b2.addEventListener(MouseEvent.CLICK, main_onUserInitiatingReply);
	user_panel.addChild(b2);
	var b3:Button = new Button();
	b3.label = "Direct Message";
	b3.setStyle("icon", this["btnDMImage"]);
	b3.percentWidth = 90;
	b3.addEventListener(MouseEvent.CLICK, main_onUserInitiatingDM);
	user_panel.addChild(b3);			
	var b4:Button = new Button();
	b4.label = "Block";
	b4.percentWidth = 90;
	b4.addEventListener(MouseEvent.CLICK, main_onBlockRequest);
	user_panel.addChild(b4);
	if(isPresently)
	{
		b4.enabled = false;
	}
}