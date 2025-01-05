package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.events.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.widgets.*;
   import jackboxgames.utils.*;
   
   public class MinigamePlayerVoteWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _avatar:PlayerAvatarWidget;
      
      private var _player:Player;
      
      private var _isGrown:Boolean;
      
      public function MinigamePlayerVoteWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._shower.behaviorTranslator = function(s:String):String
         {
            return s == "Disappear" ? (_isGrown ? "Disappear" : "DisappearSmall") : s;
         };
         this._avatar = new PlayerAvatarWidget(this._mc.avatar);
      }
      
      public function reset() : void
      {
         JBGUtil.reset([this._shower,this._avatar]);
         if(Boolean(this._player))
         {
            this._player.removeEventListener(Player.EVENT_IS_CHOOSING_ACTIVE_CHANGED,this._onIsChoosingActiveChanged);
            this._player.isChoosingActive = false;
            this._player = null;
         }
         this._isGrown = false;
      }
      
      public function setup(player:Player) : void
      {
         this._player = player;
         this._avatar.setup(player);
         this._player.addEventListener(Player.EVENT_IS_CHOOSING_ACTIVE_CHANGED,this._onIsChoosingActiveChanged);
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         this._shower.setShown(isShown,doneFn);
      }
      
      private function _onIsChoosingActiveChanged(evt:EventWithData) : void
      {
         if(evt.data)
         {
            this._shower.doAnimation("Shrink",function():void
            {
               _isGrown = false;
               JBGUtil.gotoFrame(_mc,"Voting");
            });
         }
         else
         {
            GameState.instance.audioRegistrationStack.play("VoteIn",Nullable.NULL_FUNCTION);
            this._shower.doAnimation("Grow",function():void
            {
               _isGrown = true;
               JBGUtil.gotoFrame(_mc,"Waiting");
            });
         }
      }
   }
}
