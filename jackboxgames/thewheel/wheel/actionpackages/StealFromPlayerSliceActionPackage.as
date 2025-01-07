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
   
   public class StealFromPlayerSliceActionPackage extends EffectActionPackage implements IWheelDataDelegate, IChooseSliceDelegate
   {
      private var _interaction:EntityInteractionHandler;
      
      private var _effect:StealFromPlayerSliceEffect;
      
      public function StealFromPlayerSliceActionPackage(apRef:IActionPackageRef)
      {
         super(apRef);
         this._interaction = new EntityInteractionHandler(new ChooseSliceBehavior(this,new WheelControllerProvider(this,GameConstants.WHEEL_CONTROLLER_MODE_DEFAULT)),GameState.instance,false,false,false);
      }
      
      override protected function _doSetup() : void
      {
         this._effect = StealFromPlayerSliceEffect(_spinResult.effect);
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
         this._interaction.setIsActive([this._effect.stealingPlayer],params.isActive).then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
      }
      
      public function getWheel() : Wheel
      {
         return this._effect.wheel;
      }
      
      public function getChooseSlicePrompt(p:Player) : String
      {
         return "[name]" + LocalizationManager.instance.getText("SLICE_EFFECT_STEALFROMPLAYERSLICE_NAME") + "[/name]" + LocalizationManager.instance.getText("SLICE_EFFECT_STEALFROMPLAYERSLICE_PROMPT");
      }
      
      public function get showSelectedSlices() : Boolean
      {
         return true;
      }
      
      public function canChooseSlice(p:Player, pos:int) : Boolean
      {
         var slice:Slice = this._effect.wheel.getSliceAt(pos,false);
         return slice.params.type == GameConstants.SLICE_TYPE_PLAYER;
      }
      
      public function onChooseSliceSubmitted(p:Player, chosenPosition:int) : void
      {
      }
      
      public function onChooseSliceDone(chosenSlices:PerPlayerContainer, finishedOnPlayerInput:Boolean) : void
      {
         if(chosenSlices.hasDataForPlayer(this._effect.stealingPlayer))
         {
            this._effect.sliceToStealFrom = this._effect.wheel.getSliceAt(chosenSlices.getDataForPlayer(this._effect.stealingPlayer),false);
         }
         if(finishedOnPlayerInput)
         {
            TSInputHandler.instance.input("Done");
         }
      }
   }
}

