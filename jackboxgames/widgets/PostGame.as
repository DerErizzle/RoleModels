package jackboxgames.widgets
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import com.greensock.events.TweenEvent;
   import flash.display.MovieClip;
   import flash.text.TextFieldAutoSize;
   import jackboxgames.algorithm.MapFold;
   import jackboxgames.blobcast.model.*;
   import jackboxgames.engine.GameEngine;
   import jackboxgames.events.*;
   import jackboxgames.loader.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.api.IActionRef;
   import jackboxgames.text.*;
   import jackboxgames.ugc.*;
   import jackboxgames.utils.*;
   
   public class PostGame
   {
       
      
      protected var CREDITS_SPEED:Number = 50;
      
      protected var _mc:MovieClip;
      
      protected var _gameState:BlobCastGameState;
      
      protected var _creditsTween:TweenMax;
      
      protected var _creditsCanceller:Function;
      
      protected var _creditsLoader:ILoader;
      
      private var _postGameRoomCodeTf:ExtendableTextField;
      
      private var _postGameJoinUrl:ExtendableTextField;
      
      private var _inCountdown:Boolean;
      
      private var _lastLobbyState:String;
      
      private var _audioHandler:IPostGameAudioHandler;
      
      private var _postGameChoice:String;
      
      private var _postGameChoices:PostGameChoices;
      
      private var _backBehaviors:ButtonCallout;
      
      private var _startCountdownCancellor:Function;
      
      private var _stopCountdownCancellor:Function;
      
      private var _postGameLobbyState:String = "PostGame";
      
      private var _postGameCountdownState:String = "Countdown";
      
      private var _creditsColor:String = "#e8b32b";
      
      private var _creditsOffset:Number = 0;
      
      protected var _creditsStyle:String;
      
      private var _countdownStartedFn:Function;
      
      private var _countdownStoppedFn:Function;
      
      public function PostGame(mc:MovieClip, gameState:BlobCastGameState)
      {
         this._startCountdownCancellor = Nullable.NULL_FUNCTION;
         this._stopCountdownCancellor = Nullable.NULL_FUNCTION;
         this._countdownStartedFn = Nullable.NULL_FUNCTION;
         this._countdownStoppedFn = Nullable.NULL_FUNCTION;
         super();
         this._mc = mc;
         this._gameState = gameState;
         this._postGameRoomCodeTf = new ExtendableTextField(this._mc.roomCode.tf,[],[]);
         this._postGameJoinUrl = new ExtendableTextField(this._mc.roomCode.tf.joinUrl,[],[PostEffectFactory.createDynamicResizerEffect(1),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         this._backBehaviors = new ButtonCallout(this._mc.back,["BACK","B"]);
         this._postGameChoices = new PostGameChoices(this._mc.postGameChoices);
         this._audioHandler = new NullPostGameAudioHandler();
         this._creditsCanceller = Nullable.NULL_FUNCTION;
      }
      
      public function get postGameLobbyState() : String
      {
         return this._postGameLobbyState;
      }
      
      public function set postGameLobbyState(value:String) : void
      {
         this._postGameLobbyState = value;
      }
      
      public function get postGameCountdownState() : String
      {
         return this._postGameCountdownState;
      }
      
      public function set postGameCountdownState(value:String) : void
      {
         this._postGameCountdownState = value;
      }
      
      public function get creditsColor() : String
      {
         return this._creditsColor;
      }
      
      public function set creditsColor(value:String) : void
      {
         this._creditsColor = value;
      }
      
      public function get creditsOffset() : Number
      {
         return this._creditsOffset;
      }
      
      public function set creditsOffset(value:Number) : void
      {
         this._creditsOffset = value;
      }
      
      public function get creditsStyle() : String
      {
         return this._creditsStyle;
      }
      
      public function set creditsStyle(value:String) : void
      {
         this._creditsStyle = value;
      }
      
      public function get onCountdownStartedFn() : Function
      {
         return this._countdownStartedFn;
      }
      
      public function set onCountdownStartedFn(value:Function) : void
      {
         this._countdownStartedFn = value;
      }
      
      public function get onCountdownStoppedFn() : Function
      {
         return this._countdownStoppedFn;
      }
      
      public function set onCountdownStoppedFn(value:Function) : void
      {
         this._countdownStoppedFn = value;
      }
      
      public function setAudioHandler(val:IPostGameAudioHandler) : void
      {
         this._audioHandler = val;
      }
      
      public function reset() : void
      {
         JBGUtil.arrayGotoFrame([this._mc.roomCode,this._mc.credits,this._mc.countdownPost],"Park");
         JBGUtil.reset([this._backBehaviors,this._postGameChoices]);
         this._mc.countdownPost.removeEventListener(MovieClipEvent.EVENT_APPEAR_DONE,this._onPostGameCountdownDone);
         Gamepad.instance.removeEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._handlePostGameInput);
         Platform.instance.removeEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._handlePostGameNativeMessage);
         if(Boolean(this._creditsLoader))
         {
            this._creditsLoader.dispose();
            this._creditsLoader = null;
         }
         this._creditsCanceller();
         this._creditsCanceller = Nullable.NULL_FUNCTION;
         if(Boolean(this._creditsTween))
         {
            TweenMax.killTweensOf(this._mc.credits.container.tf);
            this._creditsTween = null;
         }
      }
      
      protected function _resetCredits() : void
      {
         if(Boolean(this._creditsTween))
         {
            this._creditsCanceller();
            this._creditsCanceller = Nullable.NULL_FUNCTION;
            TweenMax.killTweensOf(this._mc.credits.container.tf);
         }
         this._mc.credits.container.tf.y = this._mc.credits.container.balancer.y + this._mc.credits.container.balancer.height - this.creditsOffset;
         this._creditsTween = TweenMax.to(this._mc.credits.container.tf,Duration.fromSec(this._mc.credits.container.tf.tf.textHeight / this.CREDITS_SPEED).inSec,{
            "y":this._mc.credits.container.balancer.y - this._mc.credits.container.tf.tf.textHeight,
            "ease":Linear.easeNone
         });
         this._creditsCanceller = JBGUtil.eventOnce(this._creditsTween,TweenEvent.COMPLETE,function(evt:TweenEvent):void
         {
            _creditsCanceller = Nullable.NULL_FUNCTION;
            _resetCredits();
         });
      }
      
      public function handleActionShowPostGameRoomCode(ref:IActionRef, params:Object) : void
      {
         this._postGameRoomCodeTf.text = this._gameState.roomId;
         JBGUtil.gotoFrameWithFn(this._mc.roomCode,"Appear",MovieClipEvent.EVENT_APPEAR_DONE,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDismissPostGameRoomCode(ref:IActionRef, params:Object) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc.roomCode,"Disappear",MovieClipEvent.EVENT_DISAPPEAR_DONE,TSUtil.createRefEndFn(ref));
      }
      
      protected function _getPreCreditsString() : String
      {
         var winningScore:int = 0;
         var g:JBGLoader = null;
         var winner:BlobCastPlayer = null;
         winningScore = MapFold.process(this._gameState.players,function(p:BlobCastPlayer, index:int, array:Array):int
         {
            return p.score.val;
         },function(previousValue:int, currentValue:int):int
         {
            return Math.max(previousValue,currentValue);
         });
         var winners:Array = this._gameState.players.filter(function(p:BlobCastPlayer, index:int, array:Array):Boolean
         {
            return p.score.val >= winningScore;
         });
         var credits:String = "<font " + (Boolean(this._creditsStyle) ? "face=\'" + this._creditsStyle + "\'" : "") + " color=\'" + this._creditsColor + "\'>" + (winners.length == 1 ? "WINNER" : "WINNERS") + "</font>";
         credits += "\n";
         for each(winner in winners)
         {
            if(winner.isCensored.val)
            {
               credits += "CENSORED\n";
            }
            else
            {
               credits += winner.name.val + "\n";
            }
         }
         credits += "\n\n\n";
         return credits;
      }
      
      public function handleActionShowCredits(ref:IActionRef, params:Object) : void
      {
         this._creditsLoader = JBGLoader.instance.loadFile("Credits.html",function(result:Object):void
         {
            var credits:* = undefined;
            _creditsLoader = null;
            if(Boolean(result.success))
            {
               _mc.credits.container.tf.tf.autoSize = TextFieldAutoSize.CENTER;
               credits = _getPreCreditsString() + TextUtils.filter(result.data,[TextUtils.replaceFilter("\r\n","\n")]);
               _mc.credits.container.tf.tf.htmlText = credits;
            }
            _resetCredits();
            JBGUtil.gotoFrameWithFn(_mc.credits,"Appear",MovieClipEvent.EVENT_APPEAR_DONE,TSUtil.createRefEndFn(ref));
         });
      }
      
      public function handleActionDismissCredits(ref:IActionRef, params:Object) : void
      {
         if(Boolean(this._creditsTween))
         {
            TweenMax.killTweensOf(this._mc.credits.container.tf);
            this._creditsTween = null;
         }
         JBGUtil.gotoFrameWithFn(this._mc.credits,"Disappear",MovieClipEvent.EVENT_DISAPPEAR_DONE,TSUtil.createRefEndFn(ref));
      }
      
      private function _onBackFromPostGame() : void
      {
         if(this._inCountdown && SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val)
         {
            this._stopCountdown();
         }
         else
         {
            GameEngine.instance.pause();
         }
      }
      
      private function _handlePostGameInput(evt:EventWithData) : void
      {
         if(evt.data.inputs.indexOf("B") >= 0 || evt.data.inputs.indexOf("BACK") >= 0)
         {
            this._onBackFromPostGame();
         }
         else if(evt.data.inputs.indexOf("A") >= 0 || evt.data.inputs.indexOf("SELECT") >= 0)
         {
            if(!this._inCountdown && SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val)
            {
               this._postGameChoice = "PostGame_Continue";
               this._startCountdown();
            }
         }
      }
      
      private function _handlePostGameNativeMessage(evt:EventWithData) : void
      {
         if(evt.data.message == "Speech" && evt.data.parameter == "Back")
         {
            this._onBackFromPostGame();
         }
      }
      
      public function handleActionDoPostGameDecision(ref:IActionRef, params:Object) : void
      {
         var p:BlobCastPlayer = null;
         this._audioHandler.setup(params);
         this._inCountdown = false;
         this._postGameChoice = null;
         this._updateRoomBlob(this.postGameLobbyState);
         for each(p in this._gameState.players)
         {
            this._gameState.setCustomerBlobWithMetadata(p,{
               "state":"Lobby",
               "playerCanStartGame":p.isVIP && !SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val,
               "playerIsVIP":p.isVIP,
               "canDoUGC":false,
               "playerCanCensor":false
            });
         }
         this._gameState.addEventListener(BlobCastGameState.EVENT_RECEIVED_MESSAGE_FROM_PLAYER,this._onReceivedPostGameMessage);
         Gamepad.instance.addEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._handlePostGameInput);
         Platform.instance.addEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._handlePostGameNativeMessage);
         GameEngine.instance.setPauseEnabled(true);
         GameEngine.instance.setPauseType("reboot");
         this._backBehaviors.setShown(true,"BACK");
         this._postGameJoinUrl.text = BuildConfig.instance.configVal("joinUrl");
         this._postGameChoices.setShown(true,"TO_START_GAME");
         ref.end();
      }
      
      protected function _updateRoomBlob(lobbyState:String = null, customOptions:Object = null) : void
      {
         var prop:String = null;
         if(!lobbyState)
         {
            lobbyState = this._lastLobbyState;
         }
         var activeContentId:String = null;
         var isLocal:Boolean = true;
         if(UGCContentManager.instance.activeContent.val)
         {
            activeContentId = Boolean(UGCContentManager.instance.activeContent.val.remoteContentId) ? String(UGCContentManager.instance.activeContent.val.remoteContentId) : String(UGCContentManager.instance.activeContent.val.localContentId);
            isLocal = UGCContentManager.instance.activeContent.val.remoteContentId == null;
         }
         var options:Object = {
            "state":"Lobby",
            "lobbyState":lobbyState,
            "activeContentId":activeContentId,
            "formattedActiveContentId":(Boolean(activeContentId) ? UGCContentProvider.FORMAT_CONTENT_ID(activeContentId) : null),
            "isLocal":isLocal
         };
         options.gameCanStart = false;
         options.gameIsStarting = false;
         options.gameFinished = true;
         if(lobbyState == this.postGameLobbyState)
         {
            options.gameCanStart = true;
            options.gameIsStarting = false;
         }
         else if(lobbyState == this.postGameCountdownState)
         {
            options.gameCanStart = true;
            options.gameIsStarting = true;
         }
         if(customOptions != null)
         {
            for(prop in customOptions)
            {
               options[prop] = customOptions[prop];
            }
         }
         this._gameState.setRoomBlob(options);
         this._lastLobbyState = lobbyState;
      }
      
      private function _startCountdown() : void
      {
         var _readyForCountdown:Function;
         this._inCountdown = true;
         GameEngine.instance.setPauseEnabled(false);
         this._countdownStartedFn();
         this._audioHandler.playChoiceMadeAudio(Nullable.NULL_FUNCTION);
         this._stopCountdownCancellor();
         this._startCountdownCancellor();
         _readyForCountdown = function():void
         {
            _startCountdownCancellor = Nullable.NULL_FUNCTION;
            if(_postGameChoice == "PostGame_NewGame")
            {
               _onPostGameCountdownDone(null);
            }
            else
            {
               _updateRoomBlob(postGameCountdownState);
               _mc.countdownPost.addEventListener(MovieClipEvent.EVENT_APPEAR_DONE,_onPostGameCountdownDone);
               _mc.countdownPost.gotoAndPlay("Appear");
               _audioHandler.playCountdownAudio(Nullable.NULL_FUNCTION);
               if(SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val)
               {
                  _postGameChoices.setShown(true,"TO_CANCEL_GAME");
                  _backBehaviors.setShown(false);
               }
            }
         };
         if(!SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val)
         {
            this._startCountdownCancellor = JBGUtil.eventOnce(this._mc.postGameChoices,MovieClipEvent.EVENT_DISAPPEAR_DONE,_readyForCountdown);
            this._postGameChoices.setShown(false);
         }
         else
         {
            _readyForCountdown();
         }
      }
      
      private function _stopCountdown() : void
      {
         this._inCountdown = false;
         this._countdownStoppedFn();
         this._mc.countdownPost.removeEventListener(MovieClipEvent.EVENT_APPEAR_DONE,this._onPostGameCountdownDone);
         this._startCountdownCancellor();
         this._stopCountdownCancellor();
         this._stopCountdownCancellor = JBGUtil.eventOnce(this._mc.countdownPost,MovieClipEvent.EVENT_CANCEL_DONE,function():void
         {
            _stopCountdownCancellor = Nullable.NULL_FUNCTION;
            _updateRoomBlob(postGameLobbyState);
            _audioHandler.stopCountdownAudio();
            _backBehaviors.setShown(true,"BACK",function():void
            {
               GameEngine.instance.setPauseEnabled(true);
            });
            _postGameChoices.setShown(true,"TO_START_GAME");
         });
         JBGUtil.gotoFrame(this._mc.countdownPost,"GameStartCancel");
      }
      
      private function _onReceivedPostGameMessage(evt:EventWithData) : void
      {
         if(!this._inCountdown && evt.data.message.hasOwnProperty("action") && (evt.data.message.action == "PostGame_Continue" || evt.data.message.action == "PostGame_NewGame"))
         {
            this._postGameChoice = evt.data.message.action;
            this._startCountdown();
         }
         else if(this._inCountdown && evt.data.message.hasOwnProperty("action") && evt.data.message.action == "cancel")
         {
            this._stopCountdown();
         }
      }
      
      private function _onPostGameCountdownDone(evt:MovieClipEvent) : void
      {
         var p:BlobCastPlayer = null;
         this._mc.countdownPost.removeEventListener(MovieClipEvent.EVENT_APPEAR_DONE,this._onPostGameCountdownDone);
         this._gameState.removeEventListener(BlobCastGameState.EVENT_RECEIVED_MESSAGE_FROM_PLAYER,this._onReceivedPostGameMessage);
         this._gameState.resetArtifact();
         this._gameState.setRoomBlob({"state":"Gameplay_Logo"});
         for each(p in this._gameState.players)
         {
            this._gameState.setCustomerBlobWithMetadata(p,{"state":"Gameplay_Logo"});
         }
         Gamepad.instance.removeEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._handlePostGameInput);
         Platform.instance.removeEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._handlePostGameNativeMessage);
         this._backBehaviors.setShown(false,"BACK",function():void
         {
            GameEngine.instance.setPauseEnabled(true);
            GameEngine.instance.setPauseType("reboot");
         });
         this._postGameChoices.setShown(false);
         TSUtil.safeInput(this._postGameChoice);
      }
   }
}
