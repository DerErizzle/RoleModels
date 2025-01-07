package jackboxgames.entityinteraction.entities
{
   import flash.utils.getQualifiedClassName;
   import jackboxgames.algorithm.Promise;
   import jackboxgames.ecast.WSClient;
   import jackboxgames.ecast.messages.Notification;
   import jackboxgames.ecast.messages.ObjectElement;
   import jackboxgames.ecast.messages.Reply;
   import jackboxgames.entityinteraction.EntityUpdatedEvent;
   import jackboxgames.entityinteraction.IEntity;
   import jackboxgames.events.EventWithData;
   import jackboxgames.utils.Assert;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class ObjectEntity extends PausableEventDispatcher implements IEntity
   {
      private var _ws:WSClient;
      
      private var _key:String;
      
      private var _defaultValue:Object;
      
      private var _acl:Array;
      
      private var _lastValue:Object;
      
      public function ObjectEntity(ws:WSClient, key:String, defaultValue:Object, acl:Array = null)
      {
         super();
         this._ws = ws;
         this._key = key;
         this._defaultValue = defaultValue;
         this._acl = acl;
      }
      
      public function create() : Promise
      {
         var p:Promise = null;
         p = new Promise();
         this._ws.setObject(this._key,this._defaultValue,this._acl).then(function(res:Reply):void
         {
            _ws.addEventListener("object",_onObjectUpdated);
            p.resolve(true);
         },function(res:Reply):void
         {
            p.reject(false);
         });
         return p;
      }
      
      public function dispose() : Promise
      {
         this._lastValue = null;
         this._ws.removeEventListener("object",this._onObjectUpdated);
         return this._ws.drop(this._key);
      }
      
      public function setValue(val:Object) : Promise
      {
         return this._ws.setObject(this._key,val);
      }
      
      public function getValue() : Object
      {
         return this._lastValue;
      }
      
      private function _onObjectUpdated(evt:EventWithData) : void
      {
         var n:Notification = evt.data;
         var o:ObjectElement = n.result;
         if(o.key != this._key)
         {
            return;
         }
         var previous:Object = this._lastValue;
         this._lastValue = o.val;
         dispatchEvent(new EntityUpdatedEvent(previous,this._lastValue));
      }
      
      public function update(val:*) : Promise
      {
         Assert.assert(getQualifiedClassName(val) == "Object");
         return this.setValue(val);
      }
   }
}

