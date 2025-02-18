package jackboxgames.model
{
   import jackboxgames.entityinteraction.entities.*;
   import jackboxgames.events.*;
   import jackboxgames.utils.*;
   
   public class JBGPlayer extends PausableEventDispatcher implements IToSimpleObject
   {
      public static const EVENT_IS_ACTIVE_CHANGED:String = "IsActiveChanged";
      
      private static const DEFAULT_MIN_MISSED_INTERACTIONS_BEFORE_INACTIVE:int = 3;
      
      protected var _index:WatchableValue;
      
      protected var _sessionId:WatchableValue;
      
      protected var _userId:WatchableValue;
      
      protected var _name:WatchableValue;
      
      protected var _score:WatchableValue;
      
      protected var _pendingPoints:WatchableValue;
      
      private var _missedInteractionsInARow:int;
      
      private var _minMissedInteractionsBeforeInactive:int;
      
      private var _mainEntity:ObjectEntity;
      
      public function JBGPlayer()
      {
         super();
         this._index = new WatchableValue(0,null,null,null);
         this._sessionId = new WatchableValue(0,null,null,null);
         this._userId = new WatchableValue("Null",null,null,null);
         this._name = new WatchableValue("Null",null,null,null);
         this._score = new WatchableValue(0,null,null,null);
         this._pendingPoints = new WatchableValue(0,null,null,null);
      }
      
      public function get index() : WatchableValue
      {
         return this._index;
      }
      
      public function get sessionId() : WatchableValue
      {
         return this._sessionId;
      }
      
      public function get userId() : WatchableValue
      {
         return this._userId;
      }
      
      public function get name() : WatchableValue
      {
         return this._name;
      }
      
      public function get isVIP() : Boolean
      {
         return this._index.val == 0;
      }
      
      public function get score() : WatchableValue
      {
         return this._score;
      }
      
      public function get pendingPoints() : WatchableValue
      {
         return this._pendingPoints;
      }
      
      public function get mainEntity() : ObjectEntity
      {
         return this._mainEntity;
      }
      
      public function initialize(index:int, sessionId:int, userId:String, name:String, mainEntity:ObjectEntity) : void
      {
         this.reset();
         this._index.val = index;
         this._sessionId.val = sessionId;
         this._userId.val = userId;
         this._name.val = TextUtils.ellipsize(name,12);
         this._mainEntity = mainEntity;
         this._missedInteractionsInARow = 0;
         if(BuildConfig.instance.hasConfigVal("minMissedInteractionsBeforeInactive"))
         {
            this._minMissedInteractionsBeforeInactive = BuildConfig.instance.configVal("minMissedInteractionsBeforeInactive");
         }
         else
         {
            this._minMissedInteractionsBeforeInactive = DEFAULT_MIN_MISSED_INTERACTIONS_BEFORE_INACTIVE;
         }
      }
      
      public function dispose() : void
      {
      }
      
      public function reset() : void
      {
      }
      
      public function updatePlayerBlob(blob:Object) : Object
      {
         blob.playerInfo = {
            "username":this._name.val,
            "sessionId":this._sessionId.val,
            "playerIndex":this._index.val,
            "index":this._index.val
         };
         return blob;
      }
      
      public function get isActive() : Boolean
      {
         return this._missedInteractionsInARow < this._minMissedInteractionsBeforeInactive;
      }
      
      private function _setMissedInteractionsInARow(val:int) : void
      {
         var wasActive:Boolean = this.isActive;
         this._missedInteractionsInARow = val;
         if(wasActive != this.isActive)
         {
            dispatchEvent(new EventWithData(EVENT_IS_ACTIVE_CHANGED,null));
         }
      }
      
      public function recordSuccessfulInteraction() : void
      {
         this._setMissedInteractionsInARow(0);
      }
      
      public function recordMissedInteraction() : void
      {
         this._setMissedInteractionsInARow(this._missedInteractionsInARow + 1);
      }
      
      public function toSimpleObject() : Object
      {
         return {
            "id":this.userId.val,
            "sessionId":this.sessionId.val,
            "name":this.name.val,
            "score":this.score.val
         };
      }
   }
}

