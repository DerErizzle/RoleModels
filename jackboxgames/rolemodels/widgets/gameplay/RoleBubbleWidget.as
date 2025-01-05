package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class RoleBubbleWidget
   {
       
      
      private var _container:MovieClip;
      
      private var _mc:MovieClip;
      
      private var _roleTF:ExtendableTextField;
      
      private var _tagTF:ExtendableTextField;
      
      private var _backgroundColor:String;
      
      public function RoleBubbleWidget(mc:MovieClip)
      {
         super();
         this._container = mc;
         this._mc = this._container.roleBubble;
         this._roleTF = new ExtendableTextField(this._mc.roleTF,[],[PostEffectFactory.createDynamicResizerEffect(2,4,128,2,false),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         this._tagTF = new ExtendableTextField(this._mc.tagTF,[],[PostEffectFactory.createDynamicResizerEffect(2,4,128,2,false),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
      }
      
      public function set primaryText(val:String) : void
      {
         this._roleTF.text = val;
      }
      
      public function set transformedText(val:String) : void
      {
         this._tagTF.text = val;
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._container,"Park");
         JBGUtil.gotoFrame(this._mc,"Park");
      }
      
      public function setup(backgroundColor:String) : void
      {
         JBGUtil.gotoFrame(this._container,"Park");
         if(backgroundColor == "Yellow")
         {
            this._backgroundColor = "Red";
         }
         else
         {
            this._backgroundColor = backgroundColor;
         }
         JBGUtil.gotoFrame(this._mc,this._backgroundColor + "BG");
      }
      
      public function appear(promptOnScreen:Boolean, doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._container,promptOnScreen ? "AppearWithPrompt" : "AppearWithoutPrompt",MovieClipEvent.EVENT_APPEAR_DONE,doneFn);
      }
      
      public function shift(prompOnScreen:Boolean, doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._container,prompOnScreen ? "MoveUpWithPrompt" : "MoveUpWithoutPrompt",MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
      }
      
      public function disappear(doneFn:Function) : void
      {
         if(this._mc.currentLabel == "TagDisappear" || this._mc.currentLabel == this._backgroundColor + "BGDisappear")
         {
            doneFn();
            return;
         }
         if(this._mc.currentLabel == "Tag")
         {
            JBGUtil.gotoFrameWithFn(this._mc,"TagDisappear",MovieClipEvent.EVENT_DISAPPEAR_DONE,doneFn);
         }
         else
         {
            JBGUtil.gotoFrameWithFn(this._mc,this._backgroundColor + "BGDisappear",MovieClipEvent.EVENT_DISAPPEAR_DONE,doneFn);
         }
      }
      
      public function transformToTag(doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc,"TransformToTag",MovieClipEvent.EVENT_ANIMATION_DONE,function():void
         {
            doneFn();
            JBGUtil.gotoFrame(_mc,"Tag");
         });
      }
      
      public function disappearToPlayer(moveIndex:int, doneFn:Function) : void
      {
         if(moveIndex == -1)
         {
            JBGUtil.gotoFrameWithFn(this._container,"DisappearToPlayerLeft",MovieClipEvent.EVENT_DISAPPEAR_DONE,doneFn);
         }
         else if(moveIndex == 0)
         {
            JBGUtil.gotoFrameWithFn(this._container,"DisappearToPlayer",MovieClipEvent.EVENT_DISAPPEAR_DONE,doneFn);
         }
         else if(moveIndex == 1)
         {
            JBGUtil.gotoFrameWithFn(this._container,"DisappearToPlayerRight",MovieClipEvent.EVENT_DISAPPEAR_DONE,doneFn);
         }
         else
         {
            doneFn();
         }
      }
   }
}
