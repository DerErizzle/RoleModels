package jackboxgames.rolemodels.actionpackages
{
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.rolemodels.gameplay.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.userinteraction.*;
   import jackboxgames.userinteraction.commonbehaviors.*;
   import jackboxgames.utils.*;
   
   public class FightTiebreaker extends JBGActionPackage implements IResultVoteHandler
   {
       
      
      private var _promptText:String;
      
      private var _revealData:FightTiebreakerData;
      
      private var _fightVoteInteraction:InteractionHandler;
      
      private var _voteResults:PerPlayerContainer;
      
      private var _audienceVotes:PerPlayerContainer;
      
      private var _votingAudienceInputter:AudienceAwareInputter;
      
      public function FightTiebreaker(sourceURL:String)
      {
         super(sourceURL);
      }
      
      public function get promptText() : String
      {
         return this._promptText;
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
         _ts.g.fightTiebreaker = this;
         this._fightVoteInteraction = new InteractionHandler(new MakeSingleChoice(true,function setup(players:Array):void
         {
            TSInputHandler.instance.setupForSingleInput();
            Player.SET_PLAYERS_CHOOSING_ACTIVE(_revealData.votingPlayers,true);
         },function getPromptFn(p:Player):Object
         {
            return {"html":_revealData.prompt.toUpperCase()};
         },function getChoicesFn(p:Player):Array
         {
            return _revealData.primaryPlayers.map(function(tiedPlayer:Player, ... args):Object
            {
               return {"text":tiedPlayer.name.val};
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
               var p:* = _revealData.primaryPlayers[choice];
               _voteResults.getDataForPlayer(p).push(GameState.instance.getPlayerByUserId(userId));
            });
         }),GameState.instance,true,true);
         this._votingAudienceInputter = new AudienceAwareInputter(GameState.instance.gameAudience.audienceModule,GameState.instance.gameAudience.votingModule,"Done",Duration.fromSec(3));
         GameState.instance.gameAudience.setResultVoteHandler(GameConstants.REVEAL_CONSTANTS.fightTiebreaker.name,this);
         this._audienceVotes = new PerPlayerContainer();
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         JBGUtil.reset([this._fightVoteInteraction,this._voteResults,this._votingAudienceInputter,this._audienceVotes]);
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         this._revealData = FightTiebreakerData(GameState.instance.currentReveal);
         this._promptText = this._revealData.prompt;
         this._voteResults = new PerPlayerContainer();
         this._revealData.primaryPlayers.forEach(function(p:Player, ... args):void
         {
            _voteResults.setDataForPlayer(p,[]);
         });
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         ref.end();
      }
      
      public function handleActionSetSubmissionActive(ref:IActionRef, params:Object) : void
      {
         this._fightVoteInteraction.setIsActive(this._revealData.votingPlayers,params.isActive);
         ref.end();
      }
      
      public function handleActionSetupReveal(ref:IActionRef, params:Object) : void
      {
         this._revealData.result = RMUtil.calculateTiebreakerResult(this._revealData,this._revealData.votingPlayers,this._voteResults,this._audienceVotes);
         ref.end();
      }
      
      public function get resultVoteText() : String
      {
         return this._revealData.prompt;
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
