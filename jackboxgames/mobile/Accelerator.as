package jackboxgames.mobile
{
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   
   public class Accelerator
   {
       
      
      private var _container:MovieClip;
      
      private var _stage:Stage;
      
      private var _scrollableArea:Rectangle;
      
      private var _offset:Number;
      
      private var _fnTop:Function;
      
      private var _fnBottom:Function;
      
      private var _fnUpperBound:Function;
      
      private var _fnLowerBound:Function;
      
      private var _fnAccelerate:Function;
      
      private var _friction:Number;
      
      private var _bounceBackConstant:Number;
      
      private var _threshold:Number;
      
      private var _moveTimer:Timer;
      
      private var _isActive:Boolean;
      
      private var _curMouseY:Number;
      
      private var _hasMovedYet:Boolean;
      
      private var _acceleration:Number;
      
      private var _isMouseDown:Boolean;
      
      public function Accelerator(container:MovieClip, stage:Stage, scrollableArea:Rectangle, fnTop:Function, fnBottom:Function, fnUpperBound:Function, fnLowerBound:Function, fnAccelerate:Function, friction:Number = 0.15, bounceBackConstant:Number = 0.5, threshold:Number = 5, interval:Number = 16)
      {
         super();
         this._container = container;
         this._stage = stage;
         this._scrollableArea = scrollableArea;
         this._offset = 0;
         this._fnTop = fnTop;
         this._fnBottom = fnBottom;
         this._fnUpperBound = fnUpperBound;
         this._fnLowerBound = fnLowerBound;
         this._fnAccelerate = fnAccelerate;
         this._friction = friction;
         this._bounceBackConstant = bounceBackConstant;
         this._threshold = threshold;
         this._moveTimer = new Timer(250,1);
         this._moveTimer.addEventListener(TimerEvent.TIMER,this.onMoveTimer);
         this._container.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         this._isActive = true;
      }
      
      public function set isActive(val:Boolean) : void
      {
         if(val == this._isActive)
         {
            return;
         }
         this._isActive = val;
         this._hasMovedYet = false;
         this._acceleration = 0;
         this._isMouseDown = false;
         this._moveTimer.stop();
         this._container.removeEventListener(Event.ENTER_FRAME,this._onEnterFrame);
         this._stage.removeEventListener(MouseEvent.MOUSE_UP,this._onMouseUp);
      }
      
      public function onMouseDown(evt:MouseEvent) : void
      {
         if(!this._isActive)
         {
            return;
         }
         this._curMouseY = this._stage.mouseY;
         this._hasMovedYet = false;
         this._acceleration = 0;
         this._isMouseDown = true;
         this._container.addEventListener(Event.ENTER_FRAME,this._onEnterFrame);
         this._stage.addEventListener(MouseEvent.MOUSE_UP,this._onMouseUp);
         this._moveTimer.start();
      }
      
      private function _onEnterFrame(evt:Event) : void
      {
         var difference:Number = NaN;
         if(!this._isActive)
         {
            return;
         }
         var newAcceleration:Number = this._stage.mouseY - this._curMouseY;
         var top:Number = this._fnTop();
         var bottom:Number = this._fnBottom();
         var upperBound:Number = this._fnUpperBound();
         var lowerBound:Number = this._fnLowerBound();
         if(!this._hasMovedYet && Math.abs(newAcceleration) < this._threshold)
         {
            return;
         }
         if(this._isMouseDown)
         {
            this._curMouseY = this._stage.mouseY;
            this._acceleration = newAcceleration;
            this._fnAccelerate(this._acceleration);
            this._offset += this._acceleration;
            this._hasMovedYet = true;
         }
         else
         {
            this._acceleration = Math.abs(this._acceleration) < 1 ? 0 : this._acceleration * (1 - this._friction);
            difference = 0;
            if(top > upperBound)
            {
               difference = upperBound - top;
            }
            else if(top < lowerBound)
            {
               difference = lowerBound - top;
            }
            if(difference < 0 && this._acceleration < 0 || difference > 0 && this._acceleration > 0)
            {
               this._acceleration = 0;
            }
            if(difference != 0)
            {
               if(Math.abs(difference) < 1)
               {
                  if(this._acceleration == 0)
                  {
                     this._container.removeEventListener(Event.ENTER_FRAME,this._onEnterFrame);
                  }
                  this._acceleration += difference;
               }
               else
               {
                  this._acceleration += difference * this._bounceBackConstant;
               }
            }
            else if(this._acceleration == 0)
            {
               this._container.removeEventListener(Event.ENTER_FRAME,this._onEnterFrame);
            }
            this._fnAccelerate(this._acceleration);
            this._offset += this._acceleration;
         }
         if(this._bounceBackConstant == 0)
         {
            bottom = this._fnBottom();
            if(this._offset >= 0)
            {
               newAcceleration = -this._offset;
            }
            else if(bottom <= lowerBound)
            {
               newAcceleration = lowerBound - bottom;
            }
            this._fnAccelerate(newAcceleration);
            this._offset += newAcceleration;
            this._acceleration = 0;
            if(!this._isMouseDown)
            {
               this._container.removeEventListener(Event.ENTER_FRAME,this._onEnterFrame);
            }
         }
      }
      
      private function _onMouseUp(evt:MouseEvent) : void
      {
         if(!this._isActive)
         {
            return;
         }
         this._isMouseDown = false;
         this._stage.removeEventListener(MouseEvent.MOUSE_UP,this._onMouseUp);
         if(!this._hasMovedYet)
         {
            this._container.removeEventListener(Event.ENTER_FRAME,this._onEnterFrame);
         }
      }
      
      public function onMoveTimer(evt:TimerEvent) : void
      {
         if(!this._isActive)
         {
            return;
         }
         this._hasMovedYet = true;
      }
   }
}
