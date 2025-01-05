package jackboxgames.timer
{
   import flash.events.IEventDispatcher;
   
   public interface IJBGTimer extends IEventDispatcher
   {
       
      
      function get currentCount() : int;
      
      function get delay() : Number;
      
      function set delay(param1:Number) : void;
      
      function get repeatCount() : int;
      
      function set repeatCount(param1:int) : void;
      
      function get running() : Boolean;
      
      function reset() : void;
      
      function start() : void;
      
      function stop() : void;
      
      function pause() : void;
      
      function resume() : void;
   }
}
