package jackboxgames.events
{
   import flash.events.Event;
   
   public class MovieClipEvent extends Event
   {
      public static const EVENT_APPEAR_DONE:String = "MovieClipEvent.AppearDone";
      
      public static const EVENT_DISAPPEAR_DONE:String = "MovieClipEvent.DisappearDone";
      
      public static const EVENT_CANCEL_DONE:String = "MovieClipEvent.CancelDone";
      
      public static const EVENT_COUNTDOWN_DONE:String = "MovieClipEvent.CountdownDone";
      
      public static const EVENT_ANIMATION_DONE:String = "MovieClipEvent.AnimationDone";
      
      public static const EVENT_TRANSITION_DONE:String = "MovieClipEvent.TransitionDone";
      
      public static const EVENT_TRIGGER:String = "MovieClipEvent.Trigger";
      
      private var _data:*;
      
      public function MovieClipEvent(type:String, data:* = null)
      {
         super(type,true,false);
         this._data = data;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

