package jackboxgames.engine.componenets
{
   import flash.system.System;
   import jackboxgames.engine.GameEngine;
   import jackboxgames.utils.BuildConfig;
   import jackboxgames.utils.EnvUtil;
   import jackboxgames.utils.PausableEventDispatcher;
   import jackboxgames.utils.StageRef;
   
   public class WindowComponent extends PausableEventDispatcher implements IExitComponent, IComponent
   {
      private var _engine:GameEngine;
      
      public function WindowComponent(engine:GameEngine)
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
         StageRef = this._engine.rootGame.main.stage;
         doneFn();
      }
      
      public function dispose() : void
      {
      }
      
      public function startGame(doneFn:Function) : void
      {
         this._engine.activeGame.main.stage.stageFocusRect = false;
         this._engine.activeGame.main.stage.focus = this._engine.activeGame.main;
         this._engine.activeGame.main.tabChildren = false;
         this._engine.activeGame.main.tabEnabled = false;
         doneFn();
      }
      
      public function disposeGame() : void
      {
      }
      
      public function get supportsExit() : Boolean
      {
         return BuildConfig.instance.configVal("needExitbutton");
      }
      
      public function exit() : void
      {
         if(EnvUtil.isPC())
         {
            System.exit(0);
         }
      }
   }
}

