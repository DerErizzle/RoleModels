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
   
   public class CatchMeChallengeActionPackage extends EffectActionPackage implements IChooseSliceDelegate, IWheelDataDelegate
   {
      private var _interaction:EntityInteractionHandler;
      
      private var _data:BonusSliceData;
      
      private var _effect:CatchMeChallengeEffect;
      
      private var _sliceWithOwner:Slice;
      
      private var _chosenSlicesByNonOwner:Array;
      
      public function CatchMeChallengeActionPackage(apRef:IActionPackageRef)
      {
         super(apRef);
         this._interaction = new EntityInteractionHandler(new ChooseSliceBehavior(this,new WheelControllerProvider(this,GameConstants.WHEEL_CONTROLLER_MODE_DEFAULT)),GameState.instance,false,false,false);
      }
      
      override protected function _doSetup() : void
      {
         this._data = BonusSliceData(_param.spunSlice.params.data);
         this._effect = CatchMeChallengeEffect(_spinResult.effect);
         TSInputHandler.instance.setupForSingleInput();
      }
      
      override protected function _doReset() : void
      {
         this._interaction.reset();
      }
      
      public function handleActionSetInteractionActive(ref:IActionRef, params:Object) : void
      {
         this._interaction.setIsActive(GameState.instance.players,params.isActive).then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetChoicesRevealed(ref:IActionRef, params:Object) : void
      {
         this._effect.wheel.getAllSlices().forEach(function(s:Slice, ... args):void
         {
            if(Boolean(params.isRevealed))
            {
               if(ArrayUtil.arrayContainsElement(_chosenSlicesByNonOwner,s))
               {
                  s.catchMe.revealPlayerChecked();
               }
            }
            else
            {
               s.catchMe.dismiss();
            }
         });
         ref.end();
      }
      
      public function handleActionRevealOwner(ref:IActionRef, params:Object) : void
      {
         this._effect.wheel.getAllSlices().forEach(function(s:Slice, ... args):void
         {
            if(s == _sliceWithOwner)
            {
               s.catchMe.revealHidingPlayer(_data.owner,_effect.ownerWasFound);
            }
            else if(ArrayUtil.arrayContainsElement(_chosenSlicesByNonOwner,s))
            {
               s.catchMe.revealNoPlayer();
            }
         });
         ref.end();
      }
      
      public function getWheel() : Wheel
      {
         return this._effect.wheel;
      }
      
      public function getChooseSlicePrompt(p:Player) : String
      {
         return "[name]" + LocalizationManager.instance.getText("SLICE_EFFECT_CATCHMECHALLENGE_NAME") + "[/name]" + LocalizationUtil.getPrintfText(p == this._data.owner ? "SLICE_EFFECT_CATCHMECHALLENGE_PROMPT_SLICE_OWNER" : "SLICE_EFFECT_CATCHMECHALLENGE_PROMPT_NON_SLICE_OWNER",TheWheelTextUtil.formattedPlayerName(this._data.owner));
      }
      
      public function get showSelectedSlices() : Boolean
      {
         return false;
      }
      
      public function canChooseSlice(p:Player, pos:int) : Boolean
      {
         return true;
      }
      
      public function onChooseSliceSubmitted(p:Player, chosenPosition:int) : void
      {
         p.widget.setAnswering(false);
      }
      
      public function onChooseSliceDone(chosenSlices:PerPlayerContainer, finishedOnPlayerInput:Boolean) : void
      {
         var ownerChoice:int = 0;
         var playersThatFoundTheOwner:Array = null;
         var owner:Player = this._data.owner;
         if(chosenSlices.hasDataForPlayer(owner))
         {
            ownerChoice = chosenSlices.getDataForPlayer(owner);
            this._sliceWithOwner = this._effect.wheel.getSliceAt(ownerChoice,false);
            this._chosenSlicesByNonOwner = [];
            this._effect.playersTryingToCatch.forEach(function(p:Player, ... args):void
            {
               var s:Slice = null;
               if(chosenSlices.hasDataForPlayer(p))
               {
                  s = _effect.wheel.getSliceAt(chosenSlices.getDataForPlayer(p),false);
                  if(!s)
                  {
                     return;
                  }
                  ArrayUtil.deduplicatedPush(_chosenSlicesByNonOwner,s);
               }
            });
            playersThatFoundTheOwner = this._effect.playersTryingToCatch.filter(function(p:Player, ... args):Boolean
            {
               return chosenSlices.hasDataForPlayer(p) ? chosenSlices.getDataForPlayer(p) == ownerChoice : false;
            });
            if(playersThatFoundTheOwner.length > 0)
            {
               this._effect.setResultToOwnerFound();
            }
            else
            {
               this._effect.setResultToOwnerNotFound();
            }
         }
         else
         {
            this._effect.setResultToOwnerDidNotHide();
         }
         if(finishedOnPlayerInput)
         {
            TSInputHandler.instance.input("Done");
         }
      }
   }
}

