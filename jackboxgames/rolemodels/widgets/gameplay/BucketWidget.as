package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.rolemodels.widgets.*;
   import jackboxgames.utils.*;
   
   public class BucketWidget
   {
       
      
      private var _shower:MovieClipShower;
      
      private var _mc:MovieClip;
      
      private var _avatar:PlayerAvatarWidget;
      
      private var _avatarAnimationMC:MovieClip;
      
      private var _playerName:PlayerNameWidget;
      
      private var _nameShower:MovieClipShower;
      
      private var _bucketBubble:BucketBubbleWidget;
      
      private var _biscuitPile:BiscuitPileWidget;
      
      public function BucketWidget(mc:MovieClip)
      {
         super();
         this._shower = new MovieClipShower(mc);
         this._mc = mc.bucket;
         this._avatar = new PlayerAvatarWidget(this._mc.avatar.avatar);
         this._avatarAnimationMC = this._mc.avatar;
         this._playerName = new PlayerNameWidget(this._mc.finalRole.role.playerName.playerName);
         this._nameShower = new MovieClipShower(this._mc.finalRole.role.playerName);
         this._bucketBubble = new BucketBubbleWidget(this._mc.finalRole);
         this._biscuitPile = new BiscuitPileWidget(this._mc.biscuits);
      }
      
      public function get shower() : MovieClipShower
      {
         return this._shower;
      }
      
      public function get roleShower() : MovieClipShower
      {
         return this._bucketBubble.shower;
      }
      
      public function get biscuitShower() : MovieClipShower
      {
         return this._biscuitPile.shower;
      }
      
      public function reset() : void
      {
         this._shower.reset();
         this._avatar.reset();
         this._playerName.reset();
         this._bucketBubble.reset();
         this._biscuitPile.reset();
         this._nameShower.reset();
         JBGUtil.gotoFrame(this._avatarAnimationMC,"Park");
      }
      
      public function setup(player:Player, role:RoleData) : void
      {
         this._avatar.setup(player);
         JBGUtil.gotoFrame(this._avatarAnimationMC,"Appear");
         this._playerName.setup(player);
         this._bucketBubble.setup(role);
         this._biscuitPile.setup(player.score.val);
         this._nameShower.setShown(true,Nullable.NULL_FUNCTION);
      }
      
      public function showBiscuitPile(doneFn:Function) : void
      {
         this._biscuitPile.showPile(doneFn);
      }
      
      public function highlight(isHighlighted:Boolean, doneFn:Function) : void
      {
         this._shower.doAnimation(isHighlighted ? "Highlight" : "Unhighlight",doneFn);
         if(isHighlighted)
         {
            JBGUtil.gotoFrame(this._avatarAnimationMC,"Highlight");
         }
      }
   }
}
