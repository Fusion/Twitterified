
/**
 * I should theoritically not need this little function. Keeping it around, just in case...
 */
private function main_quickSort(arrayInput:Array, left:int, right:int):void
{ 
	var i:int = left; 
	var j:int = right; 
	var pivotPoint:TwitterStatus = arrayInput[Math.round((left+right)*.5)]; 
	// Loop 
	while (i<=j) { 
		while (arrayInput[i].id<pivotPoint.id) { 
			i++;
		} 
		while (arrayInput[j].id>pivotPoint.id) { 
			j--;
		} 
		if (i<=j) { 
			var tempStore:TwitterStatus = arrayInput[i]; 
			arrayInput[i] = arrayInput[j]; 
			i++; 
			arrayInput[j] = tempStore; 
			j--;
		}
	} 
	// Swap 
	if (left<j) { 
		main_quickSort(arrayInput, left, j);
	} 
	if (i<right) { 
		main_quickSort(arrayInput, i, right);
	} 
	return;
}

// This function used to sort based on id...this obviously does not work with different servers
// so now we are using created at...
// Note: this guys was complexified a bit but it's to work exactly like what's in StatusRow
private function main_sortData(a:TwitterStatus, b:TwitterStatus):int
{
//	if(a.id == b.id)
	var now:Date = new Date();
	var offsetA:Number;
	var offsetB:Number;
	if(null != a.server && -1 == a.server.indexOf(".presentlyapp.com"))
		offsetA = (now.valueOf() + now.timezoneOffset * 60000 - a.createdAt.time);
	else
		offsetA = (now.valueOf() - a.createdAt.time);
	if(null != b.server && -1 == b.server.indexOf(".presentlyapp.com"))
		offsetB = (now.valueOf() + now.timezoneOffset * 60000 - b.createdAt.time);
	else
		offsetB = (now.valueOf() - b.createdAt.time);
	if(offsetA == offsetB)
		return 0;
	return (offsetA > offsetB ? -1 : 1);
}

/**
 * Queue + unQueue: I am well aware of the potential for race conditions...
 * Still unclear whether Flex's event listeners are aysnchronous
 * but something is telling me that they aren't.
 */
private function main_queue(token:String, parameter:String = null):void
{
	queueFifo.push(new QueuedAction(token, parameter));
	if(!processing)
		main_unqueue();		
}

/**
 * @see main_queue
 */
private function main_unqueue():void
{
	if(queueFifo.length < 1)
	{
		spinner.stop();
		// empty queue
		processing = null;
		return; 		
	}
	spinner.play();
	var queuedAction:QueuedAction = queueFifo.shift();
	processing = queuedAction.token;
	Logger.info("Unqueued "+processing);
	if(accountsList.length < 1) { main_unqueue(); return; } // No account setup
	switch(processing)
	{
		case FRIENDS_TL:
			main_status("Loading Friends Timeline...");
			twitter.loadFriendsTimeline();
			break;
		case DIRMSG_TL:
			main_status("Loading Dir Msgs Timeline...");
			twitter.loadDirectMessagesTimeline();
			break;
		case REPLIES_TL:
			main_status("Loading Replies Timeline...");
			twitter.loadRepliesTimeline();
			break;
		case USER_TL:
			main_status("Loading User Timeline...");
			twitter.loadUserTimeline();
			break;
		case SENT_DIRMSG_TL:
			main_status("Loading Sent Dir Msgs Timeline...");
			twitter.loadUserTimeline();
			break;
		case PUBLIC_TL:
			main_status("Loading Public Timeline...");
			twitter.loadPublicTimeline();
			break;
		case FRIENDS_LS:
			if(queuedAction.parameter != null)
				main_status("Loading "+queuedAction.parameter+"'s Friends...");
			else
				main_status("Loading Your Friends...");
			/*
			twitter.loadFriends(
				queuedAction.parameter != null ?
				queuedAction.parameter :
				preferences['username']);
			 */
			twitter.loadFriends();
			break;
		case FOLLOWERS_LS:
			main_status("Loading Followers...");
			twitter.loadFollowers();
			break;
		case SEARCH_AC:
			main_status("Performing Search...");
			var searchStr:String = '';
			if(searchtrendscb.selected)
				searchStr = '#';
			searchStr += search_expr.text;
			summize.search(searchStr);	
			break;
	}
}

/**
 * Return time elapsed since 'old'... value in ms / 60000 * refresh
 */
private function main_elapsed(old:int):int
{
	/*
	var i:int = (int)(new Date().valueOf() / 60000) - old;
	var a:int = (int)(new Date().valueOf() / 60000);
	 */
	return (int)(new Date().valueOf() / 60000) - old;
}

/**
 * If enough time has elapsed, we may indeed queue up a request for a refresh action
 * Note that if a non-null parameter is passed, the time check is bypassed. 
 */
private function main_youmayproceed(token:String, parameter:String = null, force:Boolean = false):Boolean
{
	showingTab = token;
	
	var mayProceed:Boolean = false;
	if(parameter != null || force) mayProceed = true;
	else if(!showedTab[token]) mayProceed = true;
	else if(main_elapsed(showedTab[token]) >= preferences['refresh']) mayProceed = true;
	if(mayProceed)
		showedTab[token] = int(new Date().valueOf() / 60000);
	if(mayProceed)
	{
		Logger.info("Queueing "+token);
		main_queue(token, parameter);
	}
	return mayProceed;	
}