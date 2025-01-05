package jackboxgames.rolemodels.actionpackages
{
   import jackboxgames.nativeoverride.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.rolemodels.gameplay.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.userinteraction.*;
   import jackboxgames.userinteraction.commonbehaviors.*;
   import jackboxgames.utils.*;
   
   public class Abundance extends JBGActionPackage implements IResultVoteHandler
   {
       
      
      private var _voteInteraction:InteractionHandler;
      
      private var _voteResults:Object;
      
      private var _revealData:AbundanceData;
      
      private var _audienceVotes:Object;
      
      private var _votingAudienceInputter:AudienceAwareInputter;
      
      public function Abundance(sourceURL:String)
      {
         super(sourceURL);
      }
      
      public function get promptText() : String
      {
         return LocalizationUtil.getPrintfText("ABUNDANCE_INSTRUCTION_PROMPT",this._revealData.primaryPlayer.name.val);
      }
      
      public function get gotConsolationRole() : Boolean
      {
         return this._revealData.roleData.source == RoleData.ROLE_SOURCE.CONSOLATION;
      }
      
      public function get votingPlayers() : Array
      {
         return this._revealData.votingPlayers;
      }
      
      public function get firstRoleName() : String
      {
         return this._revealData.rolesInvolved[0].name.toUpperCase();
      }
      
      public function get secondRoleName() : String
      {
         return this._revealData.rolesInvolved[1].name.toUpperCase();
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
         _ts.g.abundance = this;
         this._voteInteraction = new InteractionHandler(new MakeSingleChoice(true,function setup(players:Array):void
         {
            TSInputHandler.instance.setupForSingleInput();
            Player.SET_PLAYERS_CHOOSING_ACTIVE(_revealData.votingPlayers,true);
         },function getPromptFn(p:Player):Object
         {
            return {"html":LocalizationUtil.getPrintfText("ABUNDANCE_VOTE_PROMPT",_revealData.primaryPlayer.name.val)};
         },function getChoicesFn(p:Player):Array
         {
            return _revealData.rolesInvolved.map(function(role:RoleData, ... args):Object
            {
               return {"html":role.name.toUpperCase()};
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
            p.isChoosingActive = false;
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
               if(_voteResults.hasOwnProperty(_revealData.rolesInvolved[choice].name.toUpperCase()))
               {
                  _voteResults[_revealData.rolesInvolved[choice].name.toUpperCase()].push(userId);
               }
               else
               {
                  _voteResults[_revealData.rolesInvolved[choice].name.toUpperCase()] = [userId];
               }
            });
         }),GameState.instance,true,true);
         this._votingAudienceInputter = new AudienceAwareInputter(GameState.instance.gameAudience.audienceModule,GameState.instance.gameAudience.votingModule,"Done",Duration.fromSec(3));
         GameState.instance.gameAudience.setResultVoteHandler(GameConstants.REVEAL_CONSTANTS.abundance.name,this);
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         JBGUtil.reset([this._voteInteraction,this._votingAudienceInputter]);
         this._voteResults = {};
         this._audienceVotes = {};
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         this._revealData = AbundanceData(GameState.instance.currentReveal);
         this._revealData.rolesInvolved.forEach(function(role:RoleData, ... args):void
         {
            _voteResults[role.name.toUpperCase()] = [];
         });
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         ref.end();
      }
      
      public function handleActionSetupReveal(ref:IActionRef, params:Object) : void
      {
         var finalRole:RoleData = null;
         this._applyAudienceVote();
         GameState.instance.artifactState.addAbundanceResult(GameState.instance.roundIndex,this._revealData.rolesInvolved,this._voteResults);
         if(this._voteResults[this._revealData.rolesInvolved[0].name.toUpperCase()].length > this._voteResults[this._revealData.rolesInvolved[1].name.toUpperCase()].length)
         {
            finalRole = this._revealData.rolesInvolved[0];
         }
         else
         {
            finalRole = this._revealData.rolesInvolved[1];
         }
         finalRole.playerAssignedRole = this._revealData.primaryPlayer;
         if(finalRole.source == RoleData.ROLE_SOURCE.CONSOLATION)
         {
            Trophy.instance.unlock(GameConstants.TROPHY_GET_CONSOLATION);
            this._revealData.primaryPlayer.pendingPoints.val += this._revealData.revealConstants.getProperty("points");
         }
         else if(GameState.instance.currentRound.playerVotedForSelf(this._revealData.primaryPlayer,finalRole))
         {
            this._revealData.primaryPlayer.pendingPoints.val += this._revealData.revealConstants.getProperty("pointsForWinningTieSelf");
         }
         else
         {
            this._revealData.primaryPlayer.pendingPoints.val += this._revealData.revealConstants.getProperty("pointsForWinningTie");
         }
         this._revealData.setWinningRole(finalRole);
         ref.end();
      }
      
      private function _applyAudienceVote() : void
      {
         var highestVotePercentage:Number = 0;
         var audienceVotedRoleIndex:int = -1;
         for(var i:int = 0; i < this._revealData.rolesInvolved.length; i++)
         {
            if(this._audienceVotes[i] > highestVotePercentage)
            {
               highestVotePercentage = Number(this._audienceVotes[i]);
               audienceVotedRoleIndex = i;
            }
         }
         if(highestVotePercentage == 0.5 || audienceVotedRoleIndex < 0)
         {
            return;
         }
         this._voteResults[this._revealData.rolesInvolved[audienceVotedRoleIndex].name.toUpperCase()].push(Player.AUDIENCE_PLAYER.userId.val);
      }
      
      public function handleActionSetSubmissionActive(ref:IActionRef, params:Object) : void
      {
         this._voteInteraction.setIsActive(this._revealData.votingPlayers,params.isActive);
         ref.end();
      }
      
      public function get resultVoteText() : String
      {
         return LocalizationUtil.getPrintfText("ABUNDANCE_VOTE_PROMPT",this._revealData.primaryPlayer.name.val);
      }
      
      public function get resultVoteKeys() : Array
      {
         return this._revealData.rolesInvolved.map(function(role:RoleData, index:int, ... args):String
         {
            return String(index);
         });
      }
      
      public function get resultVoteChoices() : Array
      {
         return this._revealData.rolesInvolved.map(function(role:RoleData, ... args):Object
         {
            return {"html":role.name.toUpperCase()};
         });
      }
      
      public function applyResultVote(results:Object) : void
      {
         var totalNumberOfVotes:Number = NaN;
         totalNumberOfVotes = ObjectUtil.getTotal(results);
         this._revealData.rolesInvolved.forEach(function(role:RoleData, i:int, ... args):void
         {
            _audienceVotes[i] = totalNumberOfVotes > 0 ? Number(results[String(i)] / totalNumberOfVotes) : 0;
         });
      }
   }
}
