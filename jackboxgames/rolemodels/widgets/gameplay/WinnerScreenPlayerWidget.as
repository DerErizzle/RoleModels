package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.widgets.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class WinnerScreenPlayerWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _playerNameTF:ExtendableTextField;
      
      private var _playerFinalRoleTF:ExtendableTextField;
      
      private var _avatar:PlayerAvatarWidget;
      
      public function WinnerScreenPlayerWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(mc);
         this._avatar = new PlayerAvatarWidget(this._mc.avatar);
         this._playerNameTF = new ExtendableTextField(this._mc.playerName,[],[PostEffectFactory.createDynamicResizerEffect(),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         this._playerFinalRoleTF = new ExtendableTextField(this._mc.playerRole,[],[PostEffectFactory.createDynamicResizerEffect(),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
      }
      
      public function reset() : void
      {
         this._shower.reset();
      }
      
      public function setup(player:Player) : void
      {
         this._avatar.setup(player);
         this._playerNameTF.text = player.name.val;
         this._playerFinalRoleTF.text = GameState.instance.getPlayerFinalRole(player);
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         this._shower.setShown(isShown,doneFn);
      }
   }
}
