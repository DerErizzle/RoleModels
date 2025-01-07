package jackboxgames.thewheel.audience
{
   import flash.events.Event;
   import jackboxgames.entityinteraction.IEntity;
   
   public class AudienceEntityUpdatedEvent extends Event
   {
      public static const EVENT_UPDATED:String = "updated";
      
      private var _key:String;
      
      private var _entity:IEntity;
      
      private var _oldValue:*;
      
      private var _newValue:*;
      
      public function AudienceEntityUpdatedEvent(key:String, e:IEntity, oldValue:*, newValue:*)
      {
         super(EVENT_UPDATED,false,false);
         this._key = key;
         this._entity = e;
         this._oldValue = oldValue;
         this._newValue = newValue;
      }
      
      public function get key() : String
      {
         return this._key;
      }
      
      public function get entity() : IEntity
      {
         return this._entity;
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

