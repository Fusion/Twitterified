private function main_showSearch():void
{
	search_expr.setFocus();
}

private function main_performSearch():void
{
	if(search_expr.text.length < 4)
	{
		Alert.show("Enter at least four characters!");
		return;
	}
	search_results.removeAllChildren();
	main_queue(SEARCH_AC);
}
