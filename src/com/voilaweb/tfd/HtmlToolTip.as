package com.voilaweb.tfd
{
	import mx.controls.ToolTip;
	import mx.core.UITextField;
	import mx.skins.halo.ToolTipBorder;
	
	public class HtmlToolTip extends ToolTipBorder
	{
		public function HtmlToolTip()
		{
			super();
		}
		
		override protected function updateDisplayList(width:Number, height:Number):void
		{
			var toolTip:ToolTip = this.parent as ToolTip;
			var textField:UITextField = toolTip.getChildAt(1) as UITextField;
			textField.htmlText = textField.text;
			height = 106; // Hmmm....tsk tsk - 8 * 9 + 4
			super.updateDisplayList(width, height);
		}
	}
}