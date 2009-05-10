import air.update.ApplicationUpdaterUI;
import air.update.events.UpdateEvent;

import com.photobucket.webapi.interfaces.IAlbum;
import com.photobucket.webapi.objects.Album;
import com.photobucket.webapi.objects.MediaType;
import com.voilaweb.tfd.DrawerContainer;
import com.voilaweb.tfd.FriendsTree;
import com.voilaweb.tfd.Logger;
import com.voilaweb.tfd.OutlinerEditor;
import com.voilaweb.tfd.OutlinerNoteEditor;
import com.voilaweb.tfd.PathBit;
import com.voilaweb.tfd.PeopleRow;
import com.voilaweb.tfd.QueuedAction;
import com.voilaweb.tfd.StatusRow;
import com.voilaweb.tfd.Storage;
import com.voilaweb.tfd.TfdEvent;
import com.voilaweb.tfd.api.PhotoBucketWrapper;
import com.voilaweb.tfd.api.Twitterified;
import com.voilaweb.tfd.api.events.TwitterifiedEvent;

import flash.data.SQLConnection;
import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.display.DisplayObject;
import flash.display.NativeMenu;
import flash.display.NativeMenuItem;
import flash.display.Sprite;
import flash.errors.SQLError;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.filesystem.FileStream;
import flash.geom.Point;
import flash.media.Sound;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Timer;

import flexlib.containers.FlowBox;

import mx.containers.Canvas;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.Image;
import mx.controls.LinkButton;
import mx.controls.Text;
import mx.controls.VideoDisplay;
import mx.controls.buttonBarClasses.*;
import mx.core.BitmapAsset;
import mx.core.ClassFactory;
import mx.core.Container;
import mx.core.UIComponent;
import mx.effects.Resize;
import mx.events.CloseEvent;
import mx.events.DynamicEvent;
import mx.events.ItemClickEvent;
import mx.events.ListEvent;
import mx.events.ListEventReason;
import mx.events.ValidationResultEvent;
import mx.graphics.codec.JPEGEncoder;
import mx.utils.UIDUtil;
import mx.validators.Validator;

import org.un.cava.birdeye.ravis.graphLayout.visual.*;

import summize.api.Summize;
import summize.api.events.SummizeEvent;

import twitter.api.MultiTwitter;
import twitter.api.Twitter;
import twitter.api.data.TwitterStatus;
import twitter.api.data.TwitterUser;
import twitter.api.events.TwitterEvent;

    
private var validators:Array;
public  var preferences:Array;
private var ignoredList:Array;

private var cnx:SQLConnection = null;

private var twitter:MultiTwitter;
private var summize:Summize;
//private var picassa:Picassa;
private var photoBucket:PhotoBucketWrapper;
private var twitterified:Twitterified;
private var showingTab:String;
private var showedTab:Array = new Array();
private var topIdTab:Array = new Array(); // Maximum Id stored for tab

// Store areas results
private var resultsStorage:Array = new Array();
private var processing:String = null;
// A FIFO
private var queueFifo:Array = new Array();

private var updateTimer:Timer, notificationTimer:Timer;

public static const MODE_TWEET:String = 'tweet';
public static const MODE_IMAGE:String = 'image';
public static const MODE_VIDEO:String = 'video';

private var tweetMode:String    = MODE_TWEET;
private var StatusPrompt:String = "What are you doing?"
private var StatusOffset:int    = 0;

private var imgPreviewPanel:Tile;
private var imgSnapPanel:Tile;
private var imgVid:VideoDisplay;
private var imgSnapImage:Bitmap;
private var imgSnapshot:BitmapData;
private var curImageCameraSelection:String;

private var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI();

private var drawingCanvas:Canvas = new Canvas();
private var ctrlKeyIsDown:Boolean = false;

private var people:Array = new Array();
private var friends_results:UIComponent = new FlowBox();
private var followers_results:UIComponent = new FlowBox();

public static const FRIENDS_TL:String     = 'friends_tl';
public static const DIRMSG_TL:String      = 'dirmsg_tl';
public static const REPLIES_TL:String     = 'replies_tl';
public static const USER_TL:String        = 'user_tl';
public static const SENT_DIRMSG_TL:String = 'sent_dirmsg_tl';
public static const PUBLIC_TL:String      = 'public_tl';
public static const FRIENDS_LS:String     = 'friends_ls';
public static const FOLLOWERS_LS:String   = 'followers_ls';
public static const SEARCH_AC:String      = 'search_ac';

