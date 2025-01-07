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
   import jackboxgames.thewheel.wheel.subwidgets.PointsForPlayerSliceSubWidget;
   import jackboxgames.utils.*;
   
   public class RainbowActionPackage extends EffectActionPackage
   {
      private var _effect:RainbowSliceEffect;
      
      public function RainbowActionPackage(apRef:IActionPackageRef)
      {
         super(apRef);
      }
      
      override protected function _doSetup() : void
      {
         this._effect = RainbowSliceEffect(_spinResult.effect);
      }
      
      override protected function _doReset() : void
      {
         this._effect = null;
      }
      
      public function handleActionSetRainbowModeActive(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isActive))
         {
            GameState.instance.client.createObject("rainbowActive",{"isActive":true},null,["r id:" + this._effect.spinningPlayer.sessionId.val]);
         }
         else
         {
            GameState.instance.client.drop("rainbowActive");
         }
         ref.end();
      }
      
      public function handleActionSetOverlayShown(ref:IActionRef, params:Object) : void
      {
         var spunSlice:Slice = null;
         spunSlice = this._effect.rainbowWheel.getSliceAtFlapper();
         var widgets:Array = this._effect.rainbowWheel.getAllSlices().map(function(s:Slice, ... args):PointsForPlayerSliceSubWidget
         {
            return PointsForPlayerSliceSubWidget(s.subWidget);
         });
         widgets.forEach(function(w:PointsForPlayerSliceSubWidget, ... args):void
         {
            if(Boolean(params.isShown))
            {
               w.setupOverlay(PointsForPlayerSliceData(spunSlice.params.data).player);
            }
            w.setOverlayShown(params.isShown);
         });
         ref.end();
      }
   }
}

