package jackboxgames.rolemodels.actionpackages
{
   import flash.display.*;
   import flash.text.*;
   import jackboxgames.blobcast.model.*;
   import jackboxgames.engine.*;
   import jackboxgames.events.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.widgets.*;
   import jackboxgames.rolemodels.widgets.global.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   import jackboxgames.utils.audiosystem.*;
   import jackboxgames.widgets.*;
   
   public class Global extends JBGActionPackage
   {
       
      
      private var _sfxSettingHandler:FaderGroupSettingsHandler;
      
      private var _hostSettingHandler:FaderGroupSettingsHandler;
      
      private var _musicSettingHandler:FaderGroupSettingsHandler;
      
      private var _debugText:DebugTextWidget;
      
      private var _subtitleHandler:SubtitleWidget;
      
      private var _audioRequestHandler:AudioRequestEventHandler;
      
      private var _roomCodeWidget:RoomCodeWidget;
      
      private var _gameEndTransition:MovieClip;
      
      public function Global(sourceURL:String)
      {
         super(sourceURL);
      }
      
      public function handleActionInit(ref:IActionRef, params:Object) : void
      {
         _setLoaded(true,function():void
         {
            _onLoaded();
            ref.end();
         });
      }
      
      private function _onLoaded() : void
      {
         var initialValues:Object;
         GameState.instance.setupScreenOrganizer(DisplayObjectContainer(this.ts.background));
         _ts.foreground.addChild(_mc);
         GameEngine.instance.error.widget = _mc.errorWidget;
         initialValues = {};
         SettingsManager.instance.setInitialValues(initialValues);
         PlatformMovieClipManager.instance.init(function(success:Boolean):void
         {
         });
         this._debugText = new DebugTextWidget(_mc.debugText);
         _ts.g.runningTestMc = _mc.runningTest;
         _ts.g.runningTestMc.visible = false;
         GameState.instance.commonCensorBarGenerator.val = CensorableTextField.GENERATE_BLACK_BAR;
         TSInputHandler.initialize(_ts);
         this._subtitleHandler = new SubtitleWidget(_mc.subtitleContainer,function(mc:MovieClip, tf:ExtendableTextField):void
         {
            var bgMC:* = mc.subtitleDisplay.bg;
            var sourceTF:* = ArrayUtil.first(tf.tfs);
            bgMC.width = sourceTF.textWidth + 15;
         });
         this._audioRequestHandler = new AudioRequestEventHandler(_ts.container,GameState.instance.audioRegistrationStack);
         this._roomCodeWidget = new RoomCodeWidget(_mc.roomCodeAnimations);
         this._gameEndTransition = _mc.endTransition;
      }
      
      private function parkEverything() : void
      {
         JBGUtil.reset([this._roomCodeWidget,this._debugText,this._subtitleHandler]);
         JBGUtil.arrayGotoFrame([this._gameEndTransition],"Park");
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         this.parkEverything();
         if(Boolean(params.hard))
         {
            GameState.instance.sessions.stopAllPolling();
            GameEngine.instance.setPauseEnabled(false);
            if(Boolean(this._sfxSettingHandler))
            {
               this._sfxSettingHandler.dispose();
               this._sfxSettingHandler = null;
            }
            if(Boolean(this._hostSettingHandler))
            {
               this._hostSettingHandler.dispose();
               this._hostSettingHandler = null;
            }
            if(Boolean(this._musicSettingHandler))
            {
               this._musicSettingHandler.dispose();
               this._musicSettingHandler = null;
            }
         }
         JBGUtil.cancelAllEventOnce();
         JBGUtil.cancelAllRunFunctionAfter();
         TSInputHandler.instance.reset();
         ref.end();
      }
      
      public function handleActionSetupAudio(ref:IActionRef, params:Object) : void
      {
         if(Boolean(this._sfxSettingHandler))
         {
            this._sfxSettingHandler.dispose();
            this._sfxSettingHandler = null;
         }
         if(Boolean(this._hostSettingHandler))
         {
            this._hostSettingHandler.dispose();
            this._hostSettingHandler = null;
         }
         if(Boolean(this._musicSettingHandler))
         {
            this._musicSettingHandler.dispose();
            this._musicSettingHandler = null;
         }
         this._sfxSettingHandler = new FaderGroupSettingsHandler(SettingsConstants.SETTING_VOLUME_SFX,"sfx");
         this._sfxSettingHandler.setActive(true);
         this._hostSettingHandler = new FaderGroupSettingsHandler(SettingsConstants.SETTING_VOLUME_HOST,"Host");
         this._hostSettingHandler.setActive(true);
         this._musicSettingHandler = new FaderGroupSettingsHandler(SettingsConstants.SETTING_VOLUME_MUSIC,"music");
         this._musicSettingHandler.setActive(true);
         ref.end();
      }
      
      public function handleActionPushAudioKeys(ref:IActionRef, params:Object) : void
      {
         var audioDictionary:Object = null;
         var keys:Array = JBGUtil.getPropertiesOfNameInOrder(params,"key").filter(function(k:String, ... args):Boolean
         {
            return k != null;
         });
         var values:Array = JBGUtil.getPropertiesOfNameInOrder(params,"value").filter(function(v:String, ... args):Boolean
         {
            return v != null;
         });
         Assert.assert(keys.length == values.length);
         audioDictionary = {};
         ArrayUtil.parallelForEach(function(key:String, value:String):void
         {
            audioDictionary[key] = value;
         },keys,values);
         GameState.instance.audioRegistrationStack.push(audioDictionary,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionPopAudioKeys(ref:IActionRef, params:Object) : void
      {
         GameState.instance.audioRegistrationStack.pop(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDoNothing(ref:IActionRef, params:Object) : void
      {
         ref.end();
      }
      
      public function handleActionSetRoomCodeShown(ref:IActionRef, params:Object) : void
      {
         this._roomCodeWidget.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionCreateRoom(ref:IActionRef, params:Object) : void
      {
         var resultCallback:Function;
         TSInputHandler.instance.setupForSingleInput();
         resultCallback = function(evt:EventWithData):void
         {
            if(evt.data)
            {
               _roomCodeWidget.setup(GameState.instance.roomId.toUpperCase());
            }
            TSInputHandler.instance.input(evt.data ? "CreateRoom_Success" : "CreateRoom_Failure");
         };
         JBGUtil.eventOnce(GameState.instance,BlobCastGameState.EVENT_CREATE_ROOM_RESULT,resultCallback);
         GameState.instance.createRoom();
      }
      
      public function handleActionDoGameEndTransitionAnimation(ref:IActionRef, params:Object) : void
      {
         JBGUtil.gotoFrameWithFn(this._gameEndTransition,params.animation,MovieClipEvent.EVENT_ANIMATION_DONE,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionGoBackToMenu(ref:IActionRef, params:Object) : void
      {
         GameState.instance.goBackToMenu();
      }
      
      public function handleActionHideLoader(ref:IActionRef, params:Object) : void
      {
         if(BuildConfig.instance.configVal("isBundle"))
         {
            Platform.instance.hideSplashScreen();
            GameEngine.instance.hideLoader();
         }
         ref.end();
      }
      
      public function handleActionSetPauseEnabled(ref:IActionRef, params:Object) : void
      {
         GameEngine.instance.setPauseEnabled(params.isEnabled);
         ref.end();
      }
   }
}
