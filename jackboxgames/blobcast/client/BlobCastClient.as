package jackboxgames.blobcast.client
{
   import com.adobe.crypto.HMAC;
   import com.adobe.crypto.SHA256;
   import com.laiyonghao.Uuid;
   import jackboxgames.blobcast.services.BlobCastSocketAPI;
   import jackboxgames.blobcast.services.BlobCastWebAPI;
   import jackboxgames.nativeoverride.BlobCast;
   import jackboxgames.socket.SocketEvent;
   import jackboxgames.socket.SocketIOAdapter;
   import jackboxgames.socket.SocketIOJSAdapter;
   import jackboxgames.utils.BuildConfig;
   import jackboxgames.utils.ObjectUtil;
   import jackboxgames.utils.TextUtils;
   
   public class BlobCastClient
   {
      
      protected static const DEFAULT_PROTOCOL:String = "http://";
      
      protected static const DEFAULT_PORT_NUMBER:String = ":38202";
      
      public static const JOIN_TYPE_PLAYER:String = "player";
      
      public static const JOIN_TYPE_AUDIENCE:String = "audience";
      
      protected static var _userId:String;
       
      
      protected var _delegate:BlobCast;
      
      protected var _socketAPI:BlobCastSocketAPI;
      
      protected var _roomData:Object;
      
      protected var _appId:String;
      
      protected var _username:String;
      
      protected var _roomId:String;
      
      protected var _license:String;
      
      public function BlobCastClient(delegate:BlobCast)
      {
         var uuid:Uuid = null;
         super();
         this._delegate = delegate;
         if(_userId == null)
         {
            uuid = new Uuid();
            _userId = uuid.toString();
         }
      }
      
      public function getUserId() : String
      {
         return _userId;
      }
      
      public function setLicense(value:String) : void
      {
         this._license = value;
         if(this._socketAPI != null)
         {
            this._socketAPI.signingFn = this._signPacket;
         }
      }
      
      public function createRoom(server:String, appId:String = null, options:Object = null) : void
      {
         this._appId = appId;
         if(this._roomId != null)
         {
            this._delegate.onFailedToCreateRoom();
            return;
         }
         BlobCastWebAPI.instance.getRoom(function(result:Object):void
         {
            if(ObjectUtil.hasProperties(result,["server"]))
            {
               _roomData = result;
               setupSocketAPI(_roomData.server);
               _socketAPI.connect(function onSuccess():void
               {
                  _socketAPI.createRoom(_userId,_appId,options);
               });
            }
            else
            {
               _delegate.onFailedToCreateRoom();
            }
         });
      }
      
      public function joinRoom(roomId:String, name:String, joinType:String = "player", options:Object = null) : void
      {
         if(this._roomId != null)
         {
            this._delegate.onFailedToJoinRoom();
            return;
         }
         this._username = name;
         BlobCastWebAPI.instance.getRoomById(roomId,function(result:Object):void
         {
            if(ObjectUtil.hasProperties(result,["server"]))
            {
               _roomData = result;
               setupSocketAPI(_roomData.server);
               _socketAPI.connect(function onSuccess():void
               {
                  _socketAPI.joinRoom(_userId,roomId,name,joinType,options);
               });
            }
            else
            {
               _delegate.onFailedToJoinRoom();
            }
         });
      }
      
      public function lockRoom() : void
      {
         if(this._roomId == null)
         {
            return;
         }
         this._socketAPI.lockRoom(_userId,this._roomId);
      }
      
      public function setRoomBlob(blob:Object) : void
      {
         if(this._roomId == null)
         {
            return;
         }
         this._socketAPI.setRoomBlob(_userId,this._roomId,blob);
      }
      
      public function setCustomer(userId:String, blob:Object) : void
      {
         if(this._roomId == null)
         {
            return;
         }
         this._socketAPI.setCustomerBlob(_userId,this._roomId,userId,blob);
      }
      
      public function sendMessageToRoomOwner(message:Object) : void
      {
         if(this._roomId == null)
         {
            return;
         }
         this._socketAPI.sendMessageToRoomOwner(_userId,this._roomId,message);
      }
      
      public function startSession(module:String, name:String, options:Object) : void
      {
         if(this._roomId == null)
         {
            return;
         }
         this._socketAPI.startSession(_userId,this._roomId,module,name,options);
      }
      
      public function stopSession(module:String, name:String, options:Object) : void
      {
         if(this._roomId == null)
         {
            return;
         }
         this._socketAPI.stopSession(_userId,this._roomId,module,name,options);
      }
      
      public function getSessionStatus(module:String, name:String, options:Object) : void
      {
         if(this._roomId == null)
         {
            return;
         }
         this._socketAPI.getSessionStatus(_userId,this._roomId,module,name,options);
      }
      
      public function sendSessionMessage(module:String, name:String, message:Object) : void
      {
         if(this._roomId == null)
         {
            return;
         }
         this._socketAPI.sendSessionMessage(_userId,this._roomId,module,name,message);
      }
      
      public function disconnectFromService() : void
      {
         if(Boolean(this._socketAPI))
         {
            this._socketAPI.disconnect();
         }
         this._roomId = null;
      }
      
      private function _signPacket(packet:Object) : void
      {
         packet.timestamp = new Date().getTime();
         packet.nonce = TextUtils.generateRandomText(16) + "@" + packet.timestamp;
         packet.signature = HMAC.hash(this._license,packet.nonce,SHA256).toLowerCase();
      }
      
      protected function setupSocketAPI(server:String) : void
      {
         if(this._socketAPI != null)
         {
            this._socketAPI.disconnect();
         }
         if(BuildConfig.instance.configVal("platform") == "web")
         {
            this._socketAPI = new BlobCastSocketAPI(new SocketIOJSAdapter(server,DEFAULT_PROTOCOL,DEFAULT_PORT_NUMBER));
         }
         else
         {
            this._socketAPI = new BlobCastSocketAPI(new SocketIOAdapter(server,DEFAULT_PROTOCOL,DEFAULT_PORT_NUMBER));
         }
         if(this._license != null)
         {
            this._socketAPI.signingFn = this._signPacket;
         }
         this._socketAPI.disconnectFn = function onDisconnect(evt:SocketEvent):void
         {
            disconnectFromService();
         };
         this._socketAPI.errorFn = function onError(evt:SocketEvent):void
         {
         };
         this._socketAPI.messageFn = function onMessage(evt:SocketEvent):void
         {
            if(_delegate == null)
            {
               return;
            }
            var msgData:Object = evt.data[0];
            switch(msgData.type)
            {
               case "Result":
                  switch(msgData.action)
                  {
                     case "CreateRoom":
                        if(Boolean(msgData.success))
                        {
                           _roomId = msgData.roomId;
                           _delegate.onRoomCreated(msgData.roomId);
                        }
                        else
                        {
                           _delegate.onFailedToCreateRoom();
                        }
                        break;
                     case "JoinRoom":
                        if(Boolean(msgData.success))
                        {
                           _roomId = msgData.roomId;
                           _appId = msgData.appId;
                           _delegate.onJoinedRoom({
                              "roomId":msgData.roomId,
                              "appId":_appId,
                              "appTag":_roomData.appTag,
                              "name":_username
                           });
                        }
                        else
                        {
                           _delegate.onFailedToJoinRoom();
                        }
                        break;
                     case "LockRoom":
                        if(Boolean(msgData.success))
                        {
                           _delegate.onRoomLocked();
                        }
                        else
                        {
                           _delegate.onFailedToLockRoom();
                        }
                        break;
                     case "StartSession":
                        _delegate.onStartSessionResult(msgData.success,msgData.module,msgData.name,msgData.response);
                        break;
                     case "StopSession":
                        _delegate.onStopSessionResult(msgData.success,msgData.module,msgData.name,msgData.response);
                        break;
                     case "GetSessionStatus":
                        _delegate.onGetSessionStatusResult(msgData.success,msgData.module,msgData.name,msgData.response);
                        break;
                     case "SendSessionMessage":
                        _delegate.onSendSessionMessageResult(msgData.success,msgData.module,msgData.name,msgData.response);
                  }
                  break;
               case "Event":
                  if(_roomId != msgData.roomId)
                  {
                     return;
                  }
                  switch(msgData.event)
                  {
                     case "CustomerJoinedRoom":
                        _delegate.onCustomerJoinedRoom(msgData.customerUserId,msgData.customerName,msgData.options);
                        break;
                     case "CustomerRejoinedRoom":
                        _delegate.onCustomerRejoinedRoom(msgData.customerUserId,msgData.customerName,msgData.options);
                        break;
                     case "CustomerLeftRoom":
                        _delegate.onCustomerLeftRoom(msgData.customerUserId);
                        break;
                     case "CustomerMessage":
                        _delegate.onCustomerSentMessage(msgData.userId,msgData.message);
                        break;
                     case "RoomBlobChanged":
                        _delegate.onOwnerChangedRoomBlob(msgData.blob);
                        break;
                     case "CustomerBlobChanged":
                        _delegate.onOwnerChangedUserBlob(msgData.blob);
                        break;
                     case "RoomDestroyed":
                        _roomId = null;
                        _delegate.onRoomDestroyed();
                  }
                  break;
            }
         };
      }
   }
}
