package com.voilaweb.tfd
{
	import flare.vis.Visualization;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.render.IRenderer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	
	/**
	 * @todo Currently the constructor takes a node as a parameter - this is an awful circular reference. Need to use a listener!
	 */
	public class TfdGraphSpriteRenderer implements IRenderer
	{
		private var _loader:Loader;
		private var _bitmapData:BitmapData;
		private var _nodeSprite:NodeSprite;
		private var _vis:Visualization;
		
		public function TfdGraphSpriteRenderer(imageUrl:String, nodeSprite:NodeSprite):void
		{
			super();
			_nodeSprite = nodeSprite;
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
			_bitmapData = Bitmap(_loader.content).bitmapData;
			_nodeSprite.dirty();
		}
		
		public function render(d:DataSprite):void
		{
			var g:Graphics = d.graphics;
			with(g)
			{				
				// Are we ready yet?
				if(!_bitmapData)
				{
					beginFill(0x000000, 1);
					drawRect(-25, -25, 50, 50);
					endFill();
				}
				else
				{						
					var matrix:Matrix = new Matrix();
					matrix.identity();
					matrix.translate(-25, -25);
					beginBitmapFill(_bitmapData, matrix, false);
					drawRect(-25, -25, 50, 50);
					endFill();
				}
			}
		}		
	}
}