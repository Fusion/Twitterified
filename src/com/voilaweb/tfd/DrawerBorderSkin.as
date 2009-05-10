package com.voilaweb.tfd
{
	import flash.display.Graphics;
	import mx.graphics.RectangularDropShadow;
	import mx.skins.RectangularBorder;	
	
	public class DrawerBorderSkin extends RectangularBorder
	{
	    private var dropShadow:RectangularDropShadow;

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);			
			var cornerRadius:Number    = getStyle("cornerRadius");
			var backgroundColor:int    = getStyle("backgroundColor");
			var backgroundAlpha:Number = getStyle("backgroundAlpha");
			graphics.clear();			
			drawRoundRect(
				0, 0, unscaledWidth, unscaledHeight, 
				{tl: 0, tr:cornerRadius, br: cornerRadius, bl: 0}, 
				backgroundColor,
				backgroundAlpha);
			if (!dropShadow)
			{
				dropShadow = new RectangularDropShadow();			
				dropShadow.distance = 4;
				dropShadow.angle    = 90;
				dropShadow.color    = 0;
				dropShadow.alpha    = 0.4;
				dropShadow.tlRadius = 0;
				dropShadow.trRadius = cornerRadius;
				dropShadow.brRadius = cornerRadius;
				dropShadow.blRadius = 0;
			}
			dropShadow.drawShadow(graphics, 0, 0, unscaledWidth, unscaledHeight);			
		}
	}
}