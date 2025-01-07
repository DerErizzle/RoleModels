package jackboxgames.model
{
   import flash.display.*;
   import flash.events.*;
   import jackboxgames.algorithm.*;
   import jackboxgames.ecast.*;
   import jackboxgames.ecast.messages.*;
   import jackboxgames.ecast.messages.client.*;
   import jackboxgames.ecast.messages.room.*;
   import jackboxgames.engine.*;
   import jackboxgames.entityinteraction.entities.*;
   import jackboxgames.events.*;
   import jackboxgames.expressionparser.*;
   import jackboxgames.localizy.*;
   import jackboxgames.logger.*;
   import jackboxgames.metrics.*;
   import jackboxgames.moderation.*;
   import jackboxgames.modules.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.ui.settings.*;
   import jackboxgames.utils.*;
   import jackboxgames.utils.audiosystem.*;
   
   public class JBGGameState extends PausableEventDispatcher
   {
      public static const EVENT_LOST_CONNECTION:String = "GameState.LostConnection";
      
      public static const EVENT_PLAYERS_CHANGED:String = "GameState.PlayersChanged";
      
      public static const EVENT_RECEIVED_MESSAGE_FROM_PLAYER:String = "GameState.ReceivedMessageFromPlayer";
      
      public static const EVENT_RECEIVED_MESSAGE_FROM_MODERATOR:String = "GameState.ReceivedMessageFromModerator";
      
      protected var _apiClient:APIClient;
      
      protected var _wsClient:WSClient;
      
      protected var _mainAudienceEntity:ObjectEntity;
      
      protected var _ts:IEngineAPI;
      
      protected var _dics:GameStateDictionaries;
      
      protected var _moderationHandler:ModerationHandler;
      
      protected var _userDataManager:UserDataManager;
      
      protected var _metrics:GameMetrics;
      
      protected var _currentRoomBlob:Object;
      
      protected var _roomId:String;
      
      protected var _hasEverSeenAudience:TSValue;
      
      protected var _isInGame:TSValue;
      
      protected var _canRestartGame:TSValue;
      
      protected var _numGamesPlayedEver:SavedTalkShowVariable;
      
      protected var _numGamesPlayedSession:TSValue;
      
      protected var _minPlayers:int;
      
      protected var _maxPlayers:int;
      
      protected var _players:Array;
      
      protected var _sessions:SessionManager;
      
      protected var _audience:Audience;
      
      private var _expressionParserDataDelegate:MultipleDataDelegate;
      
      private var _numGamesPlayedWithSamePlayers:TSValue;
      
      private var _screenOrganizer:DisplayObjectOrganizer;
      
      private var _audioRegistrationStack:AudioEventRegistrationStack;
      
      public function JBGGameState(ts:IEngineAPI, options:Object = null, target:IEventDispatcher = null)
      {
         super(target);
         this._ts = ts;
         this._ts.g.gs = this;
         this._expressionParserDataDelegate = new MultipleDataDelegate();
         this._expressionParserDataDelegate.add(new PropertyDataDelegate(this));
         ContentManager.initialize(this._expressionParserDataDelegate);
         this._userDataManager = new UserDataManager();
         this._moderationHandler = new ModerationHandler(this);
         this._metrics = new GameMetrics(this);
         this._dics = new GameStateDictionaries();
         this._dics.resetPerRun();
         this._players = [];
         this._roomId = null;
         this._hasEverSeenAudience = new TSValue("hasEverSeenAudience",false);
         this._isInGame = new TSValue("isInGame",false);
         this._canRestartGame = new TSValue("canRestartGame",false);
         this._minPlayers = 1;
         this._maxPlayers = SettingsManager.instance.getValue(SettingsConstants.SETTING_MAX_PLAYERS).val;
         SettingsManager.instance.addEventListener(SettingsManager.EVENT_SETTING_CHANGED,this._onSettingChanged);
         this._numGamesPlayedSession = new TSValue("numGamesPlayedThisSession",0);
         this._numGamesPlayedEver = new SavedTalkShowVariable(ts,"numGamesPlayedEver",0);
         this._numGamesPlayedWithSamePlayers = new TSValue("numGamesPlayedWithSamePlayers",0);
         Random.instance.seedRandom(new Date().getTime(),false);
         Analytics.initialize(BuildConfig.instance.configVal("uaAppName"),BuildConfig.instance.configVal("uaAppId") + "-" + Platform.instance.PlatformId,BuildConfig.instance.configVal("uaVersionId"));
         this._sessions = new SessionManager();
         if(Boolean(options.audience))
         {
            this._audience = this._sessions.registerModule(new Audience(this,BuildConfig.instance.configVal("gameName") + " Audience")) as Audience;
            this._audience.addEventListener(Audience.EVENT_AUDIENCE_COUNT_CHANGED,function(evt:EventWithData):void
            {
               if(evt.data > 0)
               {
                  hasEverSeenAudience = true;
               }
            });
         }
         this._audioRegistrationStack = new AudioEventRegistrationStack();
      }
      
      public function get client() : WSClient
      {
         return this._wsClient;
      }
      
      public function get mainAudienceEntity() : ObjectEntity
      {
         return this._mainAudienceEntity;
      }
      
      public function get userDataManager() : UserDataManager
      {
         return this._userDataManager;
      }
      
      public function get metrics() : GameMetrics
      {
         return this._metrics;
      }
      
      public function get VIP() : JBGPlayer
      {
         return this._players[0];
      }
      
      public function get audience() : Audience
      {
         return this._audience;
      }
      
      public function get expressionParserDataDelegate() : MultipleDataDelegate
      {
         return this._expressionParserDataDelegate;
      }
      
      public function get moderationHandler() : ModerationHandler
      {
         return this._moderationHandler;
      }
      
      public function get dics() : GameStateDictionaries
      {
         return this._dics;
      }
      
      public function get roomId() : String
      {
         return this._roomId;
      }
      
      public function get hasEverSeenAudience() : Boolean
      {
         return this._hasEverSeenAudience.val;
      }
      
      public function set hasEverSeenAudience(val:Boolean) : void
      {
         this._hasEverSeenAudience.val = val;
      }
      
      public function get isInGame() : Boolean
      {
         return this._isInGame.val;
      }
      
      public function set isInGame(val:Boolean) : void
      {
         this._isInGame.val = val;
      }
      
      public function get canRestartGame() : Boolean
      {
         return this._canRestartGame.val;
      }
      
      public function set canRestartGame(val:Boolean) : void
      {
         this._canRestartGame.val = val;
      }
      
      public function get numGamesPlayedEver() : int
      {
         return this._numGamesPlayedEver.value;
      }
      
      public function set numGamesPlayedEver(val:int) : void
      {
         this._numGamesPlayedEver.value = val;
      }
      
      public function get numGamesPlayedSession() : int
      {
         return this._numGamesPlayedSession.val;
      }
      
      public function set numGamesPlayedSession(val:int) : void
      {
         this._numGamesPlayedSession.val = val;
      }
      
      public function get numGamesPlayedWithSamePlayers() : int
      {
         return this._numGamesPlayedWithSamePlayers.val;
      }
      
      public function set numGamesPlayedWithSamePlayers(val:int) : void
      {
         this._numGamesPlayedWithSamePlayers.val = val;
      }
      
      public function get players() : Array
      {
         return this._players;
      }
      
      public function get numPlayers() : int
      {
         return this._players.length;
      }
      
      public function get minPlayers() : int
      {
         return this._minPlayers;
      }
      
      public function set minPlayers(val:int) : void
      {
         this._minPlayers = val;
      }
      
      public function get maxPlayers() : int
      {
         return this._maxPlayers;
      }
      
      public function set maxPlayers(val:int) : void
      {
         this._maxPlayers = val;
      }
      
      public function get sessions() : SessionManager
      {
         return this._sessions;
      }
      
      public function setupScreenOrganizer(d:DisplayObjectContainer) : void
      {
         this._screenOrganizer = new DisplayObjectOrganizer(d);
      }
      
      public function get screenOrganizer() : DisplayObjectOrganizer
      {
         return this._screenOrganizer;
      }
      
      public function get audioRegistrationStack() : AudioEventRegistrationStack
      {
         return this._audioRegistrationStack;
      }
      
      public function get locale() : String
      {
         return LocalizationManager.instance.currentLocale;
      }
      
      public function getPlayerByUserId(userId:String) : JBGPlayer
      {
         var p:JBGPlayer = null;
         for each(p in this._players)
         {
            if(p != null)
            {
               if(p.userId.val == userId)
               {
                  return p;
               }
            }
         }
         return null;
      }
      
      public function getPlayerBySessionId(sessionId:int) : JBGPlayer
      {
         return ArrayUtil.find(this._players,function(p:JBGPlayer, ... args):Boolean
         {
            return p.sessionId.val == sessionId;
         });
      }
      
      public function setRoomBlob(blob:Object) : void
      {
         this._currentRoomBlob = blob;
         this._wsClient.setObject("room",this._prepareSharedObject());
      }
      
      public function setAudienceBlob(blob:Object) : void
      {
         if(this._mainAudienceEntity != null)
         {
            this._mainAudienceEntity.setValue(blob);
         }
      }
      
      public function setCustomerBlobWithMetadata(p:JBGPlayer, blob:Object) : void
      {
         if(p == null)
         {
            return;
         }
         this._wsClient.updateObject("player:" + p.sessionId.val,p.updatePlayerBlob(blob));
      }
      
      protected function _prepareSharedObject() : Object
      {
         var copy:Object = Boolean(this._currentRoomBlob) ? JBGUtil.primitiveDeepCopy(this._currentRoomBlob) : {};
         copy.locale = SettingsManager.instance.getValue(LocalizationManager.SETTING_LOCALE).val;
         copy.platformId = Platform.instance.PlatformIdUpperCase;
         copy.analytics = Analytics.instance.analytics;
         return SimpleObjectUtil.deepCopyWithSimpleObjectReplacement(copy);
      }
      
      private function _addPasswordForSettingIfNeeded(options:Object, field:String, setting:String) : void
      {
         if(RoomPasswordManager.instance.hasPasswordForSetting(setting))
         {
            options[field] = RoomPasswordManager.instance.getPasswordForSetting(setting);
         }
      }
      
      private function _onSettingChanged(evt:EventWithData) : void
      {
         if(evt.data.settingName == SettingsConstants.SETTING_MAX_PLAYERS || evt.data.settingName == BuildConfig.instance.configVal("gameName") + SettingsConstants.SETTING_MAX_PLAYERS)
         {
            this._maxPlayers = SettingsManager.instance.getValue(SettingsConstants.SETTING_MAX_PLAYERS).val;
         }
      }
      
      public function createRoom() : Promise
      {
         var options:Object;
         this._resetConnection();
         options = {
            "appTag":BuildConfig.instance.configVal("gameTag"),
            "platform":Platform.instance.PlatformId,
            "twitchLocked":SettingsManager.instance.getValue(SettingsConstants.SETTING_REQUIRE_TWITCH).val,
            "maxPlayers":this._maxPlayers,
            "audienceEnabled":SettingsManager.instance.getValue(SettingsConstants.SETTING_AUDIENCE_ON).val,
            "locale":SettingsManager.instance.getValue(LocalizationManager.SETTING_LOCALE).val
         };
         if(BuildConfig.instance.configVal("roomCode"))
         {
            options.forceRoomId = BuildConfig.instance.configVal("roomCode");
         }
         if(BuildConfig.instance.configVal("licenseId"))
         {
            options.licenseId = BuildConfig.instance.configVal("licenseId");
         }
         if(BuildConfig.instance.configVal("safeNames"))
         {
            options.generateSafeNames = BuildConfig.instance.configVal("safeNames");
         }
         if(BuildConfig.instance.configVal("staff"))
         {
            options.staff = BuildConfig.instance.configVal("staff");
         }
         this._addPasswordForSettingIfNeeded(options,"password",SettingsConstants.SETTING_PASSWORDED_ROOM);
         this._addPasswordForSettingIfNeeded(options,"moderatorPassword",SettingsConstants.SETTING_MODERATED_ROOM);
         options.playerNames = EcastUtil.getExtraCreateParamsForContentFilter(SettingsManager.instance.getValue(SettingsConstants.SETTING_PLAYER_CONTENT_FILTERING).val);
         this._apiClient = new APIClient(BuildConfig.instance.configVal("gameId"),BuildConfig.instance.configVal("serverUrl"),BuildConfig.instance.configVal("protocol"));
         return this._apiClient.createRoom(options).then(function(res:CreateRoomReply):Promise
         {
            _roomId = res.code;
            JBGUtil.reset(_players);
            _players = [];
            _moderationHandler.reset();
            _resetModeration();
            _numGamesPlayedWithSamePlayers.val = 0;
            _dics.resetPerSetOfPlayers();
            GameEngine.instance.error.reset();
            _wsClient = new WSClient(res.host,res.code,BuildConfig.instance.configVal("gameId"),"host",String(Math.random() * 100000),res.token);
            _wsClient.addEventListener(WSClient.EVENT_NOTIFICATION,_parseNotification);
            _wsClient.addEventListener(WSClient.EVENT_SOCKET_CLOSE,_onDisconnect);
            if(SettingsManager.instance.getValue(SettingsConstants.SETTING_AUDIENCE_ON).val)
            {
               return _wsClient.connect().then(function(res:Notification):Promise
               {
                  canRestartGame = true;
                  _mainAudienceEntity = new ObjectEntity(_wsClient,"audiencePlayer",{"kind":"Logo"},["r role:audience"]);
                  _mainAudienceEntity.create();
                  _sessions.startPolling(_audience,{},Nullable.NULL_FUNCTION);
                  return _wsClient.startAudience();
               });
            }
            return _wsClient.connect().then(function(res:Notification):void
            {
               canRestartGame = true;
            });
         });
      }
      
      public function reportRoomMetrics() : void
      {
         this._metrics.reportMetrics(GameMetrics.KEY_SETTINGS,SettingsDataStore.instance.parseMetrics());
         this._metrics.reportMetrics(GameMetrics.KEY_PLATFORM,Platform.instance.parseMetrics());
      }
      
      public function lockRoom() : Promise
      {
         return this._wsClient.lockRoom();
      }
      
      public function showLogoForPlayer(p:JBGPlayer, message:String = null) : void
      {
         var blob:Object = {"state":"Logo"};
         if(message != null)
         {
            blob.message = {"html":message};
         }
         this.setCustomerBlobWithMetadata(p,blob);
      }
      
      public function showLogoForPlayers(players:Array, message:String = null) : void
      {
         var p:JBGPlayer = null;
         for each(p in players)
         {
            this.showLogoForPlayer(p,message);
         }
      }
      
      public function showLogoForAllPlayers(message:String = null) : void
      {
         var p:JBGPlayer = null;
         for each(p in this._players)
         {
            this.showLogoForPlayer(p,message);
         }
      }
      
      public function setPlayerControllerStateToWait(p:JBGPlayer, message:String = undefined) : void
      {
         if(this._wsClient != null)
         {
            this._wsClient.updateObject("player:" + p.sessionId.val,{
               "kind":"waiting",
               "message":message
            });
         }
      }
      
      public function destroy() : void
      {
         this._audioRegistrationStack.reset();
      }
      
      protected function _onCustomerJoined(result:ClientConnected) : void
      {
         if(Boolean(this.getPlayerByUserId(result.userId)))
         {
            return;
         }
         if(this.numPlayers >= this._maxPlayers)
         {
            return;
         }
         if(result.reconnect)
         {
         }
         var newPlayer:JBGPlayer = this.createPlayer(this._players.length,result.id,result.userId,TextUtils.filter(result.name,[TextUtils.truncateFilter(12)]));
         newPlayer.mainEntity.create();
         this._players.push(newPlayer);
         this._wsClient.setObject("info:" + newPlayer.sessionId.val,this._generateInfoForPlayer(newPlayer),this._getACLsForInfo(newPlayer));
         dispatchEvent(new EventWithData(EVENT_PLAYERS_CHANGED,{
            "added":[newPlayer],
            "removed":[]
         }));
      }
      
      protected function createPlayer(index:int, sessionId:int, userId:String, name:String) : JBGPlayer
      {
         var p:JBGPlayer = new JBGPlayer();
         p.initialize(index,sessionId,userId,name,new ObjectEntity(this._wsClient,"player:" + sessionId,{},["r id:" + sessionId]));
         return p;
      }
      
      protected function _generateInfoForPlayer(p:JBGPlayer) : Object
      {
         return {"name":p.name.val};
      }
      
      protected function _getACLsForInfo(p:JBGPlayer) : Array
      {
         return ["r id:" + p.sessionId.val];
      }
      
      public function updateInfoForPlayer(p:JBGPlayer) : Promise
      {
         return this._wsClient.setObject("info:" + p.sessionId.val,this._generateInfoForPlayer(p));
      }
      
      protected function _onDisconnect(evt:EventWithData) : void
      {
         this.goBackToMenu();
         if(Boolean(evt.data.hasOpened))
         {
            GameEngine.instance.error.handleError("ROOM_DESTROYED");
         }
         else
         {
            GameEngine.instance.error.handleError("INTERNET_DISCONNECTED");
         }
      }
      
      private function _parseNotification(evt:EventWithData) : void
      {
         var result:* = evt.data.result;
         var shouldResetIdleTimer:Boolean = false;
         if(result is ClientConnected)
         {
            if(result.role == ClientConnected.ROLE_PLAYER)
            {
               this._onCustomerJoined(result);
            }
            else if(result.role == ClientConnected.ROLE_MODERATOR)
            {
               this._moderationHandler.onModeratorConnected(result);
            }
            shouldResetIdleTimer = true;
         }
         else if(result is ClientDisconnected)
         {
            if(result.role == ClientConnected.ROLE_PLAYER)
            {
               this._onCustomerLeft(result);
            }
            else if(result.role == ClientConnected.ROLE_MODERATOR)
            {
               this._moderationHandler.onModeratorLeft(result);
            }
            shouldResetIdleTimer = true;
         }
         else if(result is ClientSend)
         {
            this._onReceivedMessageFromCustomer(result);
            shouldResetIdleTimer = true;
         }
         else if(result is RoomExit)
         {
            this.goBackToMenu();
            GameEngine.instance.error.handleError(RoomExit(result).localizationKey);
         }
         if(shouldResetIdleTimer)
         {
            Platform.instance.sendMessageToNative("ResetIdleTimer",null);
         }
      }
      
      protected function _onCustomerLeft(result:ClientDisconnected) : void
      {
      }
      
      protected function _onReceivedMessageFromCustomer(result:ClientSend) : void
      {
         var playerWhoSentMessage:JBGPlayer = this.getPlayerBySessionId(result.from);
         if(Boolean(playerWhoSentMessage))
         {
            dispatchEvent(new EventWithData(EVENT_RECEIVED_MESSAGE_FROM_PLAYER,{
               "player":playerWhoSentMessage,
               "message":result.body
            }));
         }
      }
      
      protected function _resetModeration() : void
      {
         JBGUtil.reset([this._userDataManager]);
      }
      
      public function goBackToMenu() : void
      {
         Assert.assert(false,"goBackToMenu must be overridden in child classes for games to function properly!");
      }
      
      public function goBackToLobby() : void
      {
         Assert.assert(false,"goBackToLobby must be overridden in child classes for games to function properly!");
      }
      
      protected function _resetGameState() : void
      {
      }
      
      protected function _cancelAllAndGoBack(fc:String, cell:String) : void
      {
         this._resetConnection();
         this._resetGameState();
         SettingsMenu.instance.reset();
         var path:String = TSUtil.createCellPath(fc,cell);
         this._ts.jumpToCell(path);
      }
      
      protected function _resetConnection() : void
      {
         if(this._roomId != null)
         {
            this._roomId = null;
         }
         if(this._wsClient != null)
         {
            this._resetModeration();
            this._wsClient.removeEventListener(WSClient.EVENT_NOTIFICATION,this._parseNotification);
            this._wsClient.removeEventListener(WSClient.EVENT_SOCKET_CLOSE,this._onDisconnect);
            try
            {
               this._wsClient.roomExit();
            }
            catch(error:TypeError)
            {
               Logger.warning("Attempting to send roomExit message with a null WebSocket connection.");
            }
            this._wsClient = null;
         }
         this._sessions.reset();
         this._currentRoomBlob = null;
         JBGUtil.dispose(this._players);
         this._players = [];
         this._numGamesPlayedWithSamePlayers.val = 0;
         this._hasEverSeenAudience.val = false;
         this.canRestartGame = false;
      }
      
      public function sendGameArtifacts(resultFn:Function) : void
      {
         var type:String;
         var artifact:Object;
         if(!SettingsManager.instance.getValue(SettingsConstants.SETTING_POST_GAME_SHARING).val)
         {
            resultFn(false);
            return;
         }
         type = this._artifactType;
         artifact = this._artifact;
         if(!type || !artifact)
         {
            resultFn(false);
            return;
         }
         this._wsClient.createArtifact(type,SimpleObjectUtil.deepCopyWithSimpleObjectReplacement(artifact)).then(function(reply:Reply):void
         {
            resultFn(true);
         },function(error:Reply):void
         {
            resultFn(false);
         });
      }
      
      protected function get _artifactType() : String
      {
         return null;
      }
      
      protected function get _artifact() : Object
      {
         return null;
      }
   }
}

