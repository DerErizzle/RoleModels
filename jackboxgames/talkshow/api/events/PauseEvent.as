package jackboxgames.talkshow.api.events
{
   import flash.events.Event;
   
   public class PauseEvent extends Event
   {
      public static const PAUSE:String = "pause";
      
      public static const RESUME:String = "resume";
      
      private var _type:int;
      
      public function PauseEvent(type:String, pauseType:int, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
         this._type = pauseType;
      }
      
      public function get pauseType() : int
      {
         return this._type;
      }
   }
}

