package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class AmoebaTextWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _tf:ExtendableTextField;
      
      public function AmoebaTextWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._tf = new ExtendableTextField(this._mc.TF,[],[PostEffectFactory.createDynamicResizerEffect(2,20,36),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._mc,"Park");
      }
      
      public function setup(roleName:String) : void
      {
         this._tf.text = roleName;
         JBGUtil.gotoFrame(this._mc,ArrayUtil.getRandomElement(MovieClipUtil.getFramesThatStartWith(this._mc,"Loop")));
      }
   }
}
