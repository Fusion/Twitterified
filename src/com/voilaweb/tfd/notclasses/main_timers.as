
private function main_startTimers():void
{
	if(updateTimer)
	{
		updateTimer.removeEventListener(TimerEvent.TIMER, onUpdateTimerEvent);
		updateTimer.stop();
	}
	updateTimer = new Timer(preferences['refresh'] * 60000, 0); // Every 'refresh' minutes
	updateTimer.addEventListener(TimerEvent.TIMER, onUpdateTimerEvent);
	updateTimer.start();	

	if(notificationTimer)
	{
		notificationTimer.removeEventListener(TimerEvent.TIMER, onNotificationTimerEvent);
		notificationTimer.stop();
	}
	notificationTimer = new Timer(5000, 0); // Every 5 seconds
	notificationTimer.addEventListener(TimerEvent.TIMER, onNotificationTimerEvent);
	notificationTimer.start();	
}

/**
 * Depending on which screen we are looking at, refresh 
 */
private function onUpdateTimerEvent(event:TimerEvent):void
{
	switch(showingTab)
	{
		case FRIENDS_TL:
			main_youmayproceed(FRIENDS_TL);
			break;
		case USER_TL:
			main_youmayproceed(USER_TL);
			break;
		case PUBLIC_TL:
			main_youmayproceed(PUBLIC_TL);
			break;
	}	
}

private function onNotificationTimerEvent(event:TimerEvent):void
{
	//trace("Housekeeping tasks underway...");
	// Have we loaded Mr outliner?
	/** @todo Beware of race condition! We need another timer here, in fact */
	/*
	if(outlinerTree.dataProvider == outlinerModel)
	{
		main_status("Saving Outliner Data...");
		main_saveOutline(outlinerModel);
		main_status("Ready.", true);
	}
	*/
}