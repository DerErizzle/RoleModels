package jackboxgames.socket
{
   import com.worlize.websocket.*;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.HTTPStatusEvent;
   import flash.system.Security;
   import jackboxgames.loader.*;
   import jackboxgames.logger.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class SocketIOAdapter extends EventDispatcher implements ISocketAdapter
   {
       
      
      private var _webSocket:WebSocket;
      
      private var ackRegexp:RegExp;
      
      private var ackId:int = 0;
      
      private var acks:Object;
      
      private var _socketURI:String;
      
      private var _socketIOUrl:String;
      
      public function SocketIOAdapter(domain:String, protocol:String, port:String)
      {
         var split:Array = null;
         this.ackRegexp = /(\d+)\+(.*)/;
         this.acks = {};
         super();
         var webSocketProtocal:String = protocol.indexOf("https") >= 0 ? "wss://" : "ws://";
         if(domain.indexOf("://") >= 0)
         {
            split = domain.split("://");
            domain = String(split[1]);
         }
         if(EnvUtil.isAIR())
         {
            Security.loadPolicyFile("xmlsocket://" + domain + ":843");
         }
         this._socketURI = webSocketProtocal + domain + port + "/socket.io/1/flashsocket";
         this._socketIOUrl = protocol + domain + port + "/socket.io/1/";
      }
      
      public function connect() : void
      {
         var v:Object = {"time":new Date().getTime()};
         JBGLoader.instance.postRequest(this._socketIOUrl,v,RequestLoader.OUTGOING_DATA_FORMAT_DEFAULT,function(result:Object):void
         {
            var respData:Array = null;
            var fe:SocketEvent = null;
            if(Boolean(result.success))
            {
               respData = result.data.split(":");
               _socketURI = _socketURI + "/" + respData[0];
               if(_webSocket != null)
               {
                  close();
               }
               _webSocket = new WebSocket(_socketURI,"*");
               _webSocket.addEventListener(WebSocketEvent.CLOSED,onClose);
               _webSocket.addEventListener(WebSocketEvent.MESSAGE,onMessage);
               _webSocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL,onError);
               _webSocket.connect();
            }
            else if(result.error is HTTPStatusEvent)
            {
               if((result.error as HTTPStatusEvent).status != 200)
               {
                  fe = new SocketEvent(SocketEvent.CONNECT_ERROR);
                  dispatchEvent(fe);
               }
            }
         });
      }
      
      public function emit(event:String, msg:Object, callback:Function = null) : void
      {
         this.send(msg,event,callback);
      }
      
      public function close() : void
      {
         if(this._webSocket != null)
         {
            this._webSocket.removeEventListener(WebSocketEvent.CLOSED,this.onClose);
            this._webSocket.removeEventListener(WebSocketEvent.MESSAGE,this.onMessage);
            this._webSocket.removeEventListener(WebSocketErrorEvent.CONNECTION_FAIL,this.onError);
            try
            {
               this._webSocket.close();
            }
            catch(err:Error)
            {
            }
         }
         this._webSocket = null;
      }
      
      private function send(msg:Object, event:String = null, callback:Function = null) : void
      {
         var messageId:String = "";
         var stringifiedMessage:String = "";
         if(null != callback)
         {
            messageId = this.ackId.toString() + "%2B";
            this.acks[this.ackId] = callback;
            ++this.ackId;
         }
         if(event == null)
         {
            if(msg is String)
            {
               this._webSocket.sendUTF("3:" + messageId + "::" + msg as String);
            }
            else
            {
               if(!(msg is Object))
               {
                  throw "Unsupported Message Type";
               }
               stringifiedMessage = JSON.serialize(msg);
               this._webSocket.sendUTF("4:" + messageId + "::" + stringifiedMessage);
            }
         }
         else
         {
            stringifiedMessage = JSON.serialize({
               "name":event,
               "args":msg
            });
            this._webSocket.sendUTF("5:" + messageId + "::" + stringifiedMessage);
         }
      }
      
      private function onClose(event:Event) : void
      {
         var fe:SocketEvent = new SocketEvent(SocketEvent.CLOSE);
         dispatchEvent(fe);
      }
      
      private function onError(event:Event) : void
      {
         var fe:SocketEvent = new SocketEvent(SocketEvent.IO_ERROR);
         dispatchEvent(fe);
      }
      
      private function onMessage(event:Event) : void
      {
         var dm:Object = null;
         var fed:SocketEvent = null;
         var fec:SocketEvent = null;
         var fem:SocketEvent = null;
         var fe:SocketEvent = null;
         var m:Object = null;
         var e:SocketEvent = null;
         var parts:Object = null;
         var id:int = 0;
         var args:Array = null;
         var func:Function = null;
         var message:String = (event as WebSocketEvent).message.utf8Data;
         dm = this.deFrame(message);
         switch(dm.type)
         {
            case "0":
               fed = new SocketEvent(SocketEvent.DISCONNECT);
               dispatchEvent(fed);
               break;
            case "1":
               fec = new SocketEvent(SocketEvent.CONNECT);
               dispatchEvent(fec);
               break;
            case "2":
               this._webSocket.sendUTF("2::");
               break;
            case "3":
               fem = new SocketEvent(SocketEvent.MESSAGE);
               fem.data = dm.msg;
               dispatchEvent(fem);
               break;
            case "4":
               fe = new SocketEvent(SocketEvent.MESSAGE);
               fe.data = JSON.deserialize(dm.msg);
               dispatchEvent(fe);
               break;
            case "5":
               m = JSON.deserialize(dm.msg);
               e = new SocketEvent(m.name);
               e.data = m.args;
               dispatchEvent(e);
               break;
            case "6":
               parts = this.ackRegexp.exec(dm.msg);
               id = int(parts[1]);
               args = JSON.deserialize(parts[2]) as Array;
               if(this.acks.hasOwnProperty(id))
               {
                  func = this.acks[id] as Function;
                  if(args.length > func.length)
                  {
                     func.apply(null,args.slice(0,func.length));
                  }
                  else
                  {
                     func.apply(null,args);
                  }
                  delete this.acks[id];
               }
         }
      }
      
      private function deFrame(message:String) : Object
      {
         var si:int = 0;
         for(var i5:int = 0; i5 < 3; i5++)
         {
            si = message.indexOf(":",si + 1);
         }
         var ds:String = message.substring(si + 1,message.length);
         return {
            "type":message.substr(0,1),
            "msg":ds
         };
      }
   }
}
