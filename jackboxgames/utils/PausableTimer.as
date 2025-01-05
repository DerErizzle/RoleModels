package jackboxgames.utils
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import jackboxgames.nativeoverride.Platform;
   import jackboxgames.timer.IJBGTimer;
   import jackboxgames.timer.TimerUtil;
   
   public class PausableTimer extends Timer implements IJBGTimer
   {
       
      
      private var _isPaused:Boolean;
      
      private var _startTime:uint;
      
      private var _elapsedTime:uint;
      
      private var _expired:Boolean;
      
      protected var _targetDelay:Number;
      
      public function PausableTimer(delay:Number, repeatCount:int = 0)
      {
         this._targetDelay = delay;
         super(delay,repeatCount);
         this._isPaused = false;
         this._expired = false;
      }
      
      public function get elapsedTime() : Number
      {
         if(this._isPaused)
         {
            return this._elapsedTime;
         }
         if(this._startTime == 0)
         {
            return 0;
         }
         return Platform.instance.getTimer() - this._startTime;
      }
      
      public function get remainingTime() : Number
      {
         return this._targetDelay - this.elapsedTime;
      }
      
      public function get targetDelay() : Number
      {
         return this._targetDelay;
      }
      
      public function get expired() : Boolean
      {
         return this._expired;
      }
      
      override public function start() : void
      {
         this._startTime = Platform.instance.getTimer();
         this._expired = false;
         TimerUtil.addTimer(this);
         super.start();
         this.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete,false,int.MAX_VALUE);
      }
      
      override public function stop() : void
      {
         super.stop();
      }
      
      override public function reset() : void
      {
         this.stop();
         TimerUtil.removeTimer(this);
         this.removeEventListener(TimerEvent.TIMER,this.onTimer);
         this.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete);
         super.reset();
      }
      
      public function isPaused() : Boolean
      {
         return this._isPaused;
      }
      
      public function pause() : void
      {
         if(!running)
         {
            return;
         }
         this._elapsedTime = Platform.instance.getTimer() - this._startTime;
         this._isPaused = true;
         super.stop();
      }
      
      public function resume() : void
      {
         if(!this._isPaused)
         {
            return;
         }
         var currentTime:int = int(Platform.instance.getTimer());
         this._startTime = currentTime - this._elapsedTime;
         delay = Math.max(1,Math.min(this._targetDelay,this._targetDelay - this._elapsedTime));
         this._isPaused = false;
         super.start();
      }
      
      private function onTimer(evt:TimerEvent) : void
      {
         this._startTime = Platform.instance.getTimer();
         if(delay != this._targetDelay)
         {
            delay = this._targetDelay;
         }
      }
      
      private function onTimerComplete(evt:TimerEvent) : void
      {
         this._expired = true;
      }
   }
}
