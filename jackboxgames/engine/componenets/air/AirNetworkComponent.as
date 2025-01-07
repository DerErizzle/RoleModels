package jackboxgames.engine.componenets.air
{
   import jackboxgames.engine.GameEngine;
   import jackboxgames.engine.componenets.IComponent;
   import jackboxgames.loader.JBGLoader;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class AirNetworkComponent extends PausableEventDispatcher implements IComponent
   {
      private var _engine:GameEngine;
      
      private var _networkTimeoutCanceller:Function;
      
      public function AirNetworkComponent(engine:GameEngine)
      {
         super();
         this._engine = engine;
      }
      
      public function get priority() : uint
      {
         return 1;
      }
      
      public function init(doneFn:Function) : void
      {
         doneFn();
      }
      
      public function dispose() : void
      {
      }
      
      public function startGame(doneFn:Function) : void
      {
         JBGLoader.setGamePrefix(this._engine.activeGame.gamePath);
         doneFn();
      }
      
      public function disposeGame() : void
      {
         JBGLoader.setGamePrefix("");
      }
   }
}

