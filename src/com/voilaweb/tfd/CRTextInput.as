package com.voilaweb.tfd
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import mx.controls.TextInput;
	
	[Event(name = "CR", type = "flash.events.Event")]
	
	public class CRTextInput extends TextInput
	{
		public static var ENTER_KEY_EVENT:String = 'CR';
		
		public function CRTextInput()
		{
			super();
		}
		
		override public function initialize():void
		{
			super.initialize();
			addEventListener(KeyboardEvent.KEY_UP, handleKey);
		}
		
		protected function handleKey(event:KeyboardEvent):void
		{
			if(event.keyCode == 0x0D)
			{
				var realEvent:Event = new Event(ENTER_KEY_EVENT, false);
				dispatchEvent(realEvent);
			}	
		}
		
	}
}