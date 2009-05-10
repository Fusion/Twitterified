package com.voilaweb.tfd
{
	import flare.vis.controls.*;
	import flare.vis.data.*;
	import flare.vis.operator.*;
	import flare.vis.operator.layout.*;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.*;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Timer;
	
	import flexlib.containers.WindowShade;
	import flexlib.controls.ImageMap;
	import flexlib.controls.area;
	import flexlib.events.ImageMapEvent;
	
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.TabNavigator;
	import mx.containers.VBox;
	import mx.controls.Text;
	import mx.core.Application;
	import mx.core.BitmapAsset;
	import mx.core.IToolTip;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.events.ResizeEvent;
	import mx.managers.ToolTipManager;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.*;
	
	import twitter.api.data.TwitterStatus;
	import twitter.api.events.TwitterEvent;
	
	public class StatusRow extends WindowShade
	{
		private static var _idrunner:int = 0;
		private static var _contextMenu:ContextMenu = null;
		private var _date:Number;
		private var _offsetable:Boolean;
		private var _app:TwitterifiedNative;
		private var _loader:Loader;
		private var _status:TwitterStatus;
		private var _shallMarkRead:Boolean;		
		private var _directMessage:Boolean;
		private var _toolTip:IToolTip = null;
		private var _imageOverlayPanel:Canvas = null;		
		private var textWrapper:VBox;
		private var mediaWrapper:UIComponent;
		private var expectedWidth:int;
		private var expectedHeight:int;
		private var storedComment:DisplayObjectContainer;
		private var timer:Timer;		
		
		public function StatusRow(app:TwitterifiedNative, status:TwitterStatus, markRead:Boolean = false)
		{
			var contextMenu:ContextMenu = new ContextMenu();
			var rtItem:ContextMenuItem = new ContextMenuItem('Retweet');
			rtItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onCMRetweet);
			contextMenu.customItems.push(rtItem);
			var replyItem:ContextMenuItem = new ContextMenuItem('Reply');
			replyItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onCMReply);
			contextMenu.customItems.push(replyItem);
			var dmItem:ContextMenuItem = new ContextMenuItem('Direct Message');
			dmItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onCMDirectMessage);
			contextMenu.customItems.push(dmItem);
			var arItem:ContextMenuItem = new ContextMenuItem('Archive');
			arItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onCMArchive);
			contextMenu.customItems.push(arItem);
			arItem.enabled = false; // TODO IN NEXT RELEASE
			var moreItem:ContextMenuItem = new ContextMenuItem('More');
			moreItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onCMMore);
			contextMenu.customItems.push(moreItem);
			this.contextMenu = contextMenu;
			styleName = 'statusrow';
			++ _idrunner;	
			this.id = 'sr_' + _idrunner.toString();
			_app = app;
			_status = status;
			_shallMarkRead = markRead;
			/** @todo Handle reply as well */
			_directMessage = (TwitterEvent.ON_DIRECT_MESSAGES_TIMELINE_RESULT == status.interaction);			
			// Ignore
			if(_status.user && _app.ignored[_status.user.screenName])
				this.opened = false;
			// Image
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			try
			{
				Logger.info("Loading image from "+status.user.profileImageUrl);
				_loader.load(new URLRequest(status.user.profileImageUrl));
			}
			catch(error:Error)
			{
				// This picture doesn't exist - C'est la vie...
				onError();
			}
		}
		
		public function get status():TwitterStatus
		{
			return _status;
		}
		
		public function isBounding(point:Point):Boolean
		{
			var pt:Point = this.globalToLocal(point);	
			return (pt.x >=0 && pt.y >= 0 && pt.x <= this.width && pt.y <= this.height);
		}
	
		private var oldOpenIconStyle:Class = null;
		private var oldCloseIconStyle:Class = null;
		
		public function toggleReadFlag(read:Boolean):void
		{
			if(read)
			{
				// Update Database
				if(_status.id)
					_app.main_markRead(_status.id.toString(), true);
				// Visual
				if(oldOpenIconStyle)
					setStyle('openIcon', oldOpenIconStyle);
				if(oldCloseIconStyle)
					setStyle('closeIcon', oldCloseIconStyle);				
			}
			else
			{
				// Update Database
				if(_status.id)
					_app.main_markRead(_status.id.toString(), false);
				// Visual
				if(!oldOpenIconStyle)
					oldOpenIconStyle = getStyle('openIcon');
				if(!oldCloseIconStyle)
					oldCloseIconStyle = getStyle('closeIcon');
				setStyle('openIcon', _app.iconInfoNew);
				setStyle('closeIcon', _app.iconInfoNew);				
			}
			/* This is how I would find the button itself
			var i:int;
			var kid:DisplayObject = null;
			for(i=0; i<rawChildren.numChildren; i++)
			{
				kid = rawChildren.getChildAt(i);
				if(kid is Button)
				{
				}
			}
			*/
		}
		
		private function onMouseMovePossiblyOut(event:MouseEvent):void
		{			
			if(!_imageOverlayPanel.parent) return;						
			var pt:Point = new Point(event.stageX, event.stageY);
			pt = _imageOverlayPanel.globalToLocal(pt);
			if(pt.x < 0 || pt.y < 0 || pt.x > _imageOverlayPanel.width || pt.y > _imageOverlayPanel.height) 	
			{
				_imageOverlayPanel.parent.addEventListener(MouseEvent.MOUSE_OVER, onImageMouseOver); // innerWrapper resumes listening to mouse_over events			
				_imageOverlayPanel.parent.removeChild(_imageOverlayPanel); // overlay panel is detached from innerWrapper	
			}		
		}
		
		private function onImageMouseOver(event:MouseEvent):void
		{
			var obj:UIComponent = event.target as UIComponent;
			if(!obj) return;			
			obj.removeEventListener(MouseEvent.MOUSE_OVER, onImageMouseOver); // innerWrapper stops listening to mouse_over events									
			if(!_imageOverlayPanel)
			{
				//
				// Structure:
				// | image map     | evt: mouse_out
				// | overlay panel |
				// | inner wrapper | evt: mouse_over
				//
				var clickAreas:Array = new Array();
				var anArea1:area = new area();
				anArea1.alt = 'reply';
				anArea1.shape = 'rect';
				anArea1.coords = '0, 0, 20, 20';
				clickAreas.push(anArea1);
				var anArea2:area = new area();
				anArea2.alt = 'direct';
				anArea2.shape = 'rect';
				anArea2.coords = '30, 0, 50, 20';
				clickAreas.push(anArea2);
				var anArea4:area = new area();
				anArea4.alt = 'more';
				anArea4.shape = 'rect';
				anArea4.coords = '0, 24, 30, 50';
				clickAreas.push(anArea4);
				var imgObj:BitmapAsset = new _app.userImageOverlay() as BitmapAsset;
				var image:ImageMap = new ImageMap();
				image.setStyle('outlineAlpha', 0);
				image.setStyle('fillAlpha', 0);
				image.showToolTips = false;
				image.map = clickAreas;
				image.source = imgObj;
				image.x = 0;
				image.y = 0;
				image.addEventListener('shapeClick', onUserImageOverlayClick);
				_imageOverlayPanel = new Canvas();
				_imageOverlayPanel.width  = 50;
				_imageOverlayPanel.height = 50;
				_imageOverlayPanel.x = 0;
				_imageOverlayPanel.y = 0;
				_imageOverlayPanel.addChild(image); // add image to overlay panel				
				_imageOverlayPanel.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut); // image map will always listen to mouse_out events			
			}			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMovePossiblyOut);
			obj.addChild(_imageOverlayPanel); // add overlay panel on top of innerWrapper
		}
		
		private function onUserImageOverlayClick(event:ImageMapEvent):void
		{
			_app.currentStatus = _status;
			_app.currentUser   = _status.user;
			
			switch(event.item.alt)
			{
				case 'reply':
					_app.main_onUserInitiatingReply(event);
					break;
				case 'direct':	
					_app.main_onUserInitiatingDM(event);
					break;
				case 'more':
					_app.main_revealMoreOptions(event);
					break;
			}
		}
		
		private function onCMRetweet(event:ContextMenuEvent):void
		{
			_app.currentStatus = _status;
			_app.currentUser   = _status.user;
			_app.main_onUserInitiatingRetweet(event);
		}

		private function onCMReply(event:ContextMenuEvent):void
		{
			_app.currentStatus = _status;
			_app.currentUser   = _status.user;
			_app.main_onUserInitiatingReply(event);			
		}
		
		private function onCMDirectMessage(event:ContextMenuEvent):void
		{
			_app.currentStatus = _status;
			_app.currentUser   = _status.user;
			_app.main_onUserInitiatingDM(event);
		}

		private function onCMArchive(event:ContextMenuEvent):void
		{
			_app.currentStatus = _status;
			_app.currentUser   = _status.user;
			_app.main_onUserInitiatingArchive(event);
		}

		private function onCMMore(event:ContextMenuEvent):void
		{
			_app.currentStatus = _status;
			_app.currentUser   = _status.user;
			_app.main_revealMoreOptions(event);
		}
		
		/*
		private function onImageMouseOut(event:MouseEvent):void
		{
			trace("-- Mouse Out ["+this.id+"]");
			if(!_imageOverlayPanel.parent) return;
			if(!event.relatedObject) return;
			// This is annoying. I do not wish to modify flexlib but an ImageMap's children are not accessible,
			// hence this weird hack...
			var parent:DisplayObject = event.relatedObject.parent;
			while(parent)
			{
				if(parent is ImageMap) return; // ignore!
				parent = parent.parent;
			}
			//			
			trace("-- REMOVE OVERLAY ["+this.id+"]");
			_imageOverlayPanel.parent.addEventListener(MouseEvent.MOUSE_OVER, onImageMouseOver); // innerWrapper resumes listening to mouse_over events			
			_imageOverlayPanel.parent.removeChild(_imageOverlayPanel); // overlay panel is detached from innerWrapper														
		}
		*/
		
		private function onMouseMove(event:MouseEvent):void
		{
			if(!_toolTip)
			{
				var toolTipStr:String =
					'<b>' + _status.user.name + ' (' + 
					(
						_status.user.url && _status.user.url.length > 0 ?
							'<a href="' + _status.user.url + '">' + _status.user.screenName + '</a>' :
							_status.user.screenName
					) +
					')</b> ' +
					_status.user.followers.toString() + ' followers' +
					'<br />' +
					'<i>' + _status.user.location + '</i><br />' +
					_status.user.description;
				if(Application.application.preferences['debugging'])
				{
					toolTipStr =
						'<b>Debug Info</b><br /><i>Id:'+_status.unique+':'+_status.id+'</i><br />' +
						toolTipStr;
				}
				_toolTip = ToolTipManager.createToolTip(toolTipStr, event.stageX, event.stageY);
				_toolTip.alpha = .9;
			}
			_toolTip.move(event.stageX, event.stageY);
			event.updateAfterEvent();
		}

		private function onMouseOut(event:MouseEvent):void
		{
			if(_toolTip)
			{
				ToolTipManager.destroyToolTip(_toolTip);
				_toolTip = null;
			}																							
		}
		
		private function onError(event:Event = null):void
		{
			Logger.info(this._status.id.toString() + ": Oops! What image?");
			_loader.load(new URLRequest('app:/sounds/bluejay_48.png'));
		}
		
		private var _t1:Text;
		private var _t2:VBox;
		private function onComplete(event:Event):void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			
			var innerBox:HBox = new HBox();
			innerBox.percentWidth = 100;
			
			var innerWrapper:UIComponent = new UIComponent();
			innerWrapper.name = 'innerWrapper';
			// Twitter et al. store avatars that are 48x48 in size.
			// Other players may not. Present.ly for instance uses 50x50 avatars.
			_loader.content.width = 48;
			_loader.content.height = 48;
			
			innerWrapper.addChild(_loader.content);
			innerWrapper.height = 50;
			innerWrapper.width = 50;
			innerWrapper.x = 0;
			innerWrapper.y = 0;
			var myWrapper:Canvas = new Canvas();
			myWrapper.width = 51;
			myWrapper.height = 51;
			myWrapper.styleName = 'statusrowavatar';
			//myWrapper.mask = _app.user_avatar_mask;
			myWrapper.addChild(innerWrapper);
			// ------------------------------------------------
			// Various expansions
			// ------------------------------------------------
			// Expand links
			var pattern:RegExp = /(?:(\s|^|\.|\:|\())(?:http:\/\/)((?:[^\W_]((?:[^\W_]|-){0,61}[^\W_])?\.)+([a-z]{2,6}))((?:\/[\w\.\/\?=%&_-]*)*)/g;
			_status.text = _status.text.replace(pattern, '$1<a href=\"http://$2$5\" title="Open link in a browser window" class="inline-link"><font color="#8888BB">$2</font></a>');
			// Expand twitpic
			pattern = /<a href="http:\/\/twitpic\.com\/([0-9A-Za-z]+).+?<\/a>/g;
			var matches:Array = pattern.exec(_status.text);
			// Note: Yup, there may be multiple matches, but I will only bother to handle the first one
			if(matches && matches.length > 1)
			{
				_status.extra = 'http://twitpic.com/show/thumb/' + matches[1] + '.jpg';
				_status.type = 'i';
			}
			// ------------------------------------------------
			// .
			// ------------------------------------------------
			var text:Text = new Text();	
			text.styleName = 'statusrowelement';
			if(_directMessage)
				text.htmlText = '<i><b>' + _status.text + '</b></i>';
			else
				text.htmlText = _status.text;
			_t1 = text;
			
			text.percentWidth = 100;			
			var textBlock:VBox = new VBox();
			textBlock.addChild(text);
			//textBlock.addChild(datePosted);
			textBlock.styleName = 'statusrowelement';
			textBlock.percentWidth = 100;
			_t2 = textBlock;
			
			var mediaTitle:Text;
			var mediaLoader:Loader;
			
			textWrapper = null;
			expectedWidth = 0;
			expectedHeight = 0;
			var labelBuilder:String = '';
			if(_status.extra)
			{
				if(_status.extra.charAt(0)=='|')
				{
					var bit:String;
					var bits:Array = _status.extra.split('|');
					for each(bit in bits)
					{
						switch(bit.charAt(0))
						{
							case 'u':
								_status.extra = bit.substr(2);	
								break;
							case 'b':
								/** @todo This is where we get the matching link */
								break;
						}
					}	
				}
				
				switch(_status.type)
				{
					case 'v': // video
						labelBuilder = 'Movie';
						textWrapper = new VBox();
						textWrapper.styleName = 'statusrowelement';
						//mediaTitle = new Text();
						//mediaTitle.styleName = 'statusrowelement';
						//mediaTitle.htmlText = '<b>Movie</b>';
						//textWrapper.addChild(mediaTitle);
						expectedWidth = 425;
						expectedHeight = 425;
						storedComment = textBlock;
						mediaLoader = new Loader();
						mediaLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onRealizeImage);
						mediaLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onNoImage);
						mediaLoader.load(new URLRequest(_status.direct));
						break;
					case 'i': // image
						labelBuilder = 'Image';			
						textWrapper = new VBox();
						textWrapper.styleName = 'statusrowelement';
						//mediaTitle = new Text();
						//mediaTitle.styleName = 'statusrowelement';
						//mediaTitle.htmlText = '<b>Image</b>';
						//textWrapper.addChild(mediaTitle);
						storedComment = textBlock;
						mediaLoader = new Loader();
						mediaLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onRealizeImage);
						mediaLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onNoImage);
						mediaLoader.load(new URLRequest(_status.extra));
						break;
					default:
						labelBuilder = 'Tweet';
				}	
			}
			else
				labelBuilder = 'Tweet';
				
			this._date = _status.createdAt.valueOf();	// Store for future reference
			this._offsetable = (null != _status.server && -1 == _status.server.indexOf(".presentlyapp.com"));
			if(_directMessage)
				labelBuilder = labelBuilder + ' (Direct Message)';
			this.label = labelBuilder + ' by ' + _status.user.name + ' - ' + getCoolDate(this._date, this._offsetable);

			innerBox.addChild(myWrapper);
			if(textWrapper)
				innerBox.addChild(textWrapper);
			else			
				innerBox.addChild(textBlock);
			this.addChild(innerBox);
			
			if(!_shallMarkRead)
				toggleReadFlag(false);
			
			this.percentWidth = 100;
			// Tooltip & Actions management
			innerWrapper.addEventListener(MouseEvent.MOUSE_OVER, onImageMouseOver);			
			myWrapper.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			myWrapper.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			/** @see doNotScrollOnMouseWheel */
			text.addEventListener(MouseEvent.MOUSE_WHEEL, doNotScrollOnMouseWheel);
		}
		
		/**
		 * An interesting hack:
		 * with Text + VBox and this layout, text.height == container.height
		 * So what? Well, as a result, the mousewheel causes the text to scroll up in some instances.
		 * I tried to fix this by preventing the default action but I guess this event is not cancelable...
		 * Silly workaround: "Oh but no, do not scroll! The container is actually bigger (by 1px)"
		 */
		private function doNotScrollOnMouseWheel(event:Event):void
		{
			if(!event.target is UITextField) return;
			var obj:UITextField = event.target as UITextField;
			if(obj.height == obj.parent.height)
				obj.parent.height++;
		}
		
		private function onRealizeImage(event:Event):void
		{
			mediaWrapper = new UIComponent();	
			mediaWrapper.styleName = 'statusrowelement';					
			mediaWrapper.addChild(event.target.loader.content);
			// @todo
			// What we must do is, if this is an asset we already know the height of, store it
			// and use it here...for instance youtube: <object width="425" height="355">
			if(expectedHeight > 0)
			{
				mediaWrapper.height = expectedHeight;
				mediaWrapper.width  = expectedWidth;
			}
			else
			{
				mediaWrapper.height = event.target.loader.content.height;
				mediaWrapper.width  = event.target.loader.content.width;
			}
			var ratio:Number = (this.width - 80)/ mediaWrapper.width;
			if(ratio < 1)
			{
				mediaWrapper.scaleX = ratio;
				mediaWrapper.scaleY = ratio;				
			}
			textWrapper.addChild(mediaWrapper);
			textWrapper.addChild(storedComment);
			
			event.target.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onNoImage);
			event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onRealizeImage);	
			
			//this.addEventListener(ResizeEvent.RESIZE, onResize);
		}
		private function onNoImage(event:Event):void
		{
			// Shhh...for now. TODO! Display default "broken" pic?
		}		
		
		// @todo This needs to be thought through a little more carefully!
		private function onResize(event:ResizeEvent):void
		{
			var ratio:Number = (this.width - 80)/ mediaWrapper.width;
			if(ratio < 1)
			{
				mediaWrapper.scaleX = ratio;
				mediaWrapper.scaleY = ratio;				
			}			
		}
		
		private function getNavigator():DisplayObjectContainer
		{
			var container:DisplayObjectContainer = this;
			while(container = container.parent)
			{
				if(container is TabNavigator)
					break;
			}
			return container;
		}
		
		public function updateCoolDate():void
		{
			var ar:Array = this.label.split(' - ');
			if(ar.length < 1) return; // This should soooo not happen!
			this.label = ar[0] + ' - ' + getCoolDate(this._date, this._offsetable);
		}
		
		// I originally got this code from Spaz, but disagreed with some of the values used so here it is...
		private function getCoolDate(inDate:Number, offsetable:Boolean):String
		{
			// What's the deal with adjusting our own timezone offset and now Twitter's?
			// Well, Twitter's times are all UTC. Or so it seems.
			var now:Date = new Date();	
			var delta:Number;
			if(offsetable)
				delta = (now.valueOf() + now.timezoneOffset * 60000 - inDate) / 1000;
			else
				delta = (now.valueOf() - inDate) / 1000;			
			if(delta < 60)
				return 'less than a minute ago';
			else if(delta < 120)
				return 'about a minute ago';
			else if(delta < 2700)
				return int(delta / 60).toString() + ' minutes ago';
			else if(delta < 5400)
				return 'about an hour ago';
			else if (delta < 86400)
			{
				if(int(delta / 3600) == 1)
					return 'about 2 hours ago';
				else
					return 'about ' + int(delta / 3600).toString() + ' hours ago';
			}
			else if(delta < 172800)
				return 'a day ago';
			else
				return int(delta / 86400).toString() + ' days ago';
		}
	}
}