package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.widgets.*;
   import jackboxgames.utils.*;
   
   public class CategoryVoteWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _avatar:PlayerAvatarWidget;
      
      private var _player:Player;
      
      public function CategoryVoteWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._avatar = new PlayerAvatarWidget(this._mc.avatar);
      }
      
      public function get isShown() : Boolean
      {
         return this._shower.isShown;
      }
      
      public function get player() : Player
      {
         return this._player;
      }
      
      public function reset() : void
      {
         this._shower.reset();
         this._avatar.reset();
         this._player = null;
      }
      
      public function setPlayer(player:Player) : void
      {
         this._player = player;
         this._avatar.setup(player);
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         this._shower.setShown(isShown,doneFn);
      }
   }
}
