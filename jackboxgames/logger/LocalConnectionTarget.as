package jackboxgames.logger
{
   import flash.events.StatusEvent;
   import flash.net.LocalConnection;
   
   public class LocalConnectionTarget
   {
      private var _lc:LocalConnection;
      
      private var _id:String;
      
      public function LocalConnectionTarget(id:String = "_log")
      {
         super();
         this._id = id;
         this._lc = new LocalConnection();
         this._lc.addEventListener(StatusEvent.STATUS,this.statusEventHandler);
      }
      
      private function statusEventHandler(event:StatusEvent) : void
      {
      }
      
      private function logEventHandler(event:LogEvent) : void
      {
         var d:Date = new Date();
         try
         {
            this._lc.send(this._id,"logMessage",d,event.category,event.level * 2,event.message);
         }
         catch(error:Error)
         {
            Logger.debug("[LocalConection Error] cound not send message across LocalConnection");
         }
      }
   }
}

