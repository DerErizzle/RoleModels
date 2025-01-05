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
   import jackboxgames.userinteraction.commonbehaviors.*;
   import jackboxgames.utils.*;
   
   public class TagChoice extends JBGActionPackage implements IResultVoteHandler
   {
       
      
      private var _revealData:TagChoiceData;
      
      private var _tagChoiceInteraction:InteractionHandler;
      
      private var _singlePlayerTagChoiceInteraction:InteractionHandler;
      
      private var _sortableVoteResults:PerPlayerContainer;
      
      private var _singlePlayerVoteResults:Object;
      
      private var _audienceVotesForFirstPrimaryPlayer:Object;
      
      private var _votingAudienceInputter:AudienceAwareInputter;
      
      public function TagChoice(sourceURL:String)
      {
         super(sourceURL);
      }
      
      public function get promptText() : String
      {
         if(this._revealData.primaryPlayers.length == 1)
         {
            return LocalizationUtil.getPrintfText("TAG_CHOICE_SINGLE_PLAYER_INSTRUCTION_PROMPT",this._revealData.primaryPlayers[0].name.val);
         }
         return LocalizationUtil.getPrintfText("TAG_CHOICE_INSTRUCTION_PROMPT");
      }
      
      public function get resultType() : String
      {
         return this._revealData.result;
      }
      
      public function get votingPlayers() : Array
      {
         return this._revealData.votingPlayers;
      }
      
      public function get firstTagString() : String
      {
         return this._revealData.tags[0].rawString;
      }
      
      public function get secondTagString() : String
      {
         return this._revealData.tags[1].rawString;
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
         _ts.g.tagChoice = this;
         this._sortableVoteResults = new PerPlayerContainer();
         this._tagChoiceInteraction = new InteractionHandler(new SortableBehavior(false,function setup(players:Array):void
         {
            TSInputHandler.instance.setupForSingleInput();
            Player.SET_PLAYERS_CHOOSING_ACTIVE(_revealData.votingPlayers,true);
         },function getPromptFn(p:Player):Object
         {
            return {"html":LocalizationUtil.getPrintfText("TAG_CHOICE_PROMPT")};
         },function getRolesFn(p:Player):Array
         {
            return _revealData.tags.map(function(tag:TagData, i:int, ... args):Object
            {
               return {
                  "index":i,
                  "choice":tag.rawString
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
            _sortableVoteResults = RMUtil.formatVotes(_revealData.primaryPlayers,choices,_revealData.rolesInvolved);
         }),GameState.instance,true,true);
         this._singlePlayerVoteResults = {};
         this._singlePlayerTagChoiceInteraction = new InteractionHandler(new MakeSingleChoice(true,function setup(players:Array):void
         {
            TSInputHandler.instance.setupForSingleInput();
         },function getPromptFn(p:Player):Object
         {
            return {"html":LocalizationUtil.getPrintfText("TAG_CHOICE_SINGLE_PLAYER_PROMPT",_revealData.primaryPlayers[0].name.val)};
         },function getChoicesFn(p:Player):Array
         {
            return _revealData.tags.map(function(tag:TagData, ... args):Object
            {
               return {"html":tag.rawString};
            });
         },function _getChoiceTypeFn(p:Player):String
         {
            return "RoleModelsChoice";
         },function getDoneText(p:Player, choiceIndex:int):String
         {
            return "Thank you!";
         },function getChoiceIdFn(p:Player):String
         {
            return undefined;
         },function getClassesFn(p:Player):Array
         {
            return [];
         },function finalizeBlob(p:Player, blob:Object):void
         {
         },function userMadeChoiceFn(p:Player, choice:int):Boolean
         {
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
            choices.forEach(function(choice:int, userId:String, ... args):void
            {
               _singlePlayerVoteResults[_revealData.rolesInvolved[choice].name].push(userId);
            });
         }),GameState.instance,true,true);
         this._votingAudienceInputter = new AudienceAwareInputter(GameState.instance.gameAudience.audienceModule,GameState.instance.gameAudience.votingModule,"Done",Duration.fromSec(3));
         GameState.instance.gameAudience.setResultVoteHandler(GameConstants.REVEAL_CONSTANTS.tagChoice.name,this);
         this._audienceVotesForFirstPrimaryPlayer = {};
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         JBGUtil.reset([this._tagChoiceInteraction,this._singlePlayerTagChoiceInteraction,this._sortableVoteResults,this._votingAudienceInputter]);
         this._audienceVotesForFirstPrimaryPlayer = {};
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         var role:RoleData = null;
         this._revealData = TagChoiceData(GameState.instance.currentReveal);
         for each(role in this._revealData.rolesInvolved)
         {
            this._singlePlayerVoteResults[role.name] = [];
         }
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         ref.end();
      }
      
      public function handleActionSetSubmissionActive(ref:IActionRef, params:Object) : void
      {
         if(this._revealData.primaryPlayers.length == 1)
         {
            this._singlePlayerTagChoiceInteraction.setIsActive(this._revealData.votingPlayers,params.isActive);
         }
         else
         {
            this._tagChoiceInteraction.setIsActive(this._revealData.votingPlayers,params.isActive);
         }
         ref.end();
      }
      
      public function handleActionSetupReveal(ref:IActionRef, params:Object) : void
      {
         var singlePlayerAudienceVoted:Boolean = false;
         var primaryPlayer:Player = null;
         var votesForFirstRole:int = 0;
         var votesForSecondRole:int = 0;
         var finalRole:RoleData = null;
         var audienceVoted:Boolean = false;
         if(this._revealData.primaryPlayers.length == 1)
         {
            singlePlayerAudienceVoted = this._applySinglePlayerAudienceVote();
            GameState.instance.artifactState.addAbundanceResult(GameState.instance.roundIndex,this._revealData.rolesInvolved,this._singlePlayerVoteResults);
            primaryPlayer = ArrayUtil.first(this._revealData.primaryPlayers);
            votesForFirstRole = int(this._singlePlayerVoteResults[this._revealData.rolesInvolved[0].name].length);
            votesForSecondRole = int(this._singlePlayerVoteResults[this._revealData.rolesInvolved[1].name].length);
            if(votesForFirstRole > votesForSecondRole)
            {
               finalRole = this._revealData.rolesInvolved[0];
               if(RMUtil.voteWasQuiplash(this._revealData.votingPlayers.length,votesForFirstRole,singlePlayerAudienceVoted))
               {
                  this._revealData.result = GameConstants.TIEBREAKER_RESULTS.QUIPLASH;
               }
               else
               {
                  this._revealData.result = GameConstants.TIEBREAKER_RESULTS.MAJORITY;
               }
            }
            else if(votesForSecondRole / this._revealData.votingPlayers.length > 0.5)
            {
               finalRole = this._revealData.rolesInvolved[1];
               if(RMUtil.voteWasQuiplash(this._revealData.votingPlayers.length,votesForSecondRole,singlePlayerAudienceVoted))
               {
                  this._revealData.result = GameConstants.TIEBREAKER_RESULTS.QUIPLASH;
               }
               else
               {
                  this._revealData.result = GameConstants.TIEBREAKER_RESULTS.MAJORITY;
               }
            }
            else if(GameState.instance.currentRound.playerVotedSelfForDoubleDown(primaryPlayer,this._revealData.rolesInvolved[0]))
            {
               finalRole = this._revealData.rolesInvolved[0];
               this._revealData.result = GameConstants.TIEBREAKER_RESULTS.DOUBLE_DOWN_BROKE_TIE;
            }
            else if(GameState.instance.currentRound.playerVotedSelfForDoubleDown(primaryPlayer,this._revealData.rolesInvolved[1]))
            {
               finalRole = this._revealData.rolesInvolved[1];
               this._revealData.result = GameConstants.TIEBREAKER_RESULTS.DOUBLE_DOWN_BROKE_TIE;
            }
            else
            {
               finalRole = Math.random() >= 0.5 ? this._revealData.rolesInvolved[0] : this._revealData.rolesInvolved[1];
               this._revealData.result = GameConstants.TIEBREAKER_RESULTS.TIE;
            }
            finalRole.playerAssignedRole = primaryPlayer;
            if(GameState.instance.currentRound.playerVotedForSelf(primaryPlayer,finalRole))
            {
               primaryPlayer.pendingPoints.val += this._revealData.revealConstants.getProperty("pointsForWinningTieSelf");
            }
            else
            {
               primaryPlayer.pendingPoints.val += this._revealData.revealConstants.getProperty("pointsForWinningTie");
            }
         }
         else
         {
            audienceVoted = false;
            if(this._revealData.primaryPlayers.length == 2)
            {
               audienceVoted = this._applySortableTwoPlayerAudienceVote();
            }
            GameState.instance.artifactState.addSplitResult(GameState.instance.roundIndex,this._revealData.primaryPlayers,this._sortableVoteResults);
            this._revealData.result = RMUtil.calculateTwoRoleTiebreakerResult(this._revealData,this._revealData.rolesInvolved,this._revealData.votingPlayers,this._sortableVoteResults,audienceVoted);
         }
         ref.end();
      }
      
      private function _applySinglePlayerAudienceVote() : Boolean
      {
         for(var i:int = 0; i < this._revealData.tags.length; i++)
         {
            if(this._audienceVotesForFirstPrimaryPlayer[this._revealData.tags[i].rawString] > 0.5)
            {
               this._singlePlayerVoteResults[this._revealData.rolesInvolved[i].name].push(Player.AUDIENCE_PLAYER.userId.val);
               return true;
            }
         }
         return false;
      }
      
      private function _applySortableTwoPlayerAudienceVote() : Boolean
      {
         var firstPrimaryPlayerRole:RoleData = null;
         var roles:Array = this._revealData.rolesInvolved;
         var players:Array = this._revealData.primaryPlayers;
         for(var i:int = 0; i < this._revealData.tags.length; i++)
         {
            if(this._audienceVotesForFirstPrimaryPlayer[this._revealData.tags[i].rawString] > 0.5)
            {
               firstPrimaryPlayerRole = roles[i];
               break;
            }
         }
         if(firstPrimaryPlayerRole == null)
         {
            return false;
         }
         this._sortableVoteResults.getDataForPlayer(players[0])[firstPrimaryPlayerRole.name].push(Player.AUDIENCE_PLAYER);
         var secondPrimaryPlayerRole:RoleData = ArrayUtil.first(ArrayUtil.difference(roles,[firstPrimaryPlayerRole]));
         this._sortableVoteResults.getDataForPlayer(players[1])[secondPrimaryPlayerRole.name].push(Player.AUDIENCE_PLAYER);
         return true;
      }
      
      public function get resultVoteText() : String
      {
         return LocalizationUtil.getPrintfText("TAG_CHOICE_SINGLE_PLAYER_PROMPT",this._revealData.primaryPlayers[0].name.val);
      }
      
      public function get resultVoteKeys() : Array
      {
         return this._revealData.tags.map(function(tag:TagData, i:int, ... args):Object
         {
            return String(i);
         });
      }
      
      public function get resultVoteChoices() : Array
      {
         return this._revealData.tags.map(function(tag:TagData, ... args):Object
         {
            return {"text":tag.rawString};
         });
      }
      
      public function applyResultVote(results:Object) : void
      {
         var totalNumberOfVotes:Number = NaN;
         totalNumberOfVotes = ObjectUtil.getTotal(results);
         this._revealData.tags.forEach(function(tag:TagData, i:int, ... args):void
         {
            _audienceVotesForFirstPrimaryPlayer[tag.rawString] = totalNumberOfVotes > 0 ? Number(results[String(i)] / totalNumberOfVotes) : 0;
         });
      }
   }
}
