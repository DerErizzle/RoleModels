package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.utils.*;
   
   public class BeakerWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _beakerIndex:int;
      
      public function BeakerWidget(mc:MovieClip, beakerIndex:int, beakerFrameIndex:int)
      {
         super();
         this._beakerIndex = beakerIndex;
         var beakerFrames:Array = MovieClipUtil.getFramesThatStartWith(mc,"Beaker");
         JBGUtil.gotoFrame(mc,beakerFrames[beakerFrameIndex]);
         this._mc = mc["beaker" + String(beakerFrameIndex)];
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._mc.eyedropper,"Park");
         JBGUtil.gotoFrame(this._mc.liquid,"Park");
      }
      
      public function drawLiquid(doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc.eyedropper,"Choose" + String(this._beakerIndex),MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
      }
      
      public function setup() : void
      {
         JBGUtil.gotoFrame(this._mc.eyedropper,"Idle");
         JBGUtil.gotoFrame(this._mc.liquid,"Category" + String(this._beakerIndex));
      }
   }
}
