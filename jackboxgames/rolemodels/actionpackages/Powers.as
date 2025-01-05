package jackboxgames.rolemodels.actionpackages
{
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.userinteraction.*;
   import jackboxgames.userinteraction.commonbehaviors.*;
   import jackboxgames.utils.*;
   
   public class Powers extends JBGActionPackage
   {
      
      public static const STEAL:String = "steal points";
      
      public static const DONATE:String = "donate points";
      
      public static const GIVE:String = "give points";
       
      
      private var _resultText:String;
      
      private var _revealData:PowersData;
      
      private var _powerModule:InteractionHandler;
      
      private var _chosenPlayer:Player;
      
      private var _finishedOnUserInput:Boolean;
      
      public function Powers(sourceURL:String)
      {
         super(sourceURL);
      }
      
      public function get promptText() : String
      {
         if(this._revealData.power == STEAL)
         {
            return LocalizationUtil.getPrintfText("POWERS_STEAL_INSTRUCTION",this._revealData.powerfulPlayer.name.val);
         }
         if(this._revealData.power == DONATE)
         {
            return LocalizationUtil.getPrintfText("POWERS_DONATE_INSTRUCTION",this._revealData.powerfulPlayer.name.val);
         }
         return LocalizationUtil.getPrintfText("POWERS_GIVE_INSTRUCTION",this._revealData.powerfulPlayer.name.val);
      }
      
      public function get resultText() : String
      {
         return this._resultText;
      }
      
      public function get powerfulPlayer() : String
      {
         return this._revealData.powerfulPlayer.userId.val;
      }
      
      public function get roleName() : String
      {
         return this._revealData.roleData.name.toUpperCase();
      }
      
      public function get pointsWereStolen() : Boolean
      {
         return this._revealData.power == STEAL && this._finishedOnUserInput;
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
         _ts.g.powers = this;
         this._powerModule = new InteractionHandler(new MakeSingleChoice(true,function setup(players:Array):void
         {
            TSInputHandler.instance.setupForSingleInput();
         },function getPromptFn(p:Player):Object
         {
            if(_revealData.power == STEAL)
            {
               return {"html":LocalizationUtil.getPrintfText("POWERS_STEAL_CHOICE_PROMPT")};
            }
            if(_revealData.power == DONATE)
            {
               return {"html":LocalizationUtil.getPrintfText("POWERS_DONATE_CHOICE_PROMPT")};
            }
            return {"html":LocalizationUtil.getPrintfText("POWERS_GIVE_CHOICE_PROMPT")};
         },function getChoicesFn(p:Player):Array
         {
            return _revealData.secondaryPlayers.map(function(p:Player, ... args):Object
            {
               return {"text":p.name.val};
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
            var choice:* = undefined;
            _finishedOnUserInput = finishedOnUserInput;
            if(finishedOnUserInput)
            {
               TSInputHandler.instance.input("Done");
               choice = choices.getDataForPlayer(_revealData.powerfulPlayer);
               _chosenPlayer = _revealData.secondaryPlayers[choice];
            }
            else
            {
               _chosenPlayer = ArrayUtil.getRandomElement(_revealData.secondaryPlayers);
            }
            GameState.instance.setCustomerBlobWithMetadata(_revealData.powerfulPlayer,{"state":"Logo"});
         }),GameState.instance,true,true);
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         JBGUtil.reset([this._powerModule]);
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         this._revealData = PowersData(GameState.instance.currentReveal);
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         ref.end();
      }
      
      public function handleActionSetSubmissionActive(ref:IActionRef, params:Object) : void
      {
         this._powerModule.setIsActive([this._revealData.powerfulPlayer],params.isActive);
         ref.end();
      }
      
      public function handleActionSetupReveal(ref:IActionRef, params:Object) : void
      {
         this._revealData.powerfulTag.usePower();
         if(this._finishedOnUserInput)
         {
            GameState.instance.artifactState.addPlayerChoiceResult(GameState.instance.roundIndex,this._chosenPlayer);
            switch(this._revealData.power)
            {
               case STEAL:
                  this._resultText = LocalizationUtil.getPrintfText("POWERS_STEAL_RESULT",this._revealData.powerfulPlayer.name.val,this._revealData.revealConstants.getProperty("points"),this._chosenPlayer.name.val);
                  this._chosenPlayer.score.val -= this._revealData.revealConstants.getProperty("points");
                  this._revealData.powerfulPlayer.pendingPoints.val += this._revealData.revealConstants.getProperty("points");
                  break;
               case DONATE:
                  this._resultText = LocalizationUtil.getPrintfText("POWERS_DONATE_RESULT",this._revealData.powerfulPlayer.name.val,this._revealData.revealConstants.getProperty("points"),this._chosenPlayer.name.val);
                  this._chosenPlayer.score.val += this._revealData.revealConstants.getProperty("points");
                  this._revealData.powerfulPlayer.score.val -= this._revealData.revealConstants.getProperty("points");
                  break;
               case GIVE:
                  this._resultText = LocalizationUtil.getPrintfText("POWERS_GIVE_RESULT",this._revealData.powerfulPlayer.name.val,this._chosenPlayer.name.val);
                  this._chosenPlayer.score.val += this._revealData.revealConstants.getProperty("points");
            }
         }
         else
         {
            switch(this._revealData.power)
            {
               case STEAL:
                  this._resultText = LocalizationUtil.getPrintfText("POWERS_STEAL_FAILURE",this._revealData.powerfulPlayer.name.val);
                  break;
               case DONATE:
                  this._resultText = LocalizationUtil.getPrintfText("POWERS_DONATE_FAILURE",this._revealData.powerfulPlayer.name.val,this._revealData.powerfulPlayer.name.val);
                  this._revealData.secondaryPlayers.forEach(function(p:Player, ... args):void
                  {
                     p.score.val += Math.ceil(_revealData.revealConstants.getProperty("points") / _revealData.secondaryPlayers.length);
                  });
                  break;
               case GIVE:
                  this._resultText = LocalizationUtil.getPrintfText("POWERS_GIVE_FAILURE",this._revealData.powerfulPlayer.name.val,this._revealData.revealConstants.getProperty("points"));
                  this._revealData.powerfulPlayer.score.val -= this._revealData.revealConstants.getProperty("points");
            }
         }
         ref.end();
      }
   }
}
