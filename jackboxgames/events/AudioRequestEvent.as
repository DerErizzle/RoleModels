package jackboxgames.events
{
   import flash.events.Event;
   
   public class AudioRequestEvent extends Event
   {
      public static const PLAY_AUDIO_EVENT:String = "AudioRequestEvent.Play";
      
      private var _eventKey:String;
      
      public function AudioRequestEvent(eventKey:String = null)
      {
         super(PLAY_AUDIO_EVENT,true,false);
         this._eventKey = eventKey;
      }
      
      public function get eventKey() : String
      {
         return this._eventKey;
      }
   }
}

