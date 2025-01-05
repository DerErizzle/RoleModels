package jackboxgames.engine.componenets
{
   import jackboxgames.engine.GameEngine;
   import jackboxgames.flash.MouseManager;
   import jackboxgames.nativeoverride.Gamepad;
   import jackboxgames.nativeoverride.Input;
   import jackboxgames.utils.BuildConfig;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class InputComponent extends PausableEventDispatcher implements IComponent
   {
       
      
      private var _engine:GameEngine;
      
      public function InputComponent(engine:GameEngine)
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
         Input.Initialize();
         Gamepad.Initialize();
         if(BuildConfig.instance.configVal("supportsMouse") == true)
         {
            MouseManager.instance.start();
         }
         doneFn();
      }
      
      public function dispose() : void
      {
      }
      
      public function startGame(doneFn:Function) : void
      {
         if(BuildConfig.instance.configVal("flashKeyboard"))
         {
            Gamepad.instance.setKeyboardObserver(this._engine.activeGame.main.stage);
         }
         doneFn();
      }
      
      public function disposeGame() : void
      {
      }
   }
}
