package jackboxgames.pause
{
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.external.ExternalInterface;
   import jackboxgames.events.*;
   import jackboxgames.loader.*;
   import jackboxgames.logger.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class PauseScreen extends EventDispatcher
   {
      
      public static const PAUSE_TYPE_REBOOT:String = "reboot";
      
      public static const PAUSE_TYPE_KILL:String = "kill";
      
      public static const PAUSE_TYPE_RESUME:String = "resume";
      
      public static const PAUSE_TYPE_START:String = "pause";
      
      public static const EVENT_PAUSE_AUDIO:String = "PauseManager.Pause_Audio";
      
      public static const EVENT_PAUSE_DECISION:String = "PauseManager.Pause_Decision";
      
      public static const EVENT_PAUSE_DONE:String = "PauseManager.Pause_Done";
      
      private static const STATE_PARKED:String = "PauseScreen.Parked";
      
      private static const STATE_APPEARING:String = "PauseScreen.Appearing";
      
      private static const STATE_ACTIVE:String = "PauseScreen.Active";
      
      private static const STATE_DISAPPEARING:String = "PauseScreen.Disappearing";
       
      
      private var _mc:MovieClip;
      
      private var _aButton:PlatformButton;
      
      private var _bButton:PlatformButton;
      
      private var _state:String = "PauseScreen.Parked";
      
      private var _cancelInputs:Array;
      
      private var _quitInputs:Array;
      
      public function PauseScreen(swfPath:String, doneFn:Function)
      {
         var _this:* = undefined;
         super();
         this._state = STATE_PARKED;
         _this = this;
         JBGLoader.instance.loadFile(swfPath,function(result:Object):void
         {
            _mc = result.data.mcPauseScreen;
            _mc.tabEnabled = false;
            _mc.tabChildren = false;
            PlatformMovieClipManager.instance.init(function(success:Boolean):void
            {
               _init();
               doneFn(_mc);
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("setPauseScreen",_this);
               }
            });
         });
      }
      
      private function _init() : void
      {
         if(BuildConfig.instance.configVal("pause-cancel-inputs"))
         {
            this._cancelInputs = JSON.deserialize(BuildConfig.instance.configVal("pause-cancel-inputs"));
         }
         else if(!EnvUtil.isConsole() || BuildConfig.instance.configVal("supportsKeyboard") == true)
         {
            this._cancelInputs = ["START","B","BACK"];
         }
         else if(EnvUtil.isConsole())
         {
            this._cancelInputs = ["START","B"];
         }
         if(BuildConfig.instance.configVal("pause-quit-inputs"))
         {
            this._quitInputs = JSON.deserialize(BuildConfig.instance.configVal("pause-quit-inputs"));
         }
         else if(!EnvUtil.isConsole() || BuildConfig.instance.configVal("supportsKeyboard") == true)
         {
            this._quitInputs = ["A","SELECT","ENTER"];
         }
         else if(EnvUtil.isConsole())
         {
            this._quitInputs = ["A"];
         }
         if(Boolean(this._mc.buttons))
         {
            MovieClipUtil.gotoFrameIfExists(this._mc.buttons,"CONSOLE");
            this._aButton = new PlatformButton(this._mc.buttons.console.aButton,this._mc.buttons.console.aButton,["SELECT","A"]);
            this._bButton = new PlatformButton(this._mc.buttons.console.bButton,this._mc.buttons.console.bButton,["BACK","B"]);
            this._aButton.canTouchPaused = true;
            this._bButton.canTouchPaused = true;
         }
      }
      
      public function park() : void
      {
         JBGUtil.gotoFrame(this._mc,"Park");
         this._mc.visible = false;
         this._state = STATE_PARKED;
      }
      
      public function appearNoFlag(loseProgress:Boolean) : void
      {
         if(Boolean(this._mc.bg.tf_progressLost))
         {
            this._mc.bg.tf_progressLost.visible = loseProgress;
         }
         this._state = STATE_APPEARING;
         if(BuildConfig.instance.configVal("flashKeyboard"))
         {
            Gamepad.instance.setKeyboardObserver(this._mc.stage);
         }
         Gamepad.instance.addEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._inputReceived,false,int.MAX_VALUE);
         Gamepad.instance.addEventListener(Gamepad.EVENT_RECEIVED_INPUT_PAUSED,this._inputReceived,false,int.MAX_VALUE);
         Platform.instance.addEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._onNativeMessage);
         if(BuildConfig.instance.configVal("supportsJoysticksHotplugging") == true)
         {
            Platform.instance.dispatchEvent(new EventWithData(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,{
               "message":"HasJoystickConnected",
               "parameter":Gamepad.instance.getNumberOfJoysticks() > 0
            }));
         }
         JBGUtil.gotoFrameWithFn(this._mc,"Appear",MovieClipEvent.EVENT_APPEAR_DONE,function():void
         {
            _state = STATE_ACTIVE;
            if(EnvUtil.isAIR())
            {
               dispatchEvent(new Event(EVENT_PAUSE_AUDIO));
            }
            else if(ExternalInterface.available)
            {
               Logger.debug("PauseScreen appearNoFlag Calling pauseAudio");
               ExternalInterface.call("pauseAudio");
            }
         });
      }
      
      public function appear() : void
      {
         this._state = STATE_APPEARING;
         Gamepad.instance.addEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._inputReceived,false,int.MAX_VALUE);
         Gamepad.instance.addEventListener(Gamepad.EVENT_RECEIVED_INPUT_PAUSED,this._inputReceived,false,int.MAX_VALUE);
         Platform.instance.addEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._onNativeMessage);
         if(BuildConfig.instance.configVal("supportsJoysticksHotplugging") == true)
         {
            Platform.instance.dispatchEvent(new EventWithData(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,{
               "message":"HasJoystickConnected",
               "parameter":Gamepad.instance.getNumberOfJoysticks() > 0
            }));
         }
         JBGUtil.gotoFrameWithFn(this._mc,"Appear",MovieClipEvent.EVENT_APPEAR_DONE,function():void
         {
            _state = STATE_ACTIVE;
         });
      }
      
      public function disappear(decision:Boolean, sendDecision:Boolean = true) : void
      {
         Logger.debug("PauseScreen::disappear( " + decision + ", " + sendDecision + " )");
         Gamepad.instance.removeEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._inputReceived);
         Gamepad.instance.removeEventListener(Gamepad.EVENT_RECEIVED_INPUT_PAUSED,this._inputReceived);
         Platform.instance.removeEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._onNativeMessage);
         this._state = STATE_DISAPPEARING;
         JBGUtil.gotoFrameWithFn(this._mc,"Disappear",MovieClipEvent.EVENT_DISAPPEAR_DONE,function():void
         {
            _state = STATE_PARKED;
            if(sendDecision)
            {
               Logger.debug("PauseScreen::onDisappearDone()");
               if(EnvUtil.isAIR())
               {
                  dispatchEvent(new EventWithData(EVENT_PAUSE_DECISION,{"decision":decision}));
               }
               else if(ExternalInterface.available)
               {
                  ExternalInterface.call("pauseDecision",decision);
               }
            }
            else
            {
               Logger.debug("PauseScreen::onDisappearDoneSilent");
               if(EnvUtil.isAIR())
               {
                  dispatchEvent(new Event(EVENT_PAUSE_DONE));
               }
               else if(ExternalInterface.available)
               {
                  ExternalInterface.call("pauseDone");
               }
            }
         });
      }
      
      private function _onQuit(sendPauseDecision:Boolean = true) : void
      {
         this.disappear(true,sendPauseDecision);
      }
      
      private function _onCancel() : void
      {
         this.disappear(false);
      }
      
      private function _inputReceived(evt:EventWithData) : void
      {
         if(this._state != STATE_ACTIVE)
         {
            evt.stopImmediatePropagation();
            return;
         }
         Logger.debug("PauseScreen::inputReceived( " + evt.data.inputs + " )");
         if(ArrayUtil.arrayContainsOneOf(evt.data.inputs,this._cancelInputs))
         {
            this._onCancel();
            evt.stopImmediatePropagation();
         }
         else if(ArrayUtil.arrayContainsOneOf(evt.data.inputs,this._quitInputs))
         {
            this._onQuit();
            evt.stopImmediatePropagation();
         }
      }
      
      private function _onNativeMessage(evt:EventWithData) : void
      {
         Logger.debug("PauseScreen::_onNativeMessage w/ message => " + evt.data.message + ", " + TraceUtil.objectRecursive(evt.data.parameter,"parameter"));
         if(this._state != STATE_ACTIVE)
         {
            if(this._state != STATE_APPEARING)
            {
               evt.stopImmediatePropagation();
            }
            return;
         }
         if(evt.data.message == "ReturnToStart")
         {
            this._onCancel();
         }
      }
   }
}
