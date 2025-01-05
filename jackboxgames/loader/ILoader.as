package jackboxgames.loader
{
   import flash.events.IEventDispatcher;
   import flash.utils.ByteArray;
   
   public interface ILoader extends IEventDispatcher
   {
       
      
      function get content() : *;
      
      function get url() : String;
      
      function get loaded() : Boolean;
      
      function load(param1:Function = null) : void;
      
      function loadUnzipped(param1:ByteArray) : void;
      
      function loadFallback() : void;
      
      function loadComplete() : void;
      
      function stop() : void;
      
      function dispose() : void;
      
      function toString() : String;
   }
}
