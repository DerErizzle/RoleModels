package jackboxgames.animation.tween
{
   import com.greensock.TweenMax;
   import jackboxgames.events.*;
   import jackboxgames.utils.*;
   
   public class JBGTween extends PausableEventDispatcher
   {
      public static const EVENT_TWEEN_START:String = "start";
      
      public static const EVENT_TWEEN_UPDATE:String = "update";
      
      public static const EVENT_TWEEN_COMPLETE:String = "complete";
      
      private var _target:Object;
      
      private var _tween:TweenMax;
      
      public function JBGTween(target:Object, d:Duration, vars:Object, ease:* = undefined, updateEvents:Boolean = false)
      {
         super();
         this._target = target;
         var varsCopy:Object = JBGUtil.primitiveDeepCopy(vars);
         if(ease)
         {
            varsCopy.ease = ease;
         }
         varsCopy.onStart = this._onStart;
         if(updateEvents)
         {
            varsCopy.onUpdate = this._onUpdate;
         }
         varsCopy.onComplete = this._onComplete;
         this._tween = TweenMax.to(this._target,d.inSec,varsCopy);
      }
      
      public function dispose() : void
      {
         if(Boolean(this._tween))
         {
            this._tween.eventCallback("onStart",null);
            this._tween.eventCallback("onUpdate",null);
            this._tween.eventCallback("onComplete",null);
            this._tween.kill();
            this._tween = null;
         }
      }
      
      public function get target() : Object
      {
         return this._target;
      }
      
      public function get vars() : Object
      {
         return this._tween.vars;
      }
      
      public function get yoyo() : Boolean
      {
         return this._tween.yoyo();
      }
      
      public function set yoyo(val:Boolean) : void
      {
         this._tween.yoyo(val);
      }
      
      public function get reversed() : Boolean
      {
         return this._tween.reversed();
      }
      
      public function set reversed(val:Boolean) : void
      {
         this._tween.reversed(val);
      }
      
      public function reverse(from:* = null, suppressEvents:Boolean = true) : void
      {
         this._tween.reverse(from,suppressEvents);
      }
      
      public function play(from:* = null, suppressEvents:Boolean = true) : void
      {
         this._tween.play(from,suppressEvents);
      }
      
      public function restart(includeDelay:Boolean = false, suppressEvents:Boolean = true) : void
      {
         this._tween.restart(includeDelay,suppressEvents);
      }
      
      public function updateVars(newVars:Object, print:Boolean = false) : void
      {
         this._tween.updateTo(newVars,true);
      }
      
      public function seek(time:*, suppressEvents:Boolean = true) : void
      {
         this._tween.seek(time,suppressEvents);
      }
      
      public function get isActive() : Boolean
      {
         return this._tween.paused();
      }
      
      public function set isActive(val:Boolean) : void
      {
         this._tween.paused(this.isActive);
      }
      
      private function _onStart() : void
      {
         dispatchEvent(new EventWithData(EVENT_TWEEN_START,this));
      }
      
      private function _onUpdate() : void
      {
         dispatchEvent(new EventWithData(EVENT_TWEEN_UPDATE,this));
      }
      
      private function _onComplete() : void
      {
         dispatchEvent(new EventWithData(EVENT_TWEEN_COMPLETE,this));
      }
   }
}

