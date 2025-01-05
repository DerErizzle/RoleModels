package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class RevealInstructionWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _tf:ExtendableTextField;
      
      public function RevealInstructionWidget(mc:MovieClip)
      {
         super();
         this._shower = new MovieClipShower(mc);
         this._mc = mc.instructions;
         this._tf = new ExtendableTextField(this._mc,[],[PostEffectFactory.createDynamicResizerEffect(2,4,128,2,false),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
      }
      
      public function get shower() : MovieClipShower
      {
         return this._shower;
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._mc.bg,"Park");
         this._shower.reset();
      }
      
      public function setup(text:String) : void
      {
         JBGUtil.gotoFrame(this._mc.bg,"Loop");
         this._tf.text = text;
      }
   }
}
