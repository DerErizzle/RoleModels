package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class BucketBubbleWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _roleTF:ExtendableTextField;
      
      public function BucketBubbleWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._roleTF = new ExtendableTextField(this._mc.role.roleTF,[],[PostEffectFactory.createDynamicResizerEffect(2),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
      }
      
      public function get shower() : MovieClipShower
      {
         return this._shower;
      }
      
      public function reset() : void
      {
         this._shower.reset();
         JBGUtil.gotoFrame(this._mc.role.role,"Park");
      }
      
      public function setup(role:RoleData) : void
      {
         JBGUtil.gotoFrame(this._mc.role.role,"Loop");
         this._roleTF.text = role.name.toUpperCase();
      }
   }
}
