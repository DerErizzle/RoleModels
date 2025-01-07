package jackboxgames.thewheel.actionpackages
{
   import flash.display.*;
   import flash.text.*;
   import jackboxgames.engine.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.utils.*;
   import jackboxgames.utils.audiosystem.*;
   import jackboxgames.widgets.*;
   
   public class Global extends JBGActionPackage
   {
      private var _subtitleHandler:SubtitleWidget;
      
      private var _audioRequestHandler:AudioRequestEventHandler;
      
      private var _roomCodeShower:MovieClipShower;
      
      private var _roomCodeTf:ExtendableTextField;
      
      public function Global(apRef:IActionPackageRef)
      {
         super(apRef);
      }
      
      override protected function get _sourceURL() : String
      {
         return "thewheel_global.swf";
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
         var white:Sprite;
         var d:*;
         GameState.instance.setupScreenOrganizer(DisplayObjectContainer(this.ts.background));
         white = new Sprite();
         white.graphics.beginFill(16777215,1);
         white.graphics.drawRect(0,0,StageRef.stageWidth,StageRef.stageHeight);
         white.graphics.endFill();
         GameState.instance.screenOrganizer.addChild(white,0);
         GameState.instance.screenOrganizer.setChildState(white,DisplayObjectOrganizer.STATE_PERMANENTLY_ON);
         _ts.foreground.addChild(_mc);
         d = _ts.foreground;
         d.mouseEnabled = false;
         d.mouseChildren = false;
         GameEngine.instance.error.widget = _mc.errorWidget;
         TSInputHandler.initialize(_ts);
         this._subtitleHandler = new SubtitleWidget(_mc.subtitleContainer,function(mc:MovieClip, tf:ExtendableTextField):void
         {
            var bgMC:* = mc.subtitleDisplay.bg;
            var sourceTF:* = ArrayUtil.first(tf.tfs);
            sourceTF.y = bgMC.y - sourceTF.textHeight / 2 - 3;
            bgMC.height = sourceTF.textHeight + 5;
            bgMC.width = sourceTF.textWidth + 15;
         },{"charactersPerSecond":27});
         this._audioRequestHandler = new AudioRequestEventHandler(_ts.container,GameState.instance.audioRegistrationStack);
         addDelegate(new AudioEventRegistrationStackDelegate(GameState.instance.audioRegistrationStack));
         g.buildConfig = BuildConfig.instance;
         this._roomCodeShower = new MovieClipShower(_mc.roomCode);
         this._roomCodeTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.roomCode.container.tf);
      }
      
      private function parkEverything() : void
      {
         JBGUtil.reset([this._roomCodeShower,this._subtitleHandler]);
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         resetDelegates();
         this.parkEverything();
         if(Boolean(params.hard))
         {
            GameState.instance.sessions.stopAllPolling();
            GameEngine.instance.setPauseEnabled(false);
         }
         JBGUtil.cancelAllEventOnce();
         TrackedTweens.reset();
         JBGUtil.cancelAllRunFunctionAfter();
         TSInputHandler.instance.reset();
         ref.end();
      }
      
      public function handleActionSetupAudio(ref:IActionRef, params:Object) : void
      {
         AudioSystemUtil.setCommonFaderGroupVolumes();
         ref.end();
      }
      
      public function handleActionDoNothing(ref:IActionRef, params:Object) : void
      {
         ref.end();
      }
      
      public function handleActionWait(ref:IActionRef, params:Object) : void
      {
         JBGUtil.runFunctionAfter(TSUtil.createRefEndFn(ref),Duration.fromSec(params.duration));
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
      
      public function handleActionCreateRoom(ref:IActionRef, params:Object) : void
      {
         TSInputHandler.instance.setupForSingleInput();
         GameState.instance.createRoom().then(function(result:*):void
         {
            GameState.instance.textDescriptions.setupForNewLobby();
            TSInputHandler.instance.input("CreateRoom_Success");
         },function(errorMessage:String):void
         {
            TSInputHandler.instance.input("CreateRoom_Failure");
         });
      }
      
      public function handleActionSetRoomCodeShown(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isShown))
         {
            this._roomCodeTf.text = GameState.instance.roomId;
         }
         this._roomCodeShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetRoomCodeMode(ref:IActionRef, params:Object) : void
      {
         JBGUtil.gotoFrame(_mc.roomCode.container,params.mode);
         ref.end();
      }
   }
}

