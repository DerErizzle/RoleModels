package jackboxgames.pause
{
   import flash.events.*;
   import flash.external.*;
   import jackboxgames.events.*;
   import jackboxgames.localizy.*;
   import jackboxgames.logger.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.settings.*;
   import jackboxgames.ui.settings.*;
   import jackboxgames.userinput.*;
   import jackboxgames.utils.*;
   
   public class PauseScreen extends EventDispatcher
   {
      public static const PAUSE_TYPE_RESUME:String = "resume";
      
      public static const PAUSE_TYPE_START:String = "pause";
      
      public static const EVENT_PAUSE_AUDIO:String = "PauseManager.Pause_Audio";
      
      public static const EVENT_PAUSE_DECISION:String = "PauseManager.Pause_Decision";
      
      public static const EVENT_PAUSE_DONE:String = "PauseManager.Pause_Done";
      
      private static const STATE_PARKED:String = "PauseScreen.Parked";
      
      private static const STATE_APPEARING:String = "PauseScreen.Appearing";
      
      private static const STATE_ACTIVE:String = "PauseScreen.Active";
      
      private static const STATE_DISAPPEARING:String = "PauseScreen.Disappearing";
      
      private var _state:String = "PauseScreen.Parked";
      
      public function PauseScreen(swfPath:String, doneFn:Function)
      {
         var _this:* = undefined;
         super();
         this._state = STATE_PARKED;
         _this = this;
         if(SettingsManager.instance == null)
         {
            SettingsDataStore.initialize();
            SettingsManager.initialize();
            SettingsMenu.initialize();
         }
         JBGUtil.runFunctionAfter(function():void
         {
            JBGUtil.eventOnce(PauseMenuManager.instance,PauseMenuManager.EVENT_PAUSE_MENU_CONTENT_LOADED,function(event:EventWithData):void
            {
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("setPauseScreen",_this);
               }
               doneFn(PauseMenuManager.instance.pauseMc);
               KeyboardInputHandler.initialize(PauseMenuManager.instance.pauseMc.stage);
            });
            PauseMenuManager.instance.loadMenuContent(swfPath);
         },Duration.fromSec(1));
      }
      
      public function park() : void
      {
         PauseMenuManager.instance.setMenuShown(false);
         this._state = STATE_PARKED;
      }
      
      public function appearNoFlag(loseProgress:Boolean) : void
      {
         this.appearNoFlagLocalized(loseProgress);
      }
      
      public function appearNoFlagLocalized(loseProgress:Boolean) : void
      {
         this._state = STATE_APPEARING;
         Gamepad.instance.useNextUpdateAsCatchUp();
         KeyboardInputHandler.instance.catchUp();
         JBGUtil.eventOnce(PauseMenuManager.instance,PauseMenuManager.EVENT_PAUSE_MENU_VISIBILITY,function(event:EventWithData):void
         {
            _state = STATE_ACTIVE;
            if(EnvUtil.isAIR())
            {
               dispatchEvent(new Event(EVENT_PAUSE_AUDIO));
            }
            else if(ExternalInterface.available)
            {
               ExternalInterface.call("pauseAudio");
            }
         });
         PauseMenuManager.instance.setMenuShown(true);
         Platform.instance.addEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._onNativeMessage);
      }
      
      public function appear() : void
      {
         this.appearLocalized();
      }
      
      public function appearLocalized() : void
      {
         this._state = STATE_APPEARING;
         JBGUtil.eventOnce(PauseMenuManager.instance,PauseMenuManager.EVENT_PAUSE_MENU_VISIBILITY,function(event:EventWithData):void
         {
            _state = STATE_ACTIVE;
            if(EnvUtil.isAIR())
            {
               dispatchEvent(new Event(EVENT_PAUSE_AUDIO));
            }
            else if(ExternalInterface.available)
            {
               ExternalInterface.call("pauseAudio");
            }
         });
         PauseMenuManager.instance.setMenuShown(true);
         Platform.instance.addEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._onNativeMessage);
      }
      
      public function disappear(decision:Boolean, sendDecision:Boolean = true) : void
      {
         Logger.debug("PauseScreen::disappear( " + decision + ", " + sendDecision + " )");
         Platform.instance.removeEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._onNativeMessage);
         this._state = STATE_DISAPPEARING;
         JBGUtil.eventOnce(PauseMenuManager.instance,PauseMenuManager.EVENT_PAUSE_MENU_VISIBILITY,function(event:EventWithData):void
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
         PauseMenuManager.instance.setMenuShown(false);
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
         Logger.debug("PauseScreen::inputReceived( " + evt.data + " )");
         if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_BACK))
         {
            this._onCancel();
            evt.stopImmediatePropagation();
         }
         else if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_SELECT))
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

