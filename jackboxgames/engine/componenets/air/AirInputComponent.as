package jackboxgames.engine.componenets.air
{
   import flash.display.Stage;
   import flash.events.KeyboardEvent;
   import flash.ui.Keyboard;
   import jackboxgames.engine.GameEngine;
   import jackboxgames.engine.componenets.IComponent;
   import jackboxgames.flash.InputManager;
   import jackboxgames.settings.SettingsConstants;
   import jackboxgames.settings.SettingsManager;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class AirInputComponent extends PausableEventDispatcher implements IComponent
   {
       
      
      private var _engine:GameEngine;
      
      private var _stage:Stage;
      
      public function AirInputComponent(engine:GameEngine)
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
         var stage:Stage = this._engine.activeGame.main.stage;
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKey,false,int.MAX_VALUE);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKey,true,int.MAX_VALUE);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.onKey,false,int.MAX_VALUE);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.onKey,true,int.MAX_VALUE);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyCommand);
         InputManager.instance.init(stage);
         doneFn();
      }
      
      public function disposeGame() : void
      {
         var stage:Stage = this._engine.activeGame.main.stage;
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKey);
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKey);
         stage.removeEventListener(KeyboardEvent.KEY_UP,this.onKey);
         stage.removeEventListener(KeyboardEvent.KEY_UP,this.onKey);
         stage.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyCommand);
      }
      
      private function onKey(evt:KeyboardEvent) : void
      {
      }
      
      private function onKeyCommand(evt:KeyboardEvent) : void
      {
         if(evt.type == KeyboardEvent.KEY_UP && evt.keyCode == Keyboard.F11)
         {
            SettingsManager.instance.getValue(SettingsConstants.SETTING_FULL_SCREEN).val = !SettingsManager.instance.getValue(SettingsConstants.SETTING_FULL_SCREEN).val;
         }
      }
   }
}
