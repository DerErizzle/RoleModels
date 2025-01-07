package jackboxgames.ecast
{
   import jackboxgames.algorithm.*;
   import jackboxgames.ecast.messages.*;
   import jackboxgames.ecast.messages.client.*;
   import jackboxgames.events.*;
   import jackboxgames.logger.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class WSClient extends PausableEventDispatcher
   {
      public static const EVENT_SOCKET_OPEN:String = "WSClient.SocketOpen";
      
      public static const EVENT_SOCKET_CLOSE:String = "WSClient.SocketClose";
      
      public static const EVENT_SOCKET_ERROR:String = "WSClient.SocketError";
      
      public static const EVENT_NOTIFICATION:String = "WSClient.Notification";
      
      private var _host:String;
      
      private var _code:String;
      
      private var _name:String;
      
      private var _role:String;
      
      private var _userId:String;
      
      private var _token:String;
      
      private var _scheme:String;
      
      private var _password:String;
      
      private var _conn:WebSocket;
      
      private var _id:int;
      
      private var _seq:int;
      
      private var _pending:Object;
      
      private var _elements:Object;
      
      private var _currentArtifactNum:int;
      
      public function WSClient(host:String, code:String, name:String, role:String, userId:String, token:String = null, scheme:String = "wss", password:String = null)
      {
         super();
         this._host = host;
         this._code = code;
         this._name = name;
         this._role = role;
         this._userId = userId;
         this._token = token;
         this._scheme = scheme;
         this._password = password;
         Assert.assert(this._host != null,"unable to create ecast WSClient: no host provided");
         Assert.assert(this._code != null,"unable to create ecast WSClient: no code provided");
         Assert.assert(this._name != null,"unable to create ecast WSClient: no name provided");
         Assert.assert(this._role != "host" || this._token != null,"unable to create ecast WSClient: tried to connect with host role but without host token");
         this._conn = null;
         this._id = -1;
         this._seq = 0;
         this._pending = {};
         this._elements = {};
         this._currentArtifactNum = 0;
      }
      
      private function get _logging() : Boolean
      {
         return BuildConfig.instance.configVal("ecastLogging");
      }
      
      public function connect() : Promise
      {
         var queryParams:Object;
         var url:String;
         var promise:Promise = null;
         var ws:WebSocket = null;
         var hasOpened:Boolean = false;
         promise = new Promise();
         ws = new WebSocket();
         hasOpened = false;
         ws.addEventListener(WebSocket.EVENT_MESSAGE_RECEIVED,function(evt:EventWithData):void
         {
            if(_logging)
            {
               Logger.debug("recv <- " + evt.data.message);
            }
            var res:* = Parse.parseResponseMessage(evt.data.message);
            if(res is Reply)
            {
               _onReply(res);
            }
            else if(res is Notification)
            {
               if(res.result is ClientWelcome)
               {
                  hasOpened = true;
                  _id = res.result.id;
                  _conn = ws;
                  promise.resolve(res);
               }
               _onNotification(res);
            }
            else
            {
               Logger.error("failed to parse response message: " + String(res));
            }
         });
         ws.addEventListener(WebSocket.EVENT_CONNECT_RESULT,function(evt:EventWithData):void
         {
            if(Boolean(evt.data.success))
            {
               dispatchEvent(new EventWithData(EVENT_SOCKET_OPEN,evt.data));
            }
            else
            {
               if(!hasOpened)
               {
                  promise.reject("WebSocket failed to connect");
               }
               dispatchEvent(new EventWithData(EVENT_SOCKET_ERROR,evt.data));
            }
         });
         ws.addEventListener(WebSocket.EVENT_DISCONNECTED,function(evt:EventWithData):void
         {
            if(!hasOpened)
            {
               promise.reject("ecast client failed to open");
            }
            dispatchEvent(new EventWithData(EVENT_SOCKET_CLOSE,{"hasOpened":hasOpened}));
         });
         queryParams = {
            "role":this._role,
            "name":this._name,
            "format":"json",
            "user-id":this._userId
         };
         if(this._role == "host")
         {
            queryParams["host-token"] = this._token;
         }
         url = "/api/v2/rooms/" + this._code + "/play?" + ObjectUtil.convertToQueryString(queryParams);
         if(this._logging)
         {
            Logger.debug("ws.connect(\"" + this._scheme + "://" + this._host + url + "\"");
         }
         ws.connect(this._host,this._scheme == "wss" ? 443 : 80,url,this._scheme == "wss");
         return promise;
      }
      
      private function _onReply(reply:Reply) : void
      {
         var re:int = reply.re;
         var pending:Object = this._pending[re];
         if(pending == null)
         {
            Logger.error("Reply received that client wasn\'t prepared for, re = " + String(re) + ". result = " + reply.result);
            return;
         }
         delete this._pending[re];
         if(reply.result is CallError)
         {
            pending.reject(reply);
         }
         else
         {
            pending.resolve(reply);
         }
      }
      
      private function _onNotification(notification:Notification) : void
      {
         if(Boolean(notification.result.hasOwnProperty("whenReceived")) && notification.result.whenReceived is Function)
         {
            notification.result.whenReceived(this);
         }
         dispatchEvent(new EventWithData(EVENT_NOTIFICATION,notification));
         dispatchEvent(new EventWithData(notification.opcode,notification));
      }
      
      private function _send(opcode:String, params:Object = null) : Promise
      {
         var seq:int = ++this._seq;
         var req:Request = new Request(seq,opcode,params == null ? {} : params);
         var p:Promise = new Promise();
         this._pending[seq] = {
            "resolve":p.resolve,
            "reject":p.reject,
            "request":req
         };
         var data:String = JSON.serialize({
            "seq":req.seq,
            "opcode":req.opcode,
            "params":req.params
         });
         if(this._logging)
         {
            Logger.debug("send -> " + data);
         }
         if(data == null)
         {
            Logger.error("ERROR: couldn\'t serialize json.");
            Logger.error(TraceUtil.objectRecursive(req.params,"req.params"));
         }
         this._conn.sendMessage(data);
         return p;
      }
      
      public function roomExit() : Promise
      {
         return this._send("room/exit");
      }
      
      public function lockRoom() : Promise
      {
         return this._send("room/lock");
      }
      
      public function drop(key:String) : Promise
      {
         return this._send("drop",{"key":key}).otherwise(function(errorMessage:String):void
         {
            Logger.error("WSClient::drop(\"" + key + "\") failed with error: \"" + errorMessage + "\"");
         });
      }
      
      private function _applyExtraPropertiesAndAcl(o:Object, extraProperties:Object, acl:Array) : void
      {
         if(Boolean(extraProperties))
         {
            ObjectUtil.copyInto(o,extraProperties);
         }
         if(Boolean(acl))
         {
            o.acl = acl;
         }
      }
      
      public function setText(key:String, val:String, acl:Array = null) : Promise
      {
         if(acl == null)
         {
            return this._send("text/set",{
               "key":key,
               "val":val
            });
         }
         return this._send("text/set",{
            "key":key,
            "val":val,
            "acl":acl
         });
      }
      
      public function createText(key:String, val:String, extraProperties:Object = null, acl:Array = null) : Promise
      {
         var createParams:Object = {
            "key":key,
            "val":val
         };
         this._applyExtraPropertiesAndAcl(createParams,extraProperties,acl);
         return this._send("text/create",createParams);
      }
      
      public function updateText(key:String, val:String) : Promise
      {
         return this._send("text/update",{
            "key":key,
            "val":val
         });
      }
      
      public function filterText(val:String, filterProperties:Object) : Promise
      {
         var filterParams:Object = {"val":val};
         ObjectUtil.copyInto(filterParams,filterProperties);
         return this._send("text/filter",filterParams);
      }
      
      public function setObject(key:String, val:Object, acl:Array = null) : Promise
      {
         if(acl == null)
         {
            return this._send("object/set",{
               "key":key,
               "val":val
            });
         }
         return this._send("object/set",{
            "key":key,
            "val":val,
            "acl":acl
         });
      }
      
      public function createObject(key:String, val:Object, extraProperties:Object = null, acl:Array = null) : Promise
      {
         var createParams:Object = {
            "key":key,
            "val":val
         };
         this._applyExtraPropertiesAndAcl(createParams,extraProperties,acl);
         return this._send("object/create",createParams);
      }
      
      public function updateObject(key:String, val:Object) : Promise
      {
         return this._send("object/update",{
            "key":key,
            "val":val
         });
      }
      
      public function kick(id:int) : Promise
      {
         return this._send("client/kick",{"id":id});
      }
      
      public function startAudience() : Promise
      {
         return this._send("room/start-audience");
      }
      
      public function getAudience() : Promise
      {
         return this._send("room/get-audience");
      }
      
      public function createArtifact(categoryId:String, artifact:Object) : Promise
      {
         var key:String = "artifact:" + this._currentArtifactNum;
         ++this._currentArtifactNum;
         return this._send("artifact/create",{
            "key":key,
            "appId":BuildConfig.instance.configVal("gameId"),
            "categoryId":categoryId,
            "blob":artifact
         });
      }
      
      public function createCountGroup(name:String, choices:Array) : Promise
      {
         return this._send("audience/count-group/create",{
            "name":name,
            "options":choices
         });
      }
      
      public function getCountGroup(name:String) : Promise
      {
         return this._send("audience/count-group/get",{"name":name});
      }
      
      public function incrementCountGroupCounter(name:String, choice:String) : Promise
      {
         return this._send("audience/count-group/increment",{
            "name":name,
            "choice":choice
         });
      }
      
      public function createGrowOnlyCounter(key:String, initialCount:int = 0) : Promise
      {
         return this._send("audience/g-counter/create",{
            "key":key,
            "count":initialCount
         });
      }
      
      public function getGrowOnlyCounter(key:String) : Promise
      {
         return this._send("audience/g-counter/get",{"key":key});
      }
      
      public function incrementGrowOnlyCounter(key:String) : Promise
      {
         return this._send("audience/g-counter/increment",{"key":key});
      }
      
      public function createPositiveNegativeCounter(key:String, initialCount:int = 0) : Promise
      {
         return this._send("audience/pn-counter/create",{
            "key":key,
            "count":initialCount
         });
      }
      
      public function getPositiveNegativeCounter(key:String) : Promise
      {
         return this._send("audience/pn-counter/get",{"key":key});
      }
      
      public function incrementPositiveNegativeCounter(key:String) : Promise
      {
         return this._send("audience/pn-counter/increment",{"key":key});
      }
      
      public function decrementPositiveNegativeCounter(key:String) : Promise
      {
         return this._send("audience/pn-counter/decrement",{"key":key});
      }
      
      public function createTextRing(name:String, limit:int) : Promise
      {
         return this._send("audience/text-ring/create",{
            "name":name,
            "limit":limit
         });
      }
      
      public function getTextRing(name:String) : Promise
      {
         return this._send("audience/text-ring/get",{"name":name});
      }
      
      public function pushTextRing(name:String, text:String) : Promise
      {
         return this._send("audience/text-ring/push",{
            "name":name,
            "text":text
         });
      }
      
      public function mail(to:int, msg:String) : Promise
      {
         return this._send("client/send",{
            "from":this._id,
            "to":to,
            "body":msg
         });
      }
      
      public function objectMail(to:int, msg:Object) : Promise
      {
         return this._send("client/send",{
            "from":this._id,
            "to":to,
            "body":msg
         });
      }
      
      public function echo(s:String) : Promise
      {
         return this._send("echo",{"message":s});
      }
      
      public function textEcho(t:String) : Promise
      {
         return this._send("text/echo",{"message":t});
      }
      
      public function objectEcho(o:Object) : Promise
      {
         return this._send("object/echo",{"message":o});
      }
   }
}

