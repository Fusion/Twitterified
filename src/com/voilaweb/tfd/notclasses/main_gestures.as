
private var lastPoint:Point;
private var lastDrawPoint:Point;
private var gesturePath:Array;

private function main_onKeyUpDown(e:KeyboardEvent):void
{
	if(!ctrlKeyIsDown)
	{
		if(e.ctrlKey)
		{
			ctrlKeyIsDown        = true;
			drawingCanvas.x      = systemManager.stage.x;
			drawingCanvas.y      = systemManager.stage.y;
			drawingCanvas.width  = systemManager.stage.width;
			drawingCanvas.height = systemManager.stage.height;		
			drawingCanvas.graphics.lineStyle(2, 0x6EBAE5, 1);
			lastPoint = new Point(systemManager.stage.mouseX, systemManager.stage.mouseY);
			lastDrawPoint = lastPoint;
			gesturePath = new Array();
			gesturePath.push(new PathBit(lastPoint, lastPoint));
		}
		if (e.altKey)
		{
			if(79 == e.keyCode) // Alt-o: Open outliner
			{
				main_openDrawer();				
			}
		}
	}
	else
	{
		if(!e.ctrlKey)
		{
			ctrlKeyIsDown = false;
			drawingCanvas.graphics.clear();
			// Gesture
			main_encodeGesture();
		}
	}
}

private function main_onMouseMove(e:MouseEvent):void
{
	if(!ctrlKeyIsDown)
		return;
	var x:int = systemManager.stage.mouseX;
	var y:int = systemManager.stage.mouseY;
	drawingCanvas.graphics.moveTo(x, y);
	drawingCanvas.graphics.lineTo(lastDrawPoint.x, lastDrawPoint.y);
	var newPoint:Point = new Point(x, y);
	var pathBit:PathBit = new PathBit(lastPoint, newPoint);
	// > 5% of stage?
	if(Math.abs(pathBit.horizontal) * 20 > systemManager.stage.width || Math.abs(pathBit.vertical) * 20 > systemManager.stage.height)
	{
		gesturePath.push(pathBit);
		lastPoint = newPoint;
	}
	lastDrawPoint = newPoint;
}

private function main_encodeGesture():void
{
	var container:Container = null;
	
	switch(showingTab)
	{
		case FRIENDS_TL:
			container = friends_timeline;
			break;
		case USER_TL:
			container = user_timeline;
			break;
		case PUBLIC_TL:
			container = public_timeline;
			break;
	}	
	
	if(!container)
		return;
	
	// Analyze path	
	var children:Array = container.getChildren();
	var statusRow:UIComponent;
	var multiComponent:Boolean = false;
	var curStatus:StatusRow;
	var lastStatus:StatusRow = null;
	var pathBit:PathBit;	
	var overallPathString:String = '';
	
	for each(pathBit in gesturePath)
	{
		curStatus = null;
		for each(statusRow in children)
		{
			if(statusRow is StatusRow)
			{
				if(StatusRow(statusRow).isBounding(pathBit.point))
				{
					curStatus = statusRow as StatusRow;
					break;
				}
			}
		}
		if(lastStatus && curStatus != lastStatus)
			multiComponent = true;		
		lastStatus = curStatus;
		if(pathBit.direction & PathBit.DOWN)
		{
			if(pathBit.direction & PathBit.LEFT)
				overallPathString += PathBit.DL;
			else if(pathBit.direction & PathBit.RIGHT)
				overallPathString += PathBit.DR;
			else
				overallPathString += PathBit.D;
		}
		else if(pathBit.direction & PathBit.UP)
		{
			if(pathBit.direction & PathBit.LEFT)
				overallPathString += PathBit.UL;
			else if(pathBit.direction & PathBit.RIGHT)
				overallPathString += PathBit.UR;
			else
				overallPathString += PathBit.U;
		}
		else if(pathBit.direction & PathBit.LEFT)
			overallPathString += PathBit.L;
		else if(pathBit.direction & PathBit.RIGHT)
			overallPathString += PathBit.R;
	}			
	overallPathString    = main_cleanupPath(overallPathString);
	main_parseGesture(multiComponent, overallPathString, lastStatus, container);
}

private function main_parseGesture(multi:Boolean, op:String, status:StatusRow,container:Container):void
{
	if(!multi)
	{
		// Single-status gesture!
		if(PathBit.L == op) // L
			main_toggleReadFlag(status, true);
		else if(PathBit.R == op) // R
			main_toggleReadFlag(status, false);
	}
	else
	{
		if("13" == op) // DL, DR
			main_toggleReadFlagForAll(container, true);
		else if("31" == op) // DR, DL
			main_toggleReadFlagForAll(container, false);
		else if ("313" == op) // DR, DL, DR
			main_openDrawer();			
	}
}

private function main_toggleReadFlag(status:StatusRow, read:Boolean):void
{
	status.toggleReadFlag(read);
}

private function main_toggleReadFlagForAll(container:Container, read:Boolean):void
{
	var children:Array = container.getChildren();
	var statusRow:StatusRow;
	for each(statusRow in children)
	{
		statusRow.toggleReadFlag(read);
	}			
}

private function main_cleanupPath(path:String):String
{
	var i:int, l:int = path.length;
	var c:String, prevC:String = null, ret:String = '';
	for (i=0; i<l; i++)
	{
		c = path.charAt(i);
		if(prevC)
		{
			if(c != prevC)
				ret += c;	
		}
		else
		{
			ret = c;
		}
		prevC = c;
	}
	return ret;	
}