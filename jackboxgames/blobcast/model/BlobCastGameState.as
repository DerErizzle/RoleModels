package jackboxgames.blobcast.model
{
   import flash.events.*;
   import flash.utils.*;
   import jackboxgames.blobcast.modules.*;
   import jackboxgames.blobcast.services.*;
   import jackboxgames.engine.*;
   import jackboxgames.events.*;
   import jackboxgames.localizy.LocalizationManager;
   import jackboxgames.logger.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.core.*;
   import jackboxgames.ugc.*;
   import jackboxgames.utils.*;
   
   public class BlobCastGameState extends PausableEventDispatcher
   {
      
      public static const EVENT_LOST_CONNECTION:String = "GameState.LostConnection";
      
      public static const EVENT_CREATE_ROOM_RESULT:String = "GameState.CreateRoomResult";
      
      public static const EVENT_PLAYERS_CHANGED:String = "GameState.PlayersChanged";
      
      public static const EVENT_RECEIVED_MESSAGE_FROM_PLAYER:String = "GameState.ReceivedMessageFromPlayer";
       
      
      protected var _ts:IEngineAPI;
      
      protected var _passwordManager:RoomPasswordManager;
      
      protected var _dics:GameStateDictionaries;
      
      protected var _roomCancellers:Array;
      
      protected var _currentRoomBlob:Object;
      
      protected var _currentAudienceBlob:Object;
      
      protected var _roomId:TSValue;
      
      protected var _hasEverSeenAudience:TSValue;
      
      protected var _isInGame:TSValue;
      
      protected var _numGamesPlayedEver:SavedTalkShowVariable;
      
      protected var _numGamesPlayedSession:TSValue;
      
      protected var _minPlayers:TSValue;
      
      protected var _players:Array;
      
      protected var _sessionPlayers:Object;
      
      protected var _artifactResult:Object;
      
      protected var _sessions:SessionManager;
      
      private var _audience:Audience;
      
      private var _ugcContentToAutoPlay:WatchableValue;
      
      private var _commonCensorBarGenerator:WatchableValue;
      
      private var _numGamesPlayedWithSamePlayers:TSValue;
      
      public function BlobCastGameState(ts:IEngineAPI, options:Object = null, target:IEventDispatcher = null)
      {
         super(target);
         this._ts = ts;
         this._ts.g.gs = this;
         this._passwordManager = new RoomPasswordManager();
         this._dics = new GameStateDictionaries();
         this._dics.resetPerRun();
         this._players = [];
         this._sessionPlayers = {};
         this._roomCancellers = [];
         this._roomId = new TSValue("roomId");
         this._hasEverSeenAudience = new TSValue("hasEverSeenAudience",false);
         this._isInGame = new TSValue("isInGame",false);
         this._minPlayers = new TSValue("minPlayers",1);
         this._numGamesPlayedSession = new TSValue("numGamesPlayedThisSession",0);
         this._numGamesPlayedEver = new SavedTalkShowVariable(ts,"numGamesPlayedEver",0);
         this._numGamesPlayedWithSamePlayers = new TSValue("numGamesPlayedWithSamePlayers",0);
         this._ugcContentToAutoPlay = new WatchableValue(null,null,null,null);
         this._commonCensorBarGenerator = new WatchableValue(null);
         Random.instance.seedRandom(new Date().getTime(),false);
         this._sessions = new SessionManager(BlobCast.instance);
         if(Boolean(options.audience))
         {
            this._audience = this._sessions.registerModule(new Audience(BuildConfig.instance.configVal("gameName") + " Audience")) as Audience;
            this._audience.addEventListener(Audience.EVENT_AUDIENCE_COUNT_CHANGED,function(evt:EventWithData):void
            {
               if(evt.data > 0)
               {
                  hasEverSeenAudience = true;
               }
            });
         }
      }
      
      public function get audience() : Audience
      {
         return this._audience;
      }
      
      public function get ugcContentToAutoPlay() : WatchableValue
      {
         return this._ugcContentToAutoPlay;
      }
      
      public function get commonCensorBarGenerator() : WatchableValue
      {
         return this._commonCensorBarGenerator;
      }
      
      public function get passwordManager() : RoomPasswordManager
      {
         return this._passwordManager;
      }
      
      public function get dics() : GameStateDictionaries
      {
         return this._dics;
      }
      
      public function get roomId() : String
      {
         return this._roomId.val;
      }
      
      public function set roomId(val:String) : void
      {
         this._roomId.val = val;
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
         return this._minPlayers.val;
      }
      
      public function set minPlayers(val:int) : void
      {
         this._minPlayers.val = val;
      }
      
      public function get sessionPlayers() : Object
      {
         return this._sessionPlayers;
      }
      
      public function get sessions() : SessionManager
      {
         return this._sessions;
      }
      
      public function getPlayerByUserId(userId:String) : BlobCastPlayer
      {
         var p:BlobCastPlayer = null;
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
      
      public function setRoomBlob(blob:Object) : void
      {
         this._currentRoomBlob = blob;
         this._updateRoomBlob();
      }
      
      public function setAudienceBlob(blob:Object) : void
      {
         this._currentAudienceBlob = blob;
         this._updateRoomBlob();
      }
      
      public function setCustomerBlobWithMetadata(p:BlobCastPlayer, blob:Object) : void
      {
         if(p == null)
         {
            return;
         }
         BlobCast.instance.setCustomerBlob(p.userId.val,p.updatePlayerBlob(blob));
      }
      
      protected function _updateRoomBlob() : void
      {
         var copy:Object = Boolean(this._currentRoomBlob) ? JBGUtil.primitiveDeepCopy(this._currentRoomBlob) : {};
         copy.audience = this._currentAudienceBlob;
         if(Boolean(this._artifactResult))
         {
            copy.artifact = this._artifactResult;
         }
         copy.locale = SettingsManager.instance.getValue(LocalizationManager.SETTING_LOCALE).val;
         copy.platformId = Platform.instance.PlatformIdUpperCase;
         BlobCast.instance.setRoomBlob(copy);
      }
      
      public function createRoom() : void
      {
         var options:Object;
         var contentToAutoPlay:Object = null;
         var _this:* = undefined;
         var canceller:Function = null;
         this._resetBlobcast();
         contentToAutoPlay = this.ugcContentToAutoPlay.val;
         this.ugcContentToAutoPlay.val = null;
         _this = this;
         canceller = JBGUtil.eventOnce(BlobCast.instance,BlobCast.EVENT_CREATE_ROOM_RESULT,function(evt:EventWithData):void
         {
            var newRoomId:*;
            if(!evt.data)
            {
               _this.dispatchEvent(new EventWithData(EVENT_CREATE_ROOM_RESULT,false));
               return;
            }
            newRoomId = evt.data;
            BlobCastWebAPI.instance.updateAccessToken(newRoomId,function(result:Object):void
            {
               var finishCreateRoom:Function = function():void
               {
                  ArrayUtil.removeElementFromArray(_roomCancellers,canceller);
                  BlobCast.instance.addEventListener(BlobCast.EVENT_DISCONNECTED,_onDisconnect);
                  BlobCast.instance.addEventListener(BlobCast.EVENT_ROOM_DESTROYED,_onRoomDestroyed);
                  BlobCast.instance.addEventListener(BlobCast.EVENT_CUSTOMER_JOINED_ROOM,_onCustomerJoined);
                  BlobCast.instance.addEventListener(BlobCast.EVENT_CUSTOMER_LEFT_ROOM,_onCustomerLeft);
                  BlobCast.instance.addEventListener(BlobCast.EVENT_CUSTOMER_REJOINED_ROOM,_onCustomerRejoined);
                  BlobCast.instance.addEventListener(BlobCast.EVENT_CUSTOMER_SENT_MESSAGE,_onReceivedMessageFromCustomer);
                  roomId = evt.data;
                  JBGUtil.reset(_players);
                  _players = [];
                  _numGamesPlayedWithSamePlayers.val = 0;
                  _dics.resetPerSetOfPlayers();
                  GameEngine.instance.error.reset();
                  if(Boolean(_audience) && SettingsManager.instance.getValue(SettingsConstants.SETTING_AUDIENCE_ON).val)
                  {
                     _audience.start({},function(success:Boolean):void
                     {
                        _this.dispatchEvent(new EventWithData(EVENT_CREATE_ROOM_RESULT,success));
                     });
                  }
                  else
                  {
                     _this.dispatchEvent(new EventWithData(EVENT_CREATE_ROOM_RESULT,true));
                  }
               };
               if(!result.success)
               {
                  _this.dispatchEvent(new EventWithData(EVENT_CREATE_ROOM_RESULT,false));
                  return;
               }
               if(Boolean(contentToAutoPlay))
               {
                  UGCContentManager.instance.activateContentData(contentToAutoPlay,function(result:Object):void
                  {
                     if(!result.success)
                     {
                        _this.dispatchEvent(new EventWithData(EVENT_CREATE_ROOM_RESULT,false));
                        return;
                     }
                     finishCreateRoom();
                  });
               }
               else
               {
                  finishCreateRoom();
               }
            });
         });
         this._roomCancellers.push(canceller);
         options = {
            "platform":Platform.instance.PlatformId,
            "platformInformations":Platform.instance.platformInformation,
            "twitchLocked":SettingsManager.instance.getValue(SettingsConstants.SETTING_REQUIRE_TWITCH).val,
            "maxPlayers":SettingsManager.instance.getValue(SettingsConstants.SETTING_MAX_PLAYERS).val
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
         if(this._passwordManager.hasPassword)
         {
            options.password = this._passwordManager.password;
         }
         Logger.info(TraceUtil.objectRecursive(options,"options"));
         BlobCast.instance.createRoom(options);
      }
      
      public function lockRoom(callback:Function) : void
      {
         var canceller:Function = null;
         canceller = JBGUtil.eventOnce(BlobCast.instance,BlobCast.EVENT_LOCK_ROOM_RESULT,function(evt:EventWithData):void
         {
            ArrayUtil.removeElementFromArray(_roomCancellers,canceller);
            callback();
         });
         this._roomCancellers.push(canceller);
         BlobCast.instance.lockRoom();
      }
      
      public function showLogoForPlayer(p:BlobCastPlayer, message:String = null) : void
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
         var p:BlobCastPlayer = null;
         for each(p in players)
         {
            this.showLogoForPlayer(p,message);
         }
      }
      
      public function showLogoForAllPlayers(message:String = null) : void
      {
         var p:BlobCastPlayer = null;
         for each(p in this._players)
         {
            this.showLogoForPlayer(p,message);
         }
      }
      
      public function destroy() : void
      {
      }
      
      protected function _onCustomerJoined(evt:EventWithData) : void
      {
         var newPlayer:BlobCastPlayer = null;
         if(Boolean(this.getPlayerByUserId(evt.data.userId)))
         {
            return;
         }
         if(this.numPlayers >= SettingsManager.instance.getValue(SettingsConstants.SETTING_MAX_PLAYERS).val)
         {
            return;
         }
         if(this._sessionPlayers[evt.data.userId] != null)
         {
            newPlayer = this.createPlayer(this._players.length,evt.data.userId,TextUtils.filter(evt.data.name,[TextUtils.truncateFilter(12)]),evt.data.options,this._sessionPlayers[evt.data.userId]);
         }
         else
         {
            newPlayer = this.createPlayer(this._players.length,evt.data.userId,TextUtils.filter(evt.data.name,[TextUtils.truncateFilter(12)]),evt.data.options);
            this._sessionPlayers[evt.data.userId] = newPlayer;
         }
         this._players.push(newPlayer);
         dispatchEvent(new EventWithData(EVENT_PLAYERS_CHANGED,{
            "added":[newPlayer],
            "removed":[]
         }));
      }
      
      protected function createPlayer(index:int, userId:String, name:String, options:Object, p:* = null) : *
      {
         if(p == null)
         {
            p = new BlobCastPlayer();
         }
         p.initialize(index,userId,name);
         return p;
      }
      
      protected function _onCustomerLeft(evt:EventWithData) : void
      {
      }
      
      protected function _onCustomerRejoined(evt:EventWithData) : void
      {
         this._onCustomerJoined(evt);
      }
      
      protected function _onReceivedMessageFromCustomer(evt:EventWithData) : void
      {
         if(!evt.data || !evt.data.hasOwnProperty("userId") || !evt.data.hasOwnProperty("message"))
         {
            if(evt.data)
            {
               Logger.debug("_onReceivedMessageFromCustomer(" + TraceUtil.objectRecursive(evt.data,"evt.data") + ")");
            }
            return;
         }
         var playerWhoSentMessage:BlobCastPlayer = this.getPlayerByUserId(evt.data.userId);
         if(Boolean(playerWhoSentMessage))
         {
            dispatchEvent(new EventWithData(EVENT_RECEIVED_MESSAGE_FROM_PLAYER,{
               "player":playerWhoSentMessage,
               "message":evt.data.message
            }));
            Platform.instance.sendMessageToNative("ResetIdleTimer",null);
            return;
         }
      }
      
      protected function _onDisconnect(evt:EventWithData) : void
      {
         if(Boolean(evt.data.error) && evt.data.error.length > 0)
         {
            GameEngine.instance.error.handleError(evt.data.error);
         }
         dispatchEvent(new EventWithData(EVENT_LOST_CONNECTION,null));
      }
      
      protected function _onRoomDestroyed(evt:EventWithData) : void
      {
         this._onDisconnect(new EventWithData(evt.type,{"error":"ROOM_DESTROYED"}));
      }
      
      protected function _resetGameState() : void
      {
      }
      
      private function _createCellPath(fc:String, cell:String) : String
      {
         return PlaybackEngine.getInstance().activeExport.projectName + ":" + fc + ":" + cell;
      }
      
      protected function _cancelAllAndGoBack(fc:String, cell:String) : void
      {
         this._resetBlobcast();
         this._resetGameState();
         PlaybackEngine.getInstance().inputManager.resetInput();
         var path:String = this._createCellPath(fc,cell);
         this._ts.jumpToCell(path);
      }
      
      protected function _resetBlobcast() : void
      {
         var canceller:Function = null;
         BlobCast.instance.removeEventListener(BlobCast.EVENT_DISCONNECTED,this._onDisconnect);
         BlobCast.instance.removeEventListener(BlobCast.EVENT_ROOM_DESTROYED,this._onRoomDestroyed);
         BlobCast.instance.removeEventListener(BlobCast.EVENT_CUSTOMER_JOINED_ROOM,this._onCustomerJoined);
         BlobCast.instance.removeEventListener(BlobCast.EVENT_CUSTOMER_LEFT_ROOM,this._onCustomerLeft);
         BlobCast.instance.removeEventListener(BlobCast.EVENT_CUSTOMER_REJOINED_ROOM,this._onCustomerRejoined);
         BlobCast.instance.removeEventListener(BlobCast.EVENT_CUSTOMER_SENT_MESSAGE,this._onReceivedMessageFromCustomer);
         if(this._roomId.val != null)
         {
            BlobCast.instance.disconnectFromService();
            this._roomId.val = null;
         }
         for each(canceller in this._roomCancellers)
         {
            canceller();
         }
         this._roomCancellers = [];
         this._sessions.reset();
         this._currentRoomBlob = null;
         this._currentAudienceBlob = null;
         JBGUtil.dispose(this._players);
         this._players = [];
         this._numGamesPlayedWithSamePlayers.val = 0;
         this._hasEverSeenAudience.val = false;
         this.resetArtifact();
      }
      
      public function resetArtifact() : void
      {
         this._artifactResult = null;
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
         BlobArtifact.instance.artifact(type,artifact,function(result:Object):void
         {
            if(Boolean(result.success))
            {
               _artifactResult = result;
               _updateRoomBlob();
            }
            resultFn(result.success);
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
