package jackboxgames.widgets.postgame
{
   import flash.display.*;
   import jackboxgames.ecast.*;
   import jackboxgames.engine.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.entityinteraction.postgame.*;
   import jackboxgames.events.*;
   import jackboxgames.model.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.userinput.*;
   import jackboxgames.utils.*;
   import jackboxgames.widgets.postgame.audio.*;
   
   public class PostGame implements IPostGameEventDelegate, IPostGameDataDelegate
   {
      protected var CREDITS_SPEED:Number = 50;
      
      protected var _mc:MovieClip;
      
      protected var _gs:JBGGameState;
      
      protected var _audioHandler:IPostGameAudioHandler;
      
      protected var _roomCode:PostGameRoomCode;
      
      protected var _countdown:PostGameCountdown;
      
      protected var _credits:PostGameCredits;
      
      protected var _postGameChoices:PostGameChoices;
      
      protected var _backBehaviors:MovieClipShower;
      
      private var _inCountdown:Boolean;
      
      private var _lastPostGameStatus:String;
      
      private var _postGameChoice:String;
      
      private var _postGameInteractionHandler:EntityInteractionHandler;
      
      private var _postGameInteraction:PostGameInteraction;
      
      public function PostGame(mc:MovieClip, gs:JBGGameState)
      {
         super();
         this._mc = mc;
         this._gs = gs;
         this._audioHandler = this._createAudioHandler();
         this._roomCode = this._createRoomCode();
         this._countdown = this._createCountdown();
         this._credits = this._createCredits();
         this._postGameChoices = this._createChoices();
         this._backBehaviors = this._createBackButton();
         this._postGameInteraction = this._createInteractionBehavior();
         this._postGameInteractionHandler = this._createEntityInteractionHandler();
      }
      
      protected function _createAudioHandler() : IPostGameAudioHandler
      {
         return new NullPostGameAudioHandler();
      }
      
      protected function _createRoomCode() : PostGameRoomCode
      {
         return new PostGameRoomCode(this._mc);
      }
      
      protected function _createCountdown() : PostGameCountdown
      {
         return new PostGameCountdown(this._mc);
      }
      
      protected function _createCredits() : PostGameCredits
      {
         return new PostGameCredits(this._mc,this._gs);
      }
      
      protected function _createChoices() : PostGameChoices
      {
         return new PostGameChoices(this._mc);
      }
      
      protected function _createBackButton() : MovieClipShower
      {
         return new MovieClipShower(this._mc.backActions);
      }
      
      protected function _createEntityInteractionHandler() : EntityInteractionHandler
      {
         return new EntityInteractionHandler(this._postGameInteraction,this._gs,false,false,true);
      }
      
      protected function _createInteractionBehavior() : PostGameInteraction
      {
         return new PostGameInteraction(this._gs,this,this);
      }
      
      protected function _onCountdownStarted() : void
      {
      }
      
      protected function _onCountdownStopped() : void
      {
      }
      
      public function finalizePlayerEntity(p:JBGPlayer, entityData:Object) : void
      {
      }
      
      public function finalizeSharedEntity(entityData:Object) : void
      {
      }
      
      public function onPostGameDone() : void
      {
      }
      
      public function dispose() : void
      {
         this._mc = null;
         this._gs = null;
         JBGUtil.dispose([this._roomCode,this._countdown,this._credits,this._postGameChoices,this._backBehaviors]);
         this._roomCode = null;
      }
      
      public function reset() : void
      {
         JBGUtil.reset([this._roomCode,this._countdown,this._credits,this._postGameChoices,this._backBehaviors,this._postGameInteractionHandler]);
         UserInputDirector.instance.removeEventListener(UserInputDirector.EVENT_INPUT,this._handlePostGameInput);
      }
      
      public function handleActionShowPostGameRoomCode(ref:IActionRef, params:Object) : void
      {
         this._roomCode.setShown(true,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDismissPostGameRoomCode(ref:IActionRef, params:Object) : void
      {
         this._roomCode.setShown(false,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionShowCredits(ref:IActionRef, params:Object) : void
      {
         this._credits.show(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDismissCredits(ref:IActionRef, params:Object) : void
      {
         this._credits.dismiss(TSUtil.createRefEndFn(ref));
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
         if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_BACK))
         {
            this._onBackFromPostGame();
         }
         else if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_SELECT))
         {
            if(!this._inCountdown && SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val)
            {
               this._postGameChoice = "samePlayers";
               this._startCountdown();
            }
         }
      }
      
      public function handleActionDoPostGameDecision(ref:IActionRef, params:Object) : void
      {
         Analytics.instance.uaScreen(BuildConfig.instance.configVal("uaAppId") + "-postgame");
         Analytics.instance.uaEvent(BuildConfig.instance.configVal("uaAppId"),"end",null,this._gs.numPlayers);
         this._audioHandler.setup(params);
         this._inCountdown = false;
         this._postGameChoice = null;
         this._updatePostGameStatus("waiting");
         this._postGameInteractionHandler.setIsActive(this._gs.players,true);
         this._gs.setAudienceBlob({"kind":"postGame"});
         UserInputDirector.instance.addEventListener(UserInputDirector.EVENT_INPUT,this._handlePostGameInput);
         GameEngine.instance.setPauseEnabled(true);
         GameEngine.instance.setPauseContext("postgame");
         this._backBehaviors.setShown(true,Nullable.NULL_FUNCTION);
         this._roomCode.setup(this._gs.roomId,BuildConfig.instance.configVal("joinUrl"));
         this._postGameChoices.setShown(true,"TO_START_GAME");
         ref.end();
      }
      
      private function _updatePostGameStatus(postGameStatus:String) : void
      {
         this._lastPostGameStatus = postGameStatus;
      }
      
      private function _startCountdown() : void
      {
         var doStart:Function = function():void
         {
            if(_postGameChoice == "newPlayers")
            {
               _onPostGameCountdownDone();
            }
            else
            {
               _countdown.start(_onPostGameCountdownDone);
               _audioHandler.playCountdownAudio(Nullable.NULL_FUNCTION);
               if(SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val)
               {
                  _postGameChoices.setShown(true,"TO_CANCEL_GAME");
                  _backBehaviors.setShown(false,Nullable.NULL_FUNCTION);
               }
            }
         };
         this._inCountdown = true;
         this._updatePostGameStatus("countdown");
         GameEngine.instance.setPauseEnabled(false);
         this._onCountdownStarted();
         this._audioHandler.playChoiceMadeAudio(Nullable.NULL_FUNCTION);
         if(!SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val)
         {
            this._postGameChoices.setShown(false,"",function():void
            {
               doStart();
            });
         }
         else
         {
            doStart();
         }
      }
      
      private function _stopCountdown() : void
      {
         this._inCountdown = false;
         this._updatePostGameStatus("waiting");
         this._onCountdownStopped();
         this._countdown.stop(function():void
         {
            _audioHandler.stopCountdownAudio();
            _backBehaviors.setShown(true,function():void
            {
               GameEngine.instance.setPauseEnabled(true);
            });
            _postGameChoices.setShown(true,"TO_START_GAME");
         });
      }
      
      private function _onPostGameCountdownDone() : void
      {
         this._postGameInteractionHandler.setIsActive(this._gs.players,false);
         this._gs.setAudienceBlob({"kind":"waiting"});
         UserInputDirector.instance.removeEventListener(UserInputDirector.EVENT_INPUT,this._handlePostGameInput);
         this._backBehaviors.setShown(false,Nullable.NULL_FUNCTION);
         this._postGameChoices.setShown(false);
         GameEngine.instance.setPauseEnabled(true);
         GameEngine.instance.setPauseContext("gameplay");
         TSUtil.safeInput(this._postGameChoice);
      }
      
      public function getPostGameStatus() : String
      {
         return this._lastPostGameStatus;
      }
      
      public function onAction(player:JBGPlayer, action:String, updateRequest:EntityUpdateRequest) : void
      {
         if(!this._inCountdown && (action == "samePlayers" || action == "newPlayers"))
         {
            this._postGameChoice = action;
            this._startCountdown();
         }
         else if(this._inCountdown && action == "cancel")
         {
            this._stopCountdown();
         }
         updateRequest.withPlayerMainEntity(this._gs.VIP);
      }
   }
}

