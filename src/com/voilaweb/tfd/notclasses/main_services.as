
private var curServiceRow:int = 0;

private function main_findServiceRowById(id:int):Array
{
	var account:Array;
	for each(account in accountsList)
	{
		if(account['id'] == id)
		{
			return account;
		}
	}
	return null;
}

private function main_findAndemoveServiceRowById(id:int):void
{
	var account:Array;
	var l:int = accountsList.length;
	var i:int;
	for(i=0; i<l;i++)
	{
		account = accountsList.getItemAt(i) as Array;
		if(account['id'] == id)
		{
			accountsList.removeItemAt(i);
			return;
		}
	}
}

private function main_findServiceRowByServerUsername(server:String, username:String):Array
{
	var account:Array;
	for each(account in accountsList)
	{
		if(twitter.mapServer(account['service'], account['server']) == server && account['username'] == username)
		{
			return account;
		}
	}
	return null;
}

private function main_addRowToServiceList():void
{
	// Only add row if previous new row was filled correctly
	if(curServiceRow < 0)
	{
		var account:Array = main_findServiceRowById(curServiceRow);
		if(null != account)
		{
			if(account['username'] == '' || account['password'] == '')
				return;
		}
	}
	var row:Array = new Array();
	row['id']       = -- curServiceRow;
	row['service']  = 'Twitter';
	row['server']   = '';
	row['username'] = '';
	row['password'] = '';
	row['httpauth'] = 0;
	row['defacc']   = 0;	
	accountsList.addItemAt(row, 0);
	main_refreshAccountSelectorValue();
}

public function main_removeRowFromServiceList(event:Event, data:Object):void
{
	main_findAndemoveServiceRowById(data.id);
	main_refreshAccountSelectorValue();
}

public function main_serviceIsDefault(data:Object):void
{
	var account:Array;
	var l:int = accountsList.length;
	var i:int;
	for(i=0; i<l; i++)
	{
		account = accountsList.getItemAt(i) as Array;
		if(account['id'] == data.id)
			account['defacc'] = 1;
		else
			account['defacc'] = 0;
		accountsList.setItemAt(account, i);		
	}	
}

// Currently, adding new services is kind of moronic. Anyway, FYI, three files need to be modified:
// main.as MultiTwitter.as ServiceRenderer.mxml
private function main_serviceNameToIdx(name:String):int
{
	/** @todo Fix this horrrrrible kludge */
	if(parseInt(name) > 0) return parseInt(name); // Hmmm ugly ugly ugly
	switch(name)
	{
		case 'Twitter':        return 1;
		case 'Identi.ca':      return 2;
		case 'Twit Army':      return 3;
		case 'Linux Infusion': return 4;
		case 'Present.ly':     return 5;
	}
	return 1;	
}

private function main_serviceIdxToName(idx:int):String
{
	switch(idx)
	{
		case 1: return 'Twitter';
		case 2: return 'Identi.ca';
		case 3: return 'Twit Army';
		case 4: return 'Linux Infusion';
		case 5: return 'Present.ly';
	}	
	return null;
}