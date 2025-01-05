package jackboxgames.rolemodels.utils
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class SubmissionTimer
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _tf:ExtendableTextField;
      
      private var _timeLeft:Duration;
      
      private var _totalTime:Duration;
      
      private var _lastWholeNumber:Number;
      
      private var _lastSetNumber:Number;
      
      private var _isStarted:Boolean;
      
      private var _doneFn:Function;
      
      public function SubmissionTimer(mc:MovieClip)
      {
         super();
         this._shower = new MovieClipShower(mc);
         this._mc = mc.timer;
         this._tf = new ExtendableTextField(this._mc.tf,[],[]);
         this._timeLeft = Duration.ZERO;
         this._totalTime = Duration.ZERO;
         this._isStarted = false;
         this._doneFn = Nullable.NULL_FUNCTION;
      }
      
      public function get shower() : MovieClipShower
      {
         return this._shower;
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._mc,"Park");
         this._shower.reset();
         this.stop();
      }
      
      private function _startAnimation() : void
      {
         if(this._lastWholeNumber != this._lastSetNumber)
         {
            this._setVisuals(null);
         }
         this._lastWholeNumber = Math.floor(this._timeLeft.inSec);
         JBGUtil.gotoFrame(this._mc,"Tick");
      }
      
      private function _setVisuals(evt:MovieClipEvent) : void
      {
         this._lastSetNumber = this._lastWholeNumber;
         this._tf.text = String(Math.floor(this._lastSetNumber));
      }
      
      public function setup(time:Duration) : void
      {
         this._timeLeft = time.clone();
         this._totalTime = time.clone();
         this._lastWholeNumber = Math.floor(this._timeLeft.inSec);
         this._setVisuals(null);
         JBGUtil.gotoFrame(this._mc,"Idle");
      }
      
      public function start(doneFn:Function) : void
      {
         if(this._isStarted)
         {
            doneFn();
            return;
         }
         this._isStarted = true;
         this._doneFn = doneFn;
         this._mc.addEventListener(MovieClipEvent.EVENT_TRIGGER,this._setVisuals);
         TickManager.instance.addEventListener(TickManager.EVENT_TICK,this._onTick);
      }
      
      public function stop() : void
      {
         if(!this._isStarted)
         {
            return;
         }
         this._mc.removeEventListener(MovieClipEvent.EVENT_TRIGGER,this._setVisuals);
         TickManager.instance.removeEventListener(TickManager.EVENT_TICK,this._onTick);
         this._isStarted = false;
         this._doneFn = Nullable.NULL_FUNCTION;
         JBGUtil.gotoFrame(this._mc,"Idle");
      }
      
      private function _onTick(evt:EventWithData) : void
      {
         this._timeLeft = Duration.sub(this._timeLeft,evt.data.elapsed);
         if(this._timeLeft.inSec <= 0)
         {
            GameState.instance.audioRegistrationStack.play("TimeExpired");
            this._timeLeft = Duration.ZERO;
            this._setVisuals(null);
            this._doneFn();
            this.stop();
         }
         if(Math.floor(this._timeLeft.inSec) != this._lastWholeNumber)
         {
            this._startAnimation();
            if(this._lastWholeNumber < 5)
            {
               GameState.instance.audioRegistrationStack.play("TimerWarning");
            }
         }
      }
   }
}
