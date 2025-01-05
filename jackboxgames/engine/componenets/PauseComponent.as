package jackboxgames.engine.componenets
{
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import jackboxgames.engine.*;
   import jackboxgames.events.EventWithData;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.pause.PauseScreen;
   import jackboxgames.utils.*;
   
   public class PauseComponent extends PausableEventDispatcher implements IPauseComponent, IComponent
   {
       
      
      private var _engine:GameEngine;
      
      private var _allowPause:Boolean;
      
      private var _allowPauseEvenIfInJustQuitMode:Boolean;
      
      private var _isPaused:Boolean;
      
      private var _pauseType:String;
      
      private var _pauseInputs:Array;
      
      private var _allowPauseEvenIfInJustQuitModeInputs:Array;
      
      public function PauseComponent(engine:GameEngine)
      {
         super();
         this._engine = engine;
         this._allowPause = false;
         this._pauseType = "kill";
      }
      
      public function get priority() : uint
      {
         return 0;
      }
      
      public function init(doneFn:Function) : void
      {
         this._allowPauseEvenIfInJustQuitMode = false;
         this._pauseInputs = BuildConfig.instance.configVal("pause-inputs") ? JSON.deserialize(BuildConfig.instance.configVal("pause-inputs")) : ["START"];
         this._allowPauseEvenIfInJustQuitModeInputs = BuildConfig.instance.configVal("allow-pause-even-if-in-just-quit-mode-inputs") ? JSON.deserialize(BuildConfig.instance.configVal("allow-pause-even-if-in-just-quit-mode-inputs")) : [];
         if(BuildConfig.instance.configVal("flashKeyboard"))
         {
            if(!ArrayUtil.arrayContainsElement(this._pauseInputs,"B"))
            {
               this._pauseInputs.push("B");
            }
            if(!ArrayUtil.arrayContainsElement(this._pauseInputs,"BACK"))
            {
               this._pauseInputs.push("BACK");
            }
         }
         this._startListeningForPause();
         doneFn();
      }
      
      public function dispose() : void
      {
         this._stopListeningForPause();
      }
      
      public function startGame(doneFn:Function) : void
      {
         doneFn();
      }
      
      public function disposeGame() : void
      {
      }
      
      private function _startListeningForPause() : void
      {
         Gamepad.instance.addEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._onGamepadInput);
      }
      
      private function _stopListeningForPause() : void
      {
         Gamepad.instance.removeEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._onGamepadInput);
      }
      
      private function _onGamepadInput(evt:EventWithData) : void
      {
         if(ArrayUtil.arrayContainsOneOf(evt.data.inputs,this._pauseInputs))
         {
            if(ArrayUtil.arrayContainsOneOf(evt.data.inputs,this._allowPauseEvenIfInJustQuitModeInputs))
            {
               this._allowPauseEvenIfInJustQuitMode = true;
            }
            if(this.pause())
            {
               Gamepad.instance.resetPreviousInput(this._pauseInputs);
            }
            this._allowPauseEvenIfInJustQuitMode = false;
         }
      }
      
      public function get isPaused() : Boolean
      {
         return this._isPaused;
      }
      
      public function get canPause() : Boolean
      {
         if(this._doNoPauseJustQuitLogicIfNecessary())
         {
            return false;
         }
         if(!this._allowPause || this.isPaused)
         {
            return false;
         }
         return true;
      }
      
      protected function _doNoPauseJustQuitLogicIfNecessary() : Boolean
      {
         if(!BuildConfig.instance.configVal("no-pause-just-quit") || !this._allowPause)
         {
            return false;
         }
         if(this._allowPauseEvenIfInJustQuitMode)
         {
            return false;
         }
         this._doPauseQuit();
         return true;
      }
      
      private function _doPauseQuit() : void
      {
         switch(this._pauseType)
         {
            case PauseScreen.PAUSE_TYPE_KILL:
               this._engine.activeGame.exit();
               this._engine.dispatchEvent(new Event(PauseScreen.PAUSE_TYPE_KILL));
               break;
            case PauseScreen.PAUSE_TYPE_REBOOT:
            default:
               this._engine.activeGame.restart();
               this._engine.dispatchEvent(new Event(PauseScreen.PAUSE_TYPE_REBOOT));
         }
      }
      
      public function onPauseDecision(decision:Boolean) : void
      {
         this.resume();
         if(decision)
         {
            this._doPauseQuit();
         }
         else
         {
            this._engine.dispatchEvent(new Event(PauseScreen.PAUSE_TYPE_RESUME));
         }
      }
      
      public function setPauseEnabled(enabled:Boolean) : void
      {
         this._allowPause = enabled;
      }
      
      public function setPauseType(type:String) : void
      {
         this._pauseType = type;
      }
      
      public function pause() : Boolean
      {
         if(this._doNoPauseJustQuitLogicIfNecessary())
         {
            return false;
         }
         if(!this._allowPause || this._isPaused)
         {
            return false;
         }
         if(JBGUtil.videoIsPlaying)
         {
            JBGUtil.pauseRequestedCallback = function():void
            {
               _allowPauseEvenIfInJustQuitMode = true;
               pause();
               _allowPauseEvenIfInJustQuitMode = false;
            };
            return true;
         }
         this._isPaused = true;
         this._engine.dispatchEvent(new Event(PauseScreen.PAUSE_TYPE_START));
         PausableEventDispatcher.pauseAll();
         ExternalInterface.call("pauseGame",this.onPauseDecision,this._pauseType == PauseScreen.PAUSE_TYPE_REBOOT);
         return true;
      }
      
      public function resume() : void
      {
         if(!this._isPaused)
         {
            return;
         }
         PausableEventDispatcher.resumeAll();
         if(BuildConfig.instance.configVal("flashKeyboard"))
         {
            Gamepad.instance.setKeyboardObserver(this._engine.activeGame.main.stage);
         }
         this._isPaused = false;
      }
   }
}
