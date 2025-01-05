package jackboxgames.rolemodels.widgets
{
   import flash.display.*;
   import flash.text.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class FlippablePlayerNameWidget
   {
      
      public static const NAME_POSITIONS:Array = ["Park","Below","Above"];
       
      
      private var _mc:MovieClip;
      
      private var _tf:ExtendableTextField;
      
      public function FlippablePlayerNameWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._tf = new ExtendableTextField(this._mc.tf,[],[PostEffectFactory.createDynamicResizerEffect(1),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
      }
      
      public function setup(p:Player, frame:String) : void
      {
         this._tf.text = p.name.val;
         JBGUtil.gotoFrame(this._mc,frame);
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._mc,"Park");
      }
   }
}
