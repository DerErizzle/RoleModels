package jackboxgames.blobcast.services
{
   import flash.events.Event;
   import jackboxgames.socket.ISocketAdapter;
   import jackboxgames.socket.SocketEvent;
   import jackboxgames.utils.JBGUtil;
   import jackboxgames.utils.Nullable;
   
   public class BlobCastSocketAPI
   {
       
      
      private var _socket:ISocketAdapter;
      
      private var _signingFn:Function;
      
      private var _disconnectFn:Function;
      
      private var _errorFn:Function;
      
      private var _messageFn:Function;
      
      public function BlobCastSocketAPI(socketAdapter:ISocketAdapter)
      {
         super();
         this._disconnectFn = Nullable.NULL_FUNCTION;
         this._errorFn = Nullable.NULL_FUNCTION;
         this._messageFn = Nullable.NULL_FUNCTION;
         this._signingFn = Nullable.NULL_FUNCTION;
         this._socket = socketAdapter;
      }
      
      public function set signingFn(val:Function) : void
      {
         this._signingFn = val;
      }
      
      public function set disconnectFn(val:Function) : void
      {
         this._disconnectFn = val;
      }
      
      public function set errorFn(val:Function) : void
      {
         this._errorFn = val;
      }
      
      public function set messageFn(val:Function) : void
      {
         this._messageFn = val;
      }
      
      public function connect(onSuccess:Function) : void
      {
         JBGUtil.eventOnce(this._socket,SocketEvent.CONNECT,onSuccess);
         this._socket.addEventListener(SocketEvent.DISCONNECT,this.onSocketDisconnect);
         this._socket.addEventListener(SocketEvent.MESSAGE,this.onSocketMessage);
         this._socket.addEventListener(SocketEvent.IO_ERROR,this.onSocketError);
         this._socket.addEventListener(SocketEvent.SECURITY_ERROR,this.onSocketError);
         this._socket.addEventListener("msg",this.onSocketMessage);
         this._socket.connect();
      }
      
      public function disconnect() : void
      {
         if(this._socket != null)
         {
            this._socket.removeEventListener(SocketEvent.DISCONNECT,this.onSocketDisconnect);
            this._socket.removeEventListener(SocketEvent.MESSAGE,this.onSocketMessage);
            this._socket.removeEventListener(SocketEvent.IO_ERROR,this.onSocketError);
            this._socket.removeEventListener(SocketEvent.SECURITY_ERROR,this.onSocketError);
            this._socket.removeEventListener("msg",this.onSocketMessage);
            this._socket.close();
         }
         this._socket = null;
      }
      
      private function onSocketMessage(evt:Event) : void
      {
         if(this._messageFn != null)
         {
            this._messageFn(evt);
         }
      }
      
      private function onSocketDisconnect(evt:Event) : void
      {
         if(this._disconnectFn != null)
         {
            this._disconnectFn(evt);
         }
      }
      
      private function onSocketError(evt:Event) : void
      {
         if(this._errorFn != null)
         {
            this._errorFn(evt);
         }
      }
      
      public function createRoom(userId:String, appId:String, options:Object = null) : void
      {
         this.send(this.createPacket("CreateRoom",{
            "userId":userId,
            "appId":appId,
            "options":options
         }));
      }
      
      public function joinRoom(userId:String, roomId:String, name:String, joinType:String, options:Object = null) : void
      {
         this.send(this.createPacket("JoinRoom",{
            "userId":userId,
            "roomId":roomId,
            "name":name,
            "joinType":joinType,
            "options":options
         }));
      }
      
      public function lockRoom(userId:String, roomId:String) : void
      {
         this.send(this.createPacket("LockRoom",{
            "userId":userId,
            "roomId":roomId
         }));
      }
      
      public function setRoomBlob(userId:String, roomId:String, blob:Object) : void
      {
         this.send(this.createPacket("SetRoomBlob",{
            "userId":userId,
            "roomId":roomId,
            "blob":blob
         }));
      }
      
      public function setCustomerBlob(userId:String, roomId:String, customerUserId:String, blob:Object) : void
      {
         this.send(this.createPacket("SetCustomerBlob",{
            "userId":userId,
            "roomId":roomId,
            "customerUserId":customerUserId,
            "blob":blob
         }));
      }
      
      public function sendMessageToRoomOwner(userId:String, roomId:String, message:Object) : void
      {
         this.send(this.createPacket("SendMessageToRoomOwner",{
            "userId":userId,
            "roomId":roomId,
            "message":message
         }));
      }
      
      public function startSession(userId:String, roomId:String, module:String, name:String, options:Object) : void
      {
         this.send(this.createPacket("StartSession",{
            "userId":userId,
            "roomId":roomId,
            "module":module,
            "name":name,
            "options":options
         }));
      }
      
      public function stopSession(userId:String, roomId:String, module:String, name:String, options:Object) : void
      {
         this.send(this.createPacket("StopSession",{
            "userId":userId,
            "roomId":roomId,
            "module":module,
            "name":name,
            "options":Object
         }));
      }
      
      public function getSessionStatus(userId:String, roomId:String, module:String, name:String, options:Object) : void
      {
         this.send(this.createPacket("GetSessionStatus",{
            "userId":userId,
            "roomId":roomId,
            "module":module,
            "name":name,
            "options":options
         }));
      }
      
      public function sendSessionMessage(userId:String, roomId:String, module:String, name:String, message:Object) : void
      {
         this.send(this.createPacket("SendSessionMessage",{
            "userId":userId,
            "roomId":roomId,
            "module":module,
            "name":name,
            "message":message
         }));
      }
      
      private function send(packet:Object) : void
      {
         this._socket.emit("msg",packet);
      }
      
      private function createPacket(action:String, data:Object = null) : Object
      {
         var packet:Object = Boolean(data) ? data : {};
         packet.type = "Action";
         packet.action = action;
         this._signingFn(packet);
         return packet;
      }
   }
}
