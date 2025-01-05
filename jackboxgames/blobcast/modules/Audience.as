package jackboxgames.blobcast.modules
{
   import jackboxgames.events.EventWithData;
   import jackboxgames.nativeoverride.BlobCast;
   import jackboxgames.utils.IToSimpleObject;
   import jackboxgames.utils.JBGUtil;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class Audience extends PausableEventDispatcher implements IToSimpleObject, ISessionModule
   {
      
      public static const EVENT_AUDIENCE_COUNT_CHANGED:String = "AudienceCountChanged";
      
      private static const MODULE_NAME:String = "audience";
       
      
      private var _name:String;
      
      private var _lastAudienceCountSeen:int;
      
      private var _maxAudienceCountSeen:int;
      
      public function Audience(name:String)
      {
         super();
         this._name = name;
         this._lastAudienceCountSeen = 0;
         this._maxAudienceCountSeen = 0;
      }
      
      public function get moduleId() : String
      {
         return MODULE_NAME + "_" + this._name;
      }
      
      public function get hasAudienceNow() : Boolean
      {
         return this._lastAudienceCountSeen > 0;
      }
      
      public function get audienceCount() : int
      {
         return this._lastAudienceCountSeen;
      }
      
      public function get maxAudienceCount() : int
      {
         return this._maxAudienceCountSeen;
      }
      
      public function reset() : void
      {
         this._lastAudienceCountSeen = 0;
         this._maxAudienceCountSeen = 0;
         dispatchEvent(new EventWithData(BlobCast.EVENT_GET_SESSION_STATUS_RESULT,this._lastAudienceCountSeen));
      }
      
      public function start(options:Object, doneFn:Function) : void
      {
         this.reset();
         JBGUtil.eventOnce(this,BlobCast.EVENT_START_SESSION_RESULT,function(evt:EventWithData):void
         {
            doneFn(evt.data);
         });
         BlobCast.instance.startSession(MODULE_NAME,this._name,options);
      }
      
      public function stop(options:Object, doneFn:Function) : void
      {
         JBGUtil.eventOnce(this,BlobCast.EVENT_STOP_SESSION_RESULT,function(evt:EventWithData):void
         {
            doneFn(evt.data);
         });
         BlobCast.instance.stopSession(MODULE_NAME,this._name,options);
      }
      
      public function getStatus(options:Object, doneFn:Function) : void
      {
         JBGUtil.eventOnce(this,EVENT_AUDIENCE_COUNT_CHANGED,function(evt:EventWithData):void
         {
            doneFn(evt.data);
         });
         BlobCast.instance.getSessionStatus(MODULE_NAME,this._name,options);
      }
      
      public function sendMessage(message:Object, doneFn:Function) : void
      {
         JBGUtil.eventOnce(this,BlobCast.EVENT_SEND_SESSION_MESSAGE_RESULT,function(evt:EventWithData):void
         {
            doneFn(evt.data);
         });
         BlobCast.instance.sendSessionMessage(MODULE_NAME,this._name,message);
      }
      
      public function onStartResult(result:Object) : void
      {
         dispatchEvent(new EventWithData(BlobCast.EVENT_START_SESSION_RESULT,result));
      }
      
      public function onStopResult(result:Object) : void
      {
         dispatchEvent(new EventWithData(BlobCast.EVENT_STOP_SESSION_RESULT,result));
      }
      
      public function onGetStatusResult(result:Object) : void
      {
         if(Boolean(result.success))
         {
            this._lastAudienceCountSeen = result.response.count;
            this._maxAudienceCountSeen = this._maxAudienceCountSeen < this._lastAudienceCountSeen ? this._lastAudienceCountSeen : this._maxAudienceCountSeen;
            dispatchEvent(new EventWithData(EVENT_AUDIENCE_COUNT_CHANGED,this._lastAudienceCountSeen));
         }
      }
      
      public function onSendMessageResult(result:Object) : void
      {
         dispatchEvent(new EventWithData(BlobCast.EVENT_SEND_SESSION_MESSAGE_RESULT,result));
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
