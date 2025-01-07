package com.worlize.websocket
{
   import com.adobe.net.URI;
   import com.adobe.net.URIEncodingBitmap;
   import com.adobe.utils.StringUtil;
   import com.hurlant.crypto.hash.SHA1;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.SecureSocket;
   import flash.net.Socket;
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   import flash.utils.Timer;
   import jackboxgames.utils.Base64;
   
   [Event(name="closed",type="com.worlize.websocket.WebSocketEvent")]
   [Event(name="open",type="com.worlize.websocket.WebSocketEvent")]
   [Event(name="pong",type="com.worlize.websocket.WebSocketEvent")]
   [Event(name="ping",type="com.worlize.websocket.WebSocketEvent")]
   [Event(name="frame",type="com.worlize.websocket.WebSocketEvent")]
   [Event(name="message",type="com.worlize.websocket.WebSocketEvent")]
   [Event(name="abnormalClose",type="com.worlize.websocket.WebSocketErrorEvent")]
   [Event(name="ioError",type="flash.events.IOErrorEvent")]
   [Event(name="connectionFail",type="com.worlize.websocket.WebSocketErrorEvent")]
   public class WebSocket extends EventDispatcher
   {
      private static const MODE_UTF8:int = 0;
      
      private static const MODE_BINARY:int = 0;
      
      private static const MAX_HANDSHAKE_BYTES:int = 10 * 1024;
      
      public static function logger(text:String):void
      {
         trace(text);
      }
      private var _bufferedAmount:int = 0;
      
      private var _readyState:int;
      
      private var _uri:URI;
      
      private var _protocols:Array;
      
      private var _serverProtocol:String;
      
      private var _host:String;
      
      private var _port:uint;
      
      private var _resource:String;
      
      private var _secure:Boolean;
      
      private var _origin:String;
      
      private var _useNullMask:Boolean = false;
      
      private var socket:Socket;
      
      private var timeout:uint;
      
      private var fatalError:Boolean = false;
      
      private var nonce:ByteArray;
      
      private var base64nonce:String;
      
      private var serverHandshakeResponse:String;
      
      private var serverExtensions:Array;
      
      private var currentFrame:WebSocketFrame;
      
      private var frameQueue:Vector.<WebSocketFrame>;
      
      private var fragmentationOpcode:int = 0;
      
      private var fragmentationSize:uint = 0;
      
      private var waitingForServerClose:Boolean = false;
      
      private var closeTimeout:int = 5000;
      
      private var closeTimer:Timer;
      
      private var handshakeBytesReceived:int;
      
      private var handshakeTimer:Timer;
      
      private var handshakeTimeout:int = 10000;
      
      private var URIpathExcludedBitmap:URIEncodingBitmap;
      
      public var config:WebSocketConfig;
      
      public var debug:Boolean = false;
      
      public function WebSocket(uri:String, origin:String, protocols:* = null, timeout:uint = 10000)
      {
         var i:int = 0;
         this.URIpathExcludedBitmap = new URIEncodingBitmap(URI.URIpathEscape);
         this.config = new WebSocketConfig();
         super(null);
         this._uri = new URI(uri);
         if(protocols is String)
         {
            this._protocols = [protocols];
         }
         else
         {
            this._protocols = protocols;
         }
         if(Boolean(this._protocols))
         {
            for(i = 0; i < this._protocols.length; i++)
            {
               this._protocols[i] = StringUtil.trim(this._protocols[i]);
            }
         }
         this._origin = origin;
         this.timeout = timeout;
         this.handshakeTimeout = timeout;
         this.init();
      }
      
      private function init() : void
      {
         this.parseUrl();
         this.validateProtocol();
         this.frameQueue = new Vector.<WebSocketFrame>();
         this.fragmentationOpcode = 0;
         this.fragmentationSize = 0;
         this.currentFrame = new WebSocketFrame();
         this.fatalError = false;
         this.closeTimer = new Timer(this.closeTimeout,1);
         this.closeTimer.addEventListener(TimerEvent.TIMER,this.handleCloseTimer);
         this.handshakeTimer = new Timer(this.handshakeTimeout,1);
         this.handshakeTimer.addEventListener(TimerEvent.TIMER,this.handleHandshakeTimer);
         this.socket = this.secure ? new SecureSocket() : new Socket();
         this.socket.endian = Endian.BIG_ENDIAN;
         this.socket.timeout = this.timeout;
         this.socket.addEventListener(Event.CONNECT,this.handleSocketConnect);
         this.socket.addEventListener(IOErrorEvent.IO_ERROR,this.handleSocketIOError);
         this.socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleSocketSecurityError);
         this.socket.addEventListener(Event.CLOSE,this.handleSocketClose);
         this.socket.addEventListener(ProgressEvent.SOCKET_DATA,this.handleSocketData);
         this._readyState = WebSocketState.INIT;
      }
      
      private function validateProtocol() : void
      {
         var separators:Array = null;
         var p:int = 0;
         var protocol:String = null;
         var i:int = 0;
         var charCode:int = 0;
         var char:String = null;
         if(Boolean(this._protocols))
         {
            separators = ["(",")","<",">","@",",",";",":","\\","\"","/","[","]","?","=","{","}"," ",String.fromCharCode(9)];
            for(p = 0; p < this._protocols.length; p++)
            {
               protocol = this._protocols[p];
               for(i = 0; i < protocol.length; i++)
               {
                  charCode = int(protocol.charCodeAt(i));
                  char = protocol.charAt(i);
                  if(charCode < 33 || charCode > 126 || separators.indexOf(char) !== -1)
                  {
                     throw new WebSocketError("Illegal character \'" + String.fromCharCode(char) + "\' in subprotocol.");
                  }
               }
            }
         }
      }
      
      public function connect() : void
      {
         if(this._readyState === WebSocketState.INIT || this._readyState === WebSocketState.CLOSED)
         {
            this._readyState = WebSocketState.CONNECTING;
            this.generateNonce();
            this.handshakeBytesReceived = 0;
            this.socket.connect(this._host,this._port);
            if(this.debug)
            {
               logger("Connecting to " + this._host + " on port " + this._port);
            }
         }
      }
      
      private function parseUrl() : void
      {
         this._host = this._uri.authority;
         var scheme:String = this._uri.scheme.toLocaleLowerCase();
         if(scheme === "wss")
         {
            this._secure = true;
            this._port = 443;
         }
         else
         {
            if(scheme !== "ws")
            {
               throw new Error("Unsupported scheme: " + scheme);
            }
            this._secure = false;
            this._port = 80;
         }
         var tempPort:uint = parseInt(this._uri.port,10);
         if(!isNaN(tempPort) && tempPort !== 0)
         {
            this._port = tempPort;
         }
         var path:String = URI.fastEscapeChars(this._uri.path,this.URIpathExcludedBitmap);
         if(path.length === 0)
         {
            path = "/";
         }
         var query:String = this._uri.queryRaw;
         if(query.length > 0)
         {
            query = "?" + query;
         }
         this._resource = path + query;
      }
      
      private function generateNonce() : void
      {
         this.nonce = new ByteArray();
         for(var i:int = 0; i < 16; i++)
         {
            this.nonce.writeByte(Math.round(Math.random() * 255));
         }
         this.nonce.position = 0;
         this.base64nonce = Base64.encodeByteArray(this.nonce);
      }
      
      public function get readyState() : int
      {
         return this._readyState;
      }
      
      public function get bufferedAmount() : int
      {
         return this._bufferedAmount;
      }
      
      public function get uri() : String
      {
         var uri:String = null;
         uri = this._secure ? "wss://" : "ws://";
         uri += this._host;
         if(this._secure && this._port !== 443 || !this._secure && this._port !== 80)
         {
            uri += ":" + this._port.toString();
         }
         return uri + this._resource;
      }
      
      public function get protocol() : String
      {
         return this._serverProtocol;
      }
      
      public function get extensions() : Array
      {
         return [];
      }
      
      public function get host() : String
      {
         return this._host;
      }
      
      public function get port() : uint
      {
         return this._port;
      }
      
      public function get resource() : String
      {
         return this._resource;
      }
      
      public function get secure() : Boolean
      {
         return this._secure;
      }
      
      public function get connected() : Boolean
      {
         return this.readyState === WebSocketState.OPEN;
      }
      
      public function set useNullMask(val:Boolean) : void
      {
         this._useNullMask = val;
      }
      
      public function get useNullMask() : Boolean
      {
         return this._useNullMask;
      }
      
      private function verifyConnectionForSend() : void
      {
         if(this._readyState === WebSocketState.CONNECTING)
         {
            throw new WebSocketError("Invalid State: Cannot send data before connected.");
         }
      }
      
      public function sendUTF(data:String) : void
      {
         this.verifyConnectionForSend();
         var frame:WebSocketFrame = new WebSocketFrame();
         frame.opcode = WebSocketOpcode.TEXT_FRAME;
         frame.binaryPayload = new ByteArray();
         frame.binaryPayload.writeMultiByte(data,"utf-8");
         this.fragmentAndSend(frame);
      }
      
      public function sendBytes(data:ByteArray) : void
      {
         this.verifyConnectionForSend();
         var frame:WebSocketFrame = new WebSocketFrame();
         frame.opcode = WebSocketOpcode.BINARY_FRAME;
         frame.binaryPayload = data;
         this.fragmentAndSend(frame);
      }
      
      public function ping(payload:ByteArray = null) : void
      {
         this.verifyConnectionForSend();
         var frame:WebSocketFrame = new WebSocketFrame();
         frame.fin = true;
         frame.opcode = WebSocketOpcode.PING;
         if(Boolean(payload))
         {
            frame.binaryPayload = payload;
         }
         this.sendFrame(frame);
      }
      
      private function pong(binaryPayload:ByteArray = null) : void
      {
         this.verifyConnectionForSend();
         var frame:WebSocketFrame = new WebSocketFrame();
         frame.fin = true;
         frame.opcode = WebSocketOpcode.PONG;
         frame.binaryPayload = binaryPayload;
         this.sendFrame(frame);
      }
      
      private function fragmentAndSend(frame:WebSocketFrame) : void
      {
         var length:int = 0;
         var numFragments:int = 0;
         var i:int = 0;
         var currentFrame:WebSocketFrame = null;
         var currentLength:int = 0;
         if(frame.opcode > 7)
         {
            throw new WebSocketError("You cannot fragment control frames.");
         }
         var threshold:uint = this.config.fragmentationThreshold;
         if(this.config.fragmentOutgoingMessages && frame.binaryPayload && frame.binaryPayload.length > threshold)
         {
            frame.binaryPayload.position = 0;
            length = int(frame.binaryPayload.length);
            numFragments = Math.ceil(length / threshold);
            for(i = 1; i <= numFragments; i++)
            {
               currentFrame = new WebSocketFrame();
               currentFrame.opcode = i === 1 ? frame.opcode : 0;
               currentFrame.fin = i === numFragments;
               currentLength = i === numFragments ? int(length - threshold * (i - 1)) : int(threshold);
               frame.binaryPayload.position = threshold * (i - 1);
               currentFrame.binaryPayload = new ByteArray();
               frame.binaryPayload.readBytes(currentFrame.binaryPayload,0,currentLength);
               this.sendFrame(currentFrame);
            }
         }
         else
         {
            frame.fin = true;
            this.sendFrame(frame);
         }
      }
      
      private function sendFrame(frame:WebSocketFrame, force:Boolean = false) : void
      {
         frame.mask = true;
         frame.useNullMask = this._useNullMask;
         var buffer:ByteArray = new ByteArray();
         frame.send(buffer);
         this.sendData(buffer);
      }
      
      private function sendData(data:ByteArray, fullFlush:Boolean = false) : void
      {
         if(!this.connected)
         {
            return;
         }
         data.position = 0;
         this.socket.writeBytes(data,0,data.bytesAvailable);
         this.socket.flush();
         data.clear();
      }
      
      public function close(waitForServer:Boolean = true) : void
      {
         var frame:WebSocketFrame = null;
         var buffer:ByteArray = null;
         if(!this.socket.connected && this._readyState === WebSocketState.CONNECTING)
         {
            this._readyState = WebSocketState.CLOSED;
            try
            {
               this.socket.close();
            }
            catch(e:Error)
            {
            }
         }
         if(this.socket.connected)
         {
            frame = new WebSocketFrame();
            frame.rsv1 = frame.rsv2 = frame.rsv3 = frame.mask = false;
            frame.fin = true;
            frame.opcode = WebSocketOpcode.CONNECTION_CLOSE;
            frame.closeStatus = WebSocketCloseStatus.NORMAL;
            buffer = new ByteArray();
            frame.mask = true;
            frame.send(buffer);
            this.sendData(buffer,true);
            if(waitForServer)
            {
               this.waitingForServerClose = true;
               this.closeTimer.stop();
               this.closeTimer.reset();
               this.closeTimer.start();
            }
            this.dispatchClosedEvent();
         }
      }
      
      private function handleCloseTimer(event:TimerEvent) : void
      {
         if(this.waitingForServerClose)
         {
            if(this.socket.connected)
            {
               this.socket.close();
            }
         }
      }
      
      private function handleSocketConnect(event:Event) : void
      {
         if(this.debug)
         {
            logger("Socket Connected");
         }
         this.sendHandshake();
      }
      
      private function handleSocketClose(event:Event) : void
      {
         if(this.debug)
         {
            logger("Socket Disconnected");
         }
         this.dispatchClosedEvent();
      }
      
      private function handleSocketData(event:ProgressEvent = null) : void
      {
         var frameEvent:WebSocketEvent = null;
         if(this._readyState === WebSocketState.CONNECTING)
         {
            this.readServerHandshake();
            return;
         }
         while(this.socket.connected && this.currentFrame.addData(this.socket,this.fragmentationOpcode,this.config) && !this.fatalError)
         {
            if(this.currentFrame.protocolError)
            {
               this.drop(WebSocketCloseStatus.PROTOCOL_ERROR,this.currentFrame.dropReason);
               return;
            }
            if(this.currentFrame.frameTooLarge)
            {
               this.drop(WebSocketCloseStatus.MESSAGE_TOO_LARGE,this.currentFrame.dropReason);
               return;
            }
            if(!this.config.assembleFragments)
            {
               frameEvent = new WebSocketEvent(WebSocketEvent.FRAME);
               frameEvent.frame = this.currentFrame;
               dispatchEvent(frameEvent);
            }
            this.processFrame(this.currentFrame);
            this.currentFrame = new WebSocketFrame();
         }
      }
      
      private function processFrame(frame:WebSocketFrame) : void
      {
         var event:WebSocketEvent = null;
         var i:int = 0;
         var currentFrame:WebSocketFrame = null;
         var pingEvent:WebSocketEvent = null;
         var pongEvent:WebSocketEvent = null;
         var messageOpcode:int = 0;
         var binaryData:ByteArray = null;
         var totalLength:int = 0;
         if(frame.rsv1 || frame.rsv2 || frame.rsv3)
         {
            this.drop(WebSocketCloseStatus.PROTOCOL_ERROR,"Received frame with reserved bit set without a negotiated extension.");
            return;
         }
         switch(frame.opcode)
         {
            case WebSocketOpcode.BINARY_FRAME:
               if(this.config.assembleFragments)
               {
                  if(this.frameQueue.length !== 0)
                  {
                     this.drop(WebSocketCloseStatus.PROTOCOL_ERROR,"Illegal BINARY_FRAME received in the middle of a fragmented message.  Expected a continuation or control frame.");
                     return;
                  }
                  if(frame.fin)
                  {
                     event = new WebSocketEvent(WebSocketEvent.MESSAGE);
                     event.message = new WebSocketMessage();
                     event.message.type = WebSocketMessage.TYPE_BINARY;
                     event.message.binaryData = frame.binaryPayload;
                     dispatchEvent(event);
                  }
                  else if(this.frameQueue.length === 0)
                  {
                     this.frameQueue.push(frame);
                     this.fragmentationOpcode = frame.opcode;
                  }
               }
               break;
            case WebSocketOpcode.TEXT_FRAME:
               if(this.config.assembleFragments)
               {
                  if(this.frameQueue.length !== 0)
                  {
                     this.drop(WebSocketCloseStatus.PROTOCOL_ERROR,"Illegal TEXT_FRAME received in the middle of a fragmented message.  Expected a continuation or control frame.");
                     return;
                  }
                  if(frame.fin)
                  {
                     event = new WebSocketEvent(WebSocketEvent.MESSAGE);
                     event.message = new WebSocketMessage();
                     event.message.type = WebSocketMessage.TYPE_UTF8;
                     event.message.utf8Data = frame.binaryPayload.readMultiByte(frame.length,"utf-8");
                     dispatchEvent(event);
                  }
                  else
                  {
                     this.frameQueue.push(frame);
                     this.fragmentationOpcode = frame.opcode;
                  }
               }
               break;
            case WebSocketOpcode.CONTINUATION:
               if(this.config.assembleFragments)
               {
                  if(this.fragmentationOpcode === WebSocketOpcode.CONTINUATION && frame.opcode === WebSocketOpcode.CONTINUATION)
                  {
                     this.drop(WebSocketCloseStatus.PROTOCOL_ERROR,"Unexpected continuation frame.");
                     return;
                  }
                  this.fragmentationSize += frame.length;
                  if(this.fragmentationSize > this.config.maxMessageSize)
                  {
                     this.drop(WebSocketCloseStatus.MESSAGE_TOO_LARGE,"Maximum message size exceeded.");
                     return;
                  }
                  this.frameQueue.push(frame);
                  if(frame.fin)
                  {
                     event = new WebSocketEvent(WebSocketEvent.MESSAGE);
                     event.message = new WebSocketMessage();
                     messageOpcode = this.frameQueue[0].opcode;
                     binaryData = new ByteArray();
                     totalLength = 0;
                     for(i = 0; i < this.frameQueue.length; i++)
                     {
                        totalLength += this.frameQueue[i].length;
                     }
                     if(totalLength > this.config.maxMessageSize)
                     {
                        this.drop(WebSocketCloseStatus.MESSAGE_TOO_LARGE,"Message size of " + totalLength + " bytes exceeds maximum accepted message size of " + this.config.maxMessageSize + " bytes.");
                        return;
                     }
                     for(i = 0; i < this.frameQueue.length; i++)
                     {
                        currentFrame = this.frameQueue[i];
                        binaryData.writeBytes(currentFrame.binaryPayload,0,currentFrame.binaryPayload.length);
                        currentFrame.binaryPayload.clear();
                     }
                     binaryData.position = 0;
                     switch(messageOpcode)
                     {
                        case WebSocketOpcode.BINARY_FRAME:
                           event.message.type = WebSocketMessage.TYPE_BINARY;
                           event.message.binaryData = binaryData;
                           break;
                        case WebSocketOpcode.TEXT_FRAME:
                           event.message.type = WebSocketMessage.TYPE_UTF8;
                           event.message.utf8Data = binaryData.readMultiByte(binaryData.length,"utf-8");
                           break;
                        default:
                           this.drop(WebSocketCloseStatus.PROTOCOL_ERROR,"Unexpected first opcode in fragmentation sequence: 0x" + messageOpcode.toString(16));
                           return;
                     }
                     this.frameQueue = new Vector.<WebSocketFrame>();
                     this.fragmentationOpcode = 0;
                     this.fragmentationSize = 0;
                     dispatchEvent(event);
                  }
               }
               break;
            case WebSocketOpcode.PING:
               if(this.debug)
               {
                  logger("Received Ping");
               }
               pingEvent = new WebSocketEvent(WebSocketEvent.PING,false,true);
               pingEvent.frame = frame;
               if(dispatchEvent(pingEvent))
               {
                  this.pong(frame.binaryPayload);
               }
               break;
            case WebSocketOpcode.PONG:
               if(this.debug)
               {
                  logger("Received Pong");
               }
               pongEvent = new WebSocketEvent(WebSocketEvent.PONG);
               pongEvent.frame = frame;
               dispatchEvent(pongEvent);
               break;
            case WebSocketOpcode.CONNECTION_CLOSE:
               if(this.debug)
               {
                  logger("Received close frame");
               }
               if(this.waitingForServerClose)
               {
                  if(this.debug)
                  {
                     logger("Got close confirmation from server.");
                  }
                  this.closeTimer.stop();
                  this.waitingForServerClose = false;
                  this.socket.close();
               }
               else
               {
                  if(this.debug)
                  {
                     logger("Sending close response to server.");
                  }
                  this.close(false);
                  this.socket.close();
               }
               break;
            default:
               if(this.debug)
               {
                  logger("Unrecognized Opcode: 0x" + frame.opcode.toString(16));
               }
               this.drop(WebSocketCloseStatus.PROTOCOL_ERROR,"Unrecognized Opcode: 0x" + frame.opcode.toString(16));
         }
      }
      
      private function handleSocketIOError(event:IOErrorEvent) : void
      {
         if(this.debug)
         {
            logger("IO Error: " + event);
         }
         dispatchEvent(event);
         this.dispatchClosedEvent();
      }
      
      private function handleSocketSecurityError(event:SecurityErrorEvent) : void
      {
         if(this.debug)
         {
            logger("Security Error: " + event);
         }
         dispatchEvent(event.clone());
         this.dispatchClosedEvent();
      }
      
      private function sendHandshake() : void
      {
         var protosList:String = null;
         this.serverHandshakeResponse = "";
         var hostValue:String = this.host;
         if(this._secure && this._port !== 443 || !this._secure && this._port !== 80)
         {
            hostValue += ":" + this._port.toString();
         }
         var text:String = "";
         text += "GET " + this.resource + " HTTP/1.1\r\n";
         text += "Host: " + hostValue + "\r\n";
         text += "Upgrade: websocket\r\n";
         text += "Connection: Upgrade\r\n";
         text += "Sec-WebSocket-Key: " + this.base64nonce + "\r\n";
         if(Boolean(this._origin))
         {
            text += "Origin: " + this._origin + "\r\n";
         }
         text += "Sec-WebSocket-Version: 13\r\n";
         if(Boolean(this._protocols))
         {
            protosList = this._protocols.join(", ");
            text += "Sec-WebSocket-Protocol: " + protosList + "\r\n";
         }
         text += "\r\n";
         if(this.debug)
         {
            logger(text);
         }
         this.socket.writeMultiByte(text,"us-ascii");
         this.handshakeTimer.stop();
         this.handshakeTimer.reset();
         this.handshakeTimer.start();
      }
      
      private function failHandshake(message:String = "Unable to complete websocket handshake.") : void
      {
         if(this.debug)
         {
            logger(message);
         }
         this._readyState = WebSocketState.CLOSED;
         if(this.socket.connected)
         {
            this.socket.close();
         }
         this.handshakeTimer.stop();
         this.handshakeTimer.reset();
         var errorEvent:WebSocketErrorEvent = new WebSocketErrorEvent(WebSocketErrorEvent.CONNECTION_FAIL);
         errorEvent.text = message;
         dispatchEvent(errorEvent);
         var event:WebSocketEvent = new WebSocketEvent(WebSocketEvent.CLOSED);
         dispatchEvent(event);
      }
      
      private function failConnection(message:String) : void
      {
         this._readyState = WebSocketState.CLOSED;
         if(this.socket.connected)
         {
            this.socket.close();
         }
         var errorEvent:WebSocketErrorEvent = new WebSocketErrorEvent(WebSocketErrorEvent.CONNECTION_FAIL);
         errorEvent.text = message;
         dispatchEvent(errorEvent);
         var event:WebSocketEvent = new WebSocketEvent(WebSocketEvent.CLOSED);
         dispatchEvent(event);
      }
      
      private function drop(closeReason:uint = 1002, reasonText:String = null) : void
      {
         var errorEvent:WebSocketErrorEvent = null;
         if(!this.connected)
         {
            return;
         }
         this.fatalError = true;
         var logText:String = "WebSocket: Dropping Connection. Code: " + closeReason.toString(10);
         if(Boolean(reasonText))
         {
            logText += " - " + reasonText;
         }
         logger(logText);
         this.frameQueue = new Vector.<WebSocketFrame>();
         this.fragmentationSize = 0;
         if(closeReason !== WebSocketCloseStatus.NORMAL)
         {
            errorEvent = new WebSocketErrorEvent(WebSocketErrorEvent.ABNORMAL_CLOSE);
            errorEvent.text = "Close reason: " + closeReason;
            dispatchEvent(errorEvent);
         }
         this.sendCloseFrame(closeReason,reasonText,true);
         this.dispatchClosedEvent();
         this.socket.close();
      }
      
      private function sendCloseFrame(reasonCode:uint = 1000, reasonText:String = null, force:Boolean = false) : void
      {
         var frame:WebSocketFrame = new WebSocketFrame();
         frame.fin = true;
         frame.opcode = WebSocketOpcode.CONNECTION_CLOSE;
         frame.closeStatus = reasonCode;
         if(Boolean(reasonText))
         {
            frame.binaryPayload = new ByteArray();
            frame.binaryPayload.writeUTFBytes(reasonText);
         }
         this.sendFrame(frame,force);
      }
      
      private function readServerHandshake() : void
      {
         var lines:Array;
         var responseLineMatch:Array;
         var httpVersion:String;
         var statusCode:int;
         var statusDescription:String;
         var responseLine:String = null;
         var header:Object = null;
         var lcName:String = null;
         var lcValue:String = null;
         var extensionsThisLine:Array = null;
         var byteArray:ByteArray = null;
         var expectedKey:String = null;
         var protocol:String = null;
         var upgradeHeader:Boolean = false;
         var connectionHeader:Boolean = false;
         var serverProtocolHeaderMatch:Boolean = false;
         var keyValidated:Boolean = false;
         var headersTerminatorIndex:int = -1;
         while(headersTerminatorIndex === -1 && this.readHandshakeLine())
         {
            if(this.handshakeBytesReceived > MAX_HANDSHAKE_BYTES)
            {
               this.failHandshake("Received more than " + MAX_HANDSHAKE_BYTES + " bytes during handshake.");
               return;
            }
            headersTerminatorIndex = int(this.serverHandshakeResponse.search(/\r?\n\r?\n/));
         }
         if(headersTerminatorIndex === -1)
         {
            return;
         }
         if(this.debug)
         {
            logger("Server Response Headers:\n" + this.serverHandshakeResponse);
         }
         this.serverHandshakeResponse = this.serverHandshakeResponse.slice(0,headersTerminatorIndex);
         lines = this.serverHandshakeResponse.split(/\r?\n/);
         responseLine = lines.shift();
         responseLineMatch = responseLine.match(/^(HTTP\/\d\.\d) (\d{3}) ?(.*)$/i);
         if(responseLineMatch.length === 0)
         {
            this.failHandshake("Unable to find correctly-formed HTTP status line.");
            return;
         }
         httpVersion = responseLineMatch[1];
         statusCode = parseInt(responseLineMatch[2],10);
         statusDescription = responseLineMatch[3];
         if(this.debug)
         {
            logger("HTTP Status Received: " + statusCode + " " + statusDescription);
         }
         if(statusCode !== 101)
         {
            this.failHandshake("An HTTP response code other than 101 was received.  Actual Response Code: " + statusCode + " " + statusDescription);
            return;
         }
         this.serverExtensions = [];
         try
         {
            while(lines.length > 0)
            {
               responseLine = lines.shift();
               header = this.parseHTTPHeader(responseLine);
               lcName = header.name.toLocaleLowerCase();
               lcValue = header.value.toLocaleLowerCase();
               if(lcName === "upgrade" && lcValue === "websocket")
               {
                  upgradeHeader = true;
               }
               else if(lcName === "connection" && lcValue === "upgrade")
               {
                  connectionHeader = true;
               }
               else if(lcName === "sec-websocket-extensions" && Boolean(header.value))
               {
                  extensionsThisLine = header.value.split(",");
                  this.serverExtensions = this.serverExtensions.concat(extensionsThisLine);
               }
               else if(lcName === "sec-websocket-accept")
               {
                  byteArray = new ByteArray();
                  byteArray.writeUTFBytes(this.base64nonce + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11");
                  expectedKey = Base64.encodeByteArray(new SHA1().hash(byteArray));
                  if(this.debug)
                  {
                     logger("Expected Sec-WebSocket-Accept value: " + expectedKey);
                  }
                  if(header.value === expectedKey)
                  {
                     keyValidated = true;
                  }
               }
               else if(lcName === "sec-websocket-protocol")
               {
                  if(Boolean(this._protocols))
                  {
                     for each(protocol in this._protocols)
                     {
                        if(protocol == header.value)
                        {
                           this._serverProtocol = protocol;
                        }
                     }
                  }
               }
            }
         }
         catch(e:Error)
         {
            failHandshake("There was an error while parsing the following HTTP Header line:\n" + responseLine);
            return;
         }
         if(!upgradeHeader)
         {
            this.failHandshake("The server response did not include a valid Upgrade: websocket header.");
            return;
         }
         if(!connectionHeader)
         {
            this.failHandshake("The server response did not include a valid Connection: upgrade header.");
            return;
         }
         if(!keyValidated)
         {
            this.failHandshake("Unable to validate server response for Sec-Websocket-Accept header.");
            return;
         }
         if(Boolean(this._protocols) && !this._serverProtocol)
         {
            this.failHandshake("The server can not respond in any of our requested protocols");
            return;
         }
         if(this.debug)
         {
            logger("Server Extensions: " + this.serverExtensions.join(" | "));
         }
         this.handshakeTimer.stop();
         this.handshakeTimer.reset();
         this.serverHandshakeResponse = null;
         this._readyState = WebSocketState.OPEN;
         this.currentFrame = new WebSocketFrame();
         this.frameQueue = new Vector.<WebSocketFrame>();
         dispatchEvent(new WebSocketEvent(WebSocketEvent.OPEN));
         this.handleSocketData();
      }
      
      private function handleHandshakeTimer(event:TimerEvent) : void
      {
         this.failHandshake("Timed out waiting for server response.");
      }
      
      private function parseHTTPHeader(line:String) : Object
      {
         var header:Array = line.split(/\: +/);
         return header.length === 2 ? {
            "name":header[0],
            "value":header[1]
         } : null;
      }
      
      private function readHandshakeLine() : Boolean
      {
         var char:String = null;
         while(Boolean(this.socket.bytesAvailable))
         {
            char = this.socket.readMultiByte(1,"us-ascii");
            ++this.handshakeBytesReceived;
            this.serverHandshakeResponse += char;
            if(char == "\n")
            {
               return true;
            }
         }
         return false;
      }
      
      private function dispatchClosedEvent() : void
      {
         var event:WebSocketEvent = null;
         if(this.handshakeTimer.running)
         {
            this.handshakeTimer.stop();
         }
         if(this._readyState !== WebSocketState.CLOSED)
         {
            this._readyState = WebSocketState.CLOSED;
            event = new WebSocketEvent(WebSocketEvent.CLOSED);
            dispatchEvent(event);
         }
      }
   }
}

