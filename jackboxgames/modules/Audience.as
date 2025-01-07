package jackboxgames.modules
{
   import jackboxgames.ecast.messages.*;
   import jackboxgames.events.*;
   import jackboxgames.model.*;
   import jackboxgames.utils.*;
   
   public class Audience extends PausableEventDispatcher implements IToSimpleObject, ISessionModule
   {
      public static const EVENT_AUDIENCE_COUNT_CHANGED:String = "AudienceCountChanged";
      
      private static const MODULE_NAME:String = "audience";
      
      private var _gs:JBGGameState;
      
      private var _name:String;
      
      private var _lastAudienceCountSeen:int;
      
      private var _maxAudienceCountSeen:int;
      
      public function Audience(gs:JBGGameState, name:String)
      {
         super();
         this._gs = gs;
         this._name = name;
         this._lastAudienceCountSeen = 0;
         this._maxAudienceCountSeen = 0;
      }
      
      public function get moduleId() : String
      {
         return MODULE_NAME + "_" + this._name;
      }
      
      public function get audienceCount() : int
      {
         return this._lastAudienceCountSeen;
      }
      
      public function get maxAudienceCount() : int
      {
         return this._maxAudienceCountSeen;
      }
      
      public function get hasAudienceNow() : Boolean
      {
         return this._lastAudienceCountSeen > 0;
      }
      
      public function reset() : void
      {
         this._lastAudienceCountSeen = 0;
         this._maxAudienceCountSeen = 0;
      }
      
      public function start(options:Object, doneFn:Function) : void
      {
         this.reset();
         doneFn();
      }
      
      public function stop(options:Object, doneFn:Function) : void
      {
         doneFn();
      }
      
      public function getStatus(options:Object, doneFn:Function) : void
      {
         this._gs.client.getAudience().then(function(re:Reply):void
         {
            _lastAudienceCountSeen = re.result.connections;
            _maxAudienceCountSeen = _maxAudienceCountSeen < _lastAudienceCountSeen ? _lastAudienceCountSeen : _maxAudienceCountSeen;
            dispatchEvent(new EventWithData(EVENT_AUDIENCE_COUNT_CHANGED,_lastAudienceCountSeen));
            doneFn(toSimpleObject());
         },function(error:*):void
         {
            doneFn(toSimpleObject());
         });
      }
      
      public function toSimpleObject() : Object
      {
         return {
            "name":this._name,
            "lastAudienceCount":this.audienceCount,
            "maxAudienceCount":this.maxAudienceCount
         };
      }
   }
}

