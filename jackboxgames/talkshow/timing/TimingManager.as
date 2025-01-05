package jackboxgames.talkshow.timing
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import jackboxgames.nativeoverride.Platform;
   import jackboxgames.talkshow.actions.ActionRef;
   import jackboxgames.talkshow.api.events.CellEvent;
   import jackboxgames.talkshow.api.events.PauseEvent;
   import jackboxgames.talkshow.core.PlaybackEngine;
   
   public class TimingManager
   {
      
      private static const kRESOLUTION:uint = 33;
       
      
      private var _queue:Array;
      
      private var _timer:Timer;
      
      private var _pauseTime:uint = 0;
      
      private var _pauseStart:uint = 0;
      
      public function TimingManager()
      {
         super();
         this._queue = new Array();
         this._timer = new Timer(kRESOLUTION);
         this._timer.addEventListener(TimerEvent.TIMER,this.check);
         this._timer.start();
         (PlaybackEngine.getInstance().pauser as EventDispatcher).addEventListener(PauseEvent.PAUSE,this.handlePause);
         (PlaybackEngine.getInstance().pauser as EventDispatcher).addEventListener(PauseEvent.RESUME,this.handleResume);
         PlaybackEngine.getInstance().addEventListener(CellEvent.CELL_JUMP,this.handleCellJump);
      }
      
      private function handlePause(evt:Event) : void
      {
         this._pauseStart = Platform.instance.getTimer();
         this._timer.stop();
      }
      
      private function handleResume(evt:Event) : void
      {
         var pauseDuration:uint = uint(Platform.instance.getTimer() - this._pauseStart);
         this._pauseTime += pauseDuration;
         this._timer.start();
      }
      
      private function handleCellJump(evt:CellEvent) : void
      {
         this.clear();
      }
      
      public function get runTime() : uint
      {
         return Platform.instance.getTimer() - this._pauseTime;
      }
      
      public function queueActionRefs(refs:Array, start:Boolean, primary:ActionRef = null) : void
      {
         var duration:uint = 0;
         var timeFromStart:uint = 0;
         var i:int = 0;
         var startNow:Array = new Array();
         var evtTime:uint = this.runTime;
         var ref:ActionRef = null;
         var t:Timing = null;
         var queueTime:uint = 0;
         var timed:TimedItem = null;
         if(start)
         {
            for each(ref in refs)
            {
               t = ref.timing;
               if(t.fromStart || !t.fromStart && t.seconds < 0)
               {
                  if(t.seconds == 0)
                  {
                     ref.start();
                  }
                  else
                  {
                     queueTime = evtTime;
                     if(t.fromStart)
                     {
                        queueTime += t.seconds * 1000;
                     }
                     else
                     {
                        duration = uint(primary.action.actionPackage.actionPackage.getDuration(primary));
                        timeFromStart = duration + t.seconds * 1000;
                        if(timeFromStart < 0)
                        {
                           timeFromStart = 0;
                        }
                        queueTime += timeFromStart;
                     }
                     timed = new TimedItem(ref,queueTime);
                     this._queue.push(timed);
                  }
               }
            }
         }
         else
         {
            for(i = 0; i < this._queue.length; i++)
            {
               timed = this._queue[i];
               if(!timed.ref.timing.fromStart && timed.ref.timing.seconds < 0)
               {
                  this._queue.splice(i,1);
                  timed.ref.start();
                  i--;
               }
            }
            for each(ref in refs)
            {
               t = ref.timing;
               if(!t.fromStart && t.seconds >= 0)
               {
                  if(t.seconds == 0)
                  {
                     ref.start();
                  }
                  else
                  {
                     queueTime = evtTime + t.seconds * 1000;
                     timed = new TimedItem(ref,queueTime);
                     this._queue.push(timed);
                  }
               }
            }
         }
         this.sortQueue();
      }
      
      private function sortQueue() : void
      {
         this._queue.sortOn("time",Array.NUMERIC);
      }
      
      public function check(e:TimerEvent) : void
      {
         var item:TimedItem = null;
         if(this._queue.length > 0)
         {
            while(this._queue.length > 0 && this.runTime >= (this._queue[0] as TimedItem).time)
            {
               item = this._queue.shift();
               item.ref.start();
            }
         }
      }
      
      public function clear() : void
      {
         this._queue = new Array();
      }
   }
}
