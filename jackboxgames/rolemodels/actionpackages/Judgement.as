package jackboxgames.rolemodels.actionpackages
{
   import jackboxgames.localizy.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.userinteraction.*;
   import jackboxgames.userinteraction.commonbehaviors.*;
   import jackboxgames.utils.*;
   
   public class Judgement extends JBGActionPackage
   {
       
      
      private var _promptText:String;
      
      private var _chooseWinnerModule:InteractionHandler;
      
      private var _endDeliberationTimerModule:InteractionHandler;
      
      private var _judge:Player;
      
      private var _leftPlayer:Player;
      
      private var _rightPlayer:Player;
      
      private var _winningPlayer:Player;
      
      private var _revealData:JudgementData;
      
      public function Judgement(sourceURL:String)
      {
         super(sourceURL);
      }
      
      public function get promptText() : String
      {
         return this._promptText;
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
         _ts.g.judgement = this;
         this._chooseWinnerModule = new InteractionHandler(new MakeSingleChoice(true,function setup(players:Array):void
         {
            TSInputHandler.instance.setupForSingleInput();
            Player.SET_PLAYERS_CHOOSING_ACTIVE(_revealData.votingPlayers,true);
         },function getPromptFn(p:Player):Object
         {
            return {"html":LocalizationUtil.getPrintfText("JUDGEMENT_VOTE_PROMPT",_revealData.roleData.name.toUpperCase())};
         },function getChoicesFn(p:Player):Array
         {
            return _revealData.primaryPlayers.map(function(player:Player, ... args):Object
            {
               return {"text":player.name.val};
            });
         },function getChoiceTypeFn(p:Player):String
         {
            return "Judgement";
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
            p.isChoosingActive = false;
            return true;
         },function doneFn(finishedOnPlayerInput:Boolean, chosenChoices:PerPlayerContainer):void
         {
            var choice:* = undefined;
            if(finishedOnPlayerInput)
            {
               choice = chosenChoices.getDataForPlayer(_judge);
               _winningPlayer = _revealData.primaryPlayers[choice];
            }
            TSInputHandler.instance.input("Done");
         }),GameState.instance,true,true);
         this._endDeliberationTimerModule = new InteractionHandler(new MakeSingleChoice(true,function setup(players:Array):void
         {
            TSInputHandler.instance.setupForSingleInput();
         },function getPromptFn(p:Player):Object
         {
            return {"html":LocalizationUtil.getPrintfText("JUDGEMENT_END_TIMER_PROMPT")};
         },function getChoicesFn(p:Player):Array
         {
            return [{"text":LocalizationUtil.getPrintfText("JUDGEMENT_END_TIMER_BUTTON_TEXT")}];
         },function getChoiceTypeFn(p:Player):String
         {
            return "JudgementTimer";
         },function getDoneText(p:Player, choiceIndex:int):String
         {
            return "Time to make a decision!";
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
            TSInputHandler.instance.input("Done");
         }),GameState.instance,true,true);
      }
      
      public function handleActionSetDeliberationTimerActive(ref:IActionRef, params:Object) : void
      {
         this._endDeliberationTimerModule.setIsActive([this._judge],params.isActive);
         ref.end();
      }
      
      public function handleActionSetJudgeSubmissionActive(ref:IActionRef, params:Object) : void
      {
         this._chooseWinnerModule.setIsActive([this._judge],params.isActive);
         ref.end();
      }
      
      public function handleActionRandomlyChooseWinner(ref:IActionRef, params:Object) : void
      {
         if(Math.random() > 0.5)
         {
            this._winningPlayer = this._leftPlayer;
         }
         else
         {
            this._winningPlayer = this._rightPlayer;
         }
         ref.end();
      }
      
      public function handleActionSetupReveal(ref:IActionRef, params:Object) : void
      {
         if(GameState.instance.currentRound.playerVotedForSelf(this._winningPlayer,this._revealData.roleData))
         {
            this._winningPlayer.pendingPoints.val += this._revealData.revealConstants.getProperty("pointsForWinningTieSelf");
         }
         else
         {
            this._winningPlayer.pendingPoints.val += this._revealData.revealConstants.getProperty("pointsForWinningTie");
         }
         this._revealData.roleData.playerAssignedRole = this._winningPlayer;
         GameState.instance.artifactState.addPlayerChoiceResult(GameState.instance.roundIndex,this._winningPlayer);
         ref.end();
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         JBGUtil.reset([this._chooseWinnerModule]);
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         this._revealData = JudgementData(GameState.instance.currentReveal);
         this._judge = this._revealData.votingPlayers[0];
         this._leftPlayer = this._revealData.primaryPlayers[0];
         this._rightPlayer = this._revealData.primaryPlayers[1];
         this._promptText = LocalizationUtil.getPrintfText("JUDGEMENT_INSTRUCTION_PROMPT",this._judge.name.val,this._leftPlayer.name.val,this._rightPlayer.name.val);
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         ref.end();
      }
   }
}
