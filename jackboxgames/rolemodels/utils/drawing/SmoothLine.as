package jackboxgames.rolemodels.utils.drawing
{
   import flash.display.*;
   import flash.geom.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class SmoothLine extends Sprite
   {
      
      public static var DEFAULT_DRAWING_SPEED:Number = 20;
      
      public static var _thicknessMultiplier:Number = 1;
      
      public static var MIN_THICKNESS:Number = 0.3;
      
      public static var THICKNESS_FACTOR:Number = 0;
      
      public static var THICKNESS_SMOOTHING_FACTOR:Number = 0.6;
      
      public static var SMOOTHING_FACTOR_X:Number = 0.55;
      
      public static var SMOOTHING_FACTOR_Y:Number = 0.55;
      
      public static var DOT_RADIUS:Number = 2;
      
      public static var TIP_TAPER_FACTOR:Number = 0.7;
      
      public static var CONTROL_VECTOR_CONSTANT_X:Number = 0.33;
      
      public static var CONTROL_VECTOR_CONSTANT_Y:Number = 0.33;
       
      
      private var _data:Object;
      
      private var _lineBitmap:Bitmap;
      
      private var _lineLayer:Sprite;
      
      private var _tipLayer:Sprite;
      
      private var lastSmoothedMouseX:Number;
      
      private var lastSmoothedMouseY:Number;
      
      private var lastMouseX:Number;
      
      private var lastMouseY:Number;
      
      private var lastThickness:Number;
      
      private var lastRotation:Number;
      
      private var lineThickness:Number;
      
      private var lineRotation:Number;
      
      private var L0Sin0:Number;
      
      private var L0Cos0:Number;
      
      private var L1Sin1:Number;
      
      private var L1Cos1:Number;
      
      private var sin0:Number;
      
      private var cos0:Number;
      
      private var sin1:Number;
      
      private var cos1:Number;
      
      private var dx:Number;
      
      private var dy:Number;
      
      private var dist:Number;
      
      private var targetLineThickness:Number;
      
      private var colorLevel:Number;
      
      private var targetColorLevel:Number;
      
      private var smoothedMouseX:Number;
      
      private var smoothedMouseY:Number;
      
      private var startX:Number;
      
      private var startY:Number;
      
      private var mouseChangeVectorX:Number;
      
      private var mouseChangeVectorY:Number;
      
      private var lastMouseChangeVectorX:Number;
      
      private var lastMouseChangeVectorY:Number;
      
      private var controlVecX:Number;
      
      private var controlVecY:Number;
      
      private var controlX1:Number;
      
      private var controlY1:Number;
      
      private var controlX2:Number;
      
      private var controlY2:Number;
      
      private var _pointIndex:int;
      
      private var _totalPoints:int;
      
      private var _bounds:Rectangle;
      
      private var _lineSprite:Sprite;
      
      private var _history:Array;
      
      private var _lastTipHistory:Array;
      
      private var _callback:Function;
      
      private var _drawingInProgress:Boolean;
      
      public function SmoothLine(bounds:Rectangle)
      {
         this._lineSprite = new Sprite();
         super();
         this._bounds = bounds;
         this._callback = Nullable.NULL_FUNCTION;
         this._drawingInProgress = false;
         this._history = [];
         this._lastTipHistory = [];
         this._lineSprite = new Sprite();
         addChild(this._lineSprite);
         this._lineLayer = new Sprite();
         this._tipLayer = new Sprite();
         this._lineSprite.addChild(this._lineLayer);
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function get drawingInProgress() : Boolean
      {
         return this._drawingInProgress;
      }
      
      public function reset() : void
      {
         this._data = {};
         this._callback = Nullable.NULL_FUNCTION;
         this._drawingInProgress = false;
         SpriteUtil.removeAllChildren(this,true);
         this._lineSprite = new Sprite();
         addChild(this._lineSprite);
         this._lineSprite.addChild(this._lineLayer);
         this._lineLayer.graphics.clear();
         this._tipLayer.graphics.clear();
         _thicknessMultiplier = 1;
         this._history = [];
         this._lastTipHistory = [];
      }
      
      public function drawFromHistory(graphics:Graphics) : void
      {
         this._history.forEach(function(o:Object, i:int, arr:Array):void
         {
            graphics[o.fn].apply(null,o.args);
         });
      }
      
      public function setupLine(line:Object, speed:int, doneFn:Function) : void
      {
         this.reset();
         this._callback = doneFn;
         this._data = line;
         this._totalPoints = this._data.points.length;
         if(speed < 0)
         {
            speed = DEFAULT_DRAWING_SPEED;
         }
         if(Platform.instance.PlatformFidelity == Platform.PLATFORM_FIDELITY_LOW)
         {
            speed = 0;
         }
         if(Boolean(this._data.thickness))
         {
            _thicknessMultiplier = this._data.thickness;
         }
         if(this._data.points.length < 1)
         {
            this._callback();
            this._callback = Nullable.NULL_FUNCTION;
         }
         else if(this._data.points.length == 1)
         {
            this._drawPoint(this._data.points[0].x,this._data.points[0].y,parseInt(this._data.color.substring(1),16));
            this._callback();
            this._callback = Nullable.NULL_FUNCTION;
         }
         else
         {
            this._startLine(this._data.points[0].x,this._data.points[0].y);
            this._pointIndex = 0;
            this._drawingInProgress = true;
            this._data.points.forEach(function(pt:Object, i:int, arr:Array):void
            {
               JBGUtil.runFunctionAfter(function():void
               {
                  _drawLine(pt.x,pt.y,parseInt(_data.color.substring(1),16));
               },Duration.fromMs(i * speed));
            });
            JBGUtil.runFunctionAfter(function():void
            {
               _endLine();
               _drawingInProgress = false;
               _callback();
               _callback = Nullable.NULL_FUNCTION;
            },Duration.fromMs((this._totalPoints + 1) * speed + 50));
         }
      }
      
      private function _drawPoint(x:Number, y:Number, color:uint) : void
      {
         var dot:Sprite = new Sprite();
         dot.graphics.beginFill(color);
         dot.graphics.drawEllipse(x - DOT_RADIUS,y - DOT_RADIUS,2 * DOT_RADIUS,2 * DOT_RADIUS);
         dot.graphics.endFill();
         this._history.push({
            "fn":"beginFill",
            "args":[color]
         });
         this._history.push({
            "fn":"drawEllipse",
            "args":[x - DOT_RADIUS,y - DOT_RADIUS,2 * DOT_RADIUS,2 * DOT_RADIUS]
         });
         this._history.push({
            "fn":"endFill",
            "args":[]
         });
         this._lineSprite.addChild(dot);
      }
      
      private function _startLine(x:Number, y:Number) : void
      {
         this.startX = this.lastMouseX = this.smoothedMouseX = this.lastSmoothedMouseX = x;
         this.startY = this.lastMouseY = this.smoothedMouseY = this.lastSmoothedMouseY = y;
         this.lastThickness = 0;
         this.lastRotation = Math.PI / 2;
         this.colorLevel = 0;
         this.lastMouseChangeVectorX = 0;
         this.lastMouseChangeVectorY = 0;
      }
      
      private function _drawLine(x:Number, y:Number, color:uint) : void
      {
         this.mouseChangeVectorX = x - this.lastMouseX;
         this.mouseChangeVectorY = y - this.lastMouseY;
         if(this.mouseChangeVectorX * this.lastMouseChangeVectorX + this.mouseChangeVectorY * this.lastMouseChangeVectorY < 0)
         {
            this._lineSprite.addChild(this._tipLayer);
            this._tipLayer = new Sprite();
            this._history.push.apply(null,this._lastTipHistory);
            this._lastTipHistory = [];
            this.smoothedMouseX = this.lastSmoothedMouseX = this.lastMouseX;
            this.smoothedMouseY = this.lastSmoothedMouseY = this.lastMouseY;
            this.lastRotation += Math.PI;
            this.lastThickness = TIP_TAPER_FACTOR * this.lastThickness;
         }
         this.smoothedMouseX += SMOOTHING_FACTOR_X * (x - this.smoothedMouseX);
         this.smoothedMouseY += SMOOTHING_FACTOR_Y * (y - this.smoothedMouseY);
         this.dx = this.smoothedMouseX - this.lastSmoothedMouseX;
         this.dy = this.smoothedMouseY - this.lastSmoothedMouseY;
         this.dist = Math.sqrt(this.dx * this.dx + this.dy * this.dy);
         if(this.dist != 0)
         {
            this.lineRotation = Math.PI / 2 + Math.atan2(this.dy,this.dx);
         }
         else
         {
            this.lineRotation = 0;
         }
         this.targetLineThickness = MIN_THICKNESS * _thicknessMultiplier + THICKNESS_FACTOR * this.dist;
         this.lineThickness = this.lastThickness + THICKNESS_SMOOTHING_FACTOR * (this.targetLineThickness - this.lastThickness);
         this.sin0 = Math.sin(this.lastRotation);
         this.cos0 = Math.cos(this.lastRotation);
         this.sin1 = Math.sin(this.lineRotation);
         this.cos1 = Math.cos(this.lineRotation);
         this.L0Sin0 = this.lastThickness * this.sin0;
         this.L0Cos0 = this.lastThickness * this.cos0;
         this.L1Sin1 = this.lineThickness * this.sin1;
         this.L1Cos1 = this.lineThickness * this.cos1;
         this.controlVecX = CONTROL_VECTOR_CONSTANT_X * this.dist * this.sin0;
         this.controlVecY = -CONTROL_VECTOR_CONSTANT_Y * this.dist * this.cos0;
         this.controlX1 = this.lastSmoothedMouseX + this.L0Cos0 + this.controlVecX;
         this.controlY1 = this.lastSmoothedMouseY + this.L0Sin0 + this.controlVecY;
         this.controlX2 = this.lastSmoothedMouseX - this.L0Cos0 + this.controlVecX;
         this.controlY2 = this.lastSmoothedMouseY - this.L0Sin0 + this.controlVecY;
         this._lineLayer.graphics.lineStyle(1,color);
         this._lineLayer.graphics.beginFill(color);
         this._lineLayer.graphics.moveTo(this.lastSmoothedMouseX + this.L0Cos0,this.lastSmoothedMouseY + this.L0Sin0);
         this._lineLayer.graphics.curveTo(this.controlX1,this.controlY1,this.smoothedMouseX + this.L1Cos1,this.smoothedMouseY + this.L1Sin1);
         this._lineLayer.graphics.lineTo(this.smoothedMouseX - this.L1Cos1,this.smoothedMouseY - this.L1Sin1);
         this._lineLayer.graphics.curveTo(this.controlX2,this.controlY2,this.lastSmoothedMouseX - this.L0Cos0,this.lastSmoothedMouseY - this.L0Sin0);
         this._lineLayer.graphics.lineTo(this.lastSmoothedMouseX + this.L0Cos0,this.lastSmoothedMouseY + this.L0Sin0);
         this._lineLayer.graphics.endFill();
         this._history.push({
            "fn":"lineStyle",
            "args":[1,color]
         });
         this._history.push({
            "fn":"beginFill",
            "args":[color]
         });
         this._history.push({
            "fn":"moveTo",
            "args":[this.lastSmoothedMouseX + this.L0Cos0,this.lastSmoothedMouseY + this.L0Sin0]
         });
         this._history.push({
            "fn":"curveTo",
            "args":[this.controlX1,this.controlY1,this.smoothedMouseX + this.L1Cos1,this.smoothedMouseY + this.L1Sin1]
         });
         this._history.push({
            "fn":"lineTo",
            "args":[this.smoothedMouseX - this.L1Cos1,this.smoothedMouseY - this.L1Sin1]
         });
         this._history.push({
            "fn":"curveTo",
            "args":[this.controlX2,this.controlY2,this.lastSmoothedMouseX - this.L0Cos0,this.lastSmoothedMouseY - this.L0Sin0]
         });
         this._history.push({
            "fn":"lineTo",
            "args":[this.lastSmoothedMouseX + this.L0Cos0,this.lastSmoothedMouseY + this.L0Sin0]
         });
         this._history.push({
            "fn":"endFill",
            "args":[]
         });
         var taperThickness:Number = TIP_TAPER_FACTOR * this.lineThickness;
         this._tipLayer.graphics.clear();
         this._tipLayer.graphics.beginFill(color);
         this._tipLayer.graphics.drawEllipse(x - taperThickness,y - taperThickness,2 * taperThickness,2 * taperThickness);
         this._tipLayer.graphics.endFill();
         this._lastTipHistory = [];
         this._lastTipHistory.push({
            "fn":"beginFill",
            "args":[color]
         });
         this._lastTipHistory.push({
            "fn":"drawEllipse",
            "args":[x - taperThickness,y - taperThickness,2 * taperThickness,2 * taperThickness]
         });
         this._lastTipHistory.push({
            "fn":"endFill",
            "args":[]
         });
         this._tipLayer.graphics.lineStyle(1,color);
         this._tipLayer.graphics.beginFill(color);
         this._tipLayer.graphics.moveTo(this.smoothedMouseX + this.L1Cos1,this.smoothedMouseY + this.L1Sin1);
         this._tipLayer.graphics.lineTo(x + TIP_TAPER_FACTOR * this.L1Cos1,y + TIP_TAPER_FACTOR * this.L1Sin1);
         this._tipLayer.graphics.lineTo(x - TIP_TAPER_FACTOR * this.L1Cos1,y - TIP_TAPER_FACTOR * this.L1Sin1);
         this._tipLayer.graphics.lineTo(this.smoothedMouseX - this.L1Cos1,this.smoothedMouseY - this.L1Sin1);
         this._tipLayer.graphics.lineTo(this.smoothedMouseX + this.L1Cos1,this.smoothedMouseY + this.L1Sin1);
         this._tipLayer.graphics.endFill();
         this._lastTipHistory.push({
            "fn":"lineStyle",
            "args":[1,color]
         });
         this._lastTipHistory.push({
            "fn":"beginFill",
            "args":[color]
         });
         this._lastTipHistory.push({
            "fn":"moveTo",
            "args":[this.smoothedMouseX + this.L1Cos1,this.smoothedMouseY + this.L1Sin1]
         });
         this._lastTipHistory.push({
            "fn":"lineTo",
            "args":[x + TIP_TAPER_FACTOR * this.L1Cos1,y + TIP_TAPER_FACTOR * this.L1Sin1]
         });
         this._lastTipHistory.push({
            "fn":"lineTo",
            "args":[x - TIP_TAPER_FACTOR * this.L1Cos1,y - TIP_TAPER_FACTOR * this.L1Sin1]
         });
         this._lastTipHistory.push({
            "fn":"lineTo",
            "args":[this.smoothedMouseX - this.L1Cos1,this.smoothedMouseY - this.L1Sin1]
         });
         this._lastTipHistory.push({
            "fn":"lineTo",
            "args":[this.smoothedMouseX + this.L1Cos1,this.smoothedMouseY + this.L1Sin1]
         });
         this._lastTipHistory.push({
            "fn":"endFill",
            "args":[]
         });
         this.lastSmoothedMouseX = this.smoothedMouseX;
         this.lastSmoothedMouseY = this.smoothedMouseY;
         this.lastRotation = this.lineRotation;
         this.lastThickness = this.lineThickness;
         this.lastMouseChangeVectorX = this.mouseChangeVectorX;
         this.lastMouseChangeVectorY = this.mouseChangeVectorY;
         this.lastMouseX = x;
         this.lastMouseY = y;
      }
      
      private function _endLine() : void
      {
         this._lineSprite.addChild(this._tipLayer);
         this._tipLayer = new Sprite();
         this._history.push.apply(null,this._lastTipHistory);
         this._lastTipHistory = [];
      }
   }
}
