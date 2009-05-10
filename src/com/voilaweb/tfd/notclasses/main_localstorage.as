
private function main_sqlinit():Boolean
{
	if(cnx == null)
	{
		cnx = new SQLConnection();
		var dbFile:File = File.applicationStorageDirectory.resolvePath('tfd.db');
// Try every time...better for upgrades!		if(!dbFile.exists)
		{
			try
			{
				cnx.open(dbFile);
				
				var createStmt:SQLStatement = new SQLStatement();
				createStmt.sqlConnection = cnx;
				createStmt.text =
					"CREATE TABLE IF NOT EXISTS preferences(" +
					"id INTEGER PRIMARY KEY AUTOINCREMENT, " +
					"key TEXT, " +
					"value TEXT" +
					")";	
				createStmt.execute();
				
				// Accounts structure:
				// Service INT: 1 = Twitter
				// Server TEXT only set if enterprise server
				// Username is account username
				// Password ibid
				// Httpauth is a boolean
				createStmt = new SQLStatement();
				createStmt.sqlConnection = cnx;
				createStmt.text =
					"CREATE TABLE IF NOT EXISTS accounts(" +
					"id INTEGER PRIMARY KEY AUTOINCREMENT, " +
					"service INTEGER, " +
					"server TEXT, " +
					"username TEXT, " +
					"password TEXT, " +
					"httpauth INTEGER, "+
					"defacc INTEGER"+
					")";	
				createStmt.execute();

				createStmt = new SQLStatement();
				createStmt.sqlConnection = cnx;
				createStmt.text =
					"CREATE TABLE IF NOT EXISTS ignored(" +
					"id INTEGER PRIMARY KEY AUTOINCREMENT, " +
					"name TEXT" +
					")";	
				createStmt.execute();

				createStmt = new SQLStatement();
				createStmt.sqlConnection = cnx;
				createStmt.text =
					"CREATE TABLE IF NOT EXISTS markedread(" +
					"id INTEGER PRIMARY KEY AUTOINCREMENT, " +
					"tid TEXT UNIQUE" + // 'unique' creates an index
					")";	
				createStmt.execute();

				createStmt = new SQLStatement();
				createStmt.sqlConnection = cnx;
				createStmt.text =
					"CREATE TABLE IF NOT EXISTS outliner(" +
					"id INTEGER PRIMARY KEY AUTOINCREMENT, " +
					"outline TEXT UNIQUE" + // max size for text: 1 billion
					")";	
				createStmt.execute();
			}
			catch(error:SQLError)
			{
				Alert.show("Error creating preferences repository :(");
				return false;
			}
		}
//		else
//		{
//			cnx.open(dbFile);			
//		}
	}
	return true;	
}

private function main_loadPreference(key:String, def:String):String
{
	if(!main_sqlinit()) return def;
	
	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = cnx;
	stmt.text =	"SELECT * FROM preferences WHERE key=:key";
	stmt.parameters[":key"] = key;
	try
	{
		stmt.execute();
		var result:SQLResult = stmt.getResult();
		if(!result || !result.data || !result.data.length || result.data.length < 1)
			return def;	
		return result.data[0].value;
	}
	catch(error:SQLError)
	{
		return def;
	}
	return def;
	//var value:ByteArray = EncryptedLocalStore.getItem(key);
	//if(value == null)
		//return def;
	//return value.readUTFBytes(value.length);
}

private function main_savePreference(key:String, value:String):Boolean
{
	if(!main_sqlinit()) return false;
	
	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = cnx;
	stmt.text =	"SELECT * FROM preferences WHERE key=:key";
	stmt.parameters[":key"] = key;
	try
	{
		stmt.execute();
		var result:SQLResult = stmt.getResult();
		
		stmt = new SQLStatement();
		stmt.sqlConnection = cnx;

		if(!result || !result.data || !result.data.length || result.data.length < 1)
			stmt.text =	"INSERT INTO preferences(key, value) VALUES(:key, :value)";
		else
			stmt.text =	"UPDATE preferences SET key=:key, value=:value";

		stmt.parameters[":key"] = key;
		stmt.parameters[":value"] = value;
		stmt.execute();
	}
	catch(error:SQLError)
	{
		Alert.show("Error storing preference: " + key + ": " + error.message + "\n\n" + error.details);
		return false;	
	}
	return true;
	//EncryptedLocalStore.removeItem(key);
	//var bytes:ByteArray = new ByteArray();
	//bytes.writeUTFBytes(value);
	//EncryptedLocalStore.setItem(key, bytes, true); // Strongly bound	
}

