package jackboxgames.engine.componenets
{
   import jackboxgames.engine.GameEngine;
   import jackboxgames.nativeoverride.URLLoader;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class NetworkComponent extends PausableEventDispatcher implements IComponent
   {
      private var _engine:GameEngine;
      
      public function NetworkComponent(engine:GameEngine)
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
         URLLoader.Initialize();
         doneFn();
      }
      
      public function dispose() : void
      {
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

