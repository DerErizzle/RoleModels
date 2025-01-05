package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.events.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class WinnerScreenFinalRoleWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _leftTF:ExtendableTextField;
      
      private var _centerTF:ExtendableTextField;
      
      private var _rightTF:ExtendableTextField;
      
      public function WinnerScreenFinalRoleWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._leftTF = new ExtendableTextField(this._mc.leftTF,[],[PostEffectFactory.createDynamicResizerEffect(),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         this._centerTF = new ExtendableTextField(this._mc.centerTF,[],[PostEffectFactory.createDynamicResizerEffect(),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         this._rightTF = new ExtendableTextField(this._mc.rightTF,[],[PostEffectFactory.createDynamicResizerEffect(),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
      }
      
      public function reset() : void
      {
         this._shower.reset();
         this._leftTF.text = "";
         this._centerTF.text = "";
         this._rightTF.text = "";
      }
      
      public function setup(player:Player) : void
      {
         var tags:Array = GameState.instance.getPlayerFinalRoleTags(player);
         if(tags.length > 0)
         {
            this._leftTF.text = tags[0];
         }
         if(tags.length > 1)
         {
            this._centerTF.text = tags[1];
         }
         if(tags.length > 2)
         {
            this._rightTF.text = tags[2];
         }
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         this._shower.setShown(isShown,doneFn);
      }
   }
}
