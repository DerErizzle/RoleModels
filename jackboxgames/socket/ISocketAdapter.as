package jackboxgames.socket
{
   import flash.events.IEventDispatcher;
   
   public interface ISocketAdapter extends IEventDispatcher
   {
       
      
      function connect() : void;
      
      function emit(param1:String, param2:Object, param3:Function = null) : void;
      
      function close() : void;
   }
}
