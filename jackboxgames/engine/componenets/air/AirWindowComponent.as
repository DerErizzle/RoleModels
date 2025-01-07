package jackboxgames.engine.componenets.air
{
   import flash.display.Stage;
   import jackboxgames.engine.GameEngine;
   import jackboxgames.engine.componenets.IComponent;
   import jackboxgames.engine.componenets.IExitComponent;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class AirWindowComponent extends PausableEventDispatcher implements IExitComponent, IComponent
   {
      private static var ASPECT_RATIO:Number = 1280 / 720;
      
      private static var WINDOW_RATIO:Number = 1296 / 759;
      
      private var _engine:GameEngine;
      
      private var _active:int = 0;
      
      private var _stage:Stage;
      
      public function AirWindowComponent(engine:GameEngine)
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
         doneFn();
      }
      
      public function disposeGame() : void
      {
      }
      
      public function get supportsExit() : Boolean
      {
         return true;
      }
      
      public function exit() : void
      {
      }
   }
}

