package jackboxgames.talkshow.events
{
   import flash.events.Event;
   
   public class PlaybackEngineEvent extends Event
   {
      public static const ENGINE_READY:String = "ready";
      
      public static const CONFIG_FINISHED:String = "config_finished";
      
      public static const USER_PAUSE:String = "user_pause";
      
      public static const USER_RESUME:String = "user_resume";
      
      public static const LOAD_PAUSE:String = "load_pause";
      
      public static const LOAD_RESUME:String = "load_resume";
      
      public var time:uint;
      
      public var msg:String;
      
      public function PlaybackEngineEvent(type:String, timestamp:uint, message:String = "")
      {
         super(type);
         this.time = timestamp;
         this.msg = message;
      }
      
      override public function clone() : Event
      {
         return new PlaybackEngineEvent(type,this.time,this.msg);
      }
      
      override public function toString() : String
      {
         return formatToString("PlaybackEngineEvent","time","msg");
      }
   }
}

