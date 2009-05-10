/*
Copyright (c) 2007 FlexLib Contributors.  See:
    http://code.google.com/p/flexlib/wiki/ProjectContributors

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
package flexlib.containers {
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	import mx.core.EdgeMetrics;
	import mx.core.IFactory;
	import mx.core.LayoutContainer;
	import mx.core.ScrollPolicy;
	import mx.effects.Resize;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.utils.StringUtil;
	
    /**
     * This is the icon displayed on the headerButton when the WindowShade is in the open state.
     */
    [Style(name="openIcon", type="Class", inherit="no")]

    /**
     * This is the icon displayed on the headerButton when the WindowShade is in the closed state.
     */
    [Style(name="closeIcon", type="Class", inherit="no")]

    /**
     * The duration of the WindowShade opening transition, in milliseconds. The value 0 specifies no transition. 
     * 
     * @default 250
     */
    [Style(name="openDuration", type="Number", format="Time", inherit="no")]

    /**
     * The duration of the WindowShade closing transition, in milliseconds. The value 0 specifies no transition. 
     * 
     * @default 250
     */
    [Style(name="closeDuration", type="Number", format="Time", inherit="no")]

    /**
     * The class from which the headerButton will be instantiated. Must be mx.controls.Button
     * or a subclass.
     * 
     * @default mx.controls.Button
     */ 
    [Style(name="headerClass", type="Class", inherit="no")]
    
    /**
     * Name of CSS style declaration that specifies styles for the headerButton.
     */
    [Style(name="headerStyleName", type="String", inherit="no")]

    /**
     * Alignment of text on the headerButton. The value set for this style is used as
     * the textAlign style on the headerButton. Valid values are "left", "center" and "right".
     * 
     * @default "right"
     */
     [Style(name="headerTextAlign", type="String", inherit="no")]

     /**
      * If true, the value of the headerButton's <code>toggle</code> property will be set to true; 
      * otherwise the <code>toggle</code> property will be left in its default state.
      * 
      * @default false
      */
     [Style(name="toggleHeader", type="Boolean", inherit="no")]

    /**
     * This control displays a button, which when clicked, will cause a panel to "unroll" beneath
     * it like a windowshade being pulled down; or if the panel is already displayed it
     * will be "rolled up" like a windowshade being rolled up. When multiple WindowShades are stacked
     * in a VBox, the result will be similar to an mx.containers.Accordian container, except that multiple
     * WindowShades can be opened simultaneously whereas an Accordian acts like a tab navigator, with only
     * one panel visible at a time.
     */
    public class WindowShade extends LayoutContainer {

		[Embed (source="../assets/assets.swf", symbol="right_arrow")]
		private static var DEFAULT_CLOSE_ICON:Class;
		
		[Embed (source="../assets/assets.swf", symbol="down_arrow")]
		private static var DEFAULT_OPEN_ICON:Class;
		
		
        private static var styleDefaults:Object = {
             openDuration:250
            ,closeDuration:250
            ,paddingTop:10
            ,headerClass:Button
            ,headerTextAlign:"left"
            ,toggleHeader:false
            ,headerStyleName:null
            ,closeIcon:DEFAULT_CLOSE_ICON
            ,openIcon:DEFAULT_OPEN_ICON
        };

        private static var classConstructed:Boolean = constructClass();

        private static function constructClass():Boolean {

            var css:CSSStyleDeclaration = StyleManager.getStyleDeclaration("WindowShade")
            var changed:Boolean = false;
            if(!css) {
                // If there is no CSS definition for WindowShade,
                // then create one and set the default value.
                css = new CSSStyleDeclaration();
                changed = true;
            }

            // make sure we have a valid values for each style. If not, set the defaults.
            for(var styleProp:String in styleDefaults) {
                if(!StyleManager.isValidStyleValue(css.getStyle(styleProp))) {
                    css.setStyle(styleProp, styleDefaults[styleProp]);
                    changed = true;
                }
            }

            if(changed) {
                StyleManager.setStyleDeclaration("WindowShade", css, true);
            }

            return true;
        }

		/**
		 * @private 
		 * A reference to the Button that will be used for the header. Must always be a Button or subclass of Button.
		 */
        private var _headerButton:Button = null;
        
        private var headerChanged:Boolean;
        
        /**
        * @private
        * The header renderer factory that will get used to create the header. 
        */
        private var _headerRenderer:IFactory;
        
        /**
        * To control the header used on the WindowShade component you can either set the <code>headerClass</code> or the
        * <code>headerRenderer</code>. The <code>headerRenderer</code> works similar to the itemRenderer of a List control.
        * You can set this using MXML using any Button control. This would let you customize things like button skin. You could
        * even combine this with the CanvasButton component to make complex headers.
        */
        public function set headerRenderer(value:IFactory):void {
        	_headerRenderer = value;
        	
        	headerChanged = true;
        	invalidateProperties();
        }
        
        public function get headerRenderer():IFactory {
        	return _headerRenderer;
        }
        
        /**
        * @private
        * Boolean dirty flag to let us know if we need to change the icon in the commitProperties method.
        */
        private var _openedChanged:Boolean = false;

        public function WindowShade() {
            super();
            
            //default scroll policies are off
            this.verticalScrollPolicy = ScrollPolicy.OFF;
            this.horizontalScrollPolicy = ScrollPolicy.OFF;
        }

        protected function createOrReplaceHeaderButton():void {
           if(_headerButton) {
                _headerButton.removeEventListener(MouseEvent.CLICK, headerButton_clickHandler);
                
                if(rawChildren.contains(_headerButton)) {
                    rawChildren.removeChild(_headerButton);
                }
            }
            
            if(_headerRenderer) {
            	_headerButton = _headerRenderer.newInstance() as Button;
            }
            else {
            	var headerClass:Class = getStyle("headerClass");
          	 	_headerButton = new headerClass();
            }
            
            applyHeaderButtonStyles(_headerButton);

            _headerButton.addEventListener(MouseEvent.CLICK, headerButton_clickHandler);
            
            rawChildren.addChild(_headerButton);
        }

        protected function applyHeaderButtonStyles(button:Button):void {
            button.setStyle("textAlign", getStyle("headerTextAlign"));
            
            var headerStyleName:String = getStyle("headerStyleName");
            if(headerStyleName) {
            	headerStyleName = StringUtil.trim(headerStyleName);
            	button.styleName = headerStyleName;
            }
            
            button.toggle = getStyle("toggleHeader");
            button.label = label;

            if(_opened) {
                button.setStyle('icon', getStyle("openIcon"));
            }
            else {
                button.setStyle('icon', getStyle("closeIcon"));
            }

            if(button.toggle) {
                button.selected = _opened;
            }
        }

        /**
         * @private
         */
        override public function set label(value:String):void {
            super.label = value;
            
            if(_headerButton) _headerButton.label = value;
        }

		/**
		 * @private
		 */
		private var _opened:Boolean = true;
		
        /**
         * Sets or gets the state of this WindowShade, either opened (true) or closed (false).
         */
        public function get opened():Boolean {
            return _opened;
        }
        
        private var _headerLocation:String = "top";
		
		[Bindable]
		[Inspectable(enumeration="top,bottom", defaultValue="top")]
		/**
		 * Specifies where the header button is placed relative tot he content of this WindowShade. Possible
		 * values are <code>top</code> and <code>bottom</code>.
		 */
		public function set headerLocation(value:String):void {
			_headerLocation = value;
			invalidateSize();
			invalidateDisplayList();
		}
		
		public function get headerLocation():String {
			return _headerLocation;
		}

        /**
         * @private
         */
         [Bindable]
        public function set opened(value:Boolean):void {
            var old:Boolean = _opened;
            
            _opened = value;
            _openedChanged = _openedChanged || old != _opened;
           
            if(_openedChanged && initialized) {
                measure();
               	runResizeEffect();
                
                invalidateProperties();
            }
        }

        /**
         * @private
         */
        override public function styleChanged(styleProp:String):void {
            super.styleChanged(styleProp);
            
            if(styleProp == "headerClass") {
                headerChanged = true;
                invalidateProperties();
            }
            else if(styleProp == "headerStyleName" || styleProp == "headerTextAlign" || styleProp == "toggleHeader" 
            	|| styleProp == "openIcon" || styleProp == "closeIcon") {
                applyHeaderButtonStyles(_headerButton);
            }
            
            invalidateDisplayList();
        }

        /**
         * @private
         */
        override protected function createChildren():void {
            super.createChildren();
         
            createOrReplaceHeaderButton();
        }

        /**
         * @private
         */
        override protected function commitProperties():void {
			
			super.commitProperties();
			
			if(headerChanged) {
				createOrReplaceHeaderButton();
				headerChanged = false;
			}
			
            if(_openedChanged) {
                
                if(_opened) {
                    _headerButton.setStyle('icon', getStyle("openIcon"));
                }
                else {
                    _headerButton.setStyle('icon', getStyle("closeIcon"));
                }
                
                _openedChanged = false;
            }
        }

        /**
         * @private
         */
        override protected function updateDisplayList(w:Number, h:Number):void {
            super.updateDisplayList(w, h);
            
            if(_headerLocation == "top") {
            	_headerButton.move(0,0);
            }
            else if(_headerLocation == "bottom") {
            	_headerButton.move(0,h - _headerButton.getExplicitOrMeasuredHeight());
            }
            
			_headerButton.setActualSize(w, _headerButton.getExplicitOrMeasuredHeight());
        }

		/**
		 * @private
		 */
		private var _viewMetrics:EdgeMetrics;
		
		override public function get viewMetrics():EdgeMetrics
    	{
    		// The getViewMetrics function needs to return its own object.
	        // Rather than allocating a new one each time, we'll allocate
	        // one once and then hold a pointer to it.
	        if (!_viewMetrics)
	            _viewMetrics = new EdgeMetrics(0, 0, 0, 0);
	        
	        var vm:EdgeMetrics = _viewMetrics;
	
	        var o:EdgeMetrics = super.viewMetrics;
	        
	        vm.left = o.left;
	        vm.top = o.top;
	        vm.right = o.right;
	        vm.bottom = o.bottom;
	        
	        var hHeight:Number = _headerButton.getExplicitOrMeasuredHeight();
	        if (!isNaN(hHeight)) {
	        	if(_headerLocation == "top") {
	        		 vm.top += hHeight;
	        	}
	        	else if(_headerLocation == "bottom") {
	        		 vm.bottom += hHeight;
	        	}
	        }
	           

	        return vm;
    	}
    	
        /**
         * @private
         */
        override protected function measure():void {
            super.measure();
            
            if(_opened) {
            	//if this WindowShade is opened then we have to include the height of the header button
                //measuredHeight += _headerButton.getExplicitOrMeasuredHeight();
            }
            else {
            	//if the WindowShade is closed then the height is only the height of the header button
            	measuredHeight = _headerButton.getExplicitOrMeasuredHeight();
            }
        }

		/**
		 * @private
		 */
		private var resize:Resize;
		
        /**
         * @private
         */
        protected function runResizeEffect():void {
			if(resize && resize.isPlaying) {
				resize.end();
			}
			
            var duration:Number = _opened ? getStyle("openDuration") : getStyle("closeDuration");
            if(duration == 0) { 
            	this.setActualSize(getExplicitOrMeasuredWidth(), measuredHeight);
            	
            	invalidateSize();
            	invalidateDisplayList();
            	
            	return;
            }
            
            resize = new Resize(this);
            resize.heightTo = Math.min(maxHeight, measuredHeight);

            resize.duration = duration;
            
            resize.play();
        }

        /**
         * @private
         */
        protected function headerButton_clickHandler(event:MouseEvent):void {
            opened = !_opened;
        }
    }
}
