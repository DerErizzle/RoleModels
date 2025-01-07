package jackboxgames.widgets.lobby
{
   import flash.display.*;
   import flash.events.Event;
   import jackboxgames.ecast.*;
   import jackboxgames.engine.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.entityinteraction.lobby.*;
   import jackboxgames.events.*;
   import jackboxgames.model.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.ui.settings.SettingsMenu;
   import jackboxgames.userinput.*;
   import jackboxgames.utils.*;
   import jackboxgames.widgets.lobby.audio.*;
   
   public class Lobby implements ILobbyEventDelegate, ILobbyDataDelegate
   {
      private static const STATUS_WAITING_FOR_MORE:String = "waitingForMore";
      
      private static const STATUS_CAN_START:String = "canStart";
      
      private static const STATUS_COUNTDOWN:String = "countdown";
      
      protected var _mc:MovieClip;
      
      protected var _gs:JBGGameState;
      
      protected var _audioHandler:ILobbyAudioHandler;
      
      protected var _countdown:LobbyCountdown;
      
      protected var _choices:LobbyChoices;
      
      protected var _lobbyAudience:LobbyAudience;
      
      protected var _players:LobbyPlayers;
      
      protected var _backBehaviors:MovieClipShower;
      
      protected var _settingsBehaviors:LobbySettingsButton;
      
      protected var _roomCode:LobbyRoomCode;
      
      protected var _accessibility:LobbyAccessibility;
      
      protected var _isInCanStart:Boolean;
      
      protected var _inCountdown:Boolean;
      
      protected var _lastLobbyStatus:String;
      
      protected var _lobbyInteractionHandler:EntityInteractionHandler;
      
      protected var _lobbyInteraction:IEntityInteractionBehavior;
      
      public function Lobby(mc:MovieClip, gs:JBGGameState)
      {
         super();
         this._mc = mc;
         this._gs = gs;
         this._audioHandler = this._createAudioHandler();
         this._countdown = this._createCountdown();
         this._choices = this._createChoices();
         this._lobbyAudience = this._createAudience();
         this._players = this._createPlayers();
         this._backBehaviors = this._createBackBehaviors();
         this._settingsBehaviors = this._createSettingsBehaviors();
         this._roomCode = this._createRoomCode();
         this._accessibility = this._createAccessibility();
         this._lobbyInteraction = this._createInteractionBehavior();
         this._lobbyInteractionHandler = this._createEntityInteractionHandler();
      }
      
      protected function _createAudioHandler() : ILobbyAudioHandler
      {
         return new NullLobbyAudioHandler();
      }
      
      protected function _createCountdown() : LobbyCountdown
      {
         return new LobbyCountdown(this._mc);
      }
      
      protected function _createChoices() : LobbyChoices
      {
         return new LobbyChoices(this._mc);
      }
      
      protected function _createAudience() : LobbyAudience
      {
         return new LobbyAudience(this._mc,this._gs,this._audioHandler);
      }
      
      protected function _createPlayers() : LobbyPlayers
      {
         return new LobbyPlayers(this._mc,this._gs);
      }
      
      protected function _createBackBehaviors() : MovieClipShower
      {
         return new MovieClipShower(this._mc.backActions);
      }
      
      protected function _createSettingsBehaviors() : LobbySettingsButton
      {
         return new LobbySettingsButton(this._mc.settingsActions);
      }
      
      protected function _createHideRoomCodeBehaviors() : MovieClipShower
      {
         return new MovieClipShower(this._mc.roomInfoActions.roomInfoContainer.hideActions);
      }
      
      protected function _createRoomCode() : LobbyRoomCode
      {
         return new LobbyRoomCode(this._mc);
      }
      
      protected function _createAccessibility() : LobbyAccessibility
      {
         return new LobbyAccessibility(this._mc.roomInfoActions.roomInfoContainer.readCodeActions,this._gs);
      }
      
      protected function _createEntityInteractionHandler() : EntityInteractionHandler
      {
         return new EntityInteractionHandler(this._lobbyInteraction,this._gs,false,false,true);
      }
      
      protected function _createInteractionBehavior() : IEntityInteractionBehavior
      {
         return new LobbyInteraction(this._gs,this,this);
      }
      
      protected function _handlePlayersChanged(addedPlayers:Array) : void
      {
      }
      
      public function finalizePlayerEntity(p:JBGPlayer, entityData:Object) : void
      {
      }
      
      public function finalizeSharedEntity(entityData:Object) : void
      {
      }
      
      public function onLobbyDone() : void
      {
      }
      
      public function reset() : void
      {
         this._audioHandler.shutdown();
         JBGUtil.reset([this._countdown,this._choices,this._lobbyAudience,this._players,this._backBehaviors,this._settingsBehaviors,this._roomCode,this._accessibility,this._lobbyInteractionHandler]);
         this._gs.removeEventListener(JBGGameState.EVENT_PLAYERS_CHANGED,this._onPlayersChanged);
         UserInputDirector.instance.removeEventListener(UserInputDirector.EVENT_INPUT,this._handleLobbyInput);
         this._isInCanStart = false;
         this._inCountdown = false;
      }
      
      public function start() : void
      {
         this._isInCanStart = false;
         this._players.setupForNewLobby();
      }
      
      public function stop() : void
      {
      }
      
      public function handleActionDoPlayersAnim(ref:IActionRef, params:Object) : void
      {
         this._players.doAnimOnAllAvailablePlayerSlots(params.frame,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDoActivePlayersAnim(ref:IActionRef, params:Object) : void
      {
         this._players.doAnimOnUsedPlayerSlots(params.frame,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDoUnusedPlayersAnim(ref:IActionRef, params:Object) : void
      {
         this._players.doAnimOnUnusedPlayerSlots(params.frame,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetLobbyAccessibilityActive(ref:IActionRef, params:Object) : void
      {
         this._accessibility.setActive(TSUtil.createRefEndFn(ref),params);
      }
      
      public function handleActionReady(ref:IActionRef, params:Object) : void
      {
         this._audioHandler.setup(params);
         this._gs.reportRoomMetrics();
         this._inCountdown = false;
         this._lobbyInteractionHandler.setIsActive([],true);
         this._gs.addEventListener(JBGGameState.EVENT_PLAYERS_CHANGED,this._onPlayersChanged);
         this._lobbyAudience.setStarted(true);
         UserInputDirector.instance.addEventListener(UserInputDirector.EVENT_INPUT,this._handleLobbyInput);
         GameEngine.instance.setPauseEnabled(true);
         GameEngine.instance.setPauseContext("lobby");
         this._backBehaviors.setShown(true,Nullable.NULL_FUNCTION);
         this._settingsBehaviors.show();
         this._choices.setShown(this._canStartGame(),"TO_START");
         this._roomCode.setup(this._gs.roomId);
         this._roomCode.show(function():void
         {
            _players.doAnimOnAllAvailablePlayerSlots("Appear",TSUtil.createRefEndFn(ref));
            _players.doAnimOnAllUnavailablePlayerSlots("Max",Nullable.NULL_FUNCTION);
         });
         Analytics.instance.uaScreen(BuildConfig.instance.configVal("uaAppId") + "-lobby");
         this._updateLobbyStatus(STATUS_WAITING_FOR_MORE);
         ref.end();
      }
      
      private function _updateLobbyStatus(lobbyStatus:String) : void
      {
         this._lastLobbyStatus = lobbyStatus;
      }
      
      private function _onBackFromLobby() : void
      {
         GameEngine.instance.pause();
      }
      
      private function _handleLobbyInput(evt:EventWithData) : void
      {
         if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_BACK))
         {
            if(this._inCountdown && this._isInCanStart && SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val)
            {
               this._stopCountdown();
            }
            else
            {
               GameEngine.instance.pause();
            }
         }
         else if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_ALT1))
         {
            if(!this._inCountdown)
            {
               if(SettingsManager.instance.getValue(SettingsConstants.SETTING_HIDE_ROOMCODE).val)
               {
                  this._roomCode.toggleRoomCodeHidden();
                  this._audioHandler.playHideRoomCodeAudio(Nullable.NULL_FUNCTION);
               }
            }
         }
         else if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_ALT2))
         {
            if(!this._inCountdown)
            {
               JBGUtil.eventOnce(SettingsMenu.instance,SettingsMenu.EVENT_CLOSED,function(evt:Event):void
               {
                  GameEngine.instance.setPauseEnabled(true);
                  UserInputDirector.instance.addEventListener(UserInputDirector.EVENT_INPUT,_handleLobbyInput);
               });
               GameEngine.instance.setPauseEnabled(false);
               UserInputDirector.instance.removeEventListener(UserInputDirector.EVENT_INPUT,this._handleLobbyInput);
               SettingsMenu.instance.prepare("lobby","main");
               SettingsMenu.instance.open();
            }
         }
         else if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_UP))
         {
            if(!this._inCountdown)
            {
               this._accessibility.readRoomCode();
            }
         }
         else if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_SELECT))
         {
            if(SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val)
            {
               if(!this._isInCanStart)
               {
                  return;
               }
               if(!this._inCountdown)
               {
                  this._startCountdown();
               }
            }
         }
      }
      
      private function _canStartGame() : Boolean
      {
         return this._gs.numPlayers >= this._gs.minPlayers;
      }
      
      private function _onPlayersChanged(evt:EventWithData) : void
      {
         var p:JBGPlayer = null;
         if(this._inCountdown)
         {
            this._isInCanStart = false;
            this._stopCountdown();
         }
         for each(p in evt.data.added)
         {
            this._players.setupForPlayer(p.index.val,p);
            this._audioHandler.playPlayerJoinedAudio(p,Nullable.NULL_FUNCTION);
         }
         if(this._gs.players.length > 0)
         {
            this._choices.setEverybodysInText(this._gs.VIP.name.val);
         }
         this._updateCanStart();
         this._handlePlayersChanged(evt.data.added);
         this._lobbyInteractionHandler.forceUpdateEntities(new EntityUpdateRequest().withPlayerMainEntity(this._gs.players));
      }
      
      protected function _startCountdown() : void
      {
         this._inCountdown = true;
         this._updateLobbyStatus(STATUS_COUNTDOWN);
         this._countdown.start(this._onCountdownDone);
         this._audioHandler.playCountdownAudio(Nullable.NULL_FUNCTION);
         SettingsMenu.instance.closeIfOpen();
         this._backBehaviors.setShown(false,Nullable.NULL_FUNCTION);
         this._settingsBehaviors.dismiss();
         this._roomCode.dismissHideCallout();
         this._accessibility.setShown(false,Nullable.NULL_FUNCTION);
         this._choices.setShown(false,"",function():void
         {
            if(SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val)
            {
               GameEngine.instance.setPauseEnabled(false);
               _choices.setShown(true,"TO_CANCEL");
            }
         });
         this._audioHandler.playEverybodysInOffAudio(Nullable.NULL_FUNCTION);
      }
      
      protected function _stopCountdown() : void
      {
         this._inCountdown = false;
         this._choices.setShown(false,"",function():void
         {
            GameEngine.instance.setPauseEnabled(true);
            _choices.setShown(_canStartGame(),"TO_START");
         });
         this._updateLobbyStatus(this._canStartGame() ? STATUS_CAN_START : STATUS_WAITING_FOR_MORE);
         this._backBehaviors.setShown(true,Nullable.NULL_FUNCTION);
         this._settingsBehaviors.show();
         this._roomCode.showHideCallout();
         this._accessibility.setShown(true,Nullable.NULL_FUNCTION);
         this._countdown.cancel(function():void
         {
            if(_canStartGame())
            {
               _audioHandler.playEverybodysInOnAudio(Nullable.NULL_FUNCTION);
            }
            _audioHandler.stopCountdownAudio();
         });
      }
      
      protected function get _shouldLockLobby() : Boolean
      {
         return true;
      }
      
      private function _onCountdownDone() : void
      {
         var onPlayersChangedWhileClosingRoom:Function = null;
         onPlayersChangedWhileClosingRoom = function(evt:EventWithData):void
         {
            var p:JBGPlayer = null;
            var entity:Object = null;
            for each(p in evt.data.added)
            {
               entity = {"kind":"waiting"};
               finalizePlayerEntity(p,entity);
               _gs.setCustomerBlobWithMetadata(p,entity);
            }
         };
         if(SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val)
         {
            this._choices.setShown(false);
         }
         this._audioHandler.playRoomCodeDisappearAudio(Nullable.NULL_FUNCTION);
         this._inCountdown = false;
         UserInputDirector.instance.removeEventListener(UserInputDirector.EVENT_INPUT,this._handleLobbyInput);
         this._backBehaviors.setShown(false,Nullable.NULL_FUNCTION);
         this._settingsBehaviors.dismiss();
         this._roomCode.dismissHideCallout();
         this._accessibility.setShown(false,Nullable.NULL_FUNCTION);
         this._lobbyInteractionHandler.setIsActive(this._gs.players,false);
         this._gs.removeEventListener(JBGGameState.EVENT_PLAYERS_CHANGED,this._onPlayersChanged);
         this._lobbyAudience.setStarted(false);
         this._lobbyAudience.dismiss();
         this.stop();
         if(this._shouldLockLobby)
         {
            this._gs.addEventListener(JBGGameState.EVENT_PLAYERS_CHANGED,onPlayersChangedWhileClosingRoom);
            this._gs.lockRoom().then(function():void
            {
               _gs.removeEventListener(JBGGameState.EVENT_PLAYERS_CHANGED,onPlayersChangedWhileClosingRoom);
               Analytics.instance.uaScreen(BuildConfig.instance.configVal("uaAppId") + "-gameplay");
               Analytics.instance.uaEvent(BuildConfig.instance.configVal("uaAppId"),"start",null,_gs.numPlayers);
               GameEngine.instance.setPauseEnabled(true);
               GameEngine.instance.setPauseContext("gameplay");
               TSUtil.safeInput("Lobby_Done");
            });
         }
         else
         {
            GameEngine.instance.setPauseEnabled(true);
            GameEngine.instance.setPauseContext("gameplay");
            TSUtil.safeInput("Lobby_Done");
         }
      }
      
      private function _updateCanStart() : void
      {
         var p:JBGPlayer = null;
         for each(p in this._gs.players)
         {
            if(p == null)
            {
            }
         }
         if(this._canStartGame())
         {
            this._updateLobbyStatus(STATUS_CAN_START);
            if(!this._isInCanStart)
            {
               this._choices.setShown(true,"TO_START");
               this._audioHandler.playEverybodysInOnAudio(Nullable.NULL_FUNCTION);
               this._isInCanStart = true;
            }
         }
         else
         {
            this._updateLobbyStatus(STATUS_WAITING_FOR_MORE);
         }
      }
      
      public function getLobbyStatus() : String
      {
         return this._lastLobbyStatus;
      }
      
      public function onAction(p:JBGPlayer, action:String, updateRequest:EntityUpdateRequest) : void
      {
         if(p.isVIP && this._isInCanStart && !SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val)
         {
            if(!this._inCountdown && action == "start")
            {
               this._startCountdown();
               updateRequest.withPlayerMainEntity(this._gs.VIP);
            }
            else if(this._inCountdown && action == "cancel")
            {
               this._stopCountdown();
               updateRequest.withPlayerMainEntity(this._gs.VIP);
            }
         }
      }
   }
}

