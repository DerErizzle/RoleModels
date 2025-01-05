package jackboxgames.blobcast.modules
{
   import flash.events.IEventDispatcher;
   
   public interface ISessionModule extends IEventDispatcher
   {
       
      
      function get moduleId() : String;
      
      function reset() : void;
      
      function start(param1:Object, param2:Function) : void;
      
      function stop(param1:Object, param2:Function) : void;
      
      function getStatus(param1:Object, param2:Function) : void;
      
      function sendMessage(param1:Object, param2:Function) : void;
      
      function onStartResult(param1:Object) : void;
      
      function onStopResult(param1:Object) : void;
      
      function onGetStatusResult(param1:Object) : void;
      
      function onSendMessageResult(param1:Object) : void;
   }
}
