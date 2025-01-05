package jackboxgames.socket
{
   import flash.events.EventDispatcher;
   import flash.external.ExternalInterface;
   
   public class SocketIOJSAdapter extends EventDispatcher implements ISocketAdapter
   {
       
      
      private var _server:String;
      
      public function SocketIOJSAdapter(domain:String, protocol:String, port:String)
      {
         super();
         this._server = protocol + domain;
         if(ExternalInterface.available)
         {
            ExternalInterface.addCallback("onConnectedToService",function(... args):void
            {
               var fec:SocketEvent = new SocketEvent(SocketEvent.CONNECT);
               dispatchEvent(fec);
            });
            ExternalInterface.addCallback("onDisconnectedFromService",function(... args):void
            {
               var fe:SocketEvent = new SocketEvent(SocketEvent.CLOSE);
               dispatchEvent(fe);
            });
            ExternalInterface.addCallback("onMessage",function(message:Object):void
            {
               var fe:SocketEvent = new SocketEvent(SocketEvent.MESSAGE);
               fe.data = message;
               dispatchEvent(fe);
            });
         }
      }
      
      public function connect() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("connectToService",{"server":this._server});
         }
      }
      
      public function emit(event:String, msg:Object, callback:Function = null) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("send",msg);
         }
      }
      
      public function close() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("disconnectFromService");
         }
      }
   }
}
