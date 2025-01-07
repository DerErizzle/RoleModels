package jackboxgames.entityinteraction.entities
{
   import flash.utils.getQualifiedClassName;
   import jackboxgames.algorithm.Promise;
   import jackboxgames.ecast.EcastUtil;
   import jackboxgames.ecast.WSClient;
   import jackboxgames.ecast.messages.CallError;
   import jackboxgames.ecast.messages.Notification;
   import jackboxgames.ecast.messages.Reply;
   import jackboxgames.ecast.messages.TextElement;
   import jackboxgames.entityinteraction.EntityUpdatedEvent;
   import jackboxgames.entityinteraction.IEntity;
   import jackboxgames.events.EventWithData;
   import jackboxgames.utils.Assert;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class TextEntity extends PausableEventDispatcher implements IEntity
   {
      private var _ws:WSClient;
      
      private var _key:String;
      
      private var _defaultValue:String;
      
      private var _filterSetting:String;
      
      private var _acl:Array;
      
      private var _lastValue:String;
      
      public function TextEntity(ws:WSClient, key:String, defaultValue:String, filterSetting:String, acl:Array = null)
      {
         super();
         this._ws = ws;
         this._key = key;
         this._defaultValue = defaultValue;
         this._filterSetting = filterSetting;
         this._acl = acl;
      }
      
      public function create() : Promise
      {
         var p:Promise = null;
         p = new Promise();
         this._ws.createText(this._key,this._defaultValue,EcastUtil.getExtraCreateParamsForContentFilter(this._filterSetting),this._acl).then(function(res:Reply):void
         {
            _ws.addEventListener("text",_onTextUpdated);
            p.resolve(true);
         },function(res:Reply):void
         {
            if(res.result is CallError && CallError(res.result).error == CallError.ECAST_ERROR_ENTITY_ALREADY_EXISTS)
            {
               _ws.updateText(_key,_defaultValue).then(function(res:Reply):void
               {
                  p.resolve(true);
               },function(res:Reply):void
               {
                  p.reject(false);
               });
            }
            else
            {
               p.reject(false);
            }
         });
         return p;
      }
      
      public function dispose() : Promise
      {
         this._lastValue = null;
         this._ws.removeEventListener("text",this._onTextUpdated);
         return this._ws.drop(this._key);
      }
      
      public function setValue(val:String) : Promise
      {
         return this._ws.updateText(this._key,val);
      }
      
      public function getValue() : String
      {
         return this._lastValue;
      }
      
      private function _onTextUpdated(evt:EventWithData) : void
      {
         var n:Notification = evt.data;
         var t:TextElement = n.result;
         if(t.key != this._key)
         {
            return;
         }
         var previous:String = this._lastValue;
         this._lastValue = t.text;
         dispatchEvent(new EntityUpdatedEvent(previous,this._lastValue));
      }
      
      public function update(val:*) : Promise
      {
         Assert.assert(getQualifiedClassName(val) == "String");
         return this.setValue(val);
      }
   }
}

