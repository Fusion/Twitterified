package com.voilaweb.tfd
{
	import flare.vis.Visualization;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.render.IRenderer;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.controls.Button;
	import mx.controls.Alert;
		
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.events.MouseEvent;
	
	import com.voilaweb.tfd.Logger;

//DEAD CLASS!
	public class TfdGraphSprite extends Canvas
	{
		private var _loader:Loader;
		private var _bitmapData:BitmapData;
		private var _nodeSprite:NodeSprite;
		private var _vis:Visualization;
		
		public function TfdGraphSprite(imageUrl:String):void
		{
			super();
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			try
			{
				if(imageUrl == null)		
					_loader.load(new URLRequest('app:/sounds/bluejay_48.png'));
				else
					_loader.load(new URLRequest(imageUrl));
			}
			catch(error:Error)
			{
				onError();
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
			innerWrapper.name = 'innerWrapper';
			innerWrapper.addChild(_loader.content);
			innerWrapper.height = 50;
			innerWrapper.width = 50;
			innerWrapper.x = 0;
			innerWrapper.y = 0;			
			this.width  = 51;
			this.height = 51;
			this.styleName = 'statusrowavatar';
			
					var b1:Button = new Button();
					b1.label = "Follow";
					b1.width  = 50;
					b1.height = 50;
					
					this.addChild(b1);
			
//			this.addChild(innerWrapper);
			Logger.info("Added new TfdGraphSprite");
		}
	}
}