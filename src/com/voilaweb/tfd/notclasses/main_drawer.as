private function main_showOutlinerDrawer():void
{
	miscComponentsContainer.removeChild(outlinerWrapper);
	_drawer.panel = outlinerWrapper;
}

private var _drawer:DrawerContainer = null;
public function main_openDrawer():void
{
	if(_drawer)
		return;
		
	_drawer = new DrawerContainer();
	_drawer.percentHeight = 95;
	_drawer.width         = 0;
	main_changeWinWidth(main_curWidth() + _drawer.availableWidth);
	wideContainer.addChild(_drawer);
	main_showOutlinerDrawer();
	var timer:Timer = new Timer(100, 1);
	timer.addEventListener(TimerEvent.TIMER, main_revealDrawer);
	timer.start();
}

private function main_revealDrawer(event:TimerEvent):void
{
	var resize:Resize = new Resize(_drawer);
	resize.widthFrom = 0;
	resize.widthTo   = main_curContainerWidth() - main_curWidth();
	resize.play();	
}

private function main_onAppMoved(event:NativeWindowBoundsEvent):void
{
	if(_drawer)
	{
		var availableWidth:int = _drawer.availableWidth;
		if(-1 < availableWidth)
		{
			main_changeWinWidth(main_curWidth() + availableWidth);
			_drawer.width = availableWidth;
		}		
	}
//		_drawer.adjustPlacement(event.afterBounds);
}