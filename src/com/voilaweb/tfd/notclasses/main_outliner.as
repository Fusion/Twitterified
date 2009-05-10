
private var outlinerUpdated:Boolean = false;
private var outlinerModel:XML =
	<list>
	    <outlinerNode nodeText="Outliner">
	    </outlinerNode>
    </list>;

private function main_loadOutline():String
{
	outlinerUpdated = false;
	var outline:String = null;
	if(!main_sqlinit()) return outline;

	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = cnx;
	stmt.text =	"SELECT * FROM outliner";
	try
	{
		stmt.execute();
		var result:SQLResult = stmt.getResult();
		if(!result || !result.data || !result.data.length || result.data.length < 1)
			return outline;
		outline = result.data[0].outline;
	}
	catch(error:SQLError)
	{
		return outline;
	}
	return outline;
}

private function main_saveOutlines():void
{
	main_status("Saving Outliner Data...");
	main_saveOutline(outlinerModel);
	main_status("Ready.", true);
}

private function main_saveOutline(outline:String):Boolean
{
	outlinerUpdated = false;
	if(!main_sqlinit()) return false;
	
	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = cnx;
	stmt.text =	"SELECT * FROM outliner";
	try
	{
		stmt.execute();
		var result:SQLResult = stmt.getResult();
		
		stmt = new SQLStatement();
		stmt.sqlConnection = cnx;

		if(!result || !result.data || !result.data.length || result.data.length < 1)
			stmt.text =	"INSERT INTO outliner(outline) VALUES(:outline)";
		else
			stmt.text =	"UPDATE outliner SET outline=:outline";

		stmt.parameters[":outline"] = outline;
		stmt.execute();
	}
	catch(error:SQLError)
	{
		Alert.show("Error storing outline: " + error.message + "\n\n" + error.details);
		return false;	
	}
	return true;
}

public function main_initOutliner():void
{
	var loadedOutline:String;
	if(null != (loadedOutline = main_loadOutline()))
	{
		outlinerModel = new XML(loadedOutline);
	}
	outlinerTree.dataProvider = outlinerModel;
	outlinerTree.selectedIndex = 0;
	outlinerTree.setFocus();
	outlinerTree.doubleClickEnabled = true;
	outlinerTree.addEventListener(KeyboardEvent.KEY_UP, main_outlinerKeyUp);
	outlinerTree.addEventListener(MouseEvent.CLICK, main_onOutlinerClick);
	outlinerTree.addEventListener(MouseEvent.DOUBLE_CLICK, main_onOutlinerDoubleClick);
}

private function main_isNote(node:XML):Boolean
{
	return ('outlinerNodeNote' == node.name().localName);
}

private function main_initiateNodeEdit(node:XML):void
{
	outlinerTree.selectedItem = node;
	outlinerTree.editable = true;
	outlinerTree.editedItemPosition = {columnIndex:0, rowIndex:outlinerTree.selectedIndex};	
}

// dlb-click edits, not single-click
private function main_onOutlinerClick(e:Event):void 
{
    outlinerTree.editable = false;
} 
private function main_onOutlinerDoubleClick(e:Event):void 
{
    outlinerTree.editable = true;
    outlinerTree.editedItemPosition = {columnIndex:0, rowIndex:outlinerTree.selectedIndex};
}

private var editingOutlinerNode:String = null;

private function main_newOutlinerNoteNode():XML
{
	var newNode:XML = <outlinerNodeNote/>;
	newNode.@nodeText = '';
	newNode.@uid      = UIDUtil.createUID();
	newNode.@complete = false;
	return newNode;		
}

private function main_newOutlinerNode():XML
{
	var newNode:XML = <outlinerNode/>;
	newNode.@nodeText = '';
	newNode.@uid      = UIDUtil.createUID();
	newNode.@complete = false;
	return newNode;	
}

private function main_outlinerAddChild():void
{
	if(null != editingOutlinerNode)
		return;
	var node:XML = outlinerTree.selectedItem as XML;
	if(null == node)
		return;
	// Do not add children to complete task
	if(true == node.@complete)
		return;
	// Notes do not have children
	if(main_isNote(node))
		return;
	var newNode:XML = main_newOutlinerNode();
	outlinerUpdated = true;
	node.appendChild(newNode);				
	outlinerTree.expandItem(node, true);
	main_initiateNodeEdit(newNode);	
}

private function main_outlinerAddSibling():void
{
	if(null != editingOutlinerNode)
		return;
	var node:XML = outlinerTree.selectedItem as XML;
	if(null == node)
		return;
	if(outlinerTree.selectedIndex < 1)
		return;				
	var newNode:XML;
	var parent:XML = node.parent();
	if(parent)
	{
		// Notes' siblings are notes, too
		if(main_isNote(node))
		{
			newNode = main_newOutlinerNoteNode();
		}
		else
		{
			newNode = main_newOutlinerNode();
		}					
		outlinerUpdated = true;
		parent.appendChild(newNode);
		main_initiateNodeEdit(newNode);
	}	
}

private function main_outlinerCreateNote():void
{
	if(null != editingOutlinerNode)
		return;
	var node:XML = outlinerTree.selectedItem as XML;
	if(null == node)
		return;
	if(true == node.@complete)
		return;
	var newNode:XML = main_newOutlinerNoteNode();
	outlinerUpdated = true;
	node.appendChild(newNode);
	outlinerTree.expandItem(node, true);
	main_initiateNodeEdit(newNode);							
}

