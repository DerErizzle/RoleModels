package jackboxgames.engine.componenets
{
   import flash.text.*;
   import jackboxgames.engine.*;
   import jackboxgames.events.EventWithData;
   import jackboxgames.nativeoverride.Gamepad;
   import jackboxgames.utils.*;
   
   public class DevConsoleComponent extends PausableEventDispatcher implements IComponent
   {
       
      
      private const _toggleCombo:Array = ["DPAD_UP","DPAD_RIGHT","DPAD_DOWN","DPAD_LEFT","DPAD_UP","DPAD_RIGHT","DPAD_DOWN","DPAD_LEFT"];
      
      private var _toggleIndex:int = 0;
      
      private var _engine:GameEngine;
      
      private var _console:DeveloperConsole;
      
      public function DevConsoleComponent(engine:GameEngine)
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
         if(!this._console && DeveloperConsole.isEnabled())
         {
            Font.registerFont(CourierNew);
            this._console = new DeveloperConsole(StageRef);
            Gamepad.instance.addEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._onGamepadInput);
         }
         doneFn();
      }
      
      public function dispose() : void
      {
         Gamepad.instance.removeEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._onGamepadInput);
      }
      
      public function startGame(doneFn:Function) : void
      {
         if(Boolean(this._console))
         {
            this._engine.activeGame.main.addChild(this._console);
         }
         doneFn();
      }
      
      public function disposeGame() : void
      {
         if(Boolean(this._console) && Boolean(this._engine.activeGame.main.contains(this._console)))
         {
            this._engine.activeGame.main.removeChild(this._console);
         }
      }
      
      protected function _onGamepadInput(evt:EventWithData) : void
      {
         if(DeveloperConsole.isEnabled())
         {
            if(evt.data.inputs.indexOf(this._toggleCombo[this._toggleIndex]) >= 0)
            {
               ++this._toggleIndex;
               if(this._toggleIndex >= this._toggleCombo.length)
               {
                  this._console.toggle();
                  this._toggleIndex = 0;
               }
            }
            else
            {
               this._toggleIndex = 0;
            }
         }
      }
   }
}