// Used by delegates
private var _currentStatus:TwitterStatus;
private var _currentUser:TwitterUser;

public function main_init():void
{
	main_loadPreferences();	
	
	// Window height
	this.height = preferences['winheight'];
	systemManager.stage.nativeWindow.height = this.height;	
					
	// Ignored users
	ignoredList = main_getIgnoreUserList();
			
	// Our Twitter talker...
	twitter = new MultiTwitter();
	twitter.addEventListener(TwitterEvent.ON_USER_TIMELINE_RESULT, main_onUserTimelineResult);
	twitter.addEventListener(TwitterEvent.ON_FRIENDS_TIMELINE_RESULT, main_onFriendsTimelineResult);
	twitter.addEventListener(TwitterEvent.ON_REPLIES_TIMELINE_RESULT, main_onRepliesTimelineResult);
	twitter.addEventListener(TwitterEvent.ON_DIRECT_MESSAGES_TIMELINE_RESULT, main_onDirectMessagesTimelineResult);
	twitter.addEventListener(TwitterEvent.ON_PUBLIC_TIMELINE_RESULT, main_onPublicTimelineResult);
	twitter.addEventListener(TwitterEvent.ON_SENT_DIRECT_MESSAGES_TIMELINE_RESULT, main_onSentDirectMessagesTimelineResult);	
	twitter.addEventListener(TwitterEvent.ON_FRIENDS_RESULT, main_onFriendsResult);
	twitter.addEventListener(TwitterEvent.ON_FOLLOWERS, main_onFollowersResult);
	twitter.addEventListener(TwitterEvent.ON_SET_STATUS, main_onUpdateResult);	
	twitter.addEventListener(TwitterEvent.ON_ERROR, main_reportError);
	twitter.addEventListener(TwitterEvent.ON_RATE_LIMIT_STATUS, main_onRateLimitStatus);	
	// Summize buddy...
	summize = new Summize();
	summize.addEventListener(SummizeEvent.ON_SEARCH_RESULT, main_onSearchResult);
	summize.addEventListener(SummizeEvent.ON_ERROR, main_reportError);
	// PhotoBucket
	photoBucket = new PhotoBucketWrapper();
	// Picassa
	//picassa = new Picassa();
	//	
	twitterified = new Twitterified();
	twitterified.addEventListener(TwitterifiedEvent.ON_RETRIEVE_RESULT, main_onRetrieveResult);
	twitterified.addEventListener(TwitterifiedEvent.ON_DELEGATE_UPDATE, main_onDelegateUpdate);
	twitterified.addEventListener(TwitterifiedEvent.ON_ERROR, main_reportError);
	
	send_status.styleName = 'fixsendbutton';
	
	statusArea.text = StatusPrompt;

	// Skin
	main_changeSkin(null);
	
	// Images
	imgPreviewPanel = new Tile();
	imgPreviewPanel.width = 320;
	imgPreviewPanel.height = 320;
	imgVid = new VideoDisplay();
	imgVid.width = 320;
	imgVid.height = 320;	
	imgPreviewPanel.addChild(imgVid);
	imgSnapshot = new BitmapData(imgVid.width, imgVid.height);	

	imgSnapPanel = new Tile();
	imgSnapPanel.width = 320;
	imgSnapPanel.height = 320;
	
	// Friends & Followers
	friends_results.percentWidth  = 100;
	friends_results.percentHeight = 100;
	followers_results.percentWidth  = 100;
	followers_results.percentHeight = 100;
	
	// Validators for preferences	
	validators = new Array();
	/*
	validators.push(cfg_username_validator);
	validators.push(cfg_password_validator);
	 */
	
	// Gestures
	systemManager.addChild(drawingCanvas);
	systemManager.addEventListener(KeyboardEvent.KEY_DOWN, main_onKeyUpDown);
	systemManager.addEventListener(KeyboardEvent.KEY_UP, main_onKeyUpDown);
	systemManager.addEventListener(MouseEvent.MOUSE_MOVE, main_onMouseMove);
	
	// Complete UI
	main_addTitleBar();
	main_addAdditionalTitleBarElements()
	main_addMoveHandle();
	systemManager.stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVE, main_onAppMoved);
	statusArea.setFocus();
	
	main_playSound('On');
	main_startTimers();
	spinner.stop();
	
	// Ready our updater 
	appUpdater.addEventListener(ErrorEvent.ERROR, onUpdaterError);
	appUpdater.addEventListener(
		UpdateEvent.INITIALIZED, 
	    function(ev:UpdateEvent):void
	    {
			appUpdater.checkNow();
	    }
	);	
	appUpdater.delay = 1;
	appUpdater.updateURL = "http://tools.militate.com/tfd.xml";
	appUpdater.isCheckForUpdateVisible   = false; // Always silently check rather than being "in your face"
	appUpdater.isDownloadProgressVisible = true;
	appUpdater.isDownloadUpdateVisible   = true;
	appUpdater.isFileUpdateVisible       = true;
	appUpdater.isUnexpectedErrorVisible  = true;
	appUpdater.initialize();	
}

