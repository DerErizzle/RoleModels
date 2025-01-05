package jackboxgames.rolemodels.actionpackages
{
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.rolemodels.gameplay.*;
   import jackboxgames.rolemodels.userinteraction.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.userinteraction.*;
   import jackboxgames.utils.*;
   
   public class Split extends JBGActionPackage implements IResultVoteHandler
   {
       
      
      private var _revealData:SplitData;
      
      private var _splitVoteInteraction:InteractionHandler;
      
      private var _voteResults:PerPlayerContainer;
      
      private var _audienceVotesForFirstPrimaryPlayer:Object;
      
      private var _votingAudienceInputter:AudienceAwareInputter;
      
      public function Split(sourceURL:String)
      {
         super(sourceURL);
      }
      
      public function get promptText() : String
      {
         return this._revealData.prompt;
      }
      
      public function get resultType() : String
      {
         return this._revealData.result;
      }
      
      public function get votingPlayers() : Array
      {
         return this._revealData.votingPlayers;
      }
      
      public function handleActionInit(ref:IActionRef, params:Object) : void
      {
         _setLoaded(true,function():void
         {
            _onLoaded();
            ref.end();
         });
      }
      
      private function _onLoaded() : void
      {
         _ts.g.split = this;
         this._voteResults = new PerPlayerContainer();
         this._splitVoteInteraction = new InteractionHandler(new SortableBehavior(false,function setup(players:Array):void
         {
            TSInputHandler.instance.setupForSingleInput();
            Player.SET_PLAYERS_CHOOSING_ACTIVE(_revealData.votingPlayers,true);
         },function getPromptFn(p:Player):Object
         {
            return {"html":_revealData.roleData.categoryName.toUpperCase()};
         },function getRolesFn(p:Player):Array
         {
            return _revealData.splitRoles.map(function(r:RoleData, i:int, ... args):Object
            {
               return {
                  "index":i,
                  "choice":r.shortName.toUpperCase()
               };
            });
         },function getPlayersFn():Array
         {
            return _revealData.primaryPlayers.map(function(player:Player, i:int, ... args):Object
            {
               return {
                  "index":player.index.val,
                  "name":player.name.val,
                  "color":GameConstants.PLAYER_COLORS[player.index.val]
               };
            });
         },function finalizeBlob(p:Player, blob:Object):void
         {
         },function userUpdatedSlotsFn(p:Player, choices:Array, submitted:Boolean):Boolean
         {
            p.isChoosingActive = !submitted;
            return true;
         },function doneFn(finishedOnUserInput:Boolean, choices:PerPlayerContainer):void
         {
            if(finishedOnUserInput)
            {
               _votingAudienceInputter.isActive = true;
            }
            GameState.instance.players.forEach(function(p:Player, i:int, arr:Array):void
            {
               GameState.instance.setCustomerBlobWithMetadata(p,{"state":"Logo"});
            });
            _voteResults = RMUtil.formatVotes(_revealData.primaryPlayers,choices,_revealData.splitRoles);
         }),GameState.instance,true,true);
         this._votingAudienceInputter = new AudienceAwareInputter(GameState.instance.gameAudience.audienceModule,GameState.instance.gameAudience.votingModule,"Done",Duration.fromSec(3));
         GameState.instance.gameAudience.setResultVoteHandler(GameConstants.REVEAL_CONSTANTS.split.name,this);
         this._audienceVotesForFirstPrimaryPlayer = {};
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         JBGUtil.reset([this._splitVoteInteraction,this._voteResults,this._votingAudienceInputter]);
         this._audienceVotesForFirstPrimaryPlayer = {};
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         this._revealData = SplitData(GameState.instance.currentReveal);
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         ref.end();
      }
      
      public function handleActionSetSubmissionActive(ref:IActionRef, params:Object) : void
      {
         this._splitVoteInteraction.setIsActive(this._revealData.votingPlayers,params.isActive);
         ref.end();
      }
      
      public function handleActionSetupReveal(ref:IActionRef, params:Object) : void
      {
         var audienceVoted:Boolean = false;
         if(this._revealData.primaryPlayers.length == 2)
         {
            audienceVoted = this._applySortableTwoPlayerAudienceVote();
         }
         GameState.instance.artifactState.addSplitResult(GameState.instance.roundIndex,this._revealData.primaryPlayers,this._voteResults);
         this._revealData.result = RMUtil.calculateTwoRoleTiebreakerResult(this._revealData,this._revealData.splitRoles,this._revealData.votingPlayers,this._voteResults,audienceVoted);
         this._revealData.roleData.playerAssignedRole = Player.STUB_PLAYER;
         ref.end();
      }
      
      private function _applySortableTwoPlayerAudienceVote() : Boolean
      {
         var firstPrimaryPlayerRole:RoleData = null;
         var roles:Array = this._revealData.splitRoles;
         var players:Array = this._revealData.primaryPlayers;
         for(var i:int = 0; i < roles.length; i++)
         {
            if(this._audienceVotesForFirstPrimaryPlayer[i] > 0.5)
            {
               firstPrimaryPlayerRole = roles[i];
               break;
            }
         }
         if(firstPrimaryPlayerRole == null)
         {
            return false;
         }
         this._voteResults.getDataForPlayer(players[0])[firstPrimaryPlayerRole.name].push(Player.AUDIENCE_PLAYER);
         var secondPrimaryPlayerRole:RoleData = ArrayUtil.first(ArrayUtil.difference(roles,[firstPrimaryPlayerRole]));
         this._voteResults.getDataForPlayer(players[1])[secondPrimaryPlayerRole.name].push(Player.AUDIENCE_PLAYER);
         return true;
      }
      
      public function get resultVoteText() : String
      {
         return LocalizationUtil.getPrintfText("AUDIENCE_SPLIT_VOTE_PROMPT",Player(this._revealData.primaryPlayers[0]).name.val);
      }
      
      public function get resultVoteKeys() : Array
      {
         return this._revealData.splitRoles.map(function(r:RoleData, i:int, ... args):Object
         {
            return String(i);
         });
      }
      
      public function get resultVoteChoices() : Array
      {
         return this._revealData.splitRoles.map(function(r:RoleData, i:int, ... args):Object
         {
            return {"html":r.shortName.toUpperCase()};
         });
      }
      
      public function applyResultVote(results:Object) : void
      {
         var totalNumberOfVotes:Number = NaN;
         totalNumberOfVotes = ObjectUtil.getTotal(results);
         this._revealData.splitRoles.forEach(function(role:RoleData, i:int, ... args):void
         {
            _audienceVotesForFirstPrimaryPlayer[i] = totalNumberOfVotes > 0 ? Number(results[String(i)] / totalNumberOfVotes) : 0;
         });
      }
   }
}
