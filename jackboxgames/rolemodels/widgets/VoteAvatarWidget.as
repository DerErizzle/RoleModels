package jackboxgames.rolemodels.widgets
{
   import flash.display.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.utils.*;
   
   public class VoteAvatarWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _avatar:PlayerAvatarWidget;
      
      private var _player:Player;
      
      public function VoteAvatarWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._avatar = new PlayerAvatarWidget(this._mc.vote);
      }
      
      public function get shower() : MovieClipShower
      {
         return this._shower;
      }
      
      public function reset() : void
      {
         this._shower.reset();
         this._avatar.reset();
      }
      
      public function setup(p:Player) : void
      {
         this._player = p;
         if(this._player == Player.AUDIENCE_PLAYER)
         {
            this._avatar.setupAudienceAvatar(p);
         }
         else
         {
            this._avatar.setup(p);
         }
      }
   }
}
