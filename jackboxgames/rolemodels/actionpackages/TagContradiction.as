package jackboxgames.rolemodels.actionpackages
{
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.rolemodels.gameplay.*;
   import jackboxgames.rolemodels.userinteraction.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.userinteraction.*;
   import jackboxgames.userinteraction.commonbehaviors.*;
   import jackboxgames.utils.*;
   
   public class TagContradiction extends JBGActionPackage implements IResultVoteHandler
   {
      
      public static const FILLER_TOPICS:Array = ["animal","song","food","movie","phrase"];
       
      
      private var _promptText:String;
      
      private var _revealData:TagContradictionData;
      
      private var _promptModule:InteractionHandler;
      
      private var _autoSubmit:Boolean;
      
      private var _tagContradictionInteraction:InteractionHandler;
      
      private var _voteResults:Object;
      
      private var _primaryPlayerGuess:String;
      
      private var _primaryPlayerGuessedCorrectly:Boolean;
      
      private var _winningIndex:int;
      
      private var _censorIndex:int;
      
      private var _isCensored:Boolean;
      
      private var _audienceVotesForFirstPrimaryPlayer:Object;
      
      private var _votingAudienceInputter:AudienceAwareInputter;
      
      public function TagContradiction(sourceURL:String)
      {
         super(sourceURL);
      }
      
      public function get promptText() : String
      {
         return this._promptText;
      }
      
      public function get voteText() : String
      {
         return LocalizationUtil.getPrintfText("TAG_CONTRADICTION_INSTRUCTION_PROMPT",this._revealData.primaryPlayer.name.val);
      }
      
      public function get resultType() : String
      {
         return this._revealData.result;
      }
      
      public function get votingPlayers() : Array
      {
         return this._revealData.votingPlayers.concat(this._revealData.primaryPlayer);
      }
      
      public function get primaryPlayerGuessedCorrectly() : Boolean
      {
         return this._primaryPlayerGuessedCorrectly;
      }
      
      public function get firstRoleName() : String
      {
         return this._revealData.rolesInvolved[0].name.toUpperCase();
      }
      
      public function get secondRoleName() : String
      {
         return this._revealData.rolesInvolved[1].name.toUpperCase();
      }
      
      public function get firstTagString() : String
      {
         return this._revealData.tags[0].protoTag;
      }
      
      public function get secondTagString() : String
      {
         return this._revealData.tags[1].protoTag;
      }
      
      public function get winningIndex() : int
      {
         return this._winningIndex;
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
         _ts.g.tagContradiction = this;
         this._promptModule = new InteractionHandler(new EnterSingleText(GameConstants.NUMBER_OF_CHARACTERS_IN_TEXT_ENTRY,true,function setup(players:Array):void
         {
            TSInputHandler.instance.setupForSingleInput();
         },function getPromptFn(p:Player):Object
         {
            return {"html":_promptText};
         },function getPlaceholderFn(p:Player):String
         {
            return LocalizationUtil.getPrintfText("TAG_CONTRADICTION_SINGLE_TEXT_PLACEHOLDER_TEXT");
         },function getDoneText(p:Player, entry:String):String
         {
            return "Thank you!";
         },function getErrorText(p:Player):String
         {
            return null;
         },function getInputType():String
         {
            return "text";
         },function getEntryId(p:Player):String
         {
            return "TagResolution";
         },function finalizeBlob(forPlayer:Player, blob:Object):void
         {
            blob.autoSubmit = _autoSubmit;
         },function onPlayerEntered(p:Player, entry:String):Boolean
         {
            return true;
         },function doneFn(finishedOnPlayerInput:Boolean, entries:PerPlayerContainer):void
         {
            if(finishedOnPlayerInput)
            {
               TSInputHandler.instance.input("Done");
            }
            var data:* = {"answer":(entries.hasDataForPlayer(_revealData.primaryPlayer) ? entries.getDataForPlayer(_revealData.primaryPlayer) : LocalizationUtil.getPrintfText("TAG_CONTRADICTION_FILLER_ANSWER"))};
            _revealData.primaryPlayer.broadcast("AnswerSubmitted",data);
         }),GameState.instance,true,true);
         this._tagContradictionInteraction = new InteractionHandler(new MakeSingleChoice(true,function setup(players:Array):void
         {
            _censorIndex = -1;
            _isCensored = false;
            TSInputHandler.instance.setupForSingleInput();
            Player.SET_PLAYERS_CHOOSING_ACTIVE(votingPlayers,true);
         },function getPromptFn(p:Player):Object
         {
            if(p == _revealData.primaryPlayer)
            {
               return {"html":LocalizationUtil.getPrintfText("TAG_CONTRADICTION_PRIMARY_PLAYER_VOTE_PROMPT")};
            }
            return {"html":LocalizationUtil.getPrintfText("TAG_CONTRADICTION_VOTE_PROMPT",_revealData.primaryPlayer.name.val)};
         },function getChoicesFn(p:Player):Array
         {
            var skip:* = undefined;
            var choices:* = _revealData.tags.map(function(tag:TagData, ... args):Object
            {
               return {"html":tag.protoTag};
            });
            if(p.isVIP && SettingsManager.instance.getValue(SettingsConstants.SETTING_CENSORABLE).val)
            {
               _censorIndex = 0;
               skip = {"text":LocalizationUtil.getPrintfText("CENSOR_REVEAL_BUTTON_TEXT")};
               _censorIndex = choices.push(skip) - 1;
               return choices;
            }
            return choices;
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
            if(p.isVIP && SettingsManager.instance.getValue(SettingsConstants.SETTING_CENSORABLE).val && choice == _censorIndex)
            {
               _isCensored = true;
               TSInputHandler.instance.input("skip");
               return true;
            }
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
               var votingPlayer:* = undefined;
               if(!(GameState.instance.getPlayerByUserId(userId).isVIP && SettingsManager.instance.getValue(SettingsConstants.SETTING_CENSORABLE).val && choice == _censorIndex))
               {
                  votingPlayer = Player(GameState.instance.getPlayerByUserId(userId));
                  if(votingPlayer == _revealData.primaryPlayer)
                  {
                     _primaryPlayerGuess = _revealData.tags[choice].protoTag;
                  }
                  else
                  {
                     _voteResults[_revealData.tags[choice].protoTag].push(votingPlayer);
                  }
               }
            });
         }),GameState.instance,true,true);
         this._votingAudienceInputter = new AudienceAwareInputter(GameState.instance.gameAudience.audienceModule,GameState.instance.gameAudience.votingModule,"Done",Duration.fromSec(3));
         GameState.instance.gameAudience.setResultVoteHandler(GameConstants.REVEAL_CONSTANTS.tagContradiction.name,this);
         this._audienceVotesForFirstPrimaryPlayer = {};
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         JBGUtil.reset([this._tagContradictionInteraction,this._votingAudienceInputter,this._promptModule]);
         this._audienceVotesForFirstPrimaryPlayer = {};
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         var tag:TagData = null;
         this._revealData = TagContradictionData(GameState.instance.currentReveal);
         this._voteResults = {};
         for each(tag in this._revealData.tags)
         {
            this._voteResults[tag.protoTag] = [];
         }
         this._primaryPlayerGuess = "";
         this._primaryPlayerGuessedCorrectly = false;
         this._promptText = this._revealData.prompt;
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         ref.end();
      }
      
      public function handleActionSetTextSubmissionActive(ref:IActionRef, params:Object) : void
      {
         this._promptModule.setIsActive(this._revealData.primaryPlayers,params.isActive);
         ref.end();
      }
      
      public function handleActionAutoSubmit(ref:IActionRef, params:Object) : void
      {
         this._autoSubmit = true;
         TSInputHandler.instance.setupForSingleInput();
         this._promptModule.forceUpdateAllPlayers();
         ref.end();
      }
      
      public function handleActionSetVoteSubmissionActive(ref:IActionRef, params:Object) : void
      {
         this._tagContradictionInteraction.setIsActive(this._revealData.votingPlayers.concat(this._revealData.primaryPlayer),params.isActive);
         ref.end();
      }
      
      public function handleActionSetupReveal(ref:IActionRef, params:Object) : void
      {
         var votesForFirstTag:int;
         var votesForSecondTag:int;
         var nonChosenTag:TagData;
         var chosenTag:TagData = null;
         var audienceVoted:Boolean = this._applySinglePlayerAudienceVote();
         GameState.instance.artifactState.addAbundanceResult(GameState.instance.roundIndex,this._revealData.rolesInvolved,this._voteResults);
         votesForFirstTag = int(this._voteResults[this._revealData.tags[0].protoTag].length);
         votesForSecondTag = int(this._voteResults[this._revealData.tags[1].protoTag].length);
         if(votesForFirstTag > votesForSecondTag)
         {
            chosenTag = this._revealData.tags[0];
            if(RMUtil.voteWasQuiplash(this._revealData.votingPlayers.length,votesForFirstTag,audienceVoted))
            {
               this._revealData.result = GameConstants.TIEBREAKER_RESULTS.QUIPLASH;
            }
            else
            {
               this._revealData.result = GameConstants.TIEBREAKER_RESULTS.MAJORITY;
            }
         }
         else if(votesForSecondTag / this._revealData.votingPlayers.length > 0.5)
         {
            chosenTag = this._revealData.tags[1];
            if(RMUtil.voteWasQuiplash(this._revealData.votingPlayers.length,votesForSecondTag,audienceVoted))
            {
               this._revealData.result = GameConstants.TIEBREAKER_RESULTS.QUIPLASH;
            }
            else
            {
               this._revealData.result = GameConstants.TIEBREAKER_RESULTS.MAJORITY;
            }
         }
         else
         {
            chosenTag = Math.random() >= 0.5 ? this._revealData.tags[0] : this._revealData.tags[1];
            this._revealData.result = GameConstants.TIEBREAKER_RESULTS.TIE;
         }
         if(this._primaryPlayerGuess == chosenTag.protoTag)
         {
            this._primaryPlayerGuessedCorrectly = true;
            this._revealData.primaryPlayer.pendingPoints.val += this._revealData.revealConstants.getProperty("pointsForWinning");
         }
         this._voteResults[chosenTag.protoTag].forEach(function(p:Player, ... args):void
         {
            p.pendingPoints.val += _revealData.revealConstants.getProperty("pointsForVotingCorrectly");
         });
         nonChosenTag = ArrayUtil.first(TagData.differentTags(this._revealData.tags,[chosenTag]));
         chosenTag.punchUp();
         nonChosenTag.punchDown();
         this._winningIndex = this._revealData.tags[0] == chosenTag ? 0 : 1;
         ref.end();
      }
      
      private function _applySinglePlayerAudienceVote() : Boolean
      {
         for(var i:int = 0; i < this._revealData.tags.length; i++)
         {
            if(this._audienceVotesForFirstPrimaryPlayer[this._revealData.tags[i].protoTag] > 0.5)
            {
               this._voteResults[this._revealData.tags[i].protoTag].push(Player.AUDIENCE_PLAYER);
               return true;
            }
         }
         return false;
      }
      
      public function get resultVoteText() : String
      {
         return LocalizationUtil.getPrintfText("TAG_CONTRADICTION_VOTE_PROMPT",this._revealData.primaryPlayer.name.val);
      }
      
      public function get resultVoteKeys() : Array
      {
         return this._revealData.tags.map(function(tag:String, i:int, ... args):Object
         {
            return String(i);
         });
      }
      
      public function get resultVoteChoices() : Array
      {
         return this._revealData.tags.map(function(tag:TagData, ... args):Object
         {
            return {"text":tag.protoTag};
         });
      }
      
      public function applyResultVote(results:Object) : void
      {
         var totalNumberOfVotes:Number = NaN;
         totalNumberOfVotes = ObjectUtil.getTotal(results);
         this._revealData.tags.forEach(function(tag:TagData, i:int, ... args):void
         {
            _audienceVotesForFirstPrimaryPlayer[tag.protoTag] = totalNumberOfVotes > 0 ? Number(results[String(i)] / totalNumberOfVotes) : 0;
         });
      }
   }
}