private function main_switchToFriendsList():void
{
	friends_results_wrapper.removeAllChildren();
	friends_results_wrapper.addChild(friends_results);
}
private function main_switchToFriendsTree():void
{	
	var friendsTree:FriendsTree = new FriendsTree(
		this,
		null,
		people[FRIENDS_LS],
		600,
		600);
	friends_results_wrapper.removeAllChildren();
	friends_results_wrapper.addChild(friendsTree);
}

/**
 * Queue up request to display the user's followers list
 */
private function main_showFollowersList():void
{
	// Add nice child if necessary
	if(followers_results_wrapper.getChildren().length < 1)
		followers_results_wrapper.addChild(followers_results);
	main_youmayproceed(FOLLOWERS_LS);
}
private function main_switchToFollowersList():void
{
	followers_results_wrapper.removeAllChildren();
	followers_results_wrapper.addChild(followers_results);
}
private function main_switchToFollowersTree():void
{
	var followersTree:FriendsTree = new FriendsTree(
		this,
		null,
		people[FOLLOWERS_LS],
		600,
		600);
	followers_results_wrapper.removeAllChildren();
	followers_results_wrapper.addChild(followersTree);
}

private function main_showGoToGuy():void
{		
	/*
			var graph:VisualGraph = new VisualGraph();
			graph.id = 'visual_graph';
			graph.visibilityLimitActive = true;
			graph.newNodesDefaultVisible = true;
			//graph.newNodesDefaultVisible = true;
			graph.percentHeight = 100;
			graph.percentWidth  = 100;
			graph.setStyle('backgroundColor', '0xFFFFFF');
			graph.alpha = 1;
			var canvas:Canvas = new Canvas();
			canvas.percentHeight = 100;
			canvas.percentWidth  = 100;
			canvas.addChild(graph);
			gotoguy_screen.addChild(canvas);

			var xml:XML = new XML(
				'<Graph>' +
				'<Node id="1" name="0" desc="This is a description" nodeColor="0x333333" nodeSize="32" nodeClass="earth" nodeIcon="center" x="10" y="10" />' +
				'<Node id="2" name="A" desc="This is a description" nodeColor="0x8F8FFF" nodeSize="12" nodeClass="tree" nodeIcon="2" x="10" y="15" />' +
				'<Edge fromID="1" toID="2" edgeLabel="...is friend of..." color="0x8F8FFF" flow="50"  />' +
				'</Graph>');
			graph.graph = new Graph('real_graph', false, xml);
			graph.draw(VisualGraph.DF_RESET_LL);
	*/
}

private function main_sendStatus():void
{
	if(statusArea.text.length < 1)
		return;
	var msg:String;
	switch(tweetMode)
	{
		case MODE_TWEET:
			if(statusArea.text.length > 140)
			{
				msg = main_preProcess(statusArea.text);
				main_twitterifiedUpdate(msg);
			}
			else // Standard Tweet...nothing to it
			{
				twitter.setStatus(main_mapSelectorValueToUnique(), statusArea.text);
			}
			break;
		case MODE_IMAGE:
			msg = main_preProcess(statusArea.text);
			switch(tweetmodes.selectedChild)
			{
				case image_tweet_mode:
					main_twitterifiedImageUpdate(msg);
					break;		
				case image_webcam_tweet_mode:
					main_twitterifiedImageWebcamUpdate(msg);
					break;
			}
			break;
		case MODE_VIDEO:
			msg = main_preProcess(statusArea.text);
			main_twitterifiedVideoUpdate(msg);		
			break;
	}
}

