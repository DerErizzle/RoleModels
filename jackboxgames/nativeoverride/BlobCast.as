package jackboxgames.nativeoverride
{
   import flash.external.ExternalInterface;
   import jackboxgames.events.*;
   import jackboxgames.utils.*;
   
   public class BlobCast extends PausableEventDispatcher
   {
      
      public static const EVENT_CREATE_ROOM_RESULT:String = "BlobCast.CreateRoomResult";
      
      public static const EVENT_JOIN_ROOM_RESULT:String = "BlobCast.JoinRoomResult";
      
      public static const EVENT_DISCONNECTED:String = "BlobCast.Disconnected";
      
      public static const EVENT_ROOM_DESTROYED:String = "BlobCast.RoomDestroyed";
      
      public static const EVENT_LOCK_ROOM_RESULT:String = "BlobCast.LockRoomResult";
      
      public static const EVENT_CUSTOMER_JOINED_ROOM:String = "BlobCast.CustomerJoinedRoom";
      
      public static const EVENT_CUSTOMER_REJOINED_ROOM:String = "BlobCast.CustomerRejoinedRoom";
      
      public static const EVENT_CUSTOMER_LEFT_ROOM:String = "BlobCast.CustomerLeftRoom";
      
      public static const EVENT_CUSTOMER_SENT_MESSAGE:String = "BlobCast.CustomerSentMessage";
      
      public static const EVENT_OWNER_CHANGED_USER_BLOB:String = "BlobCast.OwnerChangedUserBlob";
      
      public static const EVENT_OWNER_CHANGED_ROOM_BLOB:String = "BlobCast.OwnerChangedRoomBlob";
      
      public static const EVENT_START_SESSION_RESULT:String = "BlobCast.StartSessionResult";
      
      public static const EVENT_STOP_SESSION_RESULT:String = "BlobCast.StopSessionResult";
      
      public static const EVENT_GET_SESSION_STATUS_RESULT:String = "BlobCast.GetSessionStatusResult";
      
      public static const EVENT_SEND_SESSION_MESSAGE_RESULT:String = "BlobCast.SendSessionMessageResult";
      
      public static const EVENT_RETRY_CONNECTION:String = "BlobCast.RetryConnection";
      
      public static var BLOBCAST_SERVER:String;
      
      public static var BLOBCAST_APP_ID:String;
      
      private static var _instance:BlobCast;
       
      
      private var _analytics:Array;
      
      private var _uaAppName:String;
      
      private var _uaAppVersion:String;
      
      private var _uaAppId:String;
      
      private var _userId:String;
      
      public var getUserIdNative:Function = null;
      
      public var setLicenseNative:Function = null;
      
      public var disconnectFromServiceNative:Function = null;
      
      public var createRoomNative:Function = null;
      
      public var joinRoomNative:Function = null;
      
      public var lockRoomNative:Function = null;
      
      public var setRoomBlobNative:Function = null;
      
      public var setCustomerBlobNative:Function = null;
      
      public var sendMessageToRoomOwnerNative:Function = null;
      
      public var startSessionNative:Function = null;
      
      public var stopSessionNative:Function = null;
      
      public var getSessionStatusNative:Function = null;
      
      public var sendSessionMessageNative:Function = null;
      
      public function BlobCast()
      {
         super();
         if(!EnvUtil.isAIR())
         {
            ExternalInterface.call("InitializeNativeOverride","BlobCast",this);
         }
         this._analytics = [];
      }
      
      public static function Initialize(server:String = null, appId:String = null) : void
      {
         BLOBCAST_SERVER = server;
         BLOBCAST_APP_ID = appId;
      }
      
      public static function get instance() : BlobCast
      {
         if(!_instance)
         {
            _instance = new BlobCast();
         }
         return _instance;
      }
      
      public function get UserId() : String
      {
         if(this._userId != null)
         {
            return this._userId;
         }
         if(this.getUserIdNative == null)
         {
            return "None";
         }
         this._userId = this.getUserIdNative();
         return this._userId;
      }
      
      public function setLicense(license:String) : void
      {
         if(this.setLicenseNative != null)
         {
            this.setLicenseNative(license);
         }
      }
      
      public function disconnectFromService() : void
      {
         if(this.disconnectFromServiceNative != null)
         {
            this.disconnectFromServiceNative();
         }
      }
      
      public function createRoom(options:Object = null) : void
      {
         if(this.createRoomNative != null)
         {
            this.createRoomNative(BLOBCAST_SERVER,BLOBCAST_APP_ID,options);
         }
      }
      
      public function joinRoom(roomId:String, name:String) : void
      {
         if(this.joinRoomNative != null)
         {
            this.joinRoomNative(BLOBCAST_SERVER,BLOBCAST_APP_ID,roomId,name);
         }
      }
      
      public function lockRoom() : void
      {
         if(this.lockRoomNative != null)
         {
            this.lockRoomNative();
         }
      }
      
      public function setRoomBlob(blob:Object) : void
      {
         if(this._analytics != null && this._analytics.length > 0)
         {
            blob.analytics = this._analytics;
         }
         this._analytics = [];
         if(this.setRoomBlobNative != null)
         {
            this.setRoomBlobNative(blob);
         }
         delete blob.analytics;
      }
      
      public function setCustomerBlob(customerUserId:String, blob:Object) : void
      {
         if(this.setCustomerBlobNative != null)
         {
            this.setCustomerBlobNative(customerUserId,blob);
         }
      }
      
      public function sendMessageToRoomOwner(message:Object) : void
      {
         if(this.sendMessageToRoomOwnerNative != null)
         {
            this.sendMessageToRoomOwnerNative(message);
         }
      }
      
      public function startSession(module:String, name:String, options:Object) : void
      {
         if(this.startSessionNative != null)
         {
            this.startSessionNative(module,name,options);
         }
      }
      
      public function stopSession(module:String, name:String, options:Object) : void
      {
         if(this.stopSessionNative != null)
         {
            this.stopSessionNative(module,name,options);
         }
      }
      
      public function getSessionStatus(module:String, name:String, options:Object) : void
      {
         if(this.getSessionStatusNative != null)
         {
            this.getSessionStatusNative(module,name,options);
         }
      }
      
      public function sendSessionMessage(module:String, name:String, message:Object) : void
      {
         if(this.sendSessionMessageNative != null)
         {
            this.sendSessionMessageNative(module,name,message);
         }
      }
      
      public function onRoomCreated(roomId:String) : void
      {
         dispatchEvent(new EventWithData(EVENT_CREATE_ROOM_RESULT,roomId));
      }
      
      public function onFailedToCreateRoom() : void
      {
         dispatchEvent(new EventWithData(EVENT_CREATE_ROOM_RESULT,null));
      }
      
      public function onJoinedRoom(roomData:Object) : void
      {
         dispatchEvent(new EventWithData(EVENT_JOIN_ROOM_RESULT,roomData));
      }
      
      public function onFailedToJoinRoom() : void
      {
         dispatchEvent(new EventWithData(EVENT_JOIN_ROOM_RESULT,null));
      }
      
      public function onRoomLocked() : void
      {
         dispatchEvent(new EventWithData(EVENT_LOCK_ROOM_RESULT,true));
      }
      
      public function onFailedToLockRoom() : void
      {
         dispatchEvent(new EventWithData(EVENT_LOCK_ROOM_RESULT,false));
      }
      
      public function onDisconnectedFromService(error:String) : void
      {
         dispatchEvent(new EventWithData(EVENT_DISCONNECTED,{"error":error}));
      }
      
      public function onRoomDestroyed() : void
      {
         dispatchEvent(new EventWithData(EVENT_ROOM_DESTROYED,null));
      }
      
      public function onCustomerJoinedRoom(userId:String, name:String, options:Object = null) : void
      {
         dispatchEvent(new EventWithData(EVENT_CUSTOMER_JOINED_ROOM,{
            "userId":userId,
            "name":name,
            "options":options
         }));
      }
      
      public function onCustomerRejoinedRoom(userId:String, name:String, options:Object = null) : void
      {
         dispatchEvent(new EventWithData(EVENT_CUSTOMER_REJOINED_ROOM,{
            "userId":userId,
            "name":name,
            "options":options
         }));
      }
      
      public function onCustomerLeftRoom(userId:String) : void
      {
         dispatchEvent(new EventWithData(EVENT_CUSTOMER_LEFT_ROOM,{"userId":userId}));
      }
      
      public function onCustomerSentMessage(userId:String, message:Object) : void
      {
         dispatchEvent(new EventWithData(EVENT_CUSTOMER_SENT_MESSAGE,{
            "userId":userId,
            "message":message
         }));
      }
      
      public function onOwnerChangedUserBlob(blob:Object) : void
      {
         dispatchEvent(new EventWithData(EVENT_OWNER_CHANGED_USER_BLOB,blob));
      }
      
      public function onOwnerChangedRoomBlob(blob:Object) : void
      {
         dispatchEvent(new EventWithData(EVENT_OWNER_CHANGED_ROOM_BLOB,blob));
      }
      
      public function onStartSessionResult(success:Boolean, module:String, name:String, response:Object) : void
      {
         dispatchEvent(new EventWithData(EVENT_START_SESSION_RESULT,{
            "success":success,
            "module":module,
            "name":name,
            "response":response
         }));
      }
      
      public function onStopSessionResult(success:Boolean, module:String, name:String, response:Object) : void
      {
         dispatchEvent(new EventWithData(EVENT_STOP_SESSION_RESULT,{
            "success":success,
            "module":module,
            "name":name,
            "response":response
         }));
      }
      
      public function onGetSessionStatusResult(success:Boolean, module:String, name:String, response:Object) : void
      {
         dispatchEvent(new EventWithData(EVENT_GET_SESSION_STATUS_RESULT,{
            "success":success,
            "module":module,
            "name":name,
            "response":response
         }));
      }
      
      public function onSendSessionMessageResult(success:Boolean, module:String, name:String, response:Object) : void
      {
         dispatchEvent(new EventWithData(EVENT_SEND_SESSION_MESSAGE_RESULT,{
            "success":success,
            "module":module,
            "name":name,
            "response":response
         }));
      }
      
      public function uaSetup(appName:String, appId:String, appVersion:String) : void
      {
         this._uaAppName = appName;
         this._uaAppId = appId;
         this._uaAppVersion = appVersion;
      }
      
      public function uaEvent(eventCategory:String, eventAction:String, eventLabel:String = null, eventValue:* = null) : void
      {
         if(!this._uaAppName)
         {
            return;
         }
         var obj:Object = {
            "appname":this._uaAppName,
            "appid":this._uaAppId,
            "appversion":this._uaAppVersion,
            "category":eventCategory,
            "action":eventAction
         };
         if(eventLabel != null)
         {
            obj.label = eventLabel;
         }
         if(eventValue != null)
         {
            obj.value = eventValue;
         }
         this._analytics.push(obj);
      }
      
      public function uaScreen(screenName:String) : void
      {
         if(!this._uaAppName)
         {
            return;
         }
         var obj:Object = {
            "appname":this._uaAppName,
            "appid":this._uaAppId,
            "appversion":this._uaAppVersion,
            "screen":screenName
         };
         this._analytics.push(obj);
      }
   }
}
