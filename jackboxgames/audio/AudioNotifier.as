package jackboxgames.audio
{
   import jackboxgames.events.AudioNotificationEvent;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class AudioNotifier extends PausableEventDispatcher
   {
      private static var _instance:AudioNotifier;
      
      public function AudioNotifier()
      {
         super();
      }
      
      public static function Initialize() : void
      {
         _instance = new AudioNotifier();
      }
      
      public static function get instance() : AudioNotifier
      {
         return _instance;
      }
      
      public function notifyStartAudio(id:String, category:String, text:String, metadata:Object) : void
      {
         dispatchEvent(new AudioNotificationEvent(AudioNotificationEvent.AUDIO_STARTED,id,category,text,metadata));
      }
      
      public function notifyEndAudio(id:String) : void
      {
         dispatchEvent(new AudioNotificationEvent(AudioNotificationEvent.AUDIO_ENDED,id));
      }
   }
}

