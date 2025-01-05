package jackboxgames.rolemodels.actionpackages
{
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.userinteraction.*;
   import jackboxgames.userinteraction.commonbehaviors.*;
   import jackboxgames.utils.*;
   
   public class Trivia extends JBGActionPackage
   {
       
      
      private var _revealData:TriviaData;
      
      private var _triviaAnswer:InteractionHandler;
      
      private var _autoSubmit:Boolean;
      
      private var _correctPlayer:Player;
      
      private var _playersWhoAnswered:Array;
      
      private var _censorAnswersModule:InteractionHandler;
      
      public function Trivia(sourceURL:String)
      {
         super(sourceURL);
      }
      
      public function get promptText() : String
      {
         return this._revealData.prompt;
      }
      
      public function get censorable() : Boolean
      {
         return SettingsManager.instance.getValue(SettingsConstants.SETTING_CENSORABLE).val;
      }
      
      public function get someoneAnsweredCorrectly() : Boolean
      {
         return this._correctPlayer != null;
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
         _ts.g.trivia = this;
         this._triviaAnswer = new InteractionHandler(new EnterSingleText(GameConstants.NUMBER_OF_CHARACTERS_IN_TEXT_ENTRY,true,function setup(players:Array):void
         {
            TSInputHandler.instance.setupForSingleInput();
         },function getPromptFn(p:Player):Object
         {
            return {"html":_revealData.prompt.toUpperCase()};
         },function getPlaceholderFn(p:Player):String
         {
            return LocalizationUtil.getPrintfText("TRIVIA_ANSWER_PLACEHOLDER_TEXT");
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
            return "Trivia";
         },function finalizeBlob(forPlayer:Player, blob:Object):void
         {
            blob.autoSubmit = _autoSubmit;
         },function onPlayerEntered(p:Player, entry:String):Boolean
         {
            if(_answerWasCorrect(entry))
            {
               TSInputHandler.instance.input("Done");
               _correctPlayer = p;
            }
            return true;
         },function doneFn(finishedOnPlayerInput:Boolean, entries:PerPlayerContainer):void
         {
            if(finishedOnPlayerInput)
            {
               TSInputHandler.instance.input("Done");
            }
            GameState.instance.players.forEach(function(p:Player, i:int, arr:Array):void
            {
               GameState.instance.setCustomerBlobWithMetadata(p,{"state":"Logo"});
            });
            _revealData.primaryPlayers.forEach(function(tiedPlayer:Player, ... args):void
            {
               if(entries.hasDataForPlayer(tiedPlayer))
               {
                  tiedPlayer.broadcast("AnswerSubmitted",{"answer":entries.getDataForPlayer(tiedPlayer)});
                  _playersWhoAnswered.push(tiedPlayer);
               }
            });
         }),GameState.instance,true,true);
         this._censorAnswersModule = new InteractionHandler(new MakeSingleChoice(true,function setup(players:Array):void
         {
            TSInputHandler.instance.setupForSingleInput();
         },function getPromptFn(p:Player):Object
         {
            return {"html":LocalizationUtil.getPrintfText("CENSOR_REVEAL_TEXT_PROMPT")};
         },function getChoicesFn(p:Player):Array
         {
            return [{"text":LocalizationUtil.getPrintfText("CENSOR_REVEAL_BUTTON_TEXT")}];
         },function getChoiceTypeFn(p:Player):String
         {
            return "SkipTutorial";
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
         },function playerMadeChoiceFn(p:Player, choice:int):Boolean
         {
            return true;
         },function doneFn(finishedOnPlayerInput:Boolean, chosenChoices:PerPlayerContainer):void
         {
            if(finishedOnPlayerInput)
            {
               TSInputHandler.instance.input("skip");
            }
         }),GameState.instance,false,false);
      }
      
      private function _answerWasCorrect(playerAnswer:String) : Boolean
      {
         var correctAnswer:String = null;
         for each(correctAnswer in this._revealData.answers)
         {
            if(TextUtils.stringsAreClose(correctAnswer,playerAnswer))
            {
               return true;
            }
         }
         return false;
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         JBGUtil.reset([this._triviaAnswer,this._censorAnswersModule]);
         this._correctPlayer = null;
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         this._revealData = TriviaData(GameState.instance.currentReveal);
         this._autoSubmit = false;
         this._playersWhoAnswered = [];
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         ref.end();
      }
      
      public function handleActionSetSubmissionActive(ref:IActionRef, params:Object) : void
      {
         this._triviaAnswer.setIsActive(this._revealData.primaryPlayers,params.isActive);
         ref.end();
      }
      
      public function handleActionSetCensorAnswersActive(ref:IActionRef, params:Object) : void
      {
         this._censorAnswersModule.setIsActive([GameState.instance.players[0]],params.isActive);
         ref.end();
      }
      
      public function handleActionAutoSubmit(ref:IActionRef, params:Object) : void
      {
         this._autoSubmit = true;
         TSInputHandler.instance.setupForSingleInput();
         this._triviaAnswer.forceUpdateAllPlayers();
         ref.end();
      }
      
      public function handleActionAutoFillEmptyAnswers(ref:IActionRef, params:Object) : void
      {
         this._revealData.primaryPlayers.forEach(function(tiedPlayer:Player, ... args):void
         {
            if(!ArrayUtil.arrayContainsElement(_playersWhoAnswered,tiedPlayer))
            {
               tiedPlayer.broadcast("AnswerSubmitted",{"answer":LocalizationUtil.getPrintfText("TRIVIA_FILLER_ANSWER")});
               _playersWhoAnswered.push(tiedPlayer);
            }
         });
         ref.end();
      }
      
      public function handleActionSetupReveal(ref:IActionRef, params:Object) : void
      {
         if(this._correctPlayer != null)
         {
            if(GameState.instance.currentRound.playerVotedForSelf(this._correctPlayer,this._revealData.roleData))
            {
               this._correctPlayer.pendingPoints.val += this._revealData.revealConstants.getProperty("pointsForWinningTieSelf");
            }
            else
            {
               this._correctPlayer.pendingPoints.val += this._revealData.revealConstants.getProperty("pointsForWinningTie");
            }
            this._revealData.roleData.playerAssignedRole = this._correctPlayer;
            GameState.instance.artifactState.addTriviaResult(GameState.instance.roundIndex,this._correctPlayer);
         }
         ref.end();
      }
      
      public function handleActionShowTriviaAnswers(ref:IActionRef, params:Object) : void
      {
         var c:Counter = null;
         c = new Counter(this._playersWhoAnswered.length,TSUtil.createRefEndFn(ref));
         this._playersWhoAnswered.forEach(function(playerWithAnswer:Player, ... args):void
         {
            playerWithAnswer.broadcast("ShowAnswer",{"doneFn":c.generateDoneFn()});
         });
      }
   }
}
