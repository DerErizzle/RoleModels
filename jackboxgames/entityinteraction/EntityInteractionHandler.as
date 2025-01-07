package jackboxgames.entityinteraction
{
   import jackboxgames.algorithm.*;
   import jackboxgames.events.*;
   import jackboxgames.model.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class EntityInteractionHandler
   {
      private static const DEFAULT_DONE_DURATION:Duration = Duration.fromSec(3);
      
      private var _behavior:IEntityInteractionBehavior;
      
      private var _gs:JBGGameState;
      
      private var _canEndEarlyDueToInactivePlayers:Boolean;
      
      private var _shouldTrackMissedInteractions:Boolean;
      
      private var _handleDynamicPlayers:Boolean;
      
      private var _doneDuration:Duration;
      
      private var _isActive:Boolean;
      
      private var _isActivePromise:Promise;
      
      private var _players:Array;
      
      private var _playerEntities:PerPlayerContainer;
      
      private var _hasUpdatedEntity:PerPlayerContainer;
      
      private var _playersForcedToBeDone:Array;
      
      private var _doneCanceller:Function;
      
      private var _finishedOnPlayerInput:Boolean;
      
      private var _sharedEntities:SharedEntities;
      
      public function EntityInteractionHandler(behavior:IEntityInteractionBehavior, gs:JBGGameState, canEndEarlyDueToInactivePlayers:Boolean, shouldTrackMissedInteractions:Boolean, handleDynamicPlayers:Boolean = false)
      {
         super();
         this._behavior = behavior;
         this._gs = gs;
         this._canEndEarlyDueToInactivePlayers = canEndEarlyDueToInactivePlayers;
         this._shouldTrackMissedInteractions = shouldTrackMissedInteractions;
         this._handleDynamicPlayers = handleDynamicPlayers;
         this._doneDuration = BuildConfig.instance.hasConfigVal("interaction-handler-done-duration") ? Duration.fromSec(Number(BuildConfig.instance.configVal("interaction-handler-done-duration"))) : DEFAULT_DONE_DURATION;
         this._isActive = false;
         this._players = [];
         this._playerEntities = new PerPlayerContainer();
         this._hasUpdatedEntity = new PerPlayerContainer();
         this._playersForcedToBeDone = [];
         this._doneCanceller = Nullable.NULL_FUNCTION;
         this._finishedOnPlayerInput = false;
      }
      
      public function reset() : Promise
      {
         return this.setIsActive(null,false);
      }
      
      private function _createPromisesForPlayers(players:Array) : Promise
      {
         var createPromises:Array = null;
         createPromises = [];
         players.forEach(function(player:JBGPlayer, ... args):void
         {
            var playerEntity:PlayerEntities = _behavior.generatePlayerEntities(player);
            _playerEntities.setDataForPlayer(player,playerEntity);
            createPromises.push(playerEntity.createEntities());
            if(playerEntity.updateMainOnCreate)
            {
               createPromises.push(player.mainEntity.update(_behavior.getPlayerEntityValue(player,"main",player.mainEntity)));
            }
            playerEntity.addEventListener(PlayerEntityUpdatedEvent.EVENT_UPDATED,_onPlayerEntityUpdated);
         });
         return PromiseUtil.ALL(createPromises);
      }
      
      private function _onPlayersChanged(evt:EventWithData) : void
      {
         var newPlayers:Array = evt.data.added;
         newPlayers.forEach(function(player:JBGPlayer, ... args):void
         {
            _players.push(player);
         });
         this._behavior.setup(this._gs.client,newPlayers);
         this._createPromisesForPlayers(newPlayers);
      }
      
      public function get isActive() : Boolean
      {
         return this._isActive;
      }
      
      public function setIsActive(players:Array, val:Boolean) : Promise
      {
         var disposePromises:Array = null;
         if(this._isActive == val)
         {
            return Boolean(this._isActivePromise) ? this._isActivePromise : PromiseUtil.RESOLVED(true);
         }
         this._isActivePromise = new Promise();
         this._isActive = val;
         if(this._isActive)
         {
            if(this._handleDynamicPlayers)
            {
               this._gs.addEventListener(JBGGameState.EVENT_PLAYERS_CHANGED,this._onPlayersChanged);
            }
            this._players = players;
            this._behavior.setup(this._gs.client,this._players);
            this._finishedOnPlayerInput = false;
            this._hasUpdatedEntity = new PerPlayerContainer();
            this._playerEntities = new PerPlayerContainer();
            this._sharedEntities = this._behavior.generateSharedEntities();
            this._playersForcedToBeDone = [];
            this._isActivePromise = PromiseUtil.ALL([this._createPromisesForPlayers(players),this._sharedEntities.createEntities()]).then(function():void
            {
               _isActivePromise = null;
            },function():void
            {
               _isActivePromise = null;
            });
         }
         else
         {
            if(this._handleDynamicPlayers)
            {
               this._gs.removeEventListener(JBGGameState.EVENT_PLAYERS_CHANGED,this._onPlayersChanged);
            }
            this._players.forEach(function(p:JBGPlayer, ... args):void
            {
               if(_hasUpdatedEntity.hasDataForPlayer(p) || _playerIsForcedToBeDone(p))
               {
                  p.recordSuccessfulInteraction();
               }
               else if(_shouldTrackMissedInteractions)
               {
                  p.recordMissedInteraction();
               }
            });
            this._players.forEach(function(p:JBGPlayer, ... args):void
            {
               _gs.setPlayerControllerStateToWait(p);
            });
            disposePromises = [];
            this._players.forEach(function(p:JBGPlayer, ... args):void
            {
               var containers:PlayerEntities = _playerEntities.getDataForPlayer(p);
               containers.removeEventListener(PlayerEntityUpdatedEvent.EVENT_UPDATED,_onPlayerEntityUpdated);
               disposePromises.push(containers.disposeEntities());
            });
            if(this._sharedEntities != null)
            {
               disposePromises.push(this._sharedEntities.disposeEntities());
            }
            PromiseUtil.ALL(disposePromises).then(function(data:Array):void
            {
               var p:Promise = _isActivePromise;
               _isActivePromise = null;
               p.resolve(true);
            },function(success:Boolean):void
            {
               var p:Promise = _isActivePromise;
               _isActivePromise = null;
               p.reject(false);
            });
            this._behavior.shutdown(this._finishedOnPlayerInput);
            this._doneCanceller();
            this._doneCanceller = Nullable.NULL_FUNCTION;
            this._players = [];
         }
         return this._isActivePromise;
      }
      
      public function forceUpdateEntities(request:EntityUpdateRequest) : void
      {
         this._updateEntitiesFromRequest(request);
      }
      
      public function forcePlayerToBeDone(p:JBGPlayer) : void
      {
         if(this._playerIsForcedToBeDone(p))
         {
            return;
         }
         this._playersForcedToBeDone.push(p);
         this._checkForDone();
      }
      
      private function _isPlayerDone(p:JBGPlayer) : Boolean
      {
         return Boolean(this._behavior.playerIsDone(p)) || this._playerIsForcedToBeDone(p);
      }
      
      private function _arePlayersDone(players:Array) : Boolean
      {
         var p:JBGPlayer = null;
         for each(p in players)
         {
            if(!this._isPlayerDone(p))
            {
               return false;
            }
         }
         return true;
      }
      
      private function _playerIsForcedToBeDone(p:JBGPlayer) : Boolean
      {
         return ArrayUtil.arrayContainsElement(this._playersForcedToBeDone,p);
      }
      
      private function _checkForDone() : void
      {
         var activePlayers:Array = this._players.filter(function(p:JBGPlayer, ... args):Boolean
         {
            return p.isActive;
         });
         if(this._arePlayersDone(this._players))
         {
            this._finishedOnPlayerInput = true;
            this.setIsActive(this._players,false);
         }
         else if(this._arePlayersDone(activePlayers))
         {
            this._doneCanceller = JBGUtil.runFunctionAfter(function():void
            {
               _finishedOnPlayerInput = true;
               setIsActive(_players,false);
            },this._doneDuration);
         }
      }
      
      private function _updateEntitiesFromRequest(request:EntityUpdateRequest) : Promise
      {
         var updatePromises:Array = null;
         updatePromises = [];
         request.sharedEntityUpdates.forEach(function(sharedEntityKey:String, ... args):void
         {
            var sharedEntity:IEntity = _sharedEntities.getEntityByKey(sharedEntityKey);
            if(Boolean(sharedEntity))
            {
               updatePromises.push(sharedEntity.update(_behavior.getSharedEntityValue(sharedEntityKey,sharedEntity)));
            }
         });
         request.playerEntityUpdates.forEach(function(entityIds:Array, player:JBGPlayer, ... args):void
         {
            entityIds.forEach(function(entityKey:String, ... args):void
            {
               var playerEntity:IEntity = PlayerEntities(_playerEntities.getDataForPlayer(player)).getEntityByKey(entityKey);
               if(Boolean(playerEntity))
               {
                  updatePromises.push(playerEntity.update(_behavior.getPlayerEntityValue(player,entityKey,playerEntity)));
               }
            });
         });
         return PromiseUtil.ALL(updatePromises);
      }
      
      private function _getPlayerFromEntities(e:PlayerEntities) : JBGPlayer
      {
         var p:JBGPlayer = null;
         for each(p in this._players)
         {
            if(this._playerEntities.getDataForPlayer(p) == e)
            {
               return p;
            }
         }
         return null;
      }
      
      private function _onPlayerEntityUpdated(evt:PlayerEntityUpdatedEvent) : void
      {
         var playerEntities:PlayerEntities = PlayerEntities(evt.target);
         var p:JBGPlayer = this._getPlayerFromEntities(playerEntities);
         var key:String = evt.key;
         var entity:IEntity = evt.entity;
         if(!ArrayUtil.arrayContainsElement(this._players,p))
         {
            return;
         }
         var res:EntityUpdateRequest = this._behavior.onPlayerInputEntityUpdated(p,playerEntities,this._sharedEntities,key,entity);
         if(!res)
         {
            return;
         }
         this._doneCanceller();
         this._doneCanceller = Nullable.NULL_FUNCTION;
         this._hasUpdatedEntity.setDataForPlayer(p,true);
         Platform.instance.sendMessageToNative("ResetIdleTimer",null);
         if(this._isActive)
         {
            this._checkForDone();
            if(this._isActive)
            {
               this._updateEntitiesFromRequest(res);
            }
         }
      }
   }
}