private function main_outlinerDelete():void
{
	if(null != editingOutlinerNode)
		return;
	var node:XML = outlinerTree.selectedItem as XML;
	if(null == node)
		return;
	if(outlinerTree.selectedIndex < 1)
		return;				
	Alert.show("Delete this entry?", "Confirmation", Alert.YES | Alert.NO, this,
		function(event:CloseEvent):void
		{
			if(Alert.YES != event.detail)
				return;
			var parent:XML = XML(outlinerTree.selectedItem).parent();
			if(parent)
			{
				outlinerUpdated = true;
				var nodeRefs:XMLList = parent.outlinerNode.(@uid == node.@uid);
				if(nodeRefs.length() > 0)
					delete nodeRefs[0];
			}			
		}, null, Alert.YES);
}

private function main_outlinerKeyUp(event:KeyboardEvent):void
{
	if(null != editingOutlinerNode)
		return;
	var node:XML = outlinerTree.selectedItem as XML;
	if(null == node)
		return;
	var newNode:XML;
	var parent:XML;
	var action:String = null;
	switch(event.keyCode)
	{
		case 0x0D: action = 'AddNode'; break; // Enter
		case 0x20: action = 'Complete'; break; // Spacebar
		case 0x6b: action = 'AddNote'; break; // '+' sign
		case 187: action = 'AddNote'; break; // '+' sign
		case 0x2e: action = 'Delete'; break; // Delete
		case 0x71: action = 'Edit'; break; // F2
	}
	if(null == action)
	{
		switch(event.charCode)
		{
			case 0x2b: action = 'AddNote'; break; // '+' sign
		}		
	}
	switch(action)
	{
		case 'AddNode':
			if(event.shiftKey)
				main_outlinerAddSibling();
			else
				main_outlinerAddChild();
			break;
		case 'Complete':
			var children:XMLList = node.children();		
			var child:XML;			
			// Can not complete a parent task directly
			var foundChild:Boolean = false;
			if(children.length() > 0)
			{
				for each(child in children)
				{
					if(!main_isNote(child))
					{
						foundChild = true;
						break;
					}
				}
				if(foundChild)
					break;
				// Crap it's not preventing the tree from folding! event.preventDefault();
			}
			// Cannot complete a note
			if(main_isNote(node))
				break;				
			if(false == node.@complete)
				node.@complete = true;
			else
				node.@complete = false;
			outlinerUpdated = true;
			parent = node.parent();
			while(parent)
			{
				children = parent.children();
				var same:Boolean = true;
				if(true == node.@complete)
				{
					for each(child in children)
					{
						if(main_isNote(child))
							continue; // ignore
						if(child.@complete != true)
						{
							same = false;
							break;
						}						
					}
					if(same)
						parent.@complete = true;
				}
				else
				{
					if(true == parent.@complete)
						parent.@complete = false;
					else
						break;	
				}
				parent = parent.parent();
			}				
			break;
		case 'AddNote':
			main_outlinerCreateNote();
			break;
		case 'Delete':
			main_outlinerDelete();
			break;
		case 'Edit':
			if(outlinerTree.selectedIndex < 1)
				return;
			outlinerTree.editable = true;
			outlinerTree.editedItemPosition = {columnIndex:0, rowIndex:outlinerTree.selectedIndex};
			break;
	}
}

private function main_addOutlinerNode():void
{
	var nodeList:XMLList = outlinerModel.outlinerNode.(@nodeText == "Outliner");
	if( nodeList.length() > 0 ) {
		outlinerUpdated = true;
		nodeList[0].appendChild(main_newOutlinerNode());
		outlinerTree.expandItem(nodeList[0], true);
	}
}
 
private function main_outlineItemEditBeginning(event:ListEvent):void
{
	// Do not edit root node
	if(0 == event.rowIndex)
		event.preventDefault();
}

private function main_outlineItemEditBegin(event:ListEvent):void
{
	if(!_drawer)
		return;
	// I am going to create the editor myself so that I can then
	// manipulate the editor instance to suit my needs
	var node:XML = outlinerTree.selectedItem as XML;
	if(!node)
		return;
	editingOutlinerNode = event.itemRenderer.data.@uid;
	var editor:ClassFactory;
	if(main_isNote(node))
	{
		editor = new ClassFactory(com.voilaweb.tfd.OutlinerNoteEditor);
		outlinerTree.editorUsesEnterKey = true;
		outlinerTree.editorXOffset = 0;
		outlinerTree.editorHeightOffset = 300;
	}
	else
	{
		editor = new ClassFactory(com.voilaweb.tfd.OutlinerEditor);
		outlinerTree.editorUsesEnterKey = false;
		outlinerTree.editorXOffset = 32; // Hmmm a hardcoded value...bad
		outlinerTree.editorHeightOffset = 0;
	}
	outlinerTree.itemEditor = editor;
}

private function main_outlineItemEditEnd(event:ListEvent):void
{
	editingOutlinerNode = null;
	event.preventDefault();
	var node:XML = outlinerTree.selectedItem as XML;
	if(!node)
		return;
	if(main_isNote(node))
	{
		if(ListEventReason.CANCELLED != event.reason)
		{
			outlinerUpdated = true;
			outlinerTree.editedItemRenderer.data.@nodeText = OutlinerNoteEditor(event.currentTarget.itemEditorInstance).outlinerTextEditField.text;
		}
	}	
	else if(ListEventReason.NEW_ROW == event.reason) // Yes, do it!
	{
		outlinerUpdated = true;
		outlinerTree.editedItemRenderer.data.@nodeText = OutlinerEditor(event.currentTarget.itemEditorInstance).outlinerTextEditField.text;
	}
	outlinerTree.destroyItemEditor();
	outlinerTree.dataProvider.notifyItemUpdate(outlinerTree.editedItemRenderer);
}

private function main_addOutliner():void
{
	main_openDrawer();
	
	var newNode:XML = main_newOutlinerNode();
	outlinerUpdated = true;
	outlinerModel.appendChild(newNode);
	main_initiateNodeEdit(newNode);	
}