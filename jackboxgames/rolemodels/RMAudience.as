package jackboxgames.rolemodels
{
   import jackboxgames.blobcast.modules.*;
   import jackboxgames.events.*;
   import jackboxgames.rolemodels.gameplay.*;
   import jackboxgames.settings.*;
   import jackboxgames.utils.*;
   
   public class RMAudience extends PausableEventDispatcher implements IToSimpleObject
   {
      
      public static const EVENT_AUDIENCE_PENDING_POINTS_GIVEN:String = "PendingPointsGiven";
      
      private static const TYPE_SORTABLE_CHOICE:String = "sortable";
      
      private static const TYPE_MAKE_SINGLE_CHOICE:String = "single";
       
      
      private var _audience:Audience;
      
      private var _voting:Voting;
      
      private var _resultVoteHandlers:Object;
      
      private var _isVoteActive:Boolean;
      
      private var _pendingPoints:WatchableValue;
      
      private var _score:WatchableValue;
      
      private var _hasEverBeenAudience:WatchableValue;
      
      private var _numAudienceMembers:WatchableValue;
      
      private var _maxAudienceMembers:WatchableValue;
      
      private var _numVotes:WatchableValue;
      
      public function RMAudience(audience:Audience, voting:Voting)
      {
         super();
         this._audience = audience;
         this._voting = voting;
         this._isVoteActive = false;
         this._resultVoteHandlers = {};
         this._hasEverBeenAudience = new WatchableValue(false,null,null,null);
         this._numAudienceMembers = new WatchableValue(0,null,null,null);
         this._maxAudienceMembers = new WatchableValue(0,null,null,null);
         this._numVotes = new WatchableValue(0,null,null,null);
         Player.AUDIENCE_PLAYER.name.val = "Audience";
         Player.AUDIENCE_PLAYER.userId.val = "Audience";
         this._audience.addEventListener(Audience.EVENT_AUDIENCE_COUNT_CHANGED,this._onAudienceCountChanged);
      }
      
      public function get audienceModule() : Audience
      {
         return this._audience;
      }
      
      public function get votingModule() : Voting
      {
         return this._voting;
      }
      
      public function get isVoteActive() : Boolean
      {
         return this._isVoteActive;
      }
      
      public function get numAudienceMembers() : WatchableValue
      {
         return this._numAudienceMembers;
      }
      
      public function get maxAudienceMembers() : WatchableValue
      {
         return this._maxAudienceMembers;
      }
      
      public function get numVotes() : WatchableValue
      {
         return this._numVotes;
      }
      
      public function get audienceIsActive() : Boolean
      {
         return SettingsManager.instance.getValue(SettingsConstants.SETTING_AUDIENCE_ON).val;
      }
      
      public function get hasEverBeenAudience() : WatchableValue
      {
         return this._hasEverBeenAudience;
      }
      
      public function get thereIsCurrentlyAnAudience() : Boolean
      {
         return this.numAudienceMembers.val > 0;
      }
      
      public function reset(hard:Boolean) : void
      {
         this._isVoteActive = false;
         this.numVotes.val = 0;
         if(hard)
         {
            this.hasEverBeenAudience.val = false;
            this.numAudienceMembers.val = 0;
            this.maxAudienceMembers.val = 0;
         }
         GameState.instance.setAudienceBlob({"state":"Logo"});
      }
      
      private function _onAudienceCountChanged(evt:EventWithData) : void
      {
         this.numAudienceMembers.val = evt.data;
         this.maxAudienceMembers.val = Math.max(this.maxAudienceMembers.val,this.numAudienceMembers.val);
         if(this.numAudienceMembers.val)
         {
            this.hasEverBeenAudience.val = true;
         }
      }
      
      private function _onVotesChanged(votes:Object) : void
      {
         this.numVotes.val = ObjectUtil.getTotal(votes);
      }
      
      public function setResultVoteHandler(id:String, handler:IResultVoteHandler) : void
      {
         this._resultVoteHandlers[id] = handler;
      }
      
      public function startResultVote(id:String, onVoteStarted:Function) : void
      {
         var handler:IResultVoteHandler = null;
         Assert.assert(this._resultVoteHandlers.hasOwnProperty(id));
         handler = this._resultVoteHandlers[id];
         this._startVote(handler.resultVoteText,TYPE_MAKE_SINGLE_CHOICE,handler.resultVoteKeys,handler.resultVoteChoices,onVoteStarted,function(results:Object):void
         {
            handler.applyResultVote(results);
         });
      }
      
      private function _startVote(text:String, type:String, moduleChoices:Array, userChoices:Array, onVoteStartedFn:Function, applyFn:Function) : void
      {
         this._isVoteActive = true;
         this.numVotes.val = 0;
         GameState.instance.setAudienceBlob({
            "state":"MakeSingleChoice",
            "type":type,
            "toggle":type == TYPE_MAKE_SINGLE_CHOICE,
            "prompt":{"html":text},
            "choiceId":"AudienceChoice",
            "choices":userChoices
         });
         this._voting.start({"choices":moduleChoices},function(success:Boolean):void
         {
            if(!success)
            {
               onVoteStartedFn(Nullable.NULL_FUNCTION);
               return;
            }
            GameState.instance.sessions.startPolling(_voting,{},_onVotesChanged);
            onVoteStartedFn(function(onVoteStoppedFn:Function):void
            {
               GameState.instance.sessions.stopPolling(_voting);
               GameState.instance.setAudienceBlob({"state":"Logo"});
               _voting.stop({},function(results:Object):void
               {
                  _isVoteActive = false;
                  onVoteStoppedFn(function():void
                  {
                     applyFn(results);
                  });
               });
            });
         });
      }
      
      public function toSimpleObject() : Object
      {
         if(!this.hasEverBeenAudience.val)
         {
            return null;
         }
         return {"count":this.maxAudienceMembers.val};
      }
   }
}