private function main_switchMode(event:ItemClickEvent):void
{
	var newStatusOffset:int;
	
	switch(event.index)
	{
		case 1: //image
			if(tweet_image_modes_bar.selectedIndex == 1)
			{
				newStatusOffset = 400;
				tweetmodes.selectedChild = image_webcam_tweet_mode;
			}
			else
			{
				newStatusOffset = 56;
				tweetmodes.selectedChild = image_tweet_mode;			
			}
			tweetmodes.height = newStatusOffset;
			if(StatusOffset != newStatusOffset)
				main_divider.getDividerAt(0).y -= (newStatusOffset - StatusOffset);
			StatusPrompt = "Enter a Caption for your Image";
			statusArea.text = StatusPrompt;
			tweet_image_modes_bar.visible = true;
			StatusOffset = newStatusOffset;
			if(tweet_imageurl) tweet_imageurl.setFocus();
			tweetMode = MODE_IMAGE;
			break;
		case 2: // video
			newStatusOffset = 56;
			tweetmodes.selectedChild = video_tweet_mode;
			tweetmodes.height = newStatusOffset;
			if(StatusOffset != newStatusOffset)
				main_divider.getDividerAt(0).y -= (newStatusOffset - StatusOffset);
			StatusPrompt = "Enter a Caption for your Video";
			statusArea.text = StatusPrompt;
			tweet_image_modes_bar.visible = false;
			StatusOffset = newStatusOffset;
			send_status.enabled = true;
			if(tweet_videoembedcode) tweet_videoembedcode.setFocus();
			tweetMode = MODE_VIDEO;
			break;
		case 0: // tweet
			newStatusOffset = 0;
			tweetmodes.height = newStatusOffset;
			if(StatusOffset != newStatusOffset)
				main_divider.getDividerAt(0).y += StatusOffset;						
			StatusPrompt = "What are you doing?";
			statusArea.text = StatusPrompt;
			tweet_image_modes_bar.visible = false;
			StatusOffset = newStatusOffset;
			send_status.enabled = true;
			statusArea.setFocus();
			tweetMode = MODE_TWEET;
			break;
	}
}

private function main_switchImageMode(event:ItemClickEvent):void
{
	var newStatusOffset:int;
	
	switch(event.index)
	{
		case 1: // webcam
			newStatusOffset = 400;
			tweetmodes.selectedChild = image_webcam_tweet_mode;
			tweetmodes.height = newStatusOffset;
			if(StatusOffset != newStatusOffset)
				main_divider.getDividerAt(0).y -= (newStatusOffset - StatusOffset);			
			StatusOffset = newStatusOffset;				
			break;
		case 0: // link
			newStatusOffset = 56;
			tweetmodes.selectedChild = image_tweet_mode;
			tweetmodes.height = newStatusOffset;
			if(StatusOffset != newStatusOffset)
				main_divider.getDividerAt(0).y -= (newStatusOffset - StatusOffset);			
			StatusOffset = newStatusOffset;	
			send_status.enabled = true;	
			tweet_imageurl.setFocus();	
			break;
	}
}

private function main_imgWebcamPreviewMode():void
{
	camerabox.removeAllChildren();
	camerabox.addChild(imgPreviewPanel);
	main_selectCamera();
	send_status.enabled = false;
}

public function main_onDelegateUpdate(event:TwitterifiedEvent):void
{
	twitter.setStatus(main_mapSelectorValueToUnique(), event.data as String);	
}

public function main_onStatusAction(event:TfdEvent):void
{
	var dest:String;
	switch(event.subType)
	{
		case TfdEvent.ON_FOLLOW_USER:
			Alert.show("Uh-oh. The developer forgot this guy.");
			/*
			dest = event.data['dest'];
			twitter.follow(dest);
			main_status('Following ' + dest, true);
			 */
			break;
		case TfdEvent.ON_BLOCK_USER:
			Alert.show("Uh-oh. The developer forgot this guy.");
			/*
			dest = event.data['dest'];
			twitter.block(dest);
			main_status('Blocked ' + dest, true);
			 */
			break;
		case TfdEvent.ON_INIT_REPLY:
			dest = event.data['dest'];
			if(statusArea.text.length > 0)
			{
				statusArea.text = '@' + dest + ' ' + statusArea.text;
				statusArea.setSelection(statusArea.text.length, statusArea.text.length);
			}
			else
			{
				statusArea.text = '@' + dest + ' ...';
				statusArea.setSelection(statusArea.text.length - 3, statusArea.text.length);
			}
			statusArea.setFocus();
			break;
		case TfdEvent.ON_INIT_DIRECT:
			dest = event.data['dest'];
			if(statusArea.text.length > 0)
			{
				statusArea.text = 'd ' + dest + ' ' + statusArea.text;
				statusArea.setSelection(statusArea.text.length, statusArea.text.length);
			}
			else
			{
				statusArea.text = 'd ' + dest + ' ...';
				statusArea.setSelection(statusArea.text.length - 3, statusArea.text.length);
			}
			statusArea.setFocus();
			break;
	}	
}

