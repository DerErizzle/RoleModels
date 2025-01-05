package jackboxgames.engine.componenets.air
{
   import com.greensock.TweenMax;
   import flash.display.*;
   import flash.events.*;
   import flash.external.*;
   import jackboxgames.audio.JBGSoundPlayer;
   import jackboxgames.engine.*;
   import jackboxgames.engine.componenets.*;
   import jackboxgames.events.EventWithData;
   import jackboxgames.flash.*;
   import jackboxgames.loader.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.pause.*;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.timer.TimerUtil;
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
      
      private var _pauseType:String;
      
      public function AirPauseComponent(engine:GameEngine)
      {
         super();
         this._engine = engine;
         this._allowPause = false;
         this._pauseType = "kill";
      }
      
      public function get priority() : uint
      {
         return 1;
      }
      
      public function init(doneFn:Function) : void
      {
         JBGLoader.instance.loadFile("PauseDialog.swf",function(result:Object):void
         {
            var t:PausableTimer = null;
            _pauseSwf = result.data;
            t = new PausableTimer(100);
            t.addEventListener(TimerEvent.TIMER,function(evt:TimerEvent):void
            {
               if(Boolean(_pauseSwf.pauseScreen))
               {
                  t.stop();
                  _pauseScreen = _pauseSwf.pauseScreen;
                  _pauseScreen.addEventListener(PauseScreen.EVENT_PAUSE_DECISION,_onPauseDecisionEventListener);
                  Gamepad.instance.addEventListener(Gamepad.EVENT_RECEIVED_INPUT,_onGamepadInput);
                  doneFn();
               }
            });
            t.start();
         },false);
      }
      
      public function dispose() : void
      {
         if(Boolean(this._pauseScreen))
         {
            this._pauseScreen.removeEventListener(PauseScreen.EVENT_PAUSE_DECISION,this._onPauseDecisionEventListener);
         }
         Gamepad.instance.removeEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._onGamepadInput);
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
         if(!this._allowPause || this.isPaused || !this._pauseSwf || !this._pauseScreen || this._isResuming)
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
         if(!this.canPause)
         {
            return false;
         }
         this._isPaused = true;
         this._engine.dispatchEvent(new Event(PauseScreen.PAUSE_TYPE_START));
         PausableEventDispatcher.pauseAll();
         VideoPlayerFlash.pauseAll();
         JBGSoundPlayer.instance.pause();
         InputManager.instance.pause();
         TweenMax.pauseAll();
         MovieClipPauser.instance.pause(this._engine.rootGame.main);
         TimerUtil.pauseAll();
         PausableEventDispatcher.pauseAll();
         if(Boolean(PlaybackEngine.getInstance().pauser))
         {
            PlaybackEngine.getInstance().pauser.userPause();
         }
         FlashNative.pauseTimer();
         StageRef.addChild(this._pauseSwf);
         this._pauseScreen.appearNoFlag(this._pauseType == PauseScreen.PAUSE_TYPE_REBOOT);
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
         PausableEventDispatcher.resumeAll();
         if(BuildConfig.instance.configVal("flashKeyboard"))
         {
            Gamepad.instance.setKeyboardObserver(this._engine.activeGame.main.stage);
         }
         if(Boolean(this._pauseSwf.parent) && this._pauseSwf.parent is DisplayObjectContainer)
         {
            JBGUtil.safeRemoveChild(this._pauseSwf.parent,this._pauseSwf);
         }
         VideoPlayerFlash.resumeAll();
         JBGSoundPlayer.instance.resume();
         InputManager.instance.resume();
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
      
      private function _onPauseDecisionEventListener(evt:EventWithData) : void
      {
         this.onPauseDecision(Boolean(evt.data.hasOwnProperty("decision")) && Boolean(evt.data.decision));
      }
      
      private function _onGamepadInput(evt:EventWithData) : void
      {
         var pauseInputs:Array = BuildConfig.instance.configVal("pause-inputs") ? JSON.deserialize(BuildConfig.instance.configVal("pause-inputs")) : ["START"];
         var allowPauseEvenIfInJustQuitModeInputs:Array = BuildConfig.instance.configVal("allow-pause-even-if-in-just-quit-mode-inputs") ? JSON.deserialize(BuildConfig.instance.configVal("allow-pause-even-if-in-just-quit-mode-inputs")) : [];
         if(ArrayUtil.arrayContainsOneOf(evt.data.inputs,pauseInputs))
         {
            if(ArrayUtil.arrayContainsOneOf(evt.data.inputs,allowPauseEvenIfInJustQuitModeInputs))
            {
               this._allowPauseEvenIfInJustQuitMode = true;
            }
            if(this.pause())
            {
               Gamepad.instance.resetPreviousInput(pauseInputs);
            }
            this._allowPauseEvenIfInJustQuitMode = false;
         }
         if(BuildConfig.instance.configVal("flashKeyboard"))
         {
            if(evt.data.inputs.indexOf("B") >= 0 || evt.data.inputs.indexOf("BACK") >= 0)
            {
               this.pause();
            }
         }
      }
   }
}
