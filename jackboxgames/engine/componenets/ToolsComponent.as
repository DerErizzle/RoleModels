package jackboxgames.engine.componenets
{
   import jackboxgames.engine.GameEngine;
   import jackboxgames.utils.PausableEventDispatcher;
   import jackboxgames.utils.TickManager;
   
   public class ToolsComponent extends PausableEventDispatcher implements IComponent
   {
      private var _engine:GameEngine;
      
      public function ToolsComponent(engine:GameEngine)
      {
         super();
         this._engine = engine;
      }
      
      public function get priority() : uint
      {
         return 0;
      }
      
      public function init(doneFn:Function) : void
      {
         TickManager.initialize();
         TickManager.instance.isActive = true;
         doneFn();
      }
      
      public function dispose() : void
      {
         TickManager.instance.isActive = false;
      }
      
      public function startGame(doneFn:Function) : void
      {
         doneFn();
      }
      
      public function disposeGame() : void
      {
      }
   }
}