// -----------------------------------------------------------------------------------
// DELEGATES
// -----------------------------------------------------------------------------------

public function set currentStatus(currentStatus:TwitterStatus):void
{
	_currentStatus = currentStatus;	
}

public function get currentStatus():TwitterStatus
{
	return _currentStatus;
}

public function set currentUser(currentUser:TwitterUser):void
{
	_currentUser = currentUser;	
}

public function get currentUser():TwitterUser
{
	return _currentUser;
}

public function main_onFollowRequest(event:Event):void
{
	if(!currentStatus) return;
	twitter.follow(_currentStatus.unique, _currentStatus.user.screenName);
	main_status('Following ' + _currentStatus.user.screenName, true);
	user_panel.removeAllChildren();
	fold_panel.unfold();
}

public function main_onBlockRequest(event:Event):void
{
	if(!currentStatus) return;
	twitter.block(_currentStatus.unique, _currentStatus.user.screenName);
	main_status('Blocked ' + _currentStatus.user.screenName, true);
	user_panel.removeAllChildren();
	fold_panel.unfold();
}

public function main_onUserIgnoreToggle(event:Event):void
{
	if(!currentStatus) return;
	main_toggleUserStatuses(_currentStatus.user.screenName);	
}

public function main_onUserInitiatingRetweet(event:Event):void
{
	if(!currentStatus) return;
	var account:Array = main_findServiceRowByServerUsername(_currentStatus.server, _currentStatus.username);
	if(account)
		main_changeSelectorValue(account['id']);
	statusArea.text = 'RT @' + _currentStatus.user.screenName + ' ' + _currentStatus.rawText;
	statusArea.setSelection(statusArea.text.length, statusArea.text.length);
	statusArea.setFocus();
	user_panel.removeAllChildren();
	fold_panel.unfold();	
}

public function main_onUserInitiatingReply(event:Event):void
{
	if(!currentStatus) return;
	var account:Array = main_findServiceRowByServerUsername(_currentStatus.server, _currentStatus.username);
	if(account)
		main_changeSelectorValue(account['id']);
	if(statusArea.text.length > 0)
	{
		statusArea.text = '@' + _currentStatus.user.screenName + ' ' + statusArea.text;
		statusArea.setSelection(statusArea.text.length, statusArea.text.length);
	}
	else
	{
		statusArea.text = '@' + _currentStatus.user.screenName + ' ...';
		statusArea.setSelection(statusArea.text.length - 3, statusArea.text.length);
	}
	statusArea.setFocus();
	user_panel.removeAllChildren();
	fold_panel.unfold();
}

public function main_onUserInitiatingDM(event:Event):void
{
	if(!currentStatus) return;
	var account:Array = main_findServiceRowByServerUsername(_currentStatus.server, _currentStatus.username);
	if(account)
		main_changeSelectorValue(account['id']);
	if(statusArea.text.length > 0)
	{
		statusArea.text = 'd ' + _currentStatus.user.screenName + ' ' + statusArea.text;
		statusArea.setSelection(statusArea.text.length, statusArea.text.length);
	}
	else
	{
		statusArea.text = 'd ' + _currentStatus.user.screenName + ' ...';
		statusArea.setSelection(statusArea.text.length - 3, statusArea.text.length);
	}
	statusArea.setFocus();
	user_panel.removeAllChildren();
	fold_panel.unfold();		
}

public function main_onUserInitiatingArchive(event:Event):void
{
	if(!currentStatus) return;
	main_openDrawer();
	if(null != editingOutlinerNode)
	{
		return;
	}
	var node:XML = outlinerTree.selectedItem as XML;
	if(null == node)
		return;
	if(true == node.@complete)
		return;
	var newNode:XML = main_newOutlinerNoteNode();
	outlinerUpdated = true;
	node.appendChild(newNode);
	outlinerTree.expandItem(node, true);
	newNode.@nodeText = _currentStatus.text;
}

