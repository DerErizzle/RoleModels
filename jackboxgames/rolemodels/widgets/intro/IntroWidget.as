package jackboxgames.rolemodels.widgets.intro
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.utils.*;
   
   public class IntroWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _titleMC:MovieClip;
      
      public function IntroWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._titleMC = this._mc.titleAnimation;
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._mc,"Park");
         JBGUtil.gotoFrame(this._titleMC,"Park");
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         if(isShown)
         {
            JBGUtil.gotoFrame(this._titleMC,"Appear");
            JBGUtil.gotoFrameWithFn(this._mc,"AppearLogo",MovieClipEvent.EVENT_APPEAR_DONE,doneFn);
         }
         else
         {
            JBGUtil.gotoFrameWithFn(this._mc,"Disappear",MovieClipEvent.EVENT_DISAPPEAR_DONE,doneFn);
         }
      }
      
      public function showAssistant(doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc,"ShowAssistant",MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
      }
   }
}
