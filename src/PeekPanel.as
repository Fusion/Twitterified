package
{
    import flash.display.BitmapData;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import mx.containers.Canvas;
    import mx.core.Container;
    import mx.effects.easing.Quartic;
    import mx.graphics.RoundedRectangle;
    import gs.TweenMax;
    
    
    /**
    * 
    * 
    * ToDo:
    * 
    * - Keep top panel alive:  With a little more work I think I should be able to determine the size of the fold and then
    * only render the corner section that is being folded and shaded.  That would allow me to keep the rest of that component
    * visible and thus, still functional.  So you could fold up a corner and still interact with the portion of the top page 
    * that is not folded.
    * - Make gradients even cleaner.  When the flip is set to be fairly large (ie, more than 40% of the top page) the 
    * quality of the gradient seems to degrade and you can see stripping etc.  Not sure why this is but I'm sure it can be
    * improved.
    * - Certain styles mess things up.  For example, rounded corners on a panel will not look right.
    * 
    * 
    * CREDITS:
    * TweenMax      (http://blog.greensock.com/tweenmaxas3/)
    * PageFlip      (http://www.foxaweb.com)
    * Vector        (http://www.quietlyscheming.com)
    * Reflection    (http://http://lab.benstucki.net/archives/reflectionexplorer)
    */
    
    
    public class PeekPanel
    extends Canvas
    {
        
        
        /* ====================================================================================== static members ============== */
        
        
        public static const FOLD_TOP_LEFT:int       = 0;
        public static const FOLD_TOP_RIGHT:int      = 1;
        public static const FOLD_BOTTOM_RIGHT:int   = 2;
        public static const FOLD_BOTTOM_LEFT:int    = 3;
        
        private static const FIXED_TOP_LEFT:Point      = new Point(0,0);
        private static const FIXED_TOP_RIGHT:Point     = new Point(1,0);
        private static const FIXED_BOTTOM_RIGHT:Point  = new Point(1,1);
        private static const FIXED_BOTTOM_LEFT:Point   = new Point(0,1);
                
                
        /* ====================================================================================== instance members ============ */
        
        private var foldLayer:Shape = new Shape();
        private var geometryLayer:Shape = new Shape();
        private var gradientLayer:Shape = new Shape();
        
        private var page1BMD:BitmapData;
        private var page2BMD:BitmapData;
        
        private var peekStartPosition:Point = new Point(foldOriginX, foldOriginY);
        private var peekEndPosition:Point = new Point(foldDestinationX, foldDestinationY);
        private var peekCurrentPosition:Point = new Point(foldOriginX, foldOriginY);
        public  var tearHorizontalMode:Boolean = false;
        
        private var pPoints:Array = null;
        private var cPoints:Array = null;
        
        private var dragVector:Vector = null;
        private var dragDistance:Number = 0;
        private var dragDistanceTotal:Number = 0;
        private var foldPoint:Point = null;
        private var foldAngleInRadians:Number = 0;
        private var foldAngleInDegrees:Number = 0;
        private var foldVector:Vector = null;
        private var foldDistance:Number = 0;
        private var foldDistanceTotal:Number = 0;
        private var animationPercentage:Number = 0;
        private var turnPercentage:Number = 0;
               
        private var backingColorTransform:ColorTransform = new ColorTransform();        
       
        // colors used to show geometry
        private var GREEN:Number  = 0x35f335;
        private var PURPLE:Number = 0xf52bcd;
        private var YELLOW:Number = 0xf2ed62; 
        private var BLUE:Number   = 0x8195C2;
        
        private var _initialized:Boolean = false;
        
        private var continueAnimating:Boolean = true
        
        /* ====================================================================================== constructor ================= */


        public function PeekPanel()
        {
            addEventListener(Event.ADDED_TO_STAGE, init);
            addEventListener(MouseEvent.CLICK, onMouseClick);
        }
        
        
        /* ====================================================================================== onMouseClick ================ */
        
        
        /**
        * If the user clicks anywhere on the top page when the fold is active, we unfold the top page.  This will hide
        * the fact that the top page is not actually functional and will not response to clicks on buttons, fields, etc which
        * may still be visible since they are not covered by the fold.
        */
        private function onMouseClick(mouseEvent:MouseEvent):void
        {
            if (foldActivated)
            {
                if (!pointInPoly(new Point(mouseX, mouseY), getRevealPoly()))
                {
                    unfold();
                }
            }
        }
        
        
        /* ====================================================================================== pointInPoly ================= */


        private function pointInPoly(pointToCheck:Point, polygonArray:Array):Boolean
        {
            var returnValue:Boolean = false;
            var crossing:Number = 0;
            var n:Number = polygonArray.length - 1;
            
            for (var i:int = 0; i<n; i++)
            {
                if (
                    ((polygonArray[i].y <= pointToCheck.y) && (polygonArray[i+1].y > pointToCheck.y)) 
                      || 
                    ((polygonArray[i].y > pointToCheck.y) && (polygonArray[i+1].y <= pointToCheck.y))
                   ) 
                { 
                    var vt:Number = (pointToCheck.y - polygonArray[i].y) / (polygonArray[i+1].y - polygonArray[i].y);
                    if (pointToCheck.x < polygonArray[i].x + vt * (polygonArray[i+1].x - polygonArray[i].x)) 
                    {
                        crossing++;
                    }
                }
            }
            if (crossing % 2) 
            {
                returnValue = true;
            } 
            else 
            {
                returnValue = false;
            }
            return returnValue;
        }
        
        
        /* ====================================================================================== init ======================== */
        
        
        private function init(event:Event=null):void
        {
            if (!_initialized)
            {
                _initialized = true; 
                // add the hidden page first
                addChild(hiddenPage);
                // finally add the visible top component
                addChild(topPage);
                // setup the backingColorTransform - this makes the reverse side of the fold darker.
                backingColorTransform.alphaOffset = -200;
            }
        }

                
        /* ====================================================================================== topPage ===================== */
        
        
        private var _topPage:Container = null;
        [Bindable]
        public function set topPage(topPageArg:Container):void
        {
            _topPage = topPageArg;
            _topPage.x = 0;
            _topPage.y = 0;
            _topPage.percentWidth = 100;
            _topPage.percentHeight = 100;
        }
        public function get topPage():Container
        {
            return _topPage;
        }
        
        
        /* ====================================================================================== hiddenPage ================== */
        
        
        private var _hiddenPage:Container = null;
        [Bindable]
        public function set hiddenPage(hiddenPageArg:Container):void
        {
            _hiddenPage = hiddenPageArg;
            _hiddenPage.visible = false;
            _hiddenPage.x = 0;
            _hiddenPage.y = 0;
            _hiddenPage.percentWidth = 100;
            _hiddenPage.percentHeight = 100;
        }
        public function get hiddenPage():Container
        {
            return _hiddenPage;
        }
        
        
        /* ====================================================================================== foldOriginX ================= */
        
        
        private var _foldOriginX:Number = 0;
        [Bindable]
        public function set foldOriginX(foldOriginXArg:Number):void
        {
            _foldOriginX = foldOriginXArg;
            peekStartPosition.x = _foldOriginX;
            if (!foldActivated)
            {
                peekCurrentPosition.x = _foldOriginX;
            }       
        }
        public function get foldOriginX():Number
        {
            return _foldOriginX;
        }
        
        
        /* ====================================================================================== foldOriginY ================= */
        
        
        private var _foldOriginY:Number = 0;
        [Bindable]
        public function set foldOriginY(foldOriginYArg:Number):void
        {
            _foldOriginY = foldOriginYArg;
            peekStartPosition.y = _foldOriginY;
            if (!foldActivated)
            {
                peekCurrentPosition.y = _foldOriginY;
            }
        }
        public function get foldOriginY():Number
        {
            return _foldOriginY;
        }
        
        /* ====================================================================================== foldDestinationX ============ */
        
        
        private var _foldDestinationX:Number = 0;
        [Bindable]
        public function set foldDestinationX(foldDestinationXArg:Number):void
        {
            _foldDestinationX = foldDestinationXArg;
            peekEndPosition.x = _foldDestinationX;
            if (foldActivated)
            {
                if (!hasEventListener("redraw"))
                {
                    addEventListener(Event.ENTER_FRAME, redraw);
                }
                peekCurrentPosition.x = _foldDestinationX;
            }
        }
        public function get foldDestinationX():Number
        {
            return _foldDestinationX;
        }
        
        
        /* ====================================================================================== foldDestinationY ============ */
        
        
        private var _foldDestinationY:Number = 0;
        [Bindable]
        public function set foldDestinationY(foldDestinationYArg:Number):void
        {
            _foldDestinationY = foldDestinationYArg;
            peekEndPosition.y = _foldDestinationY;
            if (foldActivated)
            {
                if (!hasEventListener("redraw"))
                {
                    addEventListener(Event.ENTER_FRAME, redraw);
                }
                peekCurrentPosition.y = _foldDestinationY;
            }
        }
        public function get foldDestinationY():Number
        {
            return _foldDestinationY;
        }
        
        
        /* ====================================================================================== foldVerticalIntersection ==== */
        
        
        /**
        * left or right
        */
        private var _foldVerticalIntersection:Number = 0;
        [Bindable]
        protected function set foldVerticalIntersection(foldVerticalIntersectionArg:Number):void
        {
            _foldVerticalIntersection = foldVerticalIntersectionArg;
        }
        protected function get foldVerticalIntersection():Number
        {
            return _foldVerticalIntersection;
        }
        
        
        /* ====================================================================================== foldHorizontalIntersection == */
        
        
        /**
        * top or bottom
        */
        private var _foldHorizontalIntersection:Number = 0;
        [Bindable]
        protected function set foldHorizontalIntersection(foldHorizontalIntersectionArg:Number):void
        {
            _foldHorizontalIntersection = foldHorizontalIntersectionArg;
        }
        protected function get foldHorizontalIntersection():Number
        {
            return _foldHorizontalIntersection;
        }
        
        
        /* ====================================================================================== foldCorner ================== */
        
        
        private var _foldCorner:int = FOLD_TOP_LEFT;
        [Bindable]
        public function set foldCorner(foldCornerArg:int):void
        {
            _foldCorner = foldCornerArg;
            // update the origin components
            switch (_foldCorner)
            {
                case FOLD_TOP_LEFT:
                {
                    foldOriginX = 0;
                    foldOriginY = 0;
                    peekFixedPosition = FIXED_TOP_LEFT;
                    break;
                }
                case FOLD_TOP_RIGHT:
                {
                    foldOriginX = width;
                    foldOriginY = 0;
                    peekFixedPosition = FIXED_TOP_RIGHT;
                    break;
                }
                case FOLD_BOTTOM_RIGHT:
                {
                    foldOriginX = width;
                    foldOriginY = height;
                    peekFixedPosition = FIXED_BOTTOM_RIGHT;
                    break;
                }
                case FOLD_BOTTOM_LEFT:
                {
                    foldOriginX = 0;
                    foldOriginY = height;
                    peekFixedPosition = FIXED_BOTTOM_LEFT;
                    break;
                }
            }
            // call fold() to render the newly selected corner
            if (foldActivated)
            {
                fold();
            }
        }
        public function get foldCorner():int
        {
            return _foldCorner;
        }
        
        
        /* ====================================================================================== peekFixedPosition =========== */
                
        
        private var _peekFixedPosition:Point = FIXED_TOP_LEFT;
        [Bindable]
        public function set peekFixedPosition(peekFixedPositionArg:Point):void
        {
            _peekFixedPosition = peekFixedPositionArg;
        }
        public function get peekFixedPosition():Point
        {
            return _peekFixedPosition;
        }
        
        
        
        /* ====================================================================================== foldActivated =============== */
        
        
        private var _foldActivated:Boolean = false;
        [Bindable]
        public function set foldActivated(foldActivatedArg:Boolean):void
        {
            _foldActivated = foldActivatedArg;
        }
        public function get foldActivated():Boolean
        {
            return _foldActivated;
        }
        
        
        /* ====================================================================================== foldLayerEnabled ============ */
        
        
        private var _foldLayerEnabled:Boolean = true;
        [Bindable]
        public function set foldLayerEnabled(foldLayerEnabledArg:Boolean):void
        {
            _foldLayerEnabled = foldLayerEnabledArg;
        }
        public function get foldLayerEnabled():Boolean
        {
            return _foldLayerEnabled;
        }
        
        
        /* ====================================================================================== geometryLayerEnabled ======== */
        
        
        private var _geometryLayerEnabled:Boolean = false;
        [Bindable]
        public function set geometryLayerEnabled(geometryLayerEnabledArg:Boolean):void
        {
            _geometryLayerEnabled = geometryLayerEnabledArg;
        }
        public function get geometryLayerEnabled():Boolean
        {
            return _geometryLayerEnabled;
        }
        
        
        /* ====================================================================================== gradientLayerEnabled ======== */
        
        
        private var _gradientLayerEnabled:Boolean = true;
        [Bindable]
        public function set gradientLayerEnabled(gradientLayerEnabledArg:Boolean):void
        {
            _gradientLayerEnabled = gradientLayerEnabledArg;
        }
        public function get gradientLayerEnabled():Boolean
        {
            return _gradientLayerEnabled;
        }
        
        
        /* ====================================================================================== useSpotLighting ============= */
        
        
        private var _useSpotlighting:Boolean = true;
        [Bindable]
        public function set useSpotLighting(useSpotLightingArg:Boolean):void
        {
            _useSpotlighting = useSpotLightingArg;
        }
        public function get useSpotLighting():Boolean
        {
            return _useSpotlighting;
        }
        
        
        /* ================================================================================= updateFoldMeasurements =========== */
        
        
        private function updateFoldMeasurements():void
        {
            // the distance dragged so far 
            dragDistance = Point.distance(peekStartPosition, peekCurrentPosition);
            // the total distance being dragged
            dragDistanceTotal = Point.distance(peekStartPosition, peekEndPosition);
            // a vector representing the start to current position of the animation
            dragVector = new Vector(peekStartPosition, peekCurrentPosition);
            // the distance of the fold from the starting point
            foldDistance = dragDistance/2;
            // the total distance of the fold from the starting point
            foldDistanceTotal = dragDistanceTotal/2;
            // the percentage of the animation that has completed
            animationPercentage = dragDistance/dragDistanceTotal;
            // turn percentage
            var totalTurnDistance:Number = Point.distance(peekStartPosition, peekEndPosition);
            turnPercentage = Point.distance(peekStartPosition, peekCurrentPosition) / totalTurnDistance;
            
            // a vector representing the fold (the length of which is 1/2 of the dragVector's length)
            foldVector = dragVector.clone();
            foldVector.length = foldVector.length/2;
            // the current position of the fold (1/2 the distance being dragged)
            foldPoint = foldVector.p1.clone();
            // flip the fold to determine the angle
            foldVector.perp();
            foldVector.moveTo(foldPoint);
            foldVector.normalize();
            // the angle of the fold
            // radians = degrees*Math.PI/180
            // degrees = radians*180/Math.PI
            foldAngleInRadians = foldVector.angle;
            foldAngleInDegrees = foldAngleInRadians*180/Math.PI;
            
            // calculate the intersection with the top and side
            switch (foldCorner)
            {
                case (FOLD_TOP_LEFT):
                {
                    foldVerticalIntersection = foldVector.yForX(0);         // left
                    foldHorizontalIntersection = foldVector.xForY(0);       // top
                    break;
                }
                case (FOLD_TOP_RIGHT):
                {
                    foldVerticalIntersection = foldVector.yForX(width);     // right 
                    foldHorizontalIntersection = foldVector.xForY(0);       // top
                    break;
                }
                case (FOLD_BOTTOM_RIGHT):
                {
                    foldVerticalIntersection = foldVector.yForX(width);     // right 
                    foldHorizontalIntersection = foldVector.xForY(height);  // bottom
                    break;
                }
                case (FOLD_BOTTOM_LEFT):
                {
                    foldVerticalIntersection = foldVector.yForX(0);         // left
                    foldHorizontalIntersection = foldVector.xForY(height);  // bottom
                    break;
                }
            }
            
            
            if (foldVerticalIntersection < 0 ||
                foldVerticalIntersection > height)
            {
                tearHorizontalMode = true;
            }
            
            if (foldHorizontalIntersection < 0 ||
                foldHorizontalIntersection > width)
            {
                tearHorizontalMode = false;
            }
        }
        
        
        /* ================================================================================= fold ============================= */
        
        
        public function fold():void
        {            
            if (foldLayerEnabled)
            {
                // add the layer to draw the flip effect on
                foldLayer.x = topPage.x;
                foldLayer.y = topPage.y;
                rawChildren.addChild(foldLayer);
            }
            
            // if the geometry layer is enabled, add it as well
            if (geometryLayerEnabled)
            {
                geometryLayer.x = topPage.x;
                geometryLayer.y = topPage.y;
                rawChildren.addChild(geometryLayer);
            }
            
            // if the gradient layer is enabled, add it as well
            if (gradientLayerEnabled)
            {
                gradientLayer.x = topPage.x;
                gradientLayer.y = topPage.y;
                rawChildren.addChild(gradientLayer);
            }
            
            // add the redraw method to the enterframe to render the layers
            addEventListener(Event.ENTER_FRAME, redraw);
            
            // copy the start position to the current position and animate the
            // fold to the end position
            TweenMax.to(peekCurrentPosition, .75, {
                                                     x: peekEndPosition.x, 
                                                     y: peekEndPosition.y,
                                                     ease: Quartic.easeInOut,
                                                     onStart: function():void 
                                                                 {
                                                                     // hide the real top_panel
                                                                     hiddenPage.visible = true;
                                                                     topPage.visible = false;
                                                                     foldActivated = true;
                                                                 }
                                                   });
        }
        
        
        /* ================================================================================= unfold =========================== */
        
        
        public function unfold(event:Event=null):void
        {
            // copy the end position to the current position and animated the
            // fold back to the start position.  when this is done, make the
            // top_panel visible again, remove the redraw event listener and 
            // remove any rendering layers.
            peekCurrentPosition = peekEndPosition.clone();
            
            // add the redraw method to the enterframe to render the layers
            addEventListener(Event.ENTER_FRAME, redraw);
            
            TweenMax.to(peekCurrentPosition, .75, {
                                                     x: peekStartPosition.x, 
                                                     y: peekStartPosition.y, 
                                                     ease: Quartic.easeInOut,
                                                     onComplete: function():void 
                                                                 {
                                                                     onUnFoldTweenComplete();
                                                                 }
                                                   });
        }
        
        
        /* ================================================================================= onUnFoldTweenComplete ============ */
        
        
        private function onUnFoldTweenComplete():void
        {
            topPage.visible = true;
            foldActivated = false;
            removeEventListener(Event.ENTER_FRAME, redraw);
            
            if (foldLayerEnabled)
            {
                if (rawChildren.contains(foldLayer))
                {
                    rawChildren.removeChild(foldLayer);
                }
            }
            
            if (geometryLayerEnabled)
            {
                if (rawChildren.contains(geometryLayer))
                {
                    rawChildren.removeChild(geometryLayer);
                }
            }
            
            if (gradientLayerEnabled)
            {
                if (rawChildren.contains(gradientLayer))
                {
                    rawChildren.removeChild(gradientLayer);
                }
            }
        }
        
        
        /* ================================================================================= redraw ======================= */
        
        
        private function redraw(event:Event = null):void
        {
            updateFoldMeasurements();
            
            if (foldDestinationX == peekCurrentPosition.x && foldDestinationY == peekCurrentPosition.y)
            {
                removeEventListener(Event.ENTER_FRAME, redraw);
            }
            
            // always render the fold layer.  if it is not enabled then it will not appear but
            // the rendering process updates the cPoints and pPoints used by the other 
            // layers so we always need to execute it.
            renderFoldLayer();
            
            // Sometimes the cPoints returned by the PageFlip are null if it is too early in the 
            // animation. therefore, we cannot render the geometry (which relies on the cPoints for
            // computation) if the cPoints are null.  
            if (geometryLayerEnabled && cPoints!=null)  
            {
                renderGeometryLayer();
            }
            
            if (gradientLayerEnabled)
            {
                renderGradientLayer();
            }
        }
        
        
        /* ================================================================================= renderFoldLayer ============== */
        
        
        private function renderFoldLayer():void
        {
            foldLayer.graphics.clear();
            if (topPage.width != 0 && topPage.height != 0)
            {
                var clippingRectangle:Rectangle = new RoundedRectangle(0, 0, topPage.width, topPage.height, topPage.getStyle("cornerRadius"));
                // create a matrix to flip the topPage around so it will looked 'flipped' on the backside
                var flipMatrix:Matrix = new Matrix(-1, 0, 0, 1, topPage.width, 1);
                // create bitmapdata for the flipped image
                var flippedTopPageBitmapData:BitmapData = new BitmapData(topPage.width, topPage.height, false, getStyle("backgroundColor"));
                // draw the flipped image
                flippedTopPageBitmapData.draw(topPage, flipMatrix, null, null, null, false);
                // create new new bitmapped data objects one for the front page and one for the back
                this.page1BMD = new BitmapData(topPage.width, topPage.height, true, getStyle("backgroundColor"));  
                this.page2BMD = new BitmapData(topPage.width, topPage.height, false, 0xCCCCCC);
                // draw the top page and the back page (using the flippedTopPageBitmapData created earlier) 
                this.page1BMD.draw(topPage, null, null, null, null, true);                
                this.page2BMD.draw(flippedTopPageBitmapData, null, backingColorTransform, null, null, true); 
                // compute the flip
                var foldedObject:Object = PageFlip.computeFlip(peekCurrentPosition.clone(),
                                                               peekFixedPosition.clone(),    
                                                               this.page1BMD.width,           // size of the sheet
                                                               this.page2BMD.height,
                                                               tearHorizontalMode,            // in horizontal mode
                                                               1);                            // sensibility to one 
                // update the pPoints (coordinates for the top page of the flip) and the 
                // cPoints (coordinates for the flipped part of the top page).
                pPoints = foldedObject.pPoints;
                cPoints = foldedObject.cPoints;
                
                // draw the flip
                PageFlip.drawBitmapSheet(foldedObject,      // computeflip returned object
                                         foldLayer,         // target
                                         this.page1BMD,     // bitmap page 0
                                         this.page2BMD);    // bitmap page 1
                                         
            }
        }
        
        
        /* ================================================================================= renderGeometryLayer ========== */
        
        
        private function renderGeometryLayer():void
        {
            geometryLayer.graphics.clear();
            // draw the outline of the fold
            drawPoly(geometryLayer.graphics, getFoldPoly(), YELLOW, 12, 1.0);                
            geometryLayer.graphics.endFill();
            // draw the outline of the revealed area
            drawPoly(geometryLayer.graphics, getRevealPoly(), GREEN, 8, 1.0);
            geometryLayer.graphics.endFill();
            // draw the outline of the fixed portion of the top page
            drawPoly(geometryLayer.graphics, getTopPoly(), PURPLE, 4, 1.0);                
            geometryLayer.graphics.endFill();
        }
        
                    
        /* ================================================================================= renderGradientLayer ========== */
        
        
        private function renderGradientLayer():void
        {
            gradientLayer.graphics.clear();
         
            // instead of this hack, only render the gradients after the fold distance is 'significant'
            if (dragVector.length > 10)   // avoid flicker
            {
                drawFlipside(gradientLayer.graphics,   getFoldPoly());
                drawRevealSide(gradientLayer.graphics, getRevealPoly());
                drawTopSide(gradientLayer.graphics,    getTopPoly());
            }
        }
        

        
        /* ================================================================================= drawFlipside ===================== */
                
        
        /**
        * Draws a gradient to simulate depth on the flipside of the Page.
        */
        public function drawFlipside(flipGraphics:Graphics, foldPolyArray:Array):void
        {
            var tempVector:Vector = dragVector.clone();
            tempVector.length /= 2;
            var startToCurrentCenter:Point = tempVector.p1.clone();
            var centerToGrab:Vector = new Vector(startToCurrentCenter, peekStartPosition);
                
            var flipMatrix:Matrix = new Matrix();
            flipMatrix.identity();
            flipMatrix.scale((dragVector.length*1.2)/1638.4, 50/1638.4);
            flipMatrix.rotate(foldAngleInRadians);
            flipMatrix.translate(startToCurrentCenter.x + centerToGrab.x/2,startToCurrentCenter.y + centerToGrab.y/2);
            var fading:Number = 1.8-turnPercentage;
            var scaling:Number = 1
            flipGraphics.beginGradientFill(GradientType.LINEAR, 
                                           [0xFFFFFF,    0xFFFFFF,    0xFFFFFF,    0x000000,   0x000000,   0XFFFFFF], 
                                           [       1,           1,    1*fading,         .35,          0,          0], 
                                           [       1,         175,         179,         195,        245,        255], 
                                           flipMatrix);
            drawPoly(flipGraphics, foldPolyArray, 0, 0, 0);
            flipGraphics.endFill(); 
        }
        
        
        /* ================================================================================= drawRevealSide =================== */
                
                
        public function drawRevealSide(revealGraphics:Graphics, revealPolyArray:Array):void
        {
            var tempVector:Vector = dragVector.clone();
            tempVector.length /= 2;
            var startToCurrentCenter:Point = tempVector.p1.clone();
            var centerToGrab:Vector = new Vector(startToCurrentCenter, peekStartPosition);
                
            var revealMatrix:Matrix = new Matrix();
            revealMatrix.identity();
            revealMatrix.scale((dragVector.length*1.2)/1638.4, 50/1638.4);
            revealMatrix.rotate(foldAngleInRadians+Math.PI);
            revealMatrix.translate(startToCurrentCenter.x + centerToGrab.x/2,startToCurrentCenter.y + centerToGrab.y/2);
            var fading:Number = 1.7-turnPercentage;
            
            var bgColor:Number = hiddenPage.getStyle("backgroundColor");
            revealGraphics.beginGradientFill(GradientType.LINEAR,
                                             [ 0,           0,  bgColor,  bgColor,  bgColor], 
                                             [ 1,  .9*fading,       .1,        0,        0], 
                                             [ 72,         75,      88,      100,      255],
                                             revealMatrix);
            drawPoly(revealGraphics, revealPolyArray, 0, 0, 0);
            revealGraphics.endFill();
        }        
        
        
        /* ================================================================================= drawTopSide ====================== */
                
        
        public function drawTopSide(topGraphics:Graphics, topPolyArray:Array):void
        {
            var tempVector:Vector = dragVector.clone();
            tempVector.length /= 2;
            var startToCurrentCenter:Point = tempVector.p1.clone();
            var centerToGrab:Vector = new Vector(startToCurrentCenter, peekStartPosition);
            var revealMatrix:Matrix = new Matrix();
            revealMatrix.identity();
            revealMatrix.scale((dragVector.length*1.2)/1638.4, 50/1638.4);
            revealMatrix.rotate(foldAngleInRadians);
            revealMatrix.translate(startToCurrentCenter.x + centerToGrab.x/2,startToCurrentCenter.y + centerToGrab.y/2);
            
            var fading:Number = 1-turnPercentage;
            var shadowing:Number = turnPercentage;
            var skewing:Number = 10*turnPercentage;
            if (useSpotLighting)
            {
                
                topGraphics.beginGradientFill(GradientType.LINEAR, 
                                              [0x000000,   0x000000,     0x000000,      0x000000,       0x000000,      0x000000], 
                                              [1,               .95,           .6,  .5*shadowing,   .5*shadowing,  .5*shadowing], 
                                              [0,               170,  180+skewing,   200+skewing,    220+skewing,           255], 
                                              revealMatrix);
            }
            else
            {
                topGraphics.beginGradientFill(GradientType.LINEAR, 
                                              [0x000000,   0x000000,      0x000000,      0x000000,      0x000000,   0x000000], 
                                              [1,               .95,            .5,            .2,             0,          0], 
                                              [0,               170,   180+skewing,   200+skewing,   220+skewing,        255], 
                                              revealMatrix);                
            }
            drawPoly(topGraphics, topPolyArray, 0, 0, 0);
            topGraphics.endFill();
        }
        
        
        /* ================================================================================= getFoldPoly ====================== */
        
        
        private function getFoldPoly():Array
        {
            var returnPolyArray:Array = cPoints;
            if (returnPolyArray==null)
            {
                returnPolyArray = [new Point(foldHorizontalIntersection, peekStartPosition.y), 
                        new Point(peekStartPosition.x, foldVerticalIntersection), 
                        peekCurrentPosition];
            }
            return returnPolyArray;
        }
        
                    
        /* ================================================================================= getTopPoly ======================= */
        
                    
        private function getTopPoly():Array
        {
            var returnPoly:Array = new Array();
            var testVector:Vector = new Vector(cPoints[0], cPoints[1]);
            switch (foldCorner)
            {
                case (FOLD_TOP_LEFT):
                {
                    if (foldHorizontalIntersection > width)
                    {
                        returnPoly = [new Point(width, testVector.yForX(width)), 
                                      cPoints[0],
                                      cPoints[3],
                                      new Point(0, height),
                                      new Point(width, height)];
                    }
                    else
                    if (foldVerticalIntersection > height)
                    {
                        returnPoly = [new Point(testVector.xForY(height), height),
                                      cPoints[0],
                                      cPoints[3],
                                      new Point(width, 0),
                                      new Point(width, height)];
                    }
                    else
                    {
                        returnPoly = [new Point(foldHorizontalIntersection, peekStartPosition.y), 
                                      peekCurrentPosition,
                                      new Point(peekStartPosition.x, foldVerticalIntersection),
                                      new Point(0, height),
                                      new Point(width, height),
                                      new Point(width, 0)];
                    }
                    break;
                }
                case (FOLD_TOP_RIGHT):
                {
                    if (foldHorizontalIntersection < 0)
                    {
                        returnPoly = [new Point(0, testVector.yForX(0)),
                                      cPoints[0],
                                      cPoints[3],
                                      new Point(width, height),
                                      new Point(0, height)];
                    }
                    else
                    if (foldVerticalIntersection > height)
                    {
                        returnPoly = [new Point(testVector.xForY(height), height),
                                      cPoints[0],
                                      cPoints[3],
                                      new Point(0, 0),
                                      new Point(0, height)];
                    }
                    else
                    {
                        returnPoly = [new Point(foldHorizontalIntersection, peekStartPosition.y), 
                                      peekCurrentPosition,
                                      new Point(peekStartPosition.x, foldVerticalIntersection),
                                      new Point(width, height),
                                      new Point(0, height),
                                      new Point(0, 0)];
                    }
                    break;
                }
                case (FOLD_BOTTOM_RIGHT):
                {
                    if (foldHorizontalIntersection < 0)
                    {
                        returnPoly = [new Point(0, testVector.yForX(0)),
                                      cPoints[0],
                                      cPoints[3],
                                      new Point(width, 0),
                                      new Point(0, 0)];
                    }
                    else
                    if (foldVerticalIntersection < 0)
                    {
                        returnPoly = [new Point(testVector.xForY(0), 0),
                                      cPoints[0],
                                      cPoints[3],
                                      new Point(0, height),
                                      new Point(0, 0)];
                    }
                    else
                    {
                        returnPoly = [new Point(foldHorizontalIntersection, peekStartPosition.y), 
                                      peekCurrentPosition,
                                      new Point(peekStartPosition.x, foldVerticalIntersection),
                                      new Point(width, 0),
                                      new Point(0, 0),
                                      new Point(0, height)];
                    }
                    break;
                }
                case (FOLD_BOTTOM_LEFT):
                {
                    if (foldHorizontalIntersection > width)
                    {
                        returnPoly = [new Point(width, testVector.yForX(width)),
                                      cPoints[0],
                                      cPoints[3],
                                      new Point(0, 0),
                                      new Point(width, 0)];
                    }
                    else
                    if (foldVerticalIntersection < 0)
                    {
                        returnPoly = [new Point(testVector.xForY(0), 0),
                                      cPoints[0],
                                      cPoints[3],
                                      new Point(width, height),
                                      new Point(width, 0)];
                    }
                    else
                    {
                        returnPoly = [new Point(foldHorizontalIntersection, peekStartPosition.y), 
                                      peekCurrentPosition,
                                      new Point(peekStartPosition.x, foldVerticalIntersection),
                                      new Point(0, 0),
                                      new Point(width, 0),
                                      new Point(width, height)];
                    }
                    break;
                }
            }
            
            return returnPoly;
        }
        
        
        /* ================================================================================= getRevealPoly ==================== */
       
        
        private function getRevealPoly():Array
        {
            var returnPoly:Array = new Array();
            
            switch (foldCorner)
            {
                case (FOLD_TOP_LEFT):
                {
                    if (foldVector.yForX(0) > height)
                    {
                        returnPoly.push(new Point(foldVector.xForY(height), height));
                        if (foldVector.xForY(0) > width)
                        {
                            returnPoly.push(new Point(width, foldVector.yForX(width)));
                            returnPoly.push(new Point(width, 0));
                        }
                        else
                        {
                            returnPoly.push(new Point(foldVector.xForY(0), 0));
                        }
                        returnPoly.push(new Point(0, 0));
                        returnPoly.push(new Point(0, height));
                    }
                    else
                    {
                        returnPoly.push(new Point(0, foldVector.yForX(0)));
                        if (foldVector.xForY(0) > width)
                        {
                            returnPoly.push(new Point(width, foldVector.yForX(width)));
                            returnPoly.push(new Point(width, 0));
                        }
                        else
                        {
                            returnPoly.push(new Point(foldVector.xForY(0), 0));
                        }
                        returnPoly.push(new Point(0, 0));
                    }
                    break;
                }
                case (FOLD_TOP_RIGHT):
                {
                    if (foldVector.yForX(width) > height)
                    {
                        returnPoly.push(new Point(foldVector.xForY(height), height));
                        if (foldVector.xForY(0) < 0)
                        {
                            returnPoly.push(new Point(0, foldVector.yForX(0)));
                            returnPoly.push(new Point(0, 0));
                        }
                        else
                        {
                            returnPoly.push(new Point(foldVector.xForY(0), 0));
                        }
                        returnPoly.push(new Point(width, 0));
                        returnPoly.push(new Point(width, height));
                    }
                    else
                    {
                        returnPoly.push(new Point(width, foldVector.yForX(width)));
                        if (foldVector.xForY(0) < 0)
                        {
                            returnPoly.push(new Point(0, foldVector.yForX(0)));
                            returnPoly.push(new Point(0, 0));
                        }
                        else
                        {
                            returnPoly.push(new Point(foldVector.xForY(0), 0));
                        }
                        returnPoly.push(new Point(width, 0));
                    }
                    break;
                }
                case (FOLD_BOTTOM_RIGHT):
                {
                    if (foldVector.yForX(0) < height)
                    {
                        returnPoly.push(new Point(0, foldVector.yForX(0)));
                        if (foldVector.xForY(0) < width)
                        {
                            returnPoly.push(new Point(foldVector.xForY(0), 0));
                            returnPoly.push(new Point(width, 0));
                        }
                        else
                        {
                            returnPoly.push(new Point(width, foldVector.yForX(width)));
                        }
                        returnPoly.push(new Point(width, height));
                        returnPoly.push(new Point(0, height));
                    }
                    else 
                    {
                        returnPoly.push(new Point(foldVector.xForY(height), height));
                        if (foldVector.xForY(0) < width)
                        {
                            returnPoly.push(new Point(foldVector.xForY(0), 0));
                            returnPoly.push(new Point(width, 0));
                        }
                        else
                        {
                            returnPoly.push(new Point(width, foldVector.yForX(width)));
                        }
                        returnPoly.push(new Point(width, height));
                    }
                    break;
                }
                case (FOLD_BOTTOM_LEFT):
                {
                    if (foldVector.xForY(0) > 0)
                    {
                        returnPoly.push(new Point(foldVector.xForY(0), 0));
                        if (foldVector.yForX(width) < height)
                        {
                            returnPoly.push(new Point(width, foldVector.yForX(width)));
                            returnPoly.push(new Point(width, height));
                        }
                        else
                        {
                            returnPoly.push(new Point(foldVector.xForY(height), height));
                        }
                        returnPoly.push(new Point(0, height));
                        returnPoly.push(new Point(0, 0));
                    }
                    else
                    {
                        returnPoly.push(new Point(0, foldVector.yForX(0)));
                        if (foldVector.yForX(width) < height)
                        {
                            returnPoly.push(new Point(width, foldVector.yForX(width)));
                            returnPoly.push(new Point(width, height));
                        }
                        else
                        {
                            returnPoly.push(new Point(foldVector.xForY(height), height));
                        }
                        returnPoly.push(new Point(0, height));
                    }
                    break;
                }
            }
            
            return returnPoly;
        }
        
        
        /* ================================================================================= getVectorIntersects ============== */
       
                
        private function getVectorIntersects(angleVector:Vector):Array
        {
            var returnArray:Array = new Array();
            
            if ( (angleVector.xForY(0)>0) && (angleVector.xForY(0)<width) )
            {
                returnArray.push(new Point(angleVector.xForY(0), 0));
            }
            
            if ( (angleVector.xForY(height)>0) && (angleVector.xForY(height)<width) )
            {
                returnArray.push(new Point(angleVector.xForY(height), height));
            }
            
            if ( (angleVector.yForX(0)>0) && (angleVector.yForX(0)<height) )
            {
                returnArray.push(new Point(0, angleVector.yForX(0)));
            }
            
            if ( (angleVector.yForX(width)>0) && (angleVector.yForX(width)<height) )
            {
                returnArray.push(new Point(0, angleVector.yForX(height)));
            }
            return returnArray;
        }
        
        
        /* ================================================================================= drawPoly ========================= */
                    
        
        private function drawPoly(g:Graphics, poly:Array, lineColor:Number, lineThickness:Number, lineAlpha:Number):void
        {
            g.lineStyle(lineThickness, lineColor, lineAlpha);
            g.moveTo(poly[0].x, poly[0].y);
            for(var i:int=0; i<poly.length; i++)
            {
                g.lineTo(poly[i].x, poly[i].y);
            }
            g.lineTo(poly[0].x, poly[0].y);
        }
    }
}