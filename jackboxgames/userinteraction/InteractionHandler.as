package jackboxgames.userinteraction
{
   import flash.events.EventDispatcher;
   import jackboxgames.blobcast.model.*;
   import jackboxgames.events.*;
   import jackboxgames.utils.*;
   
   public class InteractionHandler extends EventDispatcher
   {
      
      public static const MESSAGE_RESULT_ERROR:String = "error";
      
      public static const MESSAGE_RESULT_NOTHING:String = "nothing";
      
      public static const MESSAGE_RESULT_UPDATE_BLOB:String = "update-blob";
      
      public static const MESSAGE_RESULT_UPDATE_ALL_BLOBS:String = "update-all-blobs";
      
      private static const DEFAULT_DONE_DURATION:Duration = Duration.fromSec(3);
       
      
      private var _behavior:IInteractionBehavior;
      
      private var _gs:BlobCastGameState;
      
      private var _canEndEarly:Boolean;
      
      private var _canEndEarlyDueToInactivePlayers:Boolean;
      
      private var _shouldTrackMissedInteractions:Boolean;
      
      private var _doneDuration:Duration;
      
      private var _subBehaviors:Array;
      
      private var _isActive:Boolean;
      
      private var _players:Array;
      
      private var _hasSentMessage:PerPlayerContainer;
      
      private var _playersForcedToBeDone:Array;
      
      private var _doneCanceller:Function;
      
      private var _finishedOnPlayerInput:Boolean;
      
      public function InteractionHandler(handler:IInteractionBehavior, gs:BlobCastGameState, canEndEarlyDueToInactivePlayers:Boolean, shouldTrackMissedInteractions:Boolean)
      {
         super();
         this._behavior = handler;
         this._gs = gs;
         this._canEndEarly = true;
         this._canEndEarlyDueToInactivePlayers = canEndEarlyDueToInactivePlayers;
         this._shouldTrackMissedInteractions = shouldTrackMissedInteractions;
         this._subBehaviors = [];
         this._doneDuration = BuildConfig.instance.hasConfigVal("interaction-handler-done-duration") ? Duration.fromSec(Number(BuildConfig.instance.configVal("interaction-handler-done-duration"))) : DEFAULT_DONE_DURATION;
         this._isActive = false;
         this._finishedOnPlayerInput = false;
         this._players = [];
         this._hasSentMessage = new PerPlayerContainer();
         this._playersForcedToBeDone = [];
         this._doneCanceller = Nullable.NULL_FUNCTION;
      }
      
      public function get canEndEarly() : Boolean
      {
         return this._canEndEarly;
      }
      
      public function set canEndEarly(val:Boolean) : void
      {
         this._canEndEarly = val;
      }
      
      public function dispose() : void
      {
         if(!this._behavior)
         {
            return;
         }
         this.reset();
         JBGUtil.dispose([this._hasSentMessage]);
         this._behavior = null;
         this._gs = null;
         this._subBehaviors = null;
         this._players = null;
         this._hasSentMessage = null;
         this._playersForcedToBeDone = null;
         this._doneDuration = null;
         this._doneCanceller = null;
      }
      
      public function reset() : void
      {
         this._isActive = false;
         this._finishedOnPlayerInput = false;
         this._players = [];
         this._hasSentMessage.reset();
         this._playersForcedToBeDone = [];
         this._doneCanceller();
         this._doneCanceller = Nullable.NULL_FUNCTION;
         this._gs.removeEventListener(BlobCastGameState.EVENT_RECEIVED_MESSAGE_FROM_PLAYER,this._onReceivedMessage);
      }
      
      public function addSubBehavior(sub:IInteractionSubBehavior) : void
      {
         this._subBehaviors.push(sub);
      }
      
      public function addPlayers(players:Array) : void
      {
         players.forEach(function(p:BlobCastPlayer, i:int, arr:Array):void
         {
            if(!ArrayUtil.arrayContainsElement(_players,p))
            {
               _players.push(p);
               forceUpdatePlayer(p);
            }
         });
      }
      
      public function removePlayers(players:Array) : void
      {
         players.forEach(function(p:BlobCastPlayer, i:int, arr:Array):void
         {
            ArrayUtil.removeElementFromArray(_players,p);
            _hasSentMessage.removeDataForPlayer(p);
            ArrayUtil.removeElementFromArray(_playersForcedToBeDone,p);
         });
      }
      
      public function forceUpdatePlayer(p:BlobCastPlayer) : void
      {
         if(!ArrayUtil.arrayContainsElement(this._players,p))
         {
            return;
         }
         this._sendCustomerBlob(p);
      }
      
      public function forceUpdateAllPlayers() : void
      {
         var p:BlobCastPlayer = null;
         for each(p in this._players)
         {
            this.forceUpdatePlayer(p);
         }
      }
      
      public function isPlayerDoneInteracting(p:BlobCastPlayer) : Boolean
      {
         return this._behavior.playerIsDoneInteracting(p);
      }
      
      public function get isActive() : Boolean
      {
         return this._isActive;
      }
      
      public function setIsActive(players:Array, val:Boolean) : void
      {
         var p:BlobCastPlayer = null;
         if(this._isActive == val)
         {
            return;
         }
         this._isActive = val;
         if(this._isActive)
         {
            this._players = players;
            this._behavior.setup(this._players);
            this._subBehaviors.forEach(function(sub:IInteractionSubBehavior, ... args):void
            {
               sub.setup(_players);
            });
            this._finishedOnPlayerInput = false;
            this._hasSentMessage.reset();
            this._playersForcedToBeDone = [];
            for each(p in this._players)
            {
               this._hasSentMessage.setDataForPlayer(p,false);
               this._sendCustomerBlob(p);
            }
            this._gs.addEventListener(BlobCastGameState.EVENT_RECEIVED_MESSAGE_FROM_PLAYER,this._onReceivedMessage);
         }
         else
         {
            this._behavior.cleanUp(this._finishedOnPlayerInput);
            this._subBehaviors.forEach(function(sub:IInteractionSubBehavior, ... args):void
            {
               sub.cleanUp(_finishedOnPlayerInput);
            });
            this._finishedOnPlayerInput = false;
            this._gs.removeEventListener(BlobCastGameState.EVENT_RECEIVED_MESSAGE_FROM_PLAYER,this._onReceivedMessage);
            this._gs.showLogoForPlayers(players);
            this._players.forEach(function(p:BlobCastPlayer, ... args):void
            {
               if(_hasSentMessage.getDataForPlayer(p) || _playerIsForcedToBeDone(p))
               {
                  p.recordSuccessfulInteraction();
               }
               else if(_shouldTrackMissedInteractions && !_hasSentMessage.getDataForPlayer(p))
               {
                  p.recordMissedInteraction();
               }
            });
            this._players = [];
            this._hasSentMessage.reset();
            this._playersForcedToBeDone = [];
            this._doneCanceller();
            this._doneCanceller = Nullable.NULL_FUNCTION;
         }
      }
      
      public function injectMessage(fromPlayer:BlobCastPlayer, message:Object) : void
      {
         this._onReceivedMessage(new EventWithData(BlobCastGameState.EVENT_RECEIVED_MESSAGE_FROM_PLAYER,{
            "player":fromPlayer,
            "message":message,
            "isInjected":true
         }));
      }
      
      private function _sendCustomerBlob(p:BlobCastPlayer) : void
      {
         var blob:Object = null;
         blob = this._behavior.generateBlob(p);
         this._subBehaviors.forEach(function(sub:IInteractionSubBehavior, ... args):void
         {
            sub.alterBlob(p,blob);
         });
         this._gs.setCustomerBlobWithMetadata(p,blob);
      }
      
      private function arePlayersDone(players:Array) : Boolean
      {
         var p:BlobCastPlayer = null;
         for each(p in players)
         {
            if(!this._behavior.playerIsDoneInteracting(p) && !this._playerIsForcedToBeDone(p))
            {
               return false;
            }
         }
         return true;
      }
      
      public function forcePlayerToBeDone(p:BlobCastPlayer) : void
      {
         if(this._playerIsForcedToBeDone(p))
         {
            return;
         }
         this._playersForcedToBeDone.push(p);
         this._checkForDone();
      }
      
      private function _playerIsForcedToBeDone(p:BlobCastPlayer) : Boolean
      {
         return ArrayUtil.arrayContainsElement(this._playersForcedToBeDone,p);
      }
      
      private function _onReceivedMessage(evt:EventWithData) : void
      {
         var result:String;
         var p:BlobCastPlayer = null;
         p = evt.data.player;
         if(!ArrayUtil.arrayContainsElement(this._players,p))
         {
            return;
         }
         result = String(this._behavior.handleMessage(p,evt.data.message));
         this._subBehaviors.forEach(function(sub:IInteractionSubBehavior, ... args):void
         {
            sub.handleMessage(p,evt.data.message);
         });
         if(result == MESSAGE_RESULT_ERROR)
         {
            return;
         }
         this._doneCanceller();
         this._doneCanceller = Nullable.NULL_FUNCTION;
         if(result == MESSAGE_RESULT_UPDATE_BLOB)
         {
            this.forceUpdatePlayer(p);
         }
         else if(result == MESSAGE_RESULT_UPDATE_ALL_BLOBS)
         {
            this.forceUpdateAllPlayers();
         }
         else if(result == MESSAGE_RESULT_NOTHING)
         {
         }
         if(!evt.data.isInjected)
         {
            this._hasSentMessage.setDataForPlayer(p,true);
         }
         this._checkForDone();
      }
      
      private function _checkForDone() : void
      {
         var activePlayers:Array;
         if(!this._canEndEarly)
         {
            return;
         }
         activePlayers = this._players.filter(function(p:BlobCastPlayer, ... args):Boolean
         {
            return p.isActive;
         });
         if(this.arePlayersDone(this._players))
         {
            this._finishedOnPlayerInput = true;
            this.setIsActive(this._players,false);
         }
         else if(this.arePlayersDone(activePlayers))
         {
            this._doneCanceller = JBGUtil.runFunctionAfter(function():void
            {
               _finishedOnPlayerInput = true;
               setIsActive(_players,false);
            },this._doneDuration);
         }
      }
   }
}
