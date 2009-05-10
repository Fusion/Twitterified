package com.voilaweb.tfd
{
	import mx.collections.*;
	import mx.controls.Text;
	import mx.controls.treeClasses.*;
	import mx.core.UITextField;
	import mx.core.UIComponent;
	import flash.text.TextLineMetrics;

	public class OutlinerRenderer extends TreeItemRenderer
	{
		private function get is_note():Boolean
		{
			return ('outlinerNodeNote' == XML(super.data).name().localName);
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			var htmlComponent:Text = super.getChildByName("htmlComponent") as Text;
			if(!htmlComponent)
			{
				htmlComponent = new Text();
				htmlComponent.name = "htmlComponent";
				addChild(htmlComponent);
			}
			if(is_note)
				htmlComponent.htmlText = XML(super.data).attribute('nodeText');
			else
				htmlComponent.htmlText = null;
			setStyle('verticalAlign', 'top');
		}
 
 /*
  * Today we've learnt a valuable lesson: there is no guarantee of when createChildren() will be invoked.
  * Better be dirty and add children in set data()
		override protected function createChildren():void
		{
			super.createChildren();
			var htmlComponent:Text = new Text();
			htmlComponent.name = "htmlComponent";
			addChild(htmlComponent);
		}
*/
		override protected function measure():void
		{
		  if(is_note)
		  {
		  	super.measure();
		  	var htmlComponent:Text = super.getChildByName("htmlComponent") as Text;
			//Setting the width of the description field
			//causes the height calculation to happen
	  		htmlComponent.width = explicitWidth - super.label.x;
			//We add the measuredHeight to the renderers measured height
			//measuredHeight += (htmlComponent.measuredHeight - label.measuredHeight);
			// Note the silly trick here...hopefully in the future I figure out how to avoid it
			//
			// Here is what happens: we check if measuredHeight is equal to decoration such as margin, insets...rather than that + some height
			// If so, then we need to come up with an actual height which we do by adding textHeight to this height
			
			// Note that I care about text being equal to margin etc but do not have proper access to these
			// For instance UITextField.TEXT_HEIGHT_PADDING == 4 but is not accessible
			// I am going to check if "<10" that will cover this case...
			trace("For text " + htmlComponent.htmlText);
			trace("width = " + htmlComponent.getExplicitOrMeasuredWidth()+" x height = " + htmlComponent.getExplicitOrMeasuredHeight());
			var m:TextLineMetrics = htmlComponent.measureHTMLText(htmlComponent.htmlText);
			//if(10 > htmlComponent.measuredHeight && !isNaN(htmlComponent.explicitHeight))
			//htmlComponent.explicitHeight = m.height + htmlComponent.measuredHeight;
			//if(htmlComponent.measuredHeight < 10) htmlComponent.explicitHeight = 50;
			
			//measuredHeight += (htmlComponent.getExplicitOrMeasuredHeight() - super.label.getExplicitOrMeasuredHeight());
			measuredHeight += (htmlComponent.getExplicitOrMeasuredHeight() - label.getExplicitOrMeasuredHeight());
			trace("m:"+m.height+" Height: " + htmlComponent.getExplicitOrMeasuredHeight());
		  }
		  else
		  {
			super.measure();
		  }
		}     

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			label.height = label.getExplicitOrMeasuredHeight(); // If you tell me my height, then I shall use my variable height!

			graphics.clear();

			if(is_note)
			{
				label.height = 0;
		  		var htmlComponent:Text = super.getChildByName("htmlComponent") as Text;
				htmlComponent.x = label.x;
				htmlComponent.y = label.y;
				htmlComponent.height = htmlComponent.getExplicitOrMeasuredHeight();

				graphics.beginFill(0x555555);
				graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
				graphics.endFill();
			}
			
			var complete:XMLList = XML(super.data).attribute('complete');
			if(complete.length() > 0 && true == complete[0])
			{
				var startx:Number = data ? TreeListData(listData).indent : 0;
				if(disclosureIcon)
					startx += disclosureIcon.measuredWidth;
				if(icon)
					startx += icon.measuredWidth;
				graphics.lineStyle(3, getStyle("color"));
				var y:Number = label.y + label.getExplicitOrMeasuredHeight() / 2;
				graphics.moveTo(startx, y);
				graphics.lineTo(startx + label.getExplicitOrMeasuredWidth(), y);
			}
		}
	}
}