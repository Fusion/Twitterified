package com.voilaweb.tfd
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.*;
	
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Text;
	import mx.core.IToolTip;
	import mx.core.UIComponent;
	import mx.managers.ToolTipManager;
	
	import twitter.api.data.TwitterUser;
	
	public class PeopleRow2 extends HBox
	{
		private static var _idrunner:int = 0;
		private var _app:TwitterifiedNative;
		private var _loader:Loader;
		private var _person:TwitterUser;
		private var _toolTip:IToolTip = null;
		private var textWrapper:VBox;
		private var mediaWrapper:UIComponent;
		private var expectedWidth:int;
		private var expectedHeight:int;
		private var storedComment:DisplayObjectContainer;
		
		public function PeopleRow2(app:TwitterifiedNative, person:TwitterUser)
		{
			//styleName = 'statusrow';
			++ _idrunner;	
			this.id = 'pr_' + _idrunner.toString();
			_app = app;
			_person = person;
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			try
			{
				_loader.load(new URLRequest(person.profileImageUrl));
			}
			catch(error:Error)
			{
				// This picture doesn't exist - C'est la vie...
				onError();
			}
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			if(!_toolTip)
			{
				var toolTipStr:String =
					'<b>' + _person.name + ' (' + 
					(
						_person.url && _person.url.length > 0 ?
							'<a href="' + _person.url + '">' + _person.screenName + '</a>' :
							_person.screenName
					) +
					')</b> ' +
					_person.followers.toString() + ' followers' +
					'<br />' +
					'<i>' + _person.location + '</i><br />' +
					_person.description;
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
			_loader.load(new URLRequest('app:/sounds/bluejay_48.png'));
		}
		
		private function onComplete(event:Event):void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			
			var innerWrapper:UIComponent = new UIComponent();
			innerWrapper.addChild(_loader.content);
			innerWrapper.height = 50;
			innerWrapper.width = 50;
			innerWrapper.x = 0;
			innerWrapper.y = 0;
			var myWrapper:Canvas = new Canvas();
			myWrapper.width = 51;
			myWrapper.height = 51;
			myWrapper.styleName = 'statusrowavatar';
			myWrapper.mask = _app.user_avatar_mask;
			myWrapper.addChild(innerWrapper);			
			this.addChild(myWrapper);

			var text:Text = new Text();
			text.htmlText = 
				(
					_person.url && _person.url.length > 0 ?
						'<a href="' + _person.url + '">' + _person.screenName + '</a>' :
						_person.screenName
				);
			var textBlock:VBox = new VBox();
			textBlock.addChild(text);
			//textBlock.styleName = 'statusrowelement';
			textBlock.percentWidth = 100;			
			this.addChild(textBlock);
						
			this.percentWidth = 100;
			// Tooltip management
			myWrapper.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			myWrapper.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}
	}
}