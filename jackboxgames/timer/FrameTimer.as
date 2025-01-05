package jackboxgames.timer
{
   import flash.events.Event;
   import flash.events.TimerEvent;
   import jackboxgames.engine.GameEngine;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class FrameTimer extends PausableEventDispatcher implements IJBGTimer
   {
       
      
      private var _delay:uint;
      
      private var _repeatCount:uint;
      
      private var _currentCount:uint;
      
      private var _frameCount:uint;
      
      private var _running:Boolean;
      
      public function FrameTimer(delay:int, repeatCount:uint = 0)
      {
         this._delay = delay;
         this._frameCount = 0;
         this._repeatCount = repeatCount;
         this._currentCount = 0;
         this._running = false;
         super();
      }
      
      public function get currentCount() : int
      {
         return this._currentCount;
      }
      
      public function get delay() : Number
      {
         return this._delay;
      }
      
      public function set delay(value:Number) : void
      {
         this._delay = value;
      }
      
      public function get repeatCount() : int
      {
         return this._repeatCount;
      }
      
      public function set repeatCount(value:int) : void
      {
         this._repeatCount = value;
      }
      
      public function get running() : Boolean
      {
         return this._running;
      }
      
      public function reset() : void
      {
         this._currentCount = 0;
         this.stop();
      }
      
      public function start() : void
      {
         if(!this._running)
         {
            this._running = true;
            this._frameCount = 0;
            GameEngine.instance.activeGame.main.addEventListener(Event.ENTER_FRAME,this._frameHandler);
            TimerUtil.addTimer(this);
         }
      }
      
      public function stop() : void
      {
         GameEngine.instance.activeGame.main.removeEventListener(Event.ENTER_FRAME,this._frameHandler);
         this._running = false;
         TimerUtil.removeTimer(this);
      }
      
      public function pause() : void
      {
         GameEngine.instance.activeGame.main.removeEventListener(Event.ENTER_FRAME,this._frameHandler);
      }
      
      public function resume() : void
      {
         GameEngine.instance.activeGame.main.addEventListener(Event.ENTER_FRAME,this._frameHandler);
      }
      
      private function _frameHandler(evt:Event) : void
      {
         ++this._frameCount;
         if(this._frameCount >= this._delay)
         {
            this._frameCount = 0;
            dispatchEvent(new TimerEvent(TimerEvent.TIMER));
            ++this._currentCount;
            if(this._repeatCount == 0 || this._currentCount == this._repeatCount)
            {
               dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
               if(this._repeatCount > 0)
               {
                  this.stop();
               }
            }
         }
      }
   }
}