/**
 * Store an array of TwitterStatus objects in the global storage structure
 */
private function main_store(area:Container, data:Array):void
{
	resultsStorage[processing] = new Storage(area);
	for each(var entry:TwitterStatus in data)
	{
		resultsStorage[processing].push(entry);
	}
}

// -----------------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------------

/**
 * This function has become somewhat of a misnommer, since it actually will help
 * us with '[xxx]' type indicators.
 */
private function main_lookup20x(text:String):String
{
	var special:String;
	var specialSpecial:Boolean = false;
	if(text.charAt(0)=='@')
	{
		var p:int = text.indexOf(' ');
		if(p>-1)
		{
			for(var i:int=p; text.charAt(i); i++)
			{
				if(text.charAt(i)==' ')
					p++;
				else
					break;
			}
			special = text.substr(p, 5);
			specialSpecial = true;
		}
	}
	if(!specialSpecial)
		special = text.substr(0, 5);
		
	return special;
}

/** @todo Move to Twitterified.as */
private function main_preProcess(msg:String):String
{
	// Left trim
	for(var i:int=0, trimmer:int=0; msg.charAt(i); i++)
	{
		if(msg.charAt(i)==' ')
			trimmer++;
		else
			break;
	}
	if(trimmer>0)
		msg = msg.substr(trimmer);
	//
	
	var p:int = msg.indexOf(' ');
	if(p>-1)
	{
		twitterified.kwrd = msg.substr(0, p);
		if(!Twitterified.RESERVED[twitterified.kwrd])
		{
			// OK so it's not a reserved Twitter keyword (other than d or @)
			twitterified.sendAsIs = false;
			if(twitterified.kwrd=='d') // direct message
			{
				for(var i:int=p; msg.charAt(i); i++)
				{
					if(msg.charAt(i)==' ')
						p++;
					else
						break;
				} // trimmed some more
				
				var p2:int = msg.indexOf(' ', p+1);
				if(p2>-1)
				{
					twitterified.dest = msg.substr(p, (p2-p));
					twitterified.kwrd = 'd ';
					msg = msg.substr(p2+1);
				}
			}
			else if(twitterified.kwrd.substr(0, 1)=='@') // reply
			{
				twitterified.dest = twitterified.kwrd.substr(1);
				twitterified.kwrd = '@';
				msg = msg.substr(p+1);
			}
		}
		// else it's one of the reserved keywords...leave it alone		
	}
	else
		twitterified.sendAsIs = false; // that's it...no space - just one word

	return msg;	
}

private function main_mapSelectorValueToUnique():String
{
	var item:Object = accountselectorcb.selectedItem;
	var account:Array = main_findServiceRowById(item.data);
	return twitter.mapServer(account['service'], account['server'])+'$'+account['username'];
}

private function main_changeSelectorValue(id:int):void
{
	var runner:int = 0;
	var row:Object;
	for each(row in accountSelectorValue)
	{
		if(row.data == id)
		{
			accountselectorcb.selectedIndex = runner;
			return;
		}
		runner ++;
	}
}

private function main_refreshAccountSelectorValue():void
{
	accountSelectorValue = new Array();
	var account:Array;
	for each(account in accountsList)
	{
		var row:Object = { label:account['service']+':'+account['username'], data:account['id'] };
		accountSelectorValue.push(row);
	}
}

include "com/voilaweb/tfd/notclasses/main_useractions.as";
include "com/voilaweb/tfd/notclasses/main_net.as";
include "com/voilaweb/tfd/notclasses/main_queueing.as";
include "com/voilaweb/tfd/notclasses/main_ui.as";
include "com/voilaweb/tfd/notclasses/main_gestures.as";
include "com/voilaweb/tfd/notclasses/main_preferences.as";
include "com/voilaweb/tfd/notclasses/main_localstorage.as";
include "com/voilaweb/tfd/notclasses/main_services.as";

include "com/voilaweb/tfd/notclasses/main_video.as";
include "com/voilaweb/tfd/notclasses/main_timers.as";
include "com/voilaweb/tfd/notclasses/main_drawer.as";
include "com/voilaweb/tfd/notclasses/main_search.as";
include "com/voilaweb/tfd/notclasses/main_outliner.as";
include "com/voilaweb/tfd/notclasses/main_help.as";