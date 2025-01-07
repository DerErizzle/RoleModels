package jackboxgames.moderation
{
   import jackboxgames.ecast.messages.*;
   import jackboxgames.ecast.messages.client.*;
   import jackboxgames.events.*;
   import jackboxgames.model.*;
   import jackboxgames.moderation.model.*;
   import jackboxgames.settings.*;
   import jackboxgames.utils.*;
   
   public class ModerationHandler extends PausableEventDispatcher
   {
      public static const EVENT_MODERATION_RESULT:String = "ModerationResult";
      
      public static const EVENT_MODERATORS_COUNT_CHANGED:String = "ModeratorCountChanged";
      
      protected var _moderators:Array;
      
      private var _gameState:JBGGameState;
      
      private var _numberOfModeratedEntities:int;
      
      public function ModerationHandler(gameState:JBGGameState)
      {
         super();
         this._gameState = gameState;
         this._moderators = [];
         this._numberOfModeratedEntities = 0;
         this._gameState.userDataManager.addEventListener(UserDataManager.USER_DATA_ADDED,this._onNewUserData);
         this._gameState.userDataManager.addEventListener(UserDataManager.USER_DATA_REMOVED,this._onRemovedUserData);
      }
      
      public function get moderators() : Array
      {
         return this._moderators;
      }
      
      public function get numModerators() : int
      {
         return this._moderators.length;
      }
      
      public function reset() : void
      {
         if(this._numberOfModeratedEntities > 0)
         {
            if(this._gameState.client != null)
            {
               this._gameState.client.removeEventListener("object",this._onEntityUpdated);
            }
            this._numberOfModeratedEntities = 0;
         }
         this._moderators = [];
      }
      
      public function isAModerator(id:int) : Boolean
      {
         return ArrayUtil.find(this._moderators,function(client:ClientConnected, ... args):Boolean
         {
            return client.id == id;
         }) != null;
      }
      
      private function _moderatedDataWasAdded() : void
      {
         if(this._numberOfModeratedEntities == 0)
         {
            this._gameState.client.addEventListener("object",this._onEntityUpdated);
         }
         ++this._numberOfModeratedEntities;
      }
      
      private function _moderatedDataWasRemoved() : void
      {
         if(this._numberOfModeratedEntities == 0)
         {
            return;
         }
         --this._numberOfModeratedEntities;
         if(this._numberOfModeratedEntities == 0)
         {
            this._gameState.client.removeEventListener("object",this._onEntityUpdated);
         }
      }
      
      private function _onNewUserData(event:EventWithData) : void
      {
         var userData:IUserData = event.data;
         if(!SettingsManager.instance.getValue(SettingsConstants.SETTING_MODERATED_ROOM).val)
         {
            userData.moderationStatus = ModerationConstants.MODERATION_STATUS_ACCEPTED;
            return;
         }
         userData.moderationStatus = ModerationConstants.MODERATION_STATUS_PENDING;
         this._gameState.client.createObject(userData.moderationKey,{
            "from":userData.from,
            "name":this._gameState.getPlayerBySessionId(userData.from).name.val,
            "context":userData.context,
            "value":userData.data,
            "status":userData.moderationStatus
         },null,["rw role:moderator"]).then(function(res:Reply):void
         {
            _moderatedDataWasAdded();
         });
      }
      
      private function _onRemovedUserData(event:EventWithData) : void
      {
         var userData:IUserData = event.data;
         if(!SettingsManager.instance.getValue(SettingsConstants.SETTING_MODERATED_ROOM).val)
         {
            return;
         }
         if(this._gameState.client != null)
         {
            this._gameState.client.drop(userData.moderationKey);
            this._moderatedDataWasRemoved();
         }
      }
      
      private function _onEntityUpdated(event:EventWithData) : void
      {
         var n:Notification = event.data;
         var o:ObjectElement = n.result;
         var data:IUserData = this._gameState.userDataManager.getUserDataWithKey(o.key);
         if(data == null || data.moderationStatus == ModerationConstants.MODERATION_STATUS_REJECTED)
         {
            return;
         }
         if(o.val.status != data.moderationStatus)
         {
            data.moderationStatus = o.val.status;
            dispatchEvent(new EventWithData(EVENT_MODERATION_RESULT,data));
         }
      }
      
      public function onModeratorConnected(newClient:ClientConnected) : void
      {
         if(ArrayUtil.find(this._moderators,function(client:ClientConnected, ... args):Boolean
         {
            return client.id == newClient.id;
         }))
         {
            return;
         }
         this._moderators.push(newClient);
         dispatchEvent(new EventWithData(EVENT_MODERATORS_COUNT_CHANGED,{"count":this.numModerators}));
      }
      
      public function onModeratorLeft(leavingClient:ClientDisconnected) : void
      {
         var existingClient:ClientConnected = ArrayUtil.find(this._moderators,function(client:ClientConnected, ... args):Boolean
         {
            return client.id == leavingClient.id;
         });
         if(existingClient == null)
         {
            return;
         }
         ArrayUtil.removeElementFromArray(this._moderators,existingClient);
         dispatchEvent(new EventWithData(EVENT_MODERATORS_COUNT_CHANGED,{"count":this.numModerators}));
      }
      
      public function waitForDataToBeModerated(dataToModerate:Array, doneFn:Function) : Function
      {
         if(dataToModerate.length == 0 || this.numModerators == 0)
         {
            doneFn();
            return Nullable.NULL_FUNCTION;
         }
         var moderationWait:ModerationWait = new ModerationWait(this,dataToModerate,doneFn);
         return moderationWait.canceler;
      }
      
      public function dropModerationForData(dataToDrop:Array) : void
      {
         if(dataToDrop.length == 0)
         {
            return;
         }
         dataToDrop.forEach(function(userData:IUserData, ... args):void
         {
            _gameState.client.drop(userData.moderationKey);
         });
      }
   }
}

