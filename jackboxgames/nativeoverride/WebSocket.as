package jackboxgames.nativeoverride
{
   import flash.external.ExternalInterface;
   import jackboxgames.events.EventWithData;
   import jackboxgames.flash.FlashNativeOverrider;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class WebSocket extends PausableEventDispatcher
   {
      public static const EVENT_CONNECT_RESULT:String = "WebSocket.ConnectResult";
      
      public static const EVENT_DISCONNECTED:String = "WebSocket.Disconnected";
      
      public static const EVENT_MESSAGE_RECEIVED:String = "WebSocket.MessageReceived";
      
      public var connectNative:Function = null;
      
      public var disconnectNative:Function = null;
      
      public var isConnectedNative:Function = null;
      
      public var sendMessageNative:Function = null;
      
      public function WebSocket()
      {
         super();
         if(ExternalInterface.available)
         {
            ExternalInterface.call("InitializeNativeOverride","WebSocket",this);
         }
         else
         {
            FlashNativeOverrider.initializeNativeOverride("WebSocket",this);
         }
      }
      
      public function connect(address:String, port:int, path:String, secure:Boolean) : void
      {
         if(this.connectNative != null)
         {
            this.connectNative(address,port,path,secure);
         }
      }
      
      public function disconnect() : void
      {
         if(this.disconnectNative != null)
         {
            this.disconnectNative();
         }
      }
      
      public function isConnected() : Boolean
      {
         if(this.isConnectedNative != null)
         {
            return this.isConnectedNative();
         }
         return false;
      }
      
      public function sendMessage(message:String) : void
      {
         if(this.sendMessageNative != null)
         {
            this.sendMessageNative(message);
         }
      }
      
      public function onConnectResult(success:Boolean) : void
      {
         dispatchEvent(new EventWithData(EVENT_CONNECT_RESULT,{"success":success}));
      }
      
      public function onMessageReceived(message:String) : void
      {
         dispatchEvent(new EventWithData(EVENT_MESSAGE_RECEIVED,{"message":message}));
      }
      
      public function onDisconnected() : void
      {
         dispatchEvent(new EventWithData(EVENT_DISCONNECTED,null));
      }
   }
}

