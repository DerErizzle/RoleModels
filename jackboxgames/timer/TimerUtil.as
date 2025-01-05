package jackboxgames.timer
{
   import flash.utils.Dictionary;
   import jackboxgames.utils.PausableTimer;
   
   public final class TimerUtil
   {
      
      public static var PAUSABLE_TIMER:Class = PausableTimer;
      
      private static var RUNNING_TIMERS:Dictionary = new Dictionary();
       
      
      public function TimerUtil()
      {
         super();
      }
      
      public static function pauseAll() : void
      {
         var t:* = undefined;
         for(t in RUNNING_TIMERS)
         {
            t.pause();
         }
      }
      
      public static function resumeAll() : void
      {
         var t:* = undefined;
         for(t in RUNNING_TIMERS)
         {
            t.resume();
         }
      }
      
      public static function addTimer(t:IJBGTimer) : void
      {
         RUNNING_TIMERS[t] = true;
      }
      
      public static function removeTimer(t:IJBGTimer) : void
      {
         if(Boolean(RUNNING_TIMERS[t]))
         {
            delete RUNNING_TIMERS[t];
         }
      }
   }
}
