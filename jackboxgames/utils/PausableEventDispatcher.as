package jackboxgames.utils
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   
   public class PausableEventDispatcher extends EventDispatcher
   {
      
      private static var PAUSED:Boolean = false;
      
      private static var PAUSED_EVENTS:Array;
       
      
      public function PausableEventDispatcher(target:IEventDispatcher = null)
      {
         super(target);
      }
      
      public static function get isPaused() : Boolean
      {
         return PAUSED;
      }
      
      public static function pauseAll() : void
      {
         PAUSED = true;
         PAUSED_EVENTS = new Array();
      }
      
      public static function resumeAll() : void
      {
         var eventObj:Object = null;
         PAUSED = false;
         while(PAUSED_EVENTS.length > 0)
         {
            eventObj = PAUSED_EVENTS.shift();
            (eventObj.dispatcher as IEventDispatcher).dispatchEvent(eventObj.event as Event);
         }
      }
      
      override public function dispatchEvent(event:Event) : Boolean
      {
         if(PAUSED)
         {
            PAUSED_EVENTS.push({
               "dispatcher":this,
               "event":event
            });
            return false;
         }
         return super.dispatchEvent(event);
      }
      
      public function dispatchEventImmediate(event:Event) : Boolean
      {
         return super.dispatchEvent(event);
      }
   }
}
