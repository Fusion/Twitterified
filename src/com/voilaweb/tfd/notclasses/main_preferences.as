
private function main_loadPreferences():void
{
	main_enumSoundThemes();	
	
	preferences					= new Array();
	preferences['username']		= main_loadPreference('username', '');
	preferences['password']		= main_loadPreference('password', '');
	preferences['secretkey']	= main_loadPreference('secretkey', '');
	preferences['httpauth']		= ('true' == main_loadPreference('httpauth', 'true'));
	preferences['opacity']		= parseInt(main_loadPreference('opacity', '100'));
	preferences['markdown']		= ('true' == main_loadPreference('markdown', 'false'));
	preferences['systray']		= ('true' == main_loadPreference('systray', 'false'));
	preferences['sounds']		= ('true' == main_loadPreference('sounds', 'true'));	
	preferences['soundtheme']	= main_loadPreference('soundtheme', soundThemes[0]);
	preferences['refresh']		= parseInt(main_loadPreference('refresh', '5'))
	preferences['conversations']= ('true' == main_loadPreference('conversations', 'false'));
	preferences['debugging']	= ('true' == main_loadPreference('debugging', 'false'));
	preferences['server']		= main_loadPreference('server', Twitter.TWITTER_SERVER);
	preferences['winheight']	= parseInt(main_loadPreference('winheight', '800'))
	
	// And load accounts
	main_loadAccounts();
	
	// We loaded them...how about applying them now?
	// @todo Currently transparency doesn't work mainLayout.parent.alpha = preferences['opacity'] / 100;
	main_startTimers();
}

// Note: Preferences mgmt only works if accordion created with creationPolicy=all ...obviously...
private var main_showedPreferences:Boolean = false;
private  function main_showPreferences():void
{
	if(main_showedPreferences)
		return;
		
//	cfg_username.text			= preferences['username'];
//	cfg_password.text			= preferences['password'];
	cfg_secretkey.text			= preferences['secretkey'];
//	cfg_httpauth.selected		= preferences['httpauth'];
	cfg_opacity.value			= preferences['opacity'];
	cfg_markdown.selected		= preferences['markdown'];
	cfg_systray.selected		= preferences['systray'];
	cfg_sounds.selected			= preferences['sounds'];
	cfg_soundtheme.text			= preferences['soundtheme'];
	cfg_refresh.value			= preferences['refresh'];
	cfg_conversations.selected	= preferences['conversations'];
	cfg_debugging.selected		= preferences['debugging'];
	cfg_server.text				= preferences['server'];
	cfg_winheight.value			= preferences['winheight'];
	
	main_showedPreferences = true;
}

public function main_savePreferences():void
{
	var validatorErrors:Array = Validator.validateAll(validators);
	if(validatorErrors.length > 0)
	{
		var err:ValidationResultEvent;
		var errMsgs:Array = [];
		for each(err in validatorErrors)
			errMsgs.push(FormItem(err.currentTarget.source.parent).label + ': ' + err.message);
		Alert.show(errMsgs.join("\n\n"), "Sorry", Alert.OK); 
		return;
	}
	
	main_saveAccounts();
	
//	main_savePreference('username',		cfg_username.text);
//	main_savePreference('password',		cfg_password.text);
	main_savePreference('secretkey',	cfg_secretkey.text);
//	main_savePreference('httpauth',		cfg_httpauth.selected.toString());
	main_savePreference('opacity',		cfg_opacity.value.toString());
	main_savePreference('markdown',		cfg_markdown.selected.toString());
	main_savePreference('systray',		cfg_systray.selected.toString());
	main_savePreference('sounds',		cfg_sounds.selected.toString());
	main_savePreference('soundtheme',	cfg_soundtheme.text);
	main_savePreference('refresh',		cfg_refresh.value.toString());
	main_savePreference('conversations',cfg_conversations.selected.toString());
	main_savePreference('debugging',	cfg_debugging.selected.toString());
	main_savePreference('server',		cfg_server.text);
	main_savePreference('winheight',	cfg_winheight.value.toString());
	
	main_loadPreferences(); // Update prefs array
	
	main_status("Saved Preferences.", true);
}