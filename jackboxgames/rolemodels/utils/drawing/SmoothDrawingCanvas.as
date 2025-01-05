package jackboxgames.rolemodels.utils.drawing
{
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class SmoothDrawingCanvas extends Sprite
   {
      
      private static const RENDER_TYPE_BITMAP:int = 0;
      
      private static const RENDER_TYPE_VECTOR:int = 1;
       
      
      private var _isCensored:Boolean;
      
      private var _bounds:Rectangle;
      
      private var _maxPoints:int = 25000;
      
      private var _pointsRenderThreshold:int = 1200;
      
      private var _startingLines:Array;
      
      private var _newLines:Array;
      
      private var _startingGraphics:Array;
      
      private var _newGraphics:Array;
      
      private var _startingLineSprite:Sprite;
      
      private var _newLineSprite:Sprite;
      
      private var _startingLineBitmap:Bitmap;
      
      private var _newLineBitmap:Bitmap;
      
      private var _startingLineRenderType:int = 1;
      
      private var _newLineRenderType:int = 1;
      
      private var _renderingNewLines:Boolean = false;
      
      private var _newLineRenderTimer:PausableTimer;
      
      private var _renderingStartingLines:Boolean = false;
      
      private var _startingLineRenderTimer:PausableTimer;
      
      public function SmoothDrawingCanvas(drawingBounds:Rectangle)
      {
         this._bounds = new Rectangle(-9999,-9999,9999 * 2,9999 * 2);
         super();
         this._bounds = drawingBounds;
         this._newLines = [];
         this._startingLines = [];
         this._startingGraphics = [];
         this._newGraphics = [];
         this._startingLineSprite = new Sprite();
         this._newLineSprite = new Sprite();
         this._startingLineBitmap = new Bitmap(new BitmapData(this._bounds.width,this._bounds.height,true,0),"auto",true);
         this._newLineBitmap = new Bitmap(new BitmapData(this._bounds.width,this._bounds.height,true,0),"auto",true);
         this._renderingNewLines = false;
         this._renderingStartingLines = false;
      }
      
      public function get isCensored() : Boolean
      {
         return this._isCensored;
      }
      
      public function get pointsRenderThreshold() : int
      {
         return this._pointsRenderThreshold;
      }
      
      public function set pointsRenderThreshold(val:int) : void
      {
         this._pointsRenderThreshold = val;
      }
      
      public function get startingLines() : Array
      {
         return this._startingLines;
      }
      
      public function get newLines() : Array
      {
         return this._newLines;
      }
      
      public function get startingLineSprite() : Sprite
      {
         return this._startingLineSprite;
      }
      
      public function get newLineSprite() : Sprite
      {
         return this._newLineSprite;
      }
      
      public function get startingLineBitmap() : Bitmap
      {
         return this._startingLineBitmap;
      }
      
      public function get newLineBitmap() : Bitmap
      {
         return this._newLineBitmap;
      }
      
      public function get lines() : Array
      {
         return this._startingLines.concat(this._newLines.concat());
      }
      
      public function get lineGraphics() : Array
      {
         return this._startingGraphics.concat(this._newGraphics.concat());
      }
      
      private function _resetNewLineRenderTimer() : void
      {
         if(Boolean(this._newLineRenderTimer))
         {
            this._newLineRenderTimer.reset();
            this._newLineRenderTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this._onNewLineRenderTimer);
            this._newLineRenderTimer = null;
         }
      }
      
      private function _startNewLineRenderTimer() : void
      {
         this._newLineRenderTimer = new PausableTimer(2500,1);
         this._newLineRenderTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this._onNewLineRenderTimer);
         this._newLineRenderTimer.start();
      }
      
      private function _resetStartingLineRenderTimer() : void
      {
         if(Boolean(this._startingLineRenderTimer))
         {
            this._startingLineRenderTimer.reset();
            this._startingLineRenderTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this._onStartingLineRenderTimer);
            this._startingLineRenderTimer = null;
         }
      }
      
      private function _startStartingLineRenderTimer() : void
      {
         this._startingLineRenderTimer = new PausableTimer(3000,1);
         this._startingLineRenderTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this._onStartingLineRenderTimer);
         this._startingLineRenderTimer.start();
      }
      
      public function reset() : void
      {
         this._isCensored = false;
         this._newLines = [];
         this._startingLines = [];
         this._startingGraphics = [];
         this._newGraphics = [];
         this._startingLineRenderType = RENDER_TYPE_VECTOR;
         this._newLineRenderType = RENDER_TYPE_VECTOR;
         SpriteUtil.removeAllChildren(this);
         this._startingLineSprite = new Sprite();
         this._newLineSprite = new Sprite();
         this.addChild(this._newLineSprite);
         this._startingLineBitmap.bitmapData.dispose();
         this._startingLineBitmap.bitmapData = new BitmapData(this._bounds.width,this._bounds.height,true,0);
         this._newLineBitmap.bitmapData.dispose();
         this._newLineBitmap.bitmapData = new BitmapData(this._bounds.width,this._bounds.height,true,0);
         this._resetNewLineRenderTimer();
         this._resetStartingLineRenderTimer();
         this._renderingNewLines = false;
         this._renderingStartingLines = false;
         this._startingLineRenderType = RENDER_TYPE_VECTOR;
         this.addChildAt(this._startingLineSprite,0);
         this._startingLineSprite.visible = true;
         if(this.contains(this._startingLineBitmap))
         {
            this.removeChild(this._startingLineBitmap);
            this._startingLineBitmap.visible = false;
         }
      }
      
      public function drawStartingLines(lines:Array, speed:int) : void
      {
         if(this.contains(this._startingLineSprite))
         {
            this.removeChild(this._startingLineSprite);
         }
         if(this.contains(this._startingLineBitmap))
         {
            this.removeChild(this._startingLineBitmap);
         }
         this._startingLineSprite = new Sprite();
         this.addChildAt(this._startingLineSprite,0);
         this._startingLines = lines.concat();
         this._startingLines.forEach(function(lineData:Object, i:int, arr:Array):void
         {
            var line:SmoothLine = new SmoothLine(_bounds);
            _startingGraphics.push(line);
            _startingLineSprite.addChild(line);
            line.setupLine(lineData,speed,Nullable.NULL_FUNCTION);
         });
         this._checkStartingLineRenderQuality();
      }
      
      public function importStartingLines(lines:Array, graphics:Array, doneFn:Function) : void
      {
         this._startingLines = lines.concat();
         this._startingGraphics = graphics.concat();
         if(this.contains(this._startingLineSprite))
         {
            this.removeChild(this._startingLineSprite);
         }
         if(this.contains(this._startingLineBitmap))
         {
            this.removeChild(this._startingLineBitmap);
         }
         this._startingLineSprite = new Sprite();
         this.addChildAt(this._startingLineSprite,0);
         graphics.forEach(function(line:SmoothLine, i:int, arr:Array):void
         {
            var newLine:Sprite = new Sprite();
            line.drawFromHistory(newLine.graphics);
            _startingLineSprite.addChild(newLine);
         });
         this._checkStartingLineRenderQuality();
         doneFn();
      }
      
      private function _checkStartingLineRenderQuality() : void
      {
         if(DrawingUtils.GET_NUM_POINTS(this._startingLines) > this._pointsRenderThreshold || Platform.instance.PlatformFidelity == Platform.PLATFORM_FIDELITY_LOW)
         {
            this._startingLineRenderType = RENDER_TYPE_BITMAP;
            if(!this._renderingStartingLines)
            {
               this._renderingStartingLines = true;
               this._resetStartingLineRenderTimer();
               this._startStartingLineRenderTimer();
            }
         }
         else
         {
            this._startingLineRenderType = RENDER_TYPE_VECTOR;
            this.addChildAt(this._startingLineSprite,0);
            this._startingLineSprite.visible = true;
            if(this.contains(this._startingLineBitmap))
            {
               this.removeChild(this._startingLineBitmap);
               this._startingLineBitmap.visible = false;
            }
         }
      }
      
      private function _onStartingLineRenderTimer(evt:Event) : void
      {
         var line:SmoothLine = null;
         for(var i:int = 0; i < this._startingGraphics.lenth; i++)
         {
            line = this._startingGraphics[i] as SmoothLine;
            if(line.drawingInProgress)
            {
               this._resetStartingLineRenderTimer();
               this._startStartingLineRenderTimer();
               return;
            }
         }
         var bm:Bitmap = new Bitmap(new BitmapData(this._bounds.width,this._bounds.height,true,0),"auto",true);
         bm.bitmapData.draw(this._startingLineSprite);
         bm.smoothing = true;
         this.addChildAt(bm,0);
         if(this.contains(this._startingLineBitmap))
         {
            this.removeChild(this._startingLineBitmap);
         }
         this._startingLineBitmap.bitmapData.dispose();
         this._startingLineBitmap = bm;
         if(this.contains(this._startingLineSprite))
         {
            this.removeChild(this._startingLineSprite);
            this._startingLineSprite.visible = false;
         }
         this._resetStartingLineRenderTimer();
         this._renderingStartingLines = false;
      }
      
      public function drawNewLine(lineData:Object, speed:int, doneFn:Function) : void
      {
         var numLines:int;
         var line:SmoothLine;
         if(this._isCensored)
         {
            return;
         }
         numLines = int(this._newLines.length);
         this._newLines.push(lineData);
         DrawingUtils.PREPARE_LINES(this._newLines,this._maxPoints,this._bounds);
         line = new SmoothLine(this._bounds);
         this._newGraphics.push(line);
         this._newLineSprite.addChild(line);
         line.setupLine(lineData,this._newLineRenderType == RENDER_TYPE_VECTOR ? speed : 0,function():void
         {
            _checkNewLineRenderQuality();
            doneFn();
         });
      }
      
      public function undoNewLines(numLines:int) : void
      {
         for(var i:int = this._newLines.length - 1; i >= this._newLines.length - numLines; i--)
         {
            this._newLineSprite.removeChildAt(i);
         }
         this._newLines.splice(this._newLines.length - numLines,numLines);
         this._newGraphics.splice(this._newGraphics.length - numLines,numLines);
         this._checkNewLineRenderQuality();
      }
      
      public function censor() : void
      {
         this._isCensored = true;
         this.undoNewLines(this._newLines.length);
      }
      
      private function _checkNewLineRenderQuality() : void
      {
         if(DrawingUtils.GET_NUM_POINTS(this._newLines) > this._pointsRenderThreshold)
         {
            this._newLineRenderType = RENDER_TYPE_BITMAP;
            if(!this._renderingNewLines)
            {
               this._renderingNewLines = true;
               this._resetNewLineRenderTimer();
               this._startNewLineRenderTimer();
            }
         }
         else
         {
            this._newLineRenderType = RENDER_TYPE_VECTOR;
            this.addChild(this._newLineSprite);
            this._newLineSprite.visible = true;
            if(this.contains(this._newLineBitmap))
            {
               this.removeChild(this._newLineBitmap);
               this._newLineBitmap.visible = false;
            }
            this._renderingNewLines = false;
            this._resetNewLineRenderTimer();
         }
      }
      
      private function _onNewLineRenderTimer(evt:Event) : void
      {
         var line:SmoothLine = null;
         for(var i:int = 0; i < this._newGraphics.lenth; i++)
         {
            line = this._newGraphics[i] as SmoothLine;
            if(line.drawingInProgress)
            {
               this._resetNewLineRenderTimer();
               this._startNewLineRenderTimer();
               return;
            }
         }
         var bm:Bitmap = new Bitmap(new BitmapData(this._bounds.width,this._bounds.height,true,0),"auto",true);
         bm.bitmapData.draw(this._newLineSprite);
         bm.smoothing = true;
         this.addChild(bm);
         if(this.contains(this._newLineBitmap))
         {
            this.removeChild(this._newLineBitmap);
         }
         this._newLineBitmap.bitmapData.dispose();
         this._newLineBitmap = bm;
         if(this.contains(this._newLineSprite))
         {
            this.removeChild(this._newLineSprite);
            this._newLineSprite.visible = false;
         }
         this._resetNewLineRenderTimer();
         this._renderingNewLines = false;
      }
      
      private function _generateSpriteFromGraphics(graphics:Array, callback:Function) : void
      {
      }
   }
}
