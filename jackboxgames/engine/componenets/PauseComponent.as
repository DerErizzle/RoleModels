package jackboxgames.engine.componenets
{
   import flash.events.*;
   import flash.external.*;
   import jackboxgames.engine.*;
   import jackboxgames.events.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.pause.*;
   import jackboxgames.userinput.*;
   import jackboxgames.utils.*;
   
   public class PauseComponent extends PausableEventDispatcher implements IPauseComponent, IComponent
   {
      private var _engine:GameEngine;
      
      private var _allowPause:Boolean;
      
      private var _allowPauseEvenIfInJustQuitMode:Boolean;
      
      private var _isPaused:Boolean;
      
      private var _pauseContext:String;
      
      private var _pauseInputs:Array;
      
      private var _allowPauseEvenIfInJustQuitModeInputs:Array;
      
      public function PauseComponent(engine:GameEngine)
      {
         super();
         this._engine = engine;
         this._allowPause = false;
      }
      
      public function get priority() : uint
      {
         return 0;
      }
      
      public function init(doneFn:Function) : void
      {
         this._allowPauseEvenIfInJustQuitMode = false;
         this._pauseInputs = BuildConfig.instance.configVal("pause-inputs") ? JSON.deserialize(BuildConfig.instance.configVal("pause-inputs")) : [UserInputDirector.INPUT_PAUSE];
         this._allowPauseEvenIfInJustQuitModeInputs = BuildConfig.instance.configVal("allow-pause-even-if-in-just-quit-mode-inputs") ? JSON.deserialize(BuildConfig.instance.configVal("allow-pause-even-if-in-just-quit-mode-inputs")) : [];
         Assert.assert(this._pauseInputs != null);
         Assert.assert(this._allowPauseEvenIfInJustQuitModeInputs != null);
         this._startListeningForPause();
         doneFn();
      }
      
      public function dispose() : void
      {
         this._stopListeningForPause();
         PauseMenuManager.instance.dispose();
      }
      
      public function startGame(doneFn:Function) : void
      {
         PauseMenuManager.initialize();
         doneFn();
      }
      
      public function disposeGame() : void
      {
      }
      
      private function _startListeningForPause() : void
      {
         UserInputDirector.instance.addEventListener(UserInputDirector.EVENT_INPUT,this._onUserInput);
      }
      
      private function _stopListeningForPause() : void
      {
         UserInputDirector.instance.removeEventListener(UserInputDirector.EVENT_INPUT,this._onUserInput);
      }
      
      private function _onUserInput(evt:EventWithData) : void
      {
         if(UserInputUtil.inputsContain(evt.data.inputs,this._pauseInputs))
         {
            if(UserInputUtil.inputsContain(evt.data.inputs,this._allowPauseEvenIfInJustQuitModeInputs))
            {
               this._allowPauseEvenIfInJustQuitMode = true;
            }
            this.pause();
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
         this._engine.activeGame.restart();
         return true;
      }
      
      public function onPauseDecision(decision:Boolean) : void
      {
         this.resume();
      }
      
      public function setPauseEnabled(enabled:Boolean) : void
      {
         this._allowPause = enabled;
      }
      
      public function setPauseContext(context:String) : void
      {
         this._pauseContext = context;
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
         PauseMenuManager.instance.updateMenu(PauseMenuManager.instance.pauseMenuData.toSimpleObject(),this._pauseContext);
         PauseMenuManager.instance.addEventListener(PauseMenuManager.EVENT_PAUSE_MENU_SELECTED,this._onPauseMenuItemSelected);
         PausableEventDispatcher.pauseAll();
         ExternalInterface.call("pauseGame",this.onPauseDecision,false);
         return true;
      }
      
      public function resume() : void
      {
         if(!this._isPaused)
         {
            return;
         }
         PauseMenuManager.instance.removeEventListener(PauseMenuManager.EVENT_PAUSE_MENU_SELECTED,this._onPauseMenuItemSelected);
         JBGUtil.eventOnce(PauseMenuManager.instance,PauseMenuManager.EVENT_PAUSE_MENU_VISIBILITY,function(event:EventWithData):void
         {
            Gamepad.instance.useNextUpdateAsCatchUp();
            KeyboardInputHandler.instance.catchUp();
            PausableEventDispatcher.resumeAll();
            _isPaused = false;
            ExternalInterface.call("pauseDone");
         });
         PauseMenuManager.instance.setMenuShown(false);
      }
      
      private function _onPauseMenuItemSelected(event:EventWithData) : void
      {
         var action:String = null;
         action = event.data.action;
         JBGUtil.eventOnce(PauseMenuManager.instance,PauseMenuManager.EVENT_PAUSE_MENU_DONE,function(event:EventWithData):void
         {
            if(action == PauseMenuManager.PAUSE_ACTION_RESUME)
            {
               _engine.dispatchEvent(new Event(PauseScreen.PAUSE_TYPE_RESUME));
            }
            if(action == PauseMenuManager.PAUSE_ACTION_RESTART_GAME)
            {
               _engine.activeGame.restart();
            }
            else if(action == PauseMenuManager.PAUSE_ACTION_BACK_TO_PACK)
            {
               _engine.activeGame.exit();
            }
            else if(action == PauseMenuManager.PAUSE_ACTION_EXIT_TO_DESKTOP)
            {
               _engine.exit();
            }
         });
         this.resume();
      }
   }
}

