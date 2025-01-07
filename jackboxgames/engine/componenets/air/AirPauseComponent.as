package jackboxgames.engine.componenets.air
{
   import com.greensock.TweenMax;
   import flash.display.*;
   import flash.events.*;
   import jackboxgames.audio.*;
   import jackboxgames.engine.*;
   import jackboxgames.engine.componenets.*;
   import jackboxgames.events.*;
   import jackboxgames.flash.*;
   import jackboxgames.localizy.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.pause.*;
   import jackboxgames.talkshow.core.*;
   import jackboxgames.timer.*;
   import jackboxgames.userinput.*;
   import jackboxgames.utils.*;
   import jackboxgames.video.*;
   
   public class AirPauseComponent extends PausableEventDispatcher implements IPauseComponent, IComponent
   {
      private var _engine:GameEngine;
      
      private var _pauseSwf:MovieClip;
      
      private var _pauseScreen:PauseScreen;
      
      private var _allowPause:Boolean;
      
      private var _allowPauseEvenIfInJustQuitMode:Boolean;
      
      private var _isPaused:Boolean;
      
      private var _isResuming:Boolean;
      
      private var _pauseContext:String;
      
      public function AirPauseComponent(engine:GameEngine)
      {
         super();
         this._engine = engine;
         this._allowPause = false;
      }
      
      public function get priority() : uint
      {
         return 1;
      }
      
      public function init(doneFn:Function) : void
      {
         PauseMenuManager.initialize();
         JBGUtil.eventOnce(PauseMenuManager.instance,PauseMenuManager.EVENT_PAUSE_MENU_CONTENT_LOADED,function(event:EventWithData):void
         {
            UserInputDirector.instance.addEventListener(UserInputDirector.EVENT_INPUT,_onUserInput);
         });
         PauseMenuManager.instance.loadMenuContent(PauseMenuManager.PAUSE_MENU_CONTENT_FILE);
         doneFn();
      }
      
      public function dispose() : void
      {
         UserInputDirector.instance.removeEventListener(UserInputDirector.EVENT_INPUT,this._onUserInput);
      }
      
      public function startGame(doneFn:Function) : void
      {
         doneFn();
      }
      
      public function disposeGame() : void
      {
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
         if(!this._allowPause || this.isPaused || this._isResuming)
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
         if(!this.canPause)
         {
            return false;
         }
         PauseMenuManager.instance.updateMenu(PauseMenuManager.instance.pauseMenuData.toSimpleObject(),this._pauseContext);
         PauseMenuManager.instance.addEventListener(PauseMenuManager.EVENT_PAUSE_MENU_SELECTED,this._onPauseMenuItemSelected);
         this._isPaused = true;
         this._engine.dispatchEvent(new Event(PauseScreen.PAUSE_TYPE_START));
         PausableEventDispatcher.pauseAll();
         VideoPlayerFlash.pauseAll();
         JBGSoundPlayer.instance.pause();
         TweenMax.pauseAll();
         MovieClipPauser.instance.pause(this._engine.rootGame.main);
         TimerUtil.pauseAll();
         PausableEventDispatcher.pauseAll();
         if(Boolean(PlaybackEngine.getInstance().pauser))
         {
            PlaybackEngine.getInstance().pauser.userPause();
         }
         FlashNative.pauseTimer();
         StageRef.addChildAt(PauseMenuManager.instance.pauseMc,StageRef.numChildren - 1);
         PauseMenuManager.instance.setMenuShown(true);
         return true;
      }
      
      public function resume() : void
      {
         if(!this.isPaused || this._isResuming)
         {
            return;
         }
         this._isResuming = true;
         this._isPaused = false;
         Gamepad.instance.useNextUpdateAsCatchUp();
         KeyboardInputHandler.instance.catchUp();
         PauseMenuManager.instance.removeEventListener(PauseMenuManager.EVENT_PAUSE_MENU_SELECTED,this._onPauseMenuItemSelected);
         PauseMenuManager.instance.setMenuShown(false);
         PausableEventDispatcher.resumeAll();
         KeyboardInputHandler.initialize(this._engine.activeGame.main.stage);
         StageRef.removeChild(PauseMenuManager.instance.pauseMc);
         VideoPlayerFlash.resumeAll();
         JBGSoundPlayer.instance.resume();
         TweenMax.resumeAll();
         MovieClipPauser.instance.resume();
         PausableEventDispatcher.resumeAll();
         TimerUtil.resumeAll();
         if(Boolean(PlaybackEngine.getInstance().pauser))
         {
            PlaybackEngine.getInstance().pauser.userResume();
         }
         FlashNative.resumeTimer();
         this._isResuming = false;
         LocalizationManager.GameSource = BuildConfig.instance.configVal("gameName");
      }
      
      public function onPauseDecision(decision:Boolean) : void
      {
         this.resume();
      }
      
      private function _onUserInput(evt:EventWithData) : void
      {
         var pauseInputs:Array = BuildConfig.instance.configVal("pause-inputs") ? JSON.deserialize(BuildConfig.instance.configVal("pause-inputs")) : ["START"];
         var allowPauseEvenIfInJustQuitModeInputs:Array = BuildConfig.instance.configVal("allow-pause-even-if-in-just-quit-mode-inputs") ? JSON.deserialize(BuildConfig.instance.configVal("allow-pause-even-if-in-just-quit-mode-inputs")) : [];
         Assert.assert(pauseInputs != null);
         Assert.assert(allowPauseEvenIfInJustQuitModeInputs != null);
         if(UserInputUtil.inputsContain(evt.data.inputs,pauseInputs))
         {
            if(UserInputUtil.inputsContain(evt.data.inputs,allowPauseEvenIfInJustQuitModeInputs))
            {
               this._allowPauseEvenIfInJustQuitMode = true;
            }
            this.pause();
            this._allowPauseEvenIfInJustQuitMode = false;
         }
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

