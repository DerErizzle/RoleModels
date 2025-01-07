package jackboxgames.events
{
   import flash.events.Event;
   
   public class EventWithData extends Event
   {
      private var _data:*;
      
      public function EventWithData(type:String, data:*)
      {
         super(type,false,false);
         this._data = data;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

