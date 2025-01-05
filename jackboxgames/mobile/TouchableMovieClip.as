package jackboxgames.mobile
{
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class TouchableMovieClip
   {
       
      
      private var _mc:MovieClip;
      
      private var _stage:Stage;
      
      private var _active:Boolean;
      
      private var _stopPropagation:Boolean;
      
      private var _touchDownFn:Function;
      
      private var _touchUpFn:Function;
      
      private var _touchCancelledFn:Function;
      
      private var _activeTouchWentOutsideFn:Function;
      
      private var _activeTouchWentInsideFn:Function;
      
      private var _overFn:Function;
      
      private var _outFn:Function;
      
      public function TouchableMovieClip(mc:MovieClip, stopPropagation:Boolean = false)
      {
         super();
         this._mc = mc;
         this._stopPropagation = stopPropagation;
         if(Boolean(this._mc.stage))
         {
            this._addListeners();
         }
         else
         {
            this._mc.addEventListener(Event.ADDED_TO_STAGE,this._onAddedToStage);
         }
         this._active = false;
      }
      
      public function set touchDownFn(value:Function) : void
      {
         this._touchDownFn = value;
      }
      
      public function set touchUpFn(value:Function) : void
      {
         this._touchUpFn = value;
      }
      
      public function set touchCancelled(value:Function) : void
      {
         this._touchCancelledFn = value;
      }
      
      public function set activeTouchWentOutsideFn(value:Function) : void
      {
         this._activeTouchWentOutsideFn = value;
      }
      
      public function set activeTouchWentInsideFn(value:Function) : void
      {
         this._activeTouchWentInsideFn = value;
      }
      
      public function set overFn(value:Function) : void
      {
         this._overFn = value;
      }
      
      public function set outFn(value:Function) : void
      {
         this._outFn = value;
      }
      
      public function clear() : void
      {
         this._removeListeners();
      }
      
      private function _addListeners() : void
      {
         this._mc.addEventListener(MouseEvent.MOUSE_DOWN,this._mouseDown);
         if(Boolean(this._mc.stage))
         {
            this._mc.stage.addEventListener(MouseEvent.MOUSE_UP,this._mouseUp);
         }
         this._mc.addEventListener(MouseEvent.MOUSE_OVER,this._mouseOver);
         this._mc.addEventListener(MouseEvent.MOUSE_OUT,this._mouseOut);
      }
      
      private function _removeListeners() : void
      {
         this._mc.removeEventListener(MouseEvent.MOUSE_DOWN,this._mouseDown);
         if(Boolean(this._mc.stage))
         {
            this._mc.stage.removeEventListener(MouseEvent.MOUSE_UP,this._mouseUp);
         }
         this._mc.removeEventListener(MouseEvent.MOUSE_OVER,this._mouseOver);
         this._mc.removeEventListener(MouseEvent.MOUSE_OUT,this._mouseOut);
      }
      
      private function _onAddedToStage(evt:Event) : void
      {
         this._addListeners();
      }
      
      private function _mouseDown(evt:MouseEvent) : void
      {
         this._active = true;
         if(this._touchDownFn != null)
         {
            this._touchDownFn(this._mc);
         }
         if(this._stopPropagation)
         {
            evt.stopImmediatePropagation();
         }
      }
      
      private function _mouseUp(evt:MouseEvent) : void
      {
         if(this._active)
         {
            if(this._touchUpFn != null)
            {
               this._touchUpFn(this._mc,this._mc.hitTestPoint(evt.stageX,evt.stageY));
            }
            if(this._stopPropagation)
            {
               evt.stopImmediatePropagation();
            }
            this._active = false;
         }
      }
      
      private function _mouseOver(evt:MouseEvent) : void
      {
         if(this._active)
         {
            if(this._activeTouchWentInsideFn != null)
            {
               this._activeTouchWentInsideFn(this._mc);
            }
            if(this._stopPropagation)
            {
               evt.stopImmediatePropagation();
            }
         }
         else
         {
            if(this._overFn != null)
            {
               this._overFn(this._mc);
            }
            if(this._stopPropagation)
            {
               evt.stopImmediatePropagation();
            }
         }
      }
      
      private function _mouseOut(evt:MouseEvent) : void
      {
         if(this._active)
         {
            if(this._activeTouchWentOutsideFn != null)
            {
               this._activeTouchWentOutsideFn(this._mc);
            }
            if(this._stopPropagation)
            {
               evt.stopImmediatePropagation();
            }
         }
         else
         {
            if(this._outFn != null)
            {
               this._outFn(this._mc);
            }
            if(this._stopPropagation)
            {
               evt.stopImmediatePropagation();
            }
         }
      }
   }
}
