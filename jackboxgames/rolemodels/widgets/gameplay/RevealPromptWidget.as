package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class RevealPromptWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _tf:ExtendableTextField;
      
      private var _isShown:Boolean;
      
      public function RevealPromptWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._tf = new ExtendableTextField(this._mc.tf,[],[PostEffectFactory.createDynamicResizerEffect(3),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         this._isShown = false;
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._mc,"Park");
         JBGUtil.gotoFrame(this._mc.tf.bg,"Park");
         this._isShown = false;
      }
      
      public function setShown(isShown:Boolean, text:String, small:Boolean, doneFn:Function) : void
      {
         if(isShown == this._isShown)
         {
            doneFn();
            return;
         }
         this._isShown = isShown;
         if(isShown)
         {
            this._tf.text = text.toUpperCase();
            JBGUtil.gotoFrame(this._mc.tf.bg,"Loop");
            GameState.instance.audioRegistrationStack.play("TiebreakerPromptAppear",Nullable.NULL_FUNCTION);
            JBGUtil.gotoFrameWithFn(this._mc,small ? "SmallAppear" : "Appear",MovieClipEvent.EVENT_APPEAR_DONE,doneFn);
         }
         else if(this._mc.currentLabel == "Shrink" || this._mc.currentLabel == "SmallAppear")
         {
            JBGUtil.gotoFrameWithFn(this._mc,"SmallDisappear",MovieClipEvent.EVENT_DISAPPEAR_DONE,doneFn);
         }
         else
         {
            JBGUtil.gotoFrameWithFn(this._mc,"Disappear",MovieClipEvent.EVENT_DISAPPEAR_DONE,doneFn);
         }
      }
      
      public function shrink(doneFn:Function) : void
      {
         if(this._mc.currentLabel == "Appear")
         {
            GameState.instance.audioRegistrationStack.play("TiebreakerPromptShrink",Nullable.NULL_FUNCTION);
            JBGUtil.gotoFrameWithFn(this._mc,"Shrink",MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
         }
         else
         {
            doneFn();
         }
      }
   }
}
