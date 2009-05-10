package com.voilaweb.tfd
{
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	import mx.core.UIComponent;
	import mx.containers.Panel;
	import mx.containers.VBox;
	import mx.controls.Spacer;
	import mx.core.Application;
	
	public class DrawerContainer extends VBox
	{
		public  static const INITIAL_WIDTH:int = 400;
		public static const NOWHERE:int = 0x0;
		public static const RIGHT:int   = 0x1;
		public static const LEFT:int    = 0x2;
		
		private var _placement:int;
		private var _drawerMain:Panel;
		
		public function DrawerContainer()
		{
			setStyle("verticalGap", 0);
			_drawerMain = new Panel();
			_drawerMain.percentHeight = 100;
			_drawerMain.percentWidth  = 100;
			_drawerMain.styleName = "notSoPanelyPanel";	
			var padBox:Spacer = new Spacer();
			padBox.percentHeight  = 5;
			addChild(padBox);
			addChild(_drawerMain);			
			// Pick a side
			placement = NOWHERE;
		}
		
		public function set panel(child:UIComponent):void
		{
			_drawerMain.addChild(child);
		}
		
		public function get placement():int
		{
			return _placement;	
		}
		
		public function set placement(newPlacement:int):void
		{
			_placement = newPlacement;
		}
		
		public function get availableWidth():int
		{
			var r:Rectangle =
				new Rectangle(
					Application.application.stage.nativeWindow.x,
					Application.application.stage.nativeWindow.y,
					Application.application.stage.nativeWindow.width,
					Application.application.stage.nativeWindow.height);				

			var aWidth:int = -1;
			switch(placement)
			{
				case NOWHERE:
					adjustPlacement(r);
					if(r.right + INITIAL_WIDTH > Capabilities.screenResolutionX)
						aWidth = Capabilities.screenResolutionX - r.right;
					else
						aWidth = INITIAL_WIDTH;
					break;
				case RIGHT:
					var curWidth:int = width;
					if(r.right > Capabilities.screenResolutionX)
						aWidth = Capabilities.screenResolutionX - (r.x + Application.application.main_curWidth());
					else
						aWidth = INITIAL_WIDTH;
					if(curWidth == aWidth)
						aWidth = -1; // Nothing to adjust
					break;
			}
			return aWidth;
		}
		
		public function adjustPlacement(r:Rectangle):void
		{
			placement = RIGHT;
			/*
			switch(placement)
			{
				case NOWHERE:
					if(r.right + INITIAL_WIDTH > Capabilities.screenResolutionX)
					{
						placement = LEFT;
					}
					else
					{
						placement = RIGHT;
					}
					break;
				case RIGHT:
					if(r.right + width > Capabilities.screenResolutionX)
					{
						placement = LEFT;
					}
					break;
				case LEFT: // Does not happen...too complex for now.
					if(x < 0)
					{
						placement = RIGHT;
					}
					break;
			}
			*/
		}		
	}
}