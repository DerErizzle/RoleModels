package jackboxgames.thewheel.wheel.actionpackages
{
   import jackboxgames.entityinteraction.*;
   import jackboxgames.entityinteraction.commonbehaviors.*;
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
   
   public class ReplaceSliceActionPackage extends EffectActionPackage implements IChooseSliceDelegate, IWheelDataDelegate
   {
      private var _interaction:EntityInteractionHandler;
      
      private var _effect:ReplaceSliceEffect;
      
      public function ReplaceSliceActionPackage(apRef:IActionPackageRef)
      {
         super(apRef);
         this._interaction = new EntityInteractionHandler(new ChooseSliceBehavior(this,new WheelControllerProvider(this,GameConstants.WHEEL_CONTROLLER_MODE_DEFAULT)),GameState.instance,false,false,false);
      }
      
      override protected function _doSetup() : void
      {
         this._effect = ReplaceSliceEffect(_spinResult.effect);
      }
      
      override protected function _doReset() : void
      {
         JBGUtil.reset([this._interaction]);
         this._effect = null;
      }
      
      public function handleActionSetInteractionActive(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isActive))
         {
            TSInputHandler.instance.setupForSingleInput();
         }
         this._interaction.setIsActive([this._effect.player],params.isActive).then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
      }
      
      public function getWheel() : Wheel
      {
         return this._effect.wheel;
      }
      
      public function getChooseSlicePrompt(p:Player) : String
      {
         return "[name]" + LocalizationManager.instance.getText("SLICE_EFFECT_REPLACESLICE_NAME") + "[/name]" + LocalizationManager.instance.getText("SLICE_EFFECT_REPLACESLICE_PROMPT");
      }
      
      public function get showSelectedSlices() : Boolean
      {
         return true;
      }
      
      public function canChooseSlice(p:Player, pos:int) : Boolean
      {
         return true;
      }
      
      public function onChooseSliceSubmitted(p:Player, chosenPosition:int) : void
      {
      }
      
      public function onChooseSliceDone(chosenSlices:PerPlayerContainer, finishedOnPlayerInput:Boolean) : void
      {
         if(chosenSlices.hasDataForPlayer(BonusSliceData(_param.spunSlice.params.data).owner))
         {
            this._effect.sliceToReplace = this._effect.wheel.getSliceAt(chosenSlices.getDataForPlayer(BonusSliceData(_param.spunSlice.params.data).owner),false);
         }
         if(finishedOnPlayerInput)
         {
            TSInputHandler.instance.input("Done");
         }
      }
   }
}

