
private var _helpCanvas:Canvas = null;

private function main_quickHelp(event:Event):void
{
	if(_helpCanvas)
	{
		systemManager.removeChild(_helpCanvas);
		_helpCanvas = null;
		return;
	}
	_helpCanvas        = new Canvas();
	_helpCanvas.x      = systemManager.stage.x;
	_helpCanvas.y      = systemManager.stage.y+12;
//	_helpCanvas.width  = systemManager.stage.width;
	_helpCanvas.width  = main_curWidth();
	_helpCanvas.height = systemManager.stage.height-32;
	_helpCanvas.graphics.beginFill(0x666666, .9);
	_helpCanvas.graphics.drawRoundRect(_helpCanvas.x, _helpCanvas.y, _helpCanvas.width, _helpCanvas.height, 20);
	_helpCanvas.graphics.endFill();
	var txt:Text = new Text();
	txt.htmlText =
		"<b>Mouse Gestures</b><br />" +
		". Use &lt;Ctrl&gt; and move your mouse. Release &lt;Ctrl&gt; to complete gesture.<br />"+
		". &lt;Ctrl&gt; and a quick mouse move to the left will mark a tweet as read<br />"+
		". &lt;Ctrl&gt; and a quick mouse move to the right will unmark the tweet<br />"+
		". &lt;Ctrl&gt; and moving the mouse left and down, then right and down,<br />"+
		"  will mark all tweets as read (Tip: draw a \"less than\" sign)<br />"+
		". &lt;Ctrl&gt; and moving the mouse right and down, then left and down,<br />"+
		"  will unmark all tweets (Tip: draw a \"greater than\" sign)";
	txt.x = 20;
	txt.y = 20;
	_helpCanvas.addChild(txt);
	var b1:Button = new Button();
	b1.label = "Close";
	b1.percentWidth = 100;
	b1.x = 0;
	b1.y = 160;
	b1.addEventListener(MouseEvent.CLICK, main_onCloseQuickHelp);
	_helpCanvas.addChild(b1);
	systemManager.addChild(_helpCanvas);
}

public function main_onCloseQuickHelp(event:Event):void
{
		main_quickHelp(event);
}