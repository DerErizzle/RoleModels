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
   
   public class SwapPointsActionPackage extends EffectActionPackage implements IChoosePlayerDelegate
   {
      private var _interaction:EntityInteractionHandler;
      
      private var _effect:SwapPointsEffect;
      
      public function SwapPointsActionPackage(apRef:IActionPackageRef)
      {
         super(apRef);
         this._interaction = new EntityInteractionHandler(new ChoosePlayerBehavior(this),GameState.instance,false,false,false);
      }
      
      override protected function _doSetup() : void
      {
         this._effect = SwapPointsEffect(_spinResult.effect);
         TSInputHandler.instance.setupForSingleInput();
      }
      
      override protected function _doReset() : void
      {
         this._interaction.reset();
      }
      
      public function handleActionSetInteractionActive(ref:IActionRef, params:Object) : void
      {
         this._interaction.setIsActive([BonusSliceData(_param.spunSlice.params.data).owner],params.isActive).then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
      }
      
      public function get choosePlayersPrompt() : String
      {
         return "[name]" + LocalizationManager.instance.getText("SLICE_EFFECT_SWAPPOINTS_NAME") + "[/name]" + LocalizationManager.instance.getText("SLICE_EFFECT_SWAPPOINTS_PROMPT");
      }
      
      public function get playersToChooseFrom() : Array
      {
         return GameState.instance.players.filter(ArrayUtil.GENERATE_FILTER_EXCEPT(BonusSliceData(_param.spunSlice.params.data).owner));
      }
      
      public function get numPlayersToChoose() : int
      {
         return 2;
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
         var chosen:Array = chosenPlayers.getDataForPlayer(BonusSliceData(_param.spunSlice.params.data).owner);
         this._effect.playerA = chosen[0];
         this._effect.playerB = chosen[1];
         if(finishedOnPlayerInput)
         {
            TSInputHandler.instance.input("Done");
         }
      }
   }
}

