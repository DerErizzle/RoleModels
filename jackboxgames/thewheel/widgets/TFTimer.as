package jackboxgames.thewheel.widgets
{
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.utils.*;
   
   public class TFTimer
   {
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _tf:ExtendableTextField;
      
      private var _step:Duration;
      
      private var _timeLeft:Duration;
      
      private var _timer:PausableTimer;
      
      private var _stepFn:Function;
      
      private var _doneFn:Function;
      
      public function TFTimer(mc:MovieClip)
      {
         var timerTfMc:MovieClip = null;
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._tf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._getTimerTfMc());
      }
      
      public function get shower() : MovieClipShower
      {
         return this._shower;
      }
      
      public function get timeLeft() : Duration
      {
         return this._timeLeft;
      }
      
      private function _getTimerTfMc() : MovieClip
      {
         if(Boolean(this._mc.container) && Boolean(this._mc.container.timer))
         {
            return this._mc.container.timer;
         }
         if(Boolean(this._mc.timer))
         {
            return this._mc.timer;
         }
         return null;
      }
      
      public function reset() : void
      {
         this._shower.reset();
         this._stepFn = Nullable.NULL_FUNCTION;
         this._doneFn = Nullable.NULL_FUNCTION;
         this.stop();
      }
      
      public function setup(cfg:TimerConfig) : void
      {
         this._timeLeft = cfg.totalDuration.clone();
         this._step = cfg.stepDuration.clone();
         this._setVisuals();
      }
      
      public function start(stepFn:Function, doneFn:Function) : void
      {
         Assert.assert(this._timer == null);
         this._stepFn = stepFn;
         this._doneFn = doneFn;
         if(EnvUtil.isDebug())
         {
            GameState.instance.debug.addEventListener(TheWheelDebug.EVENT_END_TIMER,this._onDebugEndTimer);
         }
         this._timer = new PausableTimer(this._step.inMs);
         this._timer.addEventListener(TimerEvent.TIMER,function(evt:TimerEvent):void
         {
            _timeLeft = Duration.sub(_timeLeft,_step);
            _stepFn(_timeLeft);
            if(_timeLeft.inSec <= 0)
            {
               _timeLeft = new Duration(0);
               _setVisuals();
               _doneFn();
               stop();
            }
            else
            {
               _setVisuals();
            }
         });
         this._timer.start();
      }
      
      public function stop() : void
      {
         if(!this._timer)
         {
            return;
         }
         this._stepFn = Nullable.NULL_FUNCTION;
         this._doneFn = Nullable.NULL_FUNCTION;
         if(EnvUtil.isDebug())
         {
            GameState.instance.debug.removeEventListener(TheWheelDebug.EVENT_END_TIMER,this._onDebugEndTimer);
         }
         this._timer.stop();
         this._timer = null;
      }
      
      private function _onDebugEndTimer(... args) : void
      {
         this._doneFn();
         this.stop();
      }
      
      private function _setVisuals() : void
      {
         this._tf.text = String(Math.ceil(this._timeLeft.inSec));
      }
   }
}

