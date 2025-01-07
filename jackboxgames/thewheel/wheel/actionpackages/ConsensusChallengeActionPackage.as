package jackboxgames.thewheel.wheel.actionpackages
{
   import jackboxgames.entityinteraction.*;
   import jackboxgames.localizy.*;
   import jackboxgames.model.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.entitybehaviors.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.effects.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.utils.*;
   
   public class ConsensusChallengeActionPackage extends EffectActionPackage implements IChoosePlayerDelegate
   {
      private var _interaction:EntityInteractionHandler;
      
      private var _data:BonusSliceData;
      
      private var _effect:ConsensusChallengeEffect;
      
      private var _choosingPlayers:Array;
      
      private var _choices:PerPlayerContainer;
      
      public function ConsensusChallengeActionPackage(apRef:IActionPackageRef)
      {
         super(apRef);
         this._interaction = new EntityInteractionHandler(new ChoosePlayerBehavior(this),GameState.instance,false,false,false);
      }
      
      override protected function _doSetup() : void
      {
         this._data = BonusSliceData(_param.spunSlice.params.data);
         this._effect = ConsensusChallengeEffect(_spinResult.effect);
         this._choosingPlayers = GameState.instance.players.filter(ArrayUtil.GENERATE_FILTER_EXCEPT(this._data.owner));
         TSInputHandler.instance.setupForSingleInput();
      }
      
      override protected function _doReset() : void
      {
         this._interaction.reset();
      }
      
      public function handleActionSetInteractionActive(ref:IActionRef, params:Object) : void
      {
         this._interaction.setIsActive(this._choosingPlayers,params.isActive).then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionPrepareEffect(ref:IActionRef, params:Object) : void
      {
         this._effect.prepareForEvaluation(this._chosenPlayer);
         ref.end();
      }
      
      private function get _chosenPlayer() : Player
      {
         for(var i:int = 0; i < this._choosingPlayers.length; i++)
         {
            if(i == 0)
            {
               if(this._choices.getDataForPlayer(this._choosingPlayers[i]).length == 0)
               {
                  return null;
               }
            }
            else
            {
               if(this._choices.getDataForPlayer(this._choosingPlayers[i]).length == 0)
               {
                  return null;
               }
               if(ArrayUtil.first(this._choices.getDataForPlayer(this._choosingPlayers[i])) != ArrayUtil.first(this._choices.getDataForPlayer(this._choosingPlayers[i - 1])))
               {
                  return null;
               }
            }
         }
         return ArrayUtil.first(this._choices.getDataForPlayer(this._choosingPlayers[0]));
      }
      
      public function get choosePlayersPrompt() : String
      {
         return "[name]" + LocalizationManager.instance.getText("SLICE_EFFECT_CONSENSUSCHALLENGE_NAME") + "[/name]" + LocalizationUtil.getPrintfText("SLICE_EFFECT_CONSENSUSCHALLENGE_PROMPT",TheWheelTextUtil.formattedPlayerName(this._data.owner));
      }
      
      public function get playersToChooseFrom() : Array
      {
         return this._choosingPlayers;
      }
      
      public function get numPlayersToChoose() : int
      {
         return 1;
      }
      
      public function get showSelectedPlayerWidgets() : Boolean
      {
         return true;
      }
      
      public function onChoosePlayerSubmitted(p:Player, choicesMade:Array) : void
      {
      }
      
      public function onChoosePlayerDone(chosenPlayers:PerPlayerContainer, finishedOnPlayerInput:Boolean) : void
      {
         this._choices = chosenPlayers;
         if(finishedOnPlayerInput)
         {
            TSInputHandler.instance.input("Done");
         }
      }
      
      public function getChooseChoices(p:JBGPlayer) : Array
      {
         return this._choosingPlayers.map(function(p:Player, ... args):String
         {
            return TheWheelTextUtil.formattedPlayerName(p);
         });
      }
   }
}

