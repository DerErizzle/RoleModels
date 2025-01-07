package jackboxgames.flash
{
   import com.worlize.websocket.*;
   import flash.events.*;
   import jackboxgames.logger.*;
   
   public final class FlashNativeOverrider
   {
      public function FlashNativeOverrider()
      {
         super();
      }
      
      public static function initializeNativeOverride(type:String, o:Object) : void
      {
         var webSocket:WebSocket = null;
         var connectSuccess:Function = null;
         var connectFailure:Function = null;
         var disconnected:Function = null;
         var messageReceived:Function = null;
         if(type == "JSON")
         {
            o.deserializeNative = function(source:String):*
            {
               var o:* = undefined;
               try
               {
                  o = JSON.parse(source);
                  return o;
               }
               catch(e:Error)
               {
                  return null;
               }
            };
            o.serializeNative = function(stringifyMe:*):String
            {
               var s:String = null;
               try
               {
                  s = JSON.stringify(stringifyMe);
                  return s;
               }
               catch(e:Error)
               {
                  return null;
               }
            };
         }
         else if(type == "WebSocket")
         {
            connectSuccess = function(event:WebSocketEvent):void
            {
               o.onConnectResult(true);
            };
            connectFailure = function(event:WebSocketErrorEvent):void
            {
               o.onConnectResult(false);
            };
            disconnected = function(event:Event):void
            {
               o.onDisconnected();
            };
            messageReceived = function(event:WebSocketEvent):void
            {
               if(event.message.type == WebSocketMessage.TYPE_UTF8)
               {
                  o.onMessageReceived(event.message.utf8Data);
               }
               else
               {
                  Logger.debug("Ignoring WebSocket message of type " + WebSocketMessage.TYPE_BINARY + " from " + webSocket.uri);
               }
            };
            o.connectNative = function(address:String, port:int, path:String, secure:Boolean):void
            {
               var uri:String = secure ? "wss://" : "ws://";
               uri += address + ":" + String(port) + path;
               webSocket = new WebSocket(uri,"*","ecast-v0");
               webSocket.addEventListener(WebSocketEvent.CLOSED,disconnected);
               webSocket.addEventListener(WebSocketErrorEvent.ABNORMAL_CLOSE,disconnected);
               webSocket.addEventListener(WebSocketEvent.MESSAGE,messageReceived);
               webSocket.addEventListener(WebSocketEvent.OPEN,connectSuccess);
               webSocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL,connectFailure);
               webSocket.connect();
            };
            o.disconnectNative = function():void
            {
               if(webSocket != null)
               {
                  webSocket.removeEventListener(WebSocketEvent.CLOSED,disconnected);
                  webSocket.removeEventListener(WebSocketErrorEvent.ABNORMAL_CLOSE,disconnected);
                  webSocket.removeEventListener(WebSocketEvent.MESSAGE,messageReceived);
                  webSocket.removeEventListener(WebSocketEvent.OPEN,connectSuccess);
                  webSocket.removeEventListener(WebSocketErrorEvent.CONNECTION_FAIL,connectFailure);
                  try
                  {
                     webSocket.close();
                  }
                  catch(err:Error)
                  {
                     Logger.error("Error closing WebSocket with uri = " + webSocket.uri);
                     Logger.error("error.name = " + err.name + ", error.message = " + err.message);
                  }
               }
               webSocket = null;
            };
            o.isConnectedNative = function():Boolean
            {
               if(webSocket != null)
               {
                  return webSocket.connected;
               }
               return false;
            };
            o.sendMessageNative = function(message:String):void
            {
               if(webSocket != null)
               {
                  webSocket.sendUTF(message);
               }
            };
         }
      }
   }
}