private function main_loadAccounts():void
{
	accountsList.removeAll();
	main_refreshAccountSelectorValue();
	
	if(!main_sqlinit()) return;

	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = cnx;
	stmt.text =	"SELECT * FROM accounts";
	try
	{
		stmt.execute();
		var result:SQLResult = stmt.getResult();
		if(!result || !result.data || !result.data.length || result.data.length < 1)
			return;
			
		var runner:int = 0, select:int = -1;
		var account:Object;
		for each(account in result.data)
		{
			var row:Array = new Array();
			row['id']       = account.id;
			row['service']  = main_serviceIdxToName(account.service);
			row['server']   = account.server;
			row['username'] = account.username;
			row['password'] = account.password;
			row['httpauth'] = account.httpauth;
			row['defacc']   = account.defacc;
			accountsList.addItem(row);
			if(account.defacc > 0)
				select = runner;
			runner ++;
		}
		main_refreshAccountSelectorValue();	
		// Oh, yes, we need to update out selector component
		if(select >= 0)
			accountselectorcb.selectedIndex = select;
		else
			accountselectorcb.selectedIndex = 0;
	}
	catch(error:SQLError)
	{
	}
}

private function main_saveAccounts():Boolean
{
	if(!main_sqlinit()) return false;

	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = cnx;
	stmt.text =	"DELETE FROM accounts";
	try
	{
		stmt.execute();

		var forceDefault:Boolean = true;
		var account:Array;
		for each(account in accountsList)
		{
			if(account['defacc'] == 1)
				forceDefault = false;
		}		
		for each(account in accountsList)
		{
			stmt = new SQLStatement();
			stmt.sqlConnection = cnx;
			stmt.text =	"INSERT INTO accounts(service, server, username, password, httpauth, defacc) VALUES(:service, :server, :username, :password, :httpauth, :defacc)";
			stmt.parameters[":service"]  = main_serviceNameToIdx(account['service']);
			stmt.parameters[":server"]   = account['server'];
			stmt.parameters[":username"] = account['username'];
			stmt.parameters[":password"] = account['password'];
			stmt.parameters[":httpauth"] = account['httpauth'];
			if(forceDefault)
			{
				forceDefault = false;
				stmt.parameters[":defacc"]   = 1;
			}
			else
				stmt.parameters[":defacc"]   = account['defacc'];
			stmt.execute();
		}
	}
	catch(error:SQLError)
	{
		Alert.show("Error storing accounts: " + error.message + "\n\n" + error.details);
		return false;	
	}
	
	main_loadAccounts();
	
	return true;	
}

public function get ignored():Array
{
	return ignoredList;
}

private function main_getIgnoreUserList():Array
{
	var ignoredArray:Array = new Array();	

	if(!main_sqlinit()) return ignoredArray;

	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = cnx;
	stmt.text =	"SELECT * FROM ignored";
	try
	{
		stmt.execute();
		var result:SQLResult = stmt.getResult();
		if(!result || !result.data || !result.data.length || result.data.length < 1)
			return ignoredArray;
		var i:int;
		for(i=0; i<result.data.length; i++)
			ignoredArray[result.data[i].name] = true;
	}
	catch(error:SQLError)
	{
		return ignoredArray;
	}
	return ignoredArray;
}

private function main_ignoreUser(name:String, shallIgnore:Boolean):Boolean
{
	if(!main_sqlinit()) return false;
	
	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = cnx;
	if(shallIgnore)
		stmt.text = "INSERT INTO ignored(name) VALUES(:name)";
	else
		stmt.text = "DELETE FROM ignored WHERE name=:name";
	stmt.parameters[":name"] = name;
	try
	{
		stmt.execute();
		if(shallIgnore)
			ignoredList[currentUser.screenName] = true;
		else
			delete ignoredList[currentUser.screenName];
		return true;
	}
	catch(error:SQLError)
	{
		Alert.show("Error toggling ignore flag for user " + name);
	}
	return false;
}

public function main_getMarkedReadList(ids:String):Array
{
	var markedArray:Array = new Array();	
	if(ids.length < 1) return markedArray;
		
	if(!main_sqlinit()) return markedArray;
	
	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = cnx;
	stmt.text =	"SELECT * FROM markedread WHERE tid in (" + ids + ")";
	try
	{
		stmt.execute();
		var result:SQLResult = stmt.getResult();
		if(!result || !result.data || !result.data.length || result.data.length < 1)
			return markedArray;
		var i:int;
		for(i=0; i<result.data.length; i++)
			markedArray[result.data[i].tid] = true;
	}
	catch(error:SQLError)
	{
		return markedArray;
	}
	return markedArray;	
}

public function main_markRead(tid:String, shallMark:Boolean):Boolean
{
	if(!main_sqlinit()) return false;
	
	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = cnx;
	if(shallMark)
		stmt.text = "INSERT INTO markedread(tid) VALUES(:tid)";
	else
		stmt.text = "DELETE FROM markedread WHERE tid=:tid";
	stmt.parameters[":tid"] = tid;
	try
	{
		stmt.execute();
	}
	catch(error:SQLError)
	{
		// I may want, in the future, to be a bit more thorough but this works nicely:
		// I am assuming that the error is a constraint violation, which happens if I try
		// to mark a status row that was already marked.
	}
	return true;
}