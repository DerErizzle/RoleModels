package jackboxgames.loader
{
   import flash.events.IEventDispatcher;
   
   public interface ILoader extends IEventDispatcher
   {
      function get content() : *;
      
      function get url() : String;
      
      function get loaded() : Boolean;
      
      function load(param1:Function = null) : void;
      
      function loadFallback() : void;
      
      function loadComplete() : void;
      
      function stop() : void;
      
      function dispose() : void;
      
      function toString() : String;
   }
}

