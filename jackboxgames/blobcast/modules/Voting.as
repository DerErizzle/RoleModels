package jackboxgames.blobcast.modules
{
   import jackboxgames.events.EventWithData;
   import jackboxgames.logger.Logger;
   import jackboxgames.nativeoverride.BlobCast;
   import jackboxgames.utils.Duration;
   import jackboxgames.utils.JBGUtil;
   import jackboxgames.utils.Nullable;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class Voting extends PausableEventDispatcher implements ISessionModule
   {
      
      private static const MODULE_NAME:String = "vote";
      
      private static const TIMEOUT_DURATION:Number = 7;
       
      
      private var _name:String;
      
      private var _lastVotesSeen:Object;
      
      private var _timeoutCancellor:Function;
      
      private var _startCancellor:Function;
      
      private var _stopCancellor:Function;
      
      public function Voting(name:String)
      {
         super();
         this._name = name;
         this._timeoutCancellor = Nullable.NULL_FUNCTION;
         this._startCancellor = Nullable.NULL_FUNCTION;
         this._stopCancellor = Nullable.NULL_FUNCTION;
      }
      
      public function get moduleId() : String
      {
         return MODULE_NAME + "_" + this._name;
      }
      
      public function get votes() : Object
      {
         return this._lastVotesSeen;
      }
      
      public function reset() : void
      {
         this._lastVotesSeen = 0;
         this._timeoutCancellor();
         this._timeoutCancellor = Nullable.NULL_FUNCTION;
         this._startCancellor();
         this._startCancellor = Nullable.NULL_FUNCTION;
         this._stopCancellor();
         this._stopCancellor = Nullable.NULL_FUNCTION;
      }
      
      public function start(options:Object, doneFn:Function) : void
      {
         this.reset();
         this._startCancellor = JBGUtil.eventOnce(this,BlobCast.EVENT_START_SESSION_RESULT,function(evt:EventWithData):void
         {
            _startCancellor = Nullable.NULL_FUNCTION;
            doneFn(evt.data);
         });
         BlobCast.instance.startSession(MODULE_NAME,this._name,options);
      }
      
      public function stop(options:Object, doneFn:Function) : void
      {
         this._stopCancellor = JBGUtil.eventOnce(this,BlobCast.EVENT_STOP_SESSION_RESULT,function(evt:EventWithData):void
         {
            _timeoutCancellor();
            _timeoutCancellor = Nullable.NULL_FUNCTION;
            _stopCancellor = Nullable.NULL_FUNCTION;
            doneFn(evt.data);
         });
         this._timeoutCancellor = JBGUtil.runFunctionAfter(function():void
         {
            Logger.debug("Voting::stop timeout tripped.");
            _stopCancellor();
            _stopCancellor = Nullable.NULL_FUNCTION;
            _timeoutCancellor = Nullable.NULL_FUNCTION;
            doneFn({});
         },Duration.fromSec(TIMEOUT_DURATION));
         BlobCast.instance.stopSession(MODULE_NAME,this._name,options);
      }
      
      public function getStatus(options:Object, doneFn:Function) : void
      {
         JBGUtil.eventOnce(this,BlobCast.EVENT_GET_SESSION_STATUS_RESULT,function(evt:EventWithData):void
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
         dispatchEvent(new EventWithData(BlobCast.EVENT_STOP_SESSION_RESULT,result.response));
      }
      
      public function onGetStatusResult(result:Object) : void
      {
         if(Boolean(result.success))
         {
            this._lastVotesSeen = result.response;
            dispatchEvent(new EventWithData(BlobCast.EVENT_GET_SESSION_STATUS_RESULT,this._lastVotesSeen));
         }
      }
      
      public function onSendMessageResult(result:Object) : void
      {
         dispatchEvent(new EventWithData(BlobCast.EVENT_SEND_SESSION_MESSAGE_RESULT,result));
      }
   }
}
