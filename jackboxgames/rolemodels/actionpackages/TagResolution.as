package jackboxgames.rolemodels.actionpackages
{
   import flash.display.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.rolemodels.gameplay.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.userinteraction.*;
   import jackboxgames.userinteraction.commonbehaviors.*;
   import jackboxgames.utils.*;
   
   public class TagResolution extends JBGActionPackage implements IResultVoteHandler
   {
       
      
      private var _promptText:String;
      
      private var _playerPromptsText:Array;
      
      private var _promptModule:InteractionHandler;
      
      private var _autoSubmit:Boolean;
      
      private var _voteModule:InteractionHandler;
      
      private var _playerVotes:PerPlayerContainer;
      
      private var _voteResults:PerPlayerContainer;
      
      private var _revealData:TagResolutionData;
      
      private var _audienceVotes:PerPlayerContainer;
      
      private var _votingAudienceInputter:AudienceAwareInputter;
      
      private var _playerChoices:PerPlayerContainer;
      
      private var _winningIndex:int;
      
      private var _censorIndex:int;
      
      private var _isCensored:Boolean;
      
      public function TagResolution(sourceURL:String)
      {
         super(sourceURL);
      }
      
      public function get promptText() : String
      {
         return this._promptText;
      }
      
      public function get voteText() : String
      {
         return LocalizationUtil.getPrintfText("TAG_RESOLUTION_VOTE_PROMPT");
      }
      
      public function get resultType() : String
      {
         return this._revealData.result;
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
         _ts.g.tagResolution = this;
         this._promptModule = new InteractionHandler(new EnterSingleText(GameConstants.NUMBER_OF_CHARACTERS_IN_TEXT_ENTRY,true,function setup(players:Array):void
         {
            TSInputHandler.instance.setupForSingleInput();
         },function getPromptFn(p:Player):Object
         {
            return {"html":_promptText.toUpperCase()};
         },function getPlaceholderFn(p:Player):String
         {
            return LocalizationUtil.getPrintfText("TAG_RESOLUTION_SINGLE_TEXT_PLACEHOLDER_TEXT");
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
            _revealData.primaryPlayers.forEach(function(tiedPlayer:Player, ... args):void
            {
               var data:* = {"answer":(entries.hasDataForPlayer(tiedPlayer) ? entries.getDataForPlayer(tiedPlayer) : LocalizationUtil.getPrintfText("TAG_RESOLUTION_FILLER_ANSWER"))};
               tiedPlayer.broadcast("AnswerSubmitted",data);
            });
         }),GameState.instance,true,true);
         this._voteModule = new InteractionHandler(new MakeSingleChoice(true,function setup(players:Array):void
         {
            _censorIndex = -1;
            _isCensored = false;
            TSInputHandler.instance.setupForSingleInput();
            Player.SET_PLAYERS_CHOOSING_ACTIVE(_revealData.votingPlayers,true);
         },function getPromptFn(p:Player):Object
         {
            return {"html":LocalizationUtil.getPrintfText("TAG_RESOLUTION_VOTE_PROMPT",_revealData.printfTag)};
         },function getChoicesFn(p:Player):Array
         {
            var skip:* = undefined;
            var choices:* = _revealData.primaryPlayers.map(function(tiedPlayer:Player, ... args):Object
            {
               return {"text":tiedPlayer.name.val};
            });
            if(p.isVIP && SettingsManager.instance.getValue(SettingsConstants.SETTING_CENSORABLE).val)
            {
               _censorIndex = 0;
               skip = {"text":LocalizationUtil.getPrintfText("CENSOR_REVEAL_BUTTON_TEXT")};
               if(ArrayUtil.arrayContainsElement(_revealData.votingPlayers,p))
               {
                  _censorIndex = choices.push(skip) - 1;
                  return choices;
               }
               return [skip];
            }
            return choices;
         },function _getChoiceTypeFn(p:Player):String
         {
            return "TagResolution";
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
            _playerChoices.setDataForPlayer(p,choice);
            if(_playerChoices.hasDataForAllOfThesePlayers(_revealData.votingPlayers))
            {
               _votingAudienceInputter.isActive = true;
            }
            return true;
         },function doneFn(finishedOnUserInput:Boolean, choices:PerPlayerContainer):void
         {
            if(finishedOnUserInput)
            {
               _votingAudienceInputter.isActive = true;
            }
            choices.forEach(function(choice:int, userId:String, ... args):void
            {
               var p:* = undefined;
               if(!(GameState.instance.getPlayerByUserId(userId).isVIP && SettingsManager.instance.getValue(SettingsConstants.SETTING_CENSORABLE).val && choice == _censorIndex))
               {
                  p = _revealData.primaryPlayers[choice];
                  _voteResults.getDataForPlayer(p).push(GameState.instance.getPlayerByUserId(userId));
               }
            });
         }),GameState.instance,true,true);
         this._votingAudienceInputter = new AudienceAwareInputter(GameState.instance.gameAudience.audienceModule,GameState.instance.gameAudience.votingModule,"Done",Duration.fromSec(3));
         GameState.instance.gameAudience.setResultVoteHandler(GameConstants.REVEAL_CONSTANTS.tagResolution.name,this);
         this._audienceVotes = new PerPlayerContainer();
         this._playerChoices = new PerPlayerContainer();
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         JBGUtil.reset([this._promptModule,this._voteModule,this._voteResults,this._votingAudienceInputter,this._audienceVotes,this._playerChoices]);
         this._playerPromptsText = [];
         ref.end();
      }
      
      public function handleActionSetupReveal(ref:IActionRef, params:Object) : void
      {
         var sortedPlayers:Array;
         var maxVotes:int = 0;
         var winningPlayer:Player = null;
         var tiedPlayers:Array = null;
         var audienceVoted:Boolean = RMUtil.applyAudienceMajorityVote(this._audienceVotes,this._voteResults);
         this._revealData.primaryPlayers.forEach(function(p:Player, ... args):void
         {
            p.broadcast("VotesReceived",{"votingPlayers":_voteResults.getDataForPlayer(p)});
         });
         GameState.instance.artifactState.addVoteResult(GameState.instance.roundIndex,this._revealData.primaryPlayers,this._voteResults);
         sortedPlayers = RMUtil.sortByRevealVotes(this._revealData.primaryPlayers,this._voteResults);
         maxVotes = int(this._voteResults.getDataForPlayer(sortedPlayers[0]).length);
         if(this._voteResults.getDataForPlayer(sortedPlayers[1]).length != maxVotes)
         {
            winningPlayer = sortedPlayers[0];
            if(RMUtil.voteWasQuiplash(this._revealData.votingPlayers.length,maxVotes,audienceVoted))
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
            tiedPlayers = sortedPlayers.filter(function(p:Player, ... args):Boolean
            {
               return _voteResults.getDataForPlayer(p).length == maxVotes;
            });
            winningPlayer = ArrayUtil.getRandomElement(tiedPlayers);
            this._revealData.result = GameConstants.TIEBREAKER_RESULTS.TIE;
         }
         winningPlayer.pendingPoints.val += this._revealData.revealConstants.getProperty("pointsForWinning");
         if(this._revealData.primaryPlayers[0] == winningPlayer)
         {
            this._winningIndex = 0;
            this._revealData.tags[0].punchUp();
            this._revealData.tags[1].punchDown();
         }
         else
         {
            this._winningIndex = 1;
            this._revealData.tags[0].punchDown();
            this._revealData.tags[1].punchUp();
         }
         ref.end();
      }
      
      public function handleActionSetupPrompt(ref:IActionRef, params:Object) : void
      {
         this._promptText = this._revealData.prompt;
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         this._revealData = TagResolutionData(GameState.instance.currentReveal);
         this._voteResults = new PerPlayerContainer();
         this._revealData.primaryPlayers.forEach(function(p:Player, ... args):void
         {
            _voteResults.setDataForPlayer(p,[]);
         });
         this._autoSubmit = false;
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
         var players:Array = this._revealData.votingPlayers;
         if(!ArrayUtil.arrayContainsElement(players,GameState.instance.players[0]) && SettingsManager.instance.getValue(SettingsConstants.SETTING_CENSORABLE).val)
         {
            players = players.concat(GameState.instance.players[0]);
         }
         this._voteModule.setIsActive(players,params.isActive);
         ref.end();
      }
      
      public function get resultVoteText() : String
      {
         return LocalizationUtil.getPrintfText("TAG_RESOLUTION_VOTE_PROMPT",this._revealData.printfTag);
      }
      
      public function get resultVoteKeys() : Array
      {
         return this._revealData.primaryPlayers.map(function(player:Player, i:int, ... args):String
         {
            return String(i);
         });
      }
      
      public function get resultVoteChoices() : Array
      {
         return this._revealData.primaryPlayers.map(function(tiedPlayer:Player, ... args):Object
         {
            return {"text":tiedPlayer.name.val};
         });
      }
      
      public function applyResultVote(results:Object) : void
      {
         var totalNumberOfVotes:Number = NaN;
         totalNumberOfVotes = ObjectUtil.getTotal(results);
         this._revealData.primaryPlayers.forEach(function(player:Player, i:int, ... args):void
         {
            _audienceVotes.setDataForPlayer(player,totalNumberOfVotes > 0 ? Number(results[String(i)] / totalNumberOfVotes) : 0);
         });
      }
   }
}
