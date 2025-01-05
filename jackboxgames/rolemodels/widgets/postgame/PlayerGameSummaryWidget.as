package jackboxgames.rolemodels.widgets.postgame
{
   import flash.display.MovieClip;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.widgets.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class PlayerGameSummaryWidget
   {
       
      
      private var _shower:MovieClipShower;
      
      private var _mc:MovieClip;
      
      private var _placeTF:ExtendableTextField;
      
      private var _playerNameTF:ExtendableTextField;
      
      private var _playerFinalRoleTF:ExtendableTextField;
      
      private var _bg:MovieClip;
      
      private var _avatar:PlayerAvatarWidget;
      
      public function PlayerGameSummaryWidget(mc:MovieClip)
      {
         super();
         this._shower = new MovieClipShower(mc);
         this._mc = mc.player;
         this._placeTF = new ExtendableTextField(this._mc.playerPlaceTF,[],[PostEffectFactory.createDynamicResizerEffect(),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         this._playerNameTF = new ExtendableTextField(this._mc.playerName,[],[PostEffectFactory.createDynamicResizerEffect(),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         this._playerFinalRoleTF = new ExtendableTextField(this._mc.playerRole,[],[PostEffectFactory.createDynamicResizerEffect(),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         this._bg = this._mc.bg;
         this._avatar = new PlayerAvatarWidget(this._mc.avatar);
      }
      
      public function get shower() : MovieClipShower
      {
         return this._shower;
      }
      
      public function reset() : void
      {
         this._avatar.reset();
         this._shower.reset();
         JBGUtil.gotoFrame(this._bg,"Park");
      }
      
      public function setup(player:Player) : void
      {
         this._avatar.setup(player);
         this._placeTF.text = String(player.placeIndex + 1);
         this._playerNameTF.text = player.name.val;
         this._playerFinalRoleTF.text = GameState.instance.getPlayerFinalRole(player);
         var frame:String = "Player" + player.index.val;
         frame += player.placeIndex % 2 == 0 ? "Loop1" : "Loop2";
         JBGUtil.gotoFrame(this._bg,frame);
      }
   }
}
