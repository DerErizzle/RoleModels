package jackboxgames.entityinteraction
{
   import flash.events.Event;
   
   public class EntityUpdatedEvent extends Event
   {
      public static const EVENT_UPDATED:String = "updated";
      
      private var _oldValue:*;
      
      private var _newValue:*;
      
      public function EntityUpdatedEvent(oldValue:*, newValue:*)
      {
         super(EVENT_UPDATED,false,false);
         this._oldValue = oldValue;
         this._newValue = newValue;
      }
      
      public function get oldValue() : *
      {
         return this._oldValue;
      }
      
      public function get newValue() : *
      {
         return this._newValue;
      }
   }
}

