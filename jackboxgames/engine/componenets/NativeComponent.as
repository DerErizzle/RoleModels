package jackboxgames.engine.componenets
{
   import jackboxgames.engine.*;
   import jackboxgames.utils.*;
   
   public class NativeComponent extends PausableEventDispatcher implements IComponent
   {
      private var _engine:GameEngine;
      
      public function NativeComponent(engine:GameEngine)
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
         doneFn();
      }
      
      public function dispose() : void
      {
      }
      
      public function startGame(doneFn:Function) : void
      {
         var game:IGame = this._engine.activeGame;
         game.main.setVisibility = game.setVisibility;
         game.main.doReset = game.doReset;
         game.main.onSetupFromNative = game.onSetupFromNative;
         doneFn();
      }
      
      public function disposeGame() : void
      {
      }
   }
}

