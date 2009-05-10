package com.voilaweb.tfd
{
	import flare.vis.Visualization;
	import flare.vis.controls.*;
	import flare.vis.data.*;
	import flare.vis.operator.*;
	import flare.vis.operator.layout.*;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.*;
	
	import mx.controls.Button;
	import mx.controls.Text;
	import mx.core.IToolTip;
	import mx.core.UIComponent;
	import mx.managers.ToolTipManager;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.*;
	
	import twitter.api.data.TwitterUser;	
	
	public class FriendsTree extends UIComponent
	{
		private var _app:TwitterifiedNative;	
		private var _toolTip:IToolTip = null;	
		
		public function FriendsTree(app:TwitterifiedNative, profileImageUrl:String = null, children:Array = null, w:int = 500, h:int = 500)
		{
			_app = app;
			// Nodes structure
			var tree:Tree = new Tree();
			var topNode:NodeSprite = tree.addRoot();
			topNode.renderer = new TfdGraphSpriteRenderer(profileImageUrl, topNode);
			var entry:TwitterUser;
			var node:NodeSprite;
			for each(entry in children)
			{
				node = tree.addChild(topNode);
				node.renderer = new TfdGraphSpriteRenderer(entry.profileImageUrl, node);
				node.data = entry;
				node.addEventListener(MouseEvent.CLICK, onNodeMouseClick);	
				node.addEventListener(MouseEvent.MOUSE_MOVE, onNodeMouseMove);	
				node.addEventListener(MouseEvent.MOUSE_OUT, onNodeMouseOut);		
			}
			var vis:Visualization = new Visualization(tree);
			vis.bounds = new Rectangle(0,0,w,h);	
			var os:OperatorSwitch = new OperatorSwitch(
				new RadialTreeLayout(20, false, true)
			);
			os.index = 0;
			vis.marks.x = w / 2;
//			vis.marks.x = w / 2;
//			vis.marks.y = h / 3;
			vis.operators.add(os);
			vis.controls.add(new DragControl());
			vis.update();	
			var wrapper:Sprite = new Sprite();
			wrapper.addChild(vis);						
			addChild(wrapper);	
		}
		
		private function onNodeMouseClick(event:MouseEvent):void
		{
			var obj:NodeSprite = event.target as NodeSprite;
			if(!obj) return;
			_app.currentStatus = null;
			_app.currentUser   = obj.data as TwitterUser;
			_app.main_revealMoreOptions(event);
		}		
		
		private function onNodeMouseMove(event:MouseEvent):void
		{
			if(!_toolTip)
			{
				var obj:NodeSprite = event.target as NodeSprite;
				if(!obj) return;
				_app.currentUser   = obj.data as TwitterUser;
				
				var toolTipStr:String =
					'<b>' + _app.currentUser.name + ' (' + 
					(
						_app.currentUser.url && _app.currentUser.url.length > 0 ?
							'<a href="' + _app.currentUser.url + '">' + _app.currentUser.screenName + '</a>' :
							_app.currentUser.screenName
					) +
					')</b> ' +
					_app.currentUser.followers.toString() + ' followers' +
					'<br />' +
					'<i>' + _app.currentUser.location + '</i><br />' +
					_app.currentUser.description;
				_toolTip = ToolTipManager.createToolTip(toolTipStr, event.stageX, event.stageY);
				_toolTip.alpha = .9;
			}
			_toolTip.move(event.stageX, event.stageY);
			event.updateAfterEvent();
		}		
		
		private function onNodeMouseOut(event:MouseEvent):void
		{
			if(_toolTip)
			{
				ToolTipManager.destroyToolTip(_toolTip);
				_toolTip = null;
			}
		}
	}
}