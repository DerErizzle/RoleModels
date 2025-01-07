package jackboxgames.events
{
   import flash.events.Event;
   
   public class AudioNotificationEvent extends Event
   {
      public static const AUDIO_STARTED:String = "AudioNotificationEvent.Start";
      
      public static const AUDIO_ENDED:String = "AudioNotificationEvent.End";
      
      private var _id:String;
      
      private var _category:String;
      
      private var _text:String;
      
      private var _metadata:Object;
      
      public function AudioNotificationEvent(type:String, id:String, category:String = null, text:String = null, metadata:Object = null)
      {
         super(type,true,true);
         this._id = id;
         this._category = category;
         this._text = text;
         this._metadata = metadata;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get category() : String
      {
         return this._category;
      }
      
      public function get text() : String
      {
         return this._text;
      }
      
      public function get metadata() : Object
      {
         return this._metadata;
      }
   }
}

