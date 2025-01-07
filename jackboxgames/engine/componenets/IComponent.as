package jackboxgames.engine.componenets
{
   import flash.events.IEventDispatcher;
   
   public interface IComponent extends IEventDispatcher
   {
      function get priority() : uint;
      
      function init(param1:Function) : void;
      
      function dispose() : void;
      
      function startGame(param1:Function) : void;
      
      function disposeGame() : void;
   }
}

