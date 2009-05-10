
/**
 * Queue up a request to refresh the user's friends timeline
 */
private function main_showFriendsTimeline():void
{
	main_youmayproceed(FRIENDS_TL);
//	main_youmayproceed(DIRMSG_TL, null, true);
}

/**
 * Queue up a request to refresh the user's own timeline
 */
private function main_showUserTimeline():void
{
	main_youmayproceed(USER_TL);
//	main_youmayproceed(SENT_DIRMSG_TL, null, true);	
}

/**
 * Queue up a request to refresh Twitter's public timeline
 */
private function main_showPublicTimeline():void
{
	main_youmayproceed(PUBLIC_TL);
}

/**
 * Queue up request to display the user's friends list
 */
public function main_showFriendsList(friendId:String = null):void
{
	// Add nice child if necessary
	if(friends_results_wrapper.getChildren().length < 1)
		friends_results_wrapper.addChild(friends_results);
	main_youmayproceed(FRIENDS_LS, friendId);
}