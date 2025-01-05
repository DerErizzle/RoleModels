package jackboxgames.rolemodels.widgets
{
   import flash.display.*;
   import flash.text.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class PlayerNameWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _tf:ExtendableTextField;
      
      private var _player:Player;
      
      public function PlayerNameWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._tf = new ExtendableTextField(this._mc,[],[PostEffectFactory.createDynamicResizerEffect(1),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
      }
      
      public function reset() : void
      {
         this._player = null;
      }
      
      public function setup(p:Player) : void
      {
         this._player = p;
         this.setName();
      }
      
      public function setName() : void
      {
         this._tf.text = this._player.name.val;
         if(Boolean(this._mc.nameBase))
         {
            this._mc.nameBase.width = TextField(ArrayUtil.first(this._tf.tfs)).textWidth + 20;
         }
      }
   }
}
