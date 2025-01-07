package jackboxgames.widgets.postgame
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.utils.*;
   
   public class PostGameCountdown
   {
      protected var _mc:MovieClip;
      
      protected var _startCountdownCanceler:Function;
      
      protected var _stopCountdownCanceler:Function;
      
      public function PostGameCountdown(mc:MovieClip)
      {
         this._startCountdownCanceler = Nullable.NULL_FUNCTION;
         this._stopCountdownCanceler = Nullable.NULL_FUNCTION;
         super();
         this._mc = mc;
      }
      
      public function dispose() : void
      {
         this.reset();
         this._mc = null;
      }
      
      protected function _getCountdownMC() : MovieClip
      {
         return this._mc.countDown;
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._getCountdownMC(),"Park");
         this._startCountdownCanceler();
         this._startCountdownCanceler = Nullable.NULL_FUNCTION;
         this._stopCountdownCanceler();
         this._stopCountdownCanceler = Nullable.NULL_FUNCTION;
      }
      
      public function start(doneFn:Function) : void
      {
         this._startCountdownCanceler();
         this._startCountdownCanceler = Nullable.NULL_FUNCTION;
         this._stopCountdownCanceler();
         this._stopCountdownCanceler = Nullable.NULL_FUNCTION;
         this._startCountdownCanceler = JBGUtil.gotoFrameWithFnCancellable(this._getCountdownMC(),"GameStartAppear",MovieClipEvent.EVENT_COUNTDOWN_DONE,doneFn);
      }
      
      public function stop(doneFn:Function) : void
      {
         this._startCountdownCanceler();
         this._startCountdownCanceler = Nullable.NULL_FUNCTION;
         this._stopCountdownCanceler();
         this._stopCountdownCanceler = Nullable.NULL_FUNCTION;
         this._startCountdownCanceler = JBGUtil.gotoFrameWithFnCancellable(this._getCountdownMC(),"GameStartCancel",MovieClipEvent.EVENT_CANCEL_DONE,doneFn);
      }
   }
}

