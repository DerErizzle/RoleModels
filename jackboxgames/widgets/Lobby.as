package jackboxgames.widgets
{
   import flash.display.*;
   import jackboxgames.blobcast.model.*;
   import jackboxgames.engine.*;
   import jackboxgames.events.*;
   import jackboxgames.localizy.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.text.*;
   import jackboxgames.ugc.*;
   import jackboxgames.utils.*;
   
   public class Lobby
   {
       
      
      protected var _mc:MovieClip;
      
      protected var _gameState:BlobCastGameState;
      
      protected var _minPlayers:int;
      
      protected var _playerMCs:Array;
      
      private var _playerNameTfs:Array;
      
      private var _playersHaveAppear:Boolean;
      
      private var _countDownCancelCallback:Function;
      
      protected var _settingsIcons:Array;
      
      private var _roomCodeHidden:Boolean = false;
      
      private var _hideRoomCodeBehaviors:ButtonCallout;
      
      private var _lobbyChoices:LobbyChoices;
      
      private var _roomCodeTf:ExtendableTextField;
      
      private var _joinUrlTf:ExtendableTextField;
      
      private var _titleRoomCodeTf:ExtendableTextField;
      
      private var _titleUrlTf:ExtendableTextField;
      
      private var _isInCanStart:Boolean;
      
      private var _inCountdown:Boolean;
      
      private var _isLoadingUGC:Boolean;
      
      protected var _lobbyAudience:ILobbyAudience;
      
      protected var _lastLobbyState:String;
      
      private var _customContentShower:MovieClipShower;
      
      private var _customContentIdTf:ExtendableTextField;
      
      private var _customContentTitleTf:ExtendableTextField;
      
      private var _customContentAuthorTf:ExtendableTextField;
      
      private var _UGCWarning:MovieClipShower;
      
      private var _lastUGCResult:Object;
      
      private var _audioHandler:ILobbyAudioHandler;
      
      private var _backBehaviors:ButtonCallout;
      
      private var _readyRefEndFn:Function;
      
      private var _startCountdownCancellor:Function;
      
      private var _stopCountdownCancellor:Function;
      
      private var _onPlayerJoinedFn:Function;
      
      private var _onMessageReceivedFn:Function;
      
      private var _updateRoomBlob:Function;
      
      private var _updateCustomerBlob:Function;
      
      public function Lobby(mc:MovieClip, gameState:BlobCastGameState, minPlayers:int)
      {
         var postEffects:Array = null;
         this._startCountdownCancellor = Nullable.NULL_FUNCTION;
         this._stopCountdownCancellor = Nullable.NULL_FUNCTION;
         this._onPlayerJoinedFn = Nullable.NULL_FUNCTION;
         this._onMessageReceivedFn = Nullable.NULL_FUNCTION;
         this._updateRoomBlob = Nullable.NULL_FUNCTION;
         this._updateCustomerBlob = Nullable.NULL_FUNCTION;
         super();
         this._mc = mc;
         this._gameState = gameState;
         this._minPlayers = minPlayers;
         this._audioHandler = new NullLobbyAudioHandler();
         this._playersHaveAppear = false;
         this._countDownCancelCallback = function():void
         {
            JBGUtil.gotoFrame(_mc.info,"Appear");
         };
         this._backBehaviors = new ButtonCallout(this._mc.back,["BACK","B"]);
         this._buildAudience();
         this._lobbyChoices = new LobbyChoices(this._mc.info.everybodysIn);
         this._playerMCs = MovieClipUtil.getChildrenWithNameInOrder(this._mc,"player");
         this._playersHaveAppear = MovieClipUtil.frameExists(this._playerMCs[0],"Appear");
         this._playerNameTfs = this._playerMCs.map(function(element:MovieClip, index:int, array:Array):ExtendableTextField
         {
            if(element.hasOwnProperty("join"))
            {
               LocalizedTextFieldManager.instance.add([element.join.tf]);
            }
            return new ExtendableTextField(element.playerName,[],[PostEffectFactory.createDynamicResizerEffect(1,4,100,2),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         });
         if(Boolean(this._mc.info))
         {
            this._roomCodeTf = new ExtendableTextField(this._mc.info.device.roomCode.code,[],[PostEffectFactory.createDynamicResizerEffect(1),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
            this._joinUrlTf = new ExtendableTextField(this._mc.info.device.joinUrl,[],[PostEffectFactory.createDynamicResizerEffect(1),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
            this._settingsIcons = MovieClipUtil.getChildrenWithNameInOrder(this._mc.icons,"icon");
            this._hideRoomCodeBehaviors = new ButtonCallout(this._mc.info.device.hide,["X","SPACE"],"Menu_XButton");
            if(Boolean(this._mc.info.device.urlTitle))
            {
               LocalizedTextFieldManager.instance.add([this._mc.info.device.urlTitle.tf]);
               this._titleUrlTf = new ExtendableTextField(this._mc.info.device.urlTitle,[],[PostEffectFactory.createDynamicResizerEffect(1),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
            }
            if(Boolean(this._mc.info.device.roomCodeTitle))
            {
               LocalizedTextFieldManager.instance.add([this._mc.info.device.roomCodeTitle.tf]);
               this._titleRoomCodeTf = new ExtendableTextField(this._mc.info.device.roomCodeTitle,[],[PostEffectFactory.createDynamicResizerEffect(1),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
            }
         }
         if(Boolean(this._mc.customContent))
         {
            this._customContentShower = new MovieClipShower(this._mc.customContent);
            this._customContentShower.addEventListener(MovieClipShower.EVENT_SHOWN_CHANGED,function(evt:EventWithData):void
            {
               if(_customContentShower.isShown)
               {
                  _audioHandler.playUGCOnAudio(Nullable.NULL_FUNCTION);
               }
               else
               {
                  _audioHandler.playUGCOffAudio(Nullable.NULL_FUNCTION);
               }
            });
            postEffects = [PostEffectFactory.createDynamicResizerEffect(1),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)];
            this._customContentIdTf = new ExtendableTextField(this._mc.customContent.container.contentId.tf,[],postEffects);
            this._customContentTitleTf = new ExtendableTextField(this._mc.customContent.container.title,[],postEffects);
            this._customContentAuthorTf = new ExtendableTextField(this._mc.customContent.container.author,[],postEffects);
         }
         if(Boolean(this._mc.UGCwarning))
         {
            this._UGCWarning = new MovieClipShower(this._mc.UGCwarning);
         }
      }
      
      public function get minPlayers() : int
      {
         return this._minPlayers;
      }
      
      public function set minPlayers(value:int) : void
      {
         this._minPlayers = value;
      }
      
      protected function set countDownCancelCallback(callbackFn:Function) : void
      {
         this._countDownCancelCallback = callbackFn;
      }
      
      public function get lobbyAudience() : ILobbyAudience
      {
         return this._lobbyAudience;
      }
      
      public function get onPlayerJoinedFn() : Function
      {
         return this._onPlayerJoinedFn;
      }
      
      public function set onPlayerJoinedFn(value:Function) : void
      {
         this._onPlayerJoinedFn = value;
      }
      
      public function get onMessageReceivedFn() : Function
      {
         return this._onMessageReceivedFn;
      }
      
      public function set onMessageReceivedFn(value:Function) : void
      {
         this._onMessageReceivedFn = value;
      }
      
      public function get updateRoomBlob() : Function
      {
         return this._updateRoomBlob;
      }
      
      public function set updateRoomBlob(value:Function) : void
      {
         this._updateRoomBlob = value;
      }
      
      public function get updateCustomerBlob() : Function
      {
         return this._updateCustomerBlob;
      }
      
      public function set updateCustomerBlob(value:Function) : void
      {
         this._updateCustomerBlob = value;
      }
      
      public function get playerMcs() : Array
      {
         return this._playerMCs;
      }
      
      public function get playerNameTfs() : Array
      {
         return this._playerNameTfs;
      }
      
      public function setAudioHandler(val:ILobbyAudioHandler) : void
      {
         this._audioHandler = val;
      }
      
      protected function _buildAudience() : void
      {
         this._lobbyAudience = new LobbyAudience(this._mc,this._gameState);
      }
      
      public function reset() : void
      {
         this._readyRefEndFn = Nullable.NULL_FUNCTION;
         JBGUtil.arrayGotoFrame([this._mc.info],"Park");
         JBGUtil.arrayGotoFrame(this._playerMCs,"Park");
         JBGUtil.arrayGotoFrame(this._settingsIcons,"Park");
         JBGUtil.reset([this._lobbyAudience,this._UGCWarning,this._customContentShower,this._backBehaviors,this._lobbyChoices,this._hideRoomCodeBehaviors]);
         this._gameState.removeEventListener(BlobCastGameState.EVENT_PLAYERS_CHANGED,this._onPlayersChanged);
         this._gameState.removeEventListener(BlobCastGameState.EVENT_RECEIVED_MESSAGE_FROM_PLAYER,this._onReceivedMessage);
         this._mc.info.removeEventListener(MovieClipEvent.EVENT_COUNTDOWN_DONE,this._onCountdownDone);
         Gamepad.instance.removeEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._handleLobbyInput);
         Platform.instance.removeEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._handleLobbyNativeMessage);
         this._lastUGCResult = null;
         this._isLoadingUGC = false;
         this._isInCanStart = false;
         this._inCountdown = false;
         this._audioHandler.shutdown();
      }
      
      public function start() : void
      {
         this._isInCanStart = false;
         JBGUtil.arrayGotoFrameWithFn(this._playerMCs,"Park",null,null);
      }
      
      public function stop() : void
      {
      }
      
      public function handleActionDoPlayersAnim(ref:IActionRef, params:Object) : void
      {
         var playerMCsToAnimate:Array = this._playerMCs.slice(0,SettingsManager.instance.getValue(SettingsConstants.SETTING_MAX_PLAYERS).val);
         JBGUtil.arrayGotoFrameWithFn(playerMCsToAnimate,params.frame,MovieClipEvent.EVENT_ANIMATION_DONE,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDoActivePlayersAnim(ref:IActionRef, params:Object) : void
      {
         var players:Array = this._playerMCs.filter(function(item:*, index:int, array:Array):Boolean
         {
            return index < _gameState.players.length;
         });
         if(players.length == 0)
         {
            ref.end();
            return;
         }
         JBGUtil.arrayGotoFrameWithFn(players,params.frame,MovieClipEvent.EVENT_ANIMATION_DONE,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDoUnusedPlayersAnim(ref:IActionRef, params:Object) : void
      {
         var players:Array = this._playerMCs.filter(function(item:*, index:int, array:Array):Boolean
         {
            return index >= _gameState.players.length && index < SettingsManager.instance.getValue(SettingsConstants.SETTING_MAX_PLAYERS).val;
         });
         JBGUtil.arrayGotoFrameWithFn(players,params.frame,MovieClipEvent.EVENT_ANIMATION_DONE,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionReady(ref:IActionRef, params:Object) : void
      {
         var showHideRoomCode:Boolean;
         var hideTf:ExtendableTextField = null;
         this._audioHandler.setup(params);
         this._inCountdown = false;
         this._lastUGCResult = null;
         this._gameState.addEventListener(BlobCastGameState.EVENT_PLAYERS_CHANGED,this._onPlayersChanged);
         this._gameState.addEventListener(BlobCastGameState.EVENT_RECEIVED_MESSAGE_FROM_PLAYER,this._onReceivedMessage);
         this._lobbyAudience.start(SettingsManager.instance.getValue(SettingsConstants.SETTING_MAX_PLAYERS).val,this._audioHandler);
         showHideRoomCode = SettingsManager.instance.getValue(SettingsConstants.SETTING_HIDE_ROOMCODE).val;
         JBGUtil.gotoFrame(this._mc.info.device.hide,showHideRoomCode ? "Appear" : "Park");
         this._roomCodeHidden = showHideRoomCode;
         this._roomCodeTf.text = this._roomCodeHidden ? "?????" : this._gameState.roomId;
         if(Boolean(this._mc.info.device.hide.container.tf))
         {
            hideTf = new ExtendableTextField(this._mc.info.device.hide.container,[],[]);
            hideTf.text = LocalizationManager.instance.getText(this._roomCodeHidden ? "UNHIDE" : "HIDE");
         }
         JBGUtil.gotoFrame(this._mc.info.device.roomCode,this._roomCodeHidden ? "Hidden" : "Default");
         Gamepad.instance.addEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._handleLobbyInput);
         Platform.instance.addEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._handleLobbyNativeMessage);
         GameEngine.instance.setPauseEnabled(true);
         GameEngine.instance.setPauseType("reboot");
         this._backBehaviors.setShown(true,"BACK");
         this._lobbyChoices.setShown(this._canStartGame(),"TO_START");
         this._joinUrlTf.text = BuildConfig.instance.configVal("joinUrl");
         this._readyRefEndFn = TSUtil.createRefEndFn(ref);
         JBGUtil.gotoFrameWithFn(this._mc.info,"Appear",MovieClipEvent.EVENT_ANIMATION_DONE,function():void
         {
            var playersToAppear:Array = null;
            var unusedPlayers:Array = null;
            if(_playersHaveAppear)
            {
               playersToAppear = ArrayUtil.copy(_playerMCs);
               unusedPlayers = playersToAppear.splice(SettingsManager.instance.getValue(SettingsConstants.SETTING_MAX_PLAYERS).val);
               if(MovieClipUtil.frameExists(_playerMCs[0],"Max"))
               {
                  JBGUtil.arrayGotoFrame(unusedPlayers,"Max");
               }
               JBGUtil.arrayGotoFrameWithFn(playersToAppear,"Appear",MovieClipEvent.EVENT_APPEAR_DONE,_readyRefEndFn);
            }
            else
            {
               _readyRefEndFn();
            }
         });
         BlobCast.instance.uaScreen(BuildConfig.instance.configVal("uaAppId") + "-lobby");
         UGCContentManager.instance.activeContent.addEventListener(WatchableValue.EVENT_VALUE_CHANGED,this._onActiveContentChanged);
         this._onActiveContentChanged(null);
         this._setupSettingsIcons();
         this._gameState.setRoomBlob({"state":"Lobby"});
         ref.end();
      }
      
      private function _onActiveContentChanged(evt:EventWithData) : void
      {
         var content:Object = UGCContentManager.instance.activeContent.val;
         if(Boolean(this._customContentShower))
         {
            this._customContentShower.setShown(content != null,Nullable.NULL_FUNCTION);
         }
         if(Boolean(content))
         {
            this._customContentIdTf.text = "";
            if(Boolean(content.remoteContentId))
            {
               this._customContentIdTf.text = UGCContentProvider.FORMAT_CONTENT_ID(content.remoteContentId.toUpperCase());
            }
            this._customContentTitleTf.text = content.metadata.title;
            this._customContentAuthorTf.text = content.metadata.author;
         }
         if(evt != null)
         {
            this._updateRoomBlob();
            if(this._gameState.players.length > 0)
            {
               this._updateCustomerBlob(this._gameState.players[0]);
            }
         }
         if(Boolean(this._UGCWarning))
         {
            this._UGCWarning.setShown(UGCContentManager.instance.activeContent.val != null,Nullable.NULL_FUNCTION);
         }
      }
      
      public function handleUpdateRoomBlob(lobbyState:String = null, options:Object = null) : void
      {
         if(!lobbyState)
         {
            lobbyState = this._lastLobbyState;
         }
         if(!options)
         {
            options = {};
         }
         var activeContentId:String = null;
         var isLocal:Boolean = true;
         if(UGCContentManager.instance.activeContent.val)
         {
            activeContentId = Boolean(UGCContentManager.instance.activeContent.val.remoteContentId) ? String(UGCContentManager.instance.activeContent.val.remoteContentId) : String(UGCContentManager.instance.activeContent.val.localContentId);
            isLocal = UGCContentManager.instance.activeContent.val.remoteContentId == null;
         }
         options.state = "Lobby";
         options.lobbyState = lobbyState;
         options.activeContentId = activeContentId;
         options.formattedActiveContentId = Boolean(activeContentId) ? UGCContentProvider.FORMAT_CONTENT_ID(activeContentId) : null;
         options.isLocal = isLocal;
         options.gameCanStart = false;
         options.gameIsStarting = false;
         options.gameFinished = false;
         if(lobbyState == "CanStart")
         {
            options.gameCanStart = true;
            options.gameIsStarting = false;
         }
         else if(lobbyState == "Countdown")
         {
            options.gameCanStart = true;
            options.gameIsStarting = true;
         }
         this._gameState.setRoomBlob(options);
         this._lastLobbyState = lobbyState;
      }
      
      private function _canViewAuthor(p:BlobCastPlayer) : Boolean
      {
         return p.isVIP && UGCContentManager.instance.activeContent.val && UGCContentManager.instance.activeContent.val.creator && Platform.instance.PlatformId == UGCContentManager.instance.activeContent.val.creator.platformId && Platform.instance.PlatformIdUpperCase == "PS4";
      }
      
      public function handleUpdateCustomerBlob(p:BlobCastPlayer, lobbyState:String = null) : void
      {
         var blob:Object;
         var allContent:Array = null;
         if(lobbyState == null)
         {
            lobbyState = this._lastLobbyState;
         }
         blob = {
            "state":"Lobby",
            "playerIsVIP":p.isVIP,
            "playerCanStartGame":p.isVIP && !SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val,
            "playerCanDoUGC":p.isVIP,
            "playerCanCensor":SettingsManager.instance.getValue(SettingsConstants.SETTING_CENSORABLE).val && p.isVIP,
            "playerCanReport":p.isVIP,
            "playerCanViewAuthor":this._canViewAuthor(p)
         };
         if(p.isVIP)
         {
            allContent = UGCContentProvider.instance.getAllContent();
            blob.history = allContent.map(function(o:Object, ... args):Object
            {
               return {
                  "localContentId":o.localContentId,
                  "remoteContentId":o.remoteContentId,
                  "formattedRemoteContentId":UGCContentProvider.FORMAT_CONTENT_ID(o.remoteContentId),
                  "metadata":o.metadata
               };
            });
            blob.lastUGCResult = Boolean(this._lastUGCResult) ? {
               "success":this._lastUGCResult.success,
               "error":this._lastUGCResult.error
            } : null;
         }
         this._gameState.setCustomerBlobWithMetadata(p,blob);
         this._lastLobbyState = lobbyState;
      }
      
      protected function _settingShouldShowIcon(settingId:String) : Boolean
      {
         if(settingId == SettingsConstants.SETTING_AUDIENCE_ON)
         {
            return SettingsManager.instance.getValue(settingId).val;
         }
         return !SettingsManager.instance.getValue(settingId).isSetToDefault;
      }
      
      protected function _setupSettingsIcons() : void
      {
         var label:FrameLabel = null;
         var tf:ExtendableTextField = null;
         var iconIndex:int = 0;
         var iconMC:MovieClip = this._settingsIcons[iconIndex];
         var labels:Array = iconMC.content.currentLabels;
         for each(label in labels)
         {
            JBGUtil.gotoFrame(iconMC.content,label.name);
            if(Boolean(iconMC.content.tf))
            {
               if(this._settingShouldShowIcon(label.name))
               {
                  tf = new ExtendableTextField(iconMC.content.tf,[],[]);
                  tf.text = String(SettingsManager.instance.getValue(label.name).val);
                  JBGUtil.gotoFrame(iconMC,"Appear");
                  iconMC = this._settingsIcons[++iconIndex];
               }
            }
            else if(SettingsManager.instance.getValue(label.name).val)
            {
               JBGUtil.gotoFrame(iconMC,"Appear");
               iconMC = this._settingsIcons[++iconIndex];
            }
         }
      }
      
      private function _onBackFromLobby() : void
      {
         GameEngine.instance.pause();
      }
      
      private function _handleLobbyInput(evt:EventWithData) : void
      {
         var hideTf:ExtendableTextField = null;
         if(evt.data.inputs.indexOf("B") >= 0 || evt.data.inputs.indexOf("BACK") >= 0)
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
         else if(evt.data.inputs.indexOf("X") >= 0 || evt.data.inputs.indexOf("SPACE") >= 0 || EnvUtil.isMobile() && evt.data.inputs.indexOf("DPAD_LEFT") >= 0)
         {
            if(SettingsManager.instance.getValue(SettingsConstants.SETTING_HIDE_ROOMCODE).val)
            {
               this._roomCodeHidden = !this._roomCodeHidden;
               this._roomCodeTf.text = this._roomCodeHidden ? "?????" : this._gameState.roomId;
               if(Boolean(this._mc.info.device.hide.container.tf))
               {
                  hideTf = new ExtendableTextField(this._mc.info.device.hide.container,[],[]);
                  hideTf.text = LocalizationManager.instance.getText(this._roomCodeHidden ? "UNHIDE" : "HIDE");
               }
               JBGUtil.gotoFrame(this._mc.info.device.roomCode,this._roomCodeHidden ? "Hidden" : "Default");
               this._audioHandler.playHideRoomCodeAudio(Nullable.NULL_FUNCTION);
            }
         }
         else if(evt.data.inputs.indexOf("A") >= 0 || evt.data.inputs.indexOf("SELECT") >= 0)
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
      
      private function _handleLobbyNativeMessage(evt:EventWithData) : void
      {
         if(evt.data.message == "Speech" && evt.data.parameter == "Back")
         {
            this._onBackFromLobby();
         }
      }
      
      private function _canStartGame() : Boolean
      {
         return this._gameState.numPlayers >= this._minPlayers;
      }
      
      private function _onPlayersChanged(evt:EventWithData) : void
      {
         var p:BlobCastPlayer = null;
         if(this._inCountdown)
         {
            this._isInCanStart = false;
            this._stopCountdown();
         }
         for each(p in evt.data.added)
         {
            this._updateCustomerBlob(p);
            this._playerNameTfs[p.index.val].text = p.name.val;
            if(this._onPlayerJoinedFn == Nullable.NULL_FUNCTION)
            {
               JBGUtil.gotoFrame(this._playerMCs[p.index.val],"AppearPlayer");
            }
            else
            {
               this._onPlayerJoinedFn(p);
            }
            this._audioHandler.playPlayerJoinedAudio(p,Nullable.NULL_FUNCTION);
         }
         if(this._gameState.players.length > 1)
         {
            this._updateCustomerBlob(this._gameState.players[0]);
         }
         this._updateCanStart();
      }
      
      private function _onReceivedMessage(evt:EventWithData) : void
      {
         var p:BlobCastPlayer = null;
         var playerWhoSentMessage:BlobCastPlayer = evt.data.player;
         var playerIndex:int = playerWhoSentMessage.index.val;
         if(playerWhoSentMessage.isVIP && this._isInCanStart && !SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val)
         {
            if(Boolean(evt.data.message.start) || evt.data.message.action == "start")
            {
               this._startCountdown();
            }
            else if(this._inCountdown && (evt.data.message.cancel || evt.data.message.action == "cancel"))
            {
               this._stopCountdown();
            }
         }
         if(playerWhoSentMessage.isVIP && !this._inCountdown && !this._isLoadingUGC)
         {
            if(Boolean(evt.data.message.activateContentId))
            {
               if(!UGCContentManager.instance.activeContent.val)
               {
                  if(Boolean(evt.data.message.hasOwnProperty("contentId")))
                  {
                     Platform.instance.checkPrivilege("UGC",function(success:Boolean):void
                     {
                        var content:Object;
                        if(!success)
                        {
                           return;
                        }
                        content = UGCContentProvider.instance.getContent(evt.data.message.contentId);
                        if(Boolean(content))
                        {
                           _lastUGCResult = null;
                           content.markAsSeen();
                           UGCContentManager.instance.activateContentData(content,Nullable.NULL_FUNCTION);
                        }
                        else
                        {
                           _isLoadingUGC = true;
                           UGCContentProvider.instance.retrieveRemoteContent(evt.data.message.contentId,function(result:Object):void
                           {
                              _isLoadingUGC = false;
                              _lastUGCResult = result;
                              if(!result.success)
                              {
                                 if(_gameState.players.length > 0 && p != _gameState.players[0])
                                 {
                                    _updateCustomerBlob(_gameState.players[0]);
                                 }
                                 return;
                              }
                              result.data.markAsSeen();
                              UGCContentManager.instance.activateContentData(result.data,Nullable.NULL_FUNCTION);
                           });
                        }
                     });
                  }
               }
            }
            else if(Boolean(evt.data.message.clearContentId))
            {
               if(UGCContentManager.instance.activeContent.val)
               {
                  UGCContentManager.instance.clearContent();
               }
            }
            else if(Boolean(evt.data.message.viewAuthor))
            {
               if(this._canViewAuthor(playerWhoSentMessage) && Boolean(UGCContentManager.instance.activeContent.val.creator))
               {
                  Platform.instance.sendMessageToNative("ShowUser",UGCContentManager.instance.activeContent.val.creator.platformUserId);
               }
            }
         }
         if(playerWhoSentMessage.isVIP && !this._inCountdown)
         {
            if(Boolean(evt.data.message.hasOwnProperty("censorPlayerId")))
            {
               p = this._gameState.getPlayerByUserId(evt.data.message.censorPlayerId) as BlobCastPlayer;
               if(Boolean(p))
               {
                  p.isCensored.val = true;
               }
               this._updateCustomerBlob(playerWhoSentMessage);
            }
         }
         this._onMessageReceivedFn(evt);
      }
      
      private function _startCountdown() : void
      {
         this._inCountdown = true;
         GameEngine.instance.setPauseEnabled(false);
         this._stopCountdownCancellor();
         this._startCountdownCancellor();
         this._startCountdownCancellor = JBGUtil.eventOnce(this._mc.info.everybodysIn,MovieClipEvent.EVENT_DISAPPEAR_DONE,function():void
         {
            _startCountdownCancellor = Nullable.NULL_FUNCTION;
            _updateRoomBlob("Countdown");
            _mc.info.addEventListener(MovieClipEvent.EVENT_COUNTDOWN_DONE,_onCountdownDone);
            _mc.info.gotoAndPlay("GameStartAppear");
            _audioHandler.playCountdownAudio(Nullable.NULL_FUNCTION);
            if(SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val)
            {
               _lobbyChoices.setShown(true,"TO_CANCEL");
               _backBehaviors.setShown(false,"BACK");
            }
         },true);
         this._lobbyChoices.setShown(false);
         this._audioHandler.playEverybodysInOffAudio(Nullable.NULL_FUNCTION);
      }
      
      private function _stopCountdown() : void
      {
         this._inCountdown = false;
         this._startCountdownCancellor();
         this._stopCountdownCancellor();
         this._mc.info.removeEventListener(MovieClipEvent.EVENT_COUNTDOWN_DONE,this._onCountdownDone);
         this._lobbyChoices.setShown(false);
         this._stopCountdownCancellor = JBGUtil.eventOnce(this._mc.info,MovieClipEvent.EVENT_CANCEL_DONE,function():void
         {
            _stopCountdownCancellor = Nullable.NULL_FUNCTION;
            _updateRoomBlob(_canStartGame() ? "CanStart" : "WaitingForMore");
            _lobbyChoices.setShown(_canStartGame(),"TO_START",function():void
            {
               GameEngine.instance.setPauseEnabled(true);
            });
            if(_canStartGame())
            {
               _audioHandler.playEverybodysInOnAudio(Nullable.NULL_FUNCTION);
            }
            _audioHandler.stopCountdownAudio();
            if(SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val)
            {
               _backBehaviors.setShown(true,"BACK");
            }
         });
         JBGUtil.gotoFrameWithFn(this._mc.info,"GameStartCancel",MovieClipEvent.EVENT_CANCEL_DONE,this._countDownCancelCallback);
      }
      
      private function _onCountdownDone(evt:MovieClipEvent) : void
      {
         var onPlayersChangedWhileClosingRoom:Function = null;
         onPlayersChangedWhileClosingRoom = function(evt:EventWithData):void
         {
            var p:BlobCastPlayer = null;
            for each(p in evt.data.added)
            {
               _gameState.setCustomerBlobWithMetadata(p,{"state":"Logo"});
            }
         };
         this._mc.info.removeEventListener(MovieClipEvent.EVENT_COUNTDOWN_DONE,this._onCountdownDone);
         if(SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val)
         {
            this._lobbyChoices.setShown(false);
         }
         this._audioHandler.playRoomCodeDisappearAudio(Nullable.NULL_FUNCTION);
         this._inCountdown = false;
         Gamepad.instance.removeEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._handleLobbyInput);
         Platform.instance.removeEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._handleLobbyNativeMessage);
         this._backBehaviors.setShown(false,"BACK");
         JBGUtil.arrayGotoFrame(this._settingsIcons,"Disappear");
         this._gameState.removeEventListener(BlobCastGameState.EVENT_RECEIVED_MESSAGE_FROM_PLAYER,this._onReceivedMessage);
         this._gameState.removeEventListener(BlobCastGameState.EVENT_PLAYERS_CHANGED,this._onPlayersChanged);
         this._lobbyAudience.stop();
         this._lobbyAudience.dismiss();
         UGCContentManager.instance.activeContent.removeEventListener(WatchableValue.EVENT_VALUE_CHANGED,this._onActiveContentChanged);
         if(Boolean(this._UGCWarning))
         {
            this._UGCWarning.setShown(false,Nullable.NULL_FUNCTION);
         }
         this._gameState.setRoomBlob({"state":"Logo"});
         this.stop();
         this._gameState.addEventListener(BlobCastGameState.EVENT_PLAYERS_CHANGED,onPlayersChangedWhileClosingRoom);
         this._gameState.lockRoom(function():void
         {
            _gameState.removeEventListener(BlobCastGameState.EVENT_PLAYERS_CHANGED,onPlayersChangedWhileClosingRoom);
            _startGameAnalytics();
            if(Boolean(_customContentShower))
            {
               _customContentShower.setShown(false,Nullable.NULL_FUNCTION);
            }
            GameEngine.instance.setPauseEnabled(true);
            TSUtil.safeInput("Lobby_Done");
         });
      }
      
      protected function _startGameAnalytics() : void
      {
         BlobCast.instance.uaScreen(BuildConfig.instance.configVal("uaAppId") + "-gameplay");
         BlobCast.instance.uaEvent(BuildConfig.instance.configVal("uaAppId"),"start",null,this._gameState.numPlayers);
      }
      
      private function _updateCanStart() : void
      {
         var p:BlobCastPlayer = null;
         for each(p in this._gameState.players)
         {
            if(p != null)
            {
               this._updateCustomerBlob(p);
            }
         }
         if(this._canStartGame())
         {
            this._updateRoomBlob("CanStart");
            if(!this._isInCanStart)
            {
               this._lobbyChoices.setShown(true,"TO_START");
               this._audioHandler.playEverybodysInOnAudio(Nullable.NULL_FUNCTION);
               this._isInCanStart = true;
            }
         }
         else
         {
            this._updateRoomBlob("WaitingForMore");
         }
      }
   }
}
