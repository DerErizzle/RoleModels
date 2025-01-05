package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.rolemodels.widgets.*;
   import jackboxgames.utils.*;
   
   public class VoteResultPlayerWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _playerVoteAvatar:PlayerAvatarWidget;
      
      private var _avatar:PlayerAvatarWidget;
      
      private var _player:Player;
      
      private var _isBiscuitShown:Boolean;
      
      private var _isVoteShown:Boolean;
      
      private var _percentShower:MovieClipShower;
      
      private var _isHighlighted:Boolean;
      
      private var _name:FlippablePlayerNameWidget;
      
      private var _namePosition:String;
      
      public function VoteResultPlayerWidget(mc:MovieClip, namePosition:String)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._avatar = new PlayerAvatarWidget(this._mc.avatar);
         this._playerVoteAvatar = new PlayerAvatarWidget(this._mc.vote);
         this._name = new FlippablePlayerNameWidget(this._mc.playerNameTF);
         this._percentShower = new MovieClipShower(this._mc.percent);
         this._namePosition = namePosition;
         this._isBiscuitShown = false;
         this._isVoteShown = false;
         this._isHighlighted = false;
      }
      
      public function get player() : Player
      {
         return this._player;
      }
      
      public function get shower() : MovieClipShower
      {
         return this._shower;
      }
      
      public function get isVoteShown() : Boolean
      {
         return this._isVoteShown;
      }
      
      public function reset() : void
      {
         JBGUtil.reset([this._avatar,this._playerVoteAvatar,this._shower,this._name,this._percentShower]);
         if(Boolean(this._player))
         {
            this._player.removeEventListener(PlayerBroadcastEvent.EVENT_PLAYER_BROADCAST,this._onPlayerBroadcast);
         }
         this._player = null;
         this._isBiscuitShown = false;
         this._isVoteShown = false;
         this._isHighlighted = false;
      }
      
      public function setup(votingPlayer:Player, playerVotedFor:Player) : void
      {
         this._player = votingPlayer;
         this._avatar.setup(votingPlayer);
         this._name.setup(votingPlayer,this._namePosition);
         if(Boolean(playerVotedFor))
         {
            this._playerVoteAvatar.setup(playerVotedFor);
         }
         this._playerVoteAvatar.setVisible(playerVotedFor != null);
      }
      
      public function setupPlayerListener() : void
      {
         this._player.addEventListener(PlayerBroadcastEvent.EVENT_PLAYER_BROADCAST,this._onPlayerBroadcast);
      }
      
      private function _onPlayerBroadcast(evt:PlayerBroadcastEvent) : void
      {
         var name:String = evt.broadcastName;
         var doneFn:Function = Nullable.NULL_FUNCTION;
         if(name == "PointsDistributed")
         {
            this.setBiscuitShown(true,doneFn);
         }
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         this._shower.setShown(isShown,doneFn);
      }
      
      public function setVoteShown(isShown:Boolean, doneFn:Function) : void
      {
         if(!this._playerVoteAvatar.visible)
         {
            doneFn();
            return;
         }
         if(isShown)
         {
            this._shower.doAnimation("AppearVote",doneFn);
         }
         else if(!this._isBiscuitShown && this._isVoteShown)
         {
            this._shower.doAnimation("DisappearVote",doneFn);
         }
         else
         {
            doneFn();
         }
         this._isVoteShown = isShown;
      }
      
      public function showAudienceBonus(doneFn:Function) : void
      {
         this._shower.doAnimation("AppearAudienceBonus",doneFn);
      }
      
      public function setPercentShown(isShown:Boolean, doneFn:Function) : void
      {
         this._percentShower.setShown(isShown,doneFn);
      }
      
      public function setBiscuitShown(isShown:Boolean, doneFn:Function) : void
      {
         if(isShown)
         {
            if(this._isVoteShown)
            {
               this._isBiscuitShown = true;
               this._shower.doAnimation("AppearVoteToBiscuit",doneFn);
            }
            else if(this._mc.currentLabel == "AppearAudienceBonus")
            {
               this._isBiscuitShown = true;
               this._shower.doAnimation("AppearAudienceToBiscuit",doneFn);
            }
            else
            {
               this._shower.doAnimation(this._isHighlighted ? "GiveBonus" : "AppearBiscuit",doneFn);
               this._isBiscuitShown = !this._isHighlighted;
            }
            GameState.instance.audioRegistrationStack.play("PelletsOn");
         }
         else if(this._isBiscuitShown)
         {
            this._shower.doAnimation("DisappearBiscuit",doneFn);
            this._isBiscuitShown = false;
         }
         else
         {
            doneFn();
         }
      }
      
      public function setHighlight(highlight:Boolean, doneFn:Function) : void
      {
         this._isHighlighted = highlight;
         if(highlight)
         {
            if(this._mc.currentLabel == "AppearVote")
            {
               this._shower.doAnimation("Highlight",doneFn);
            }
            else
            {
               this._shower.doAnimation("HighlightNoBubble",doneFn);
            }
         }
         else if(this._mc.currentLabel == "Highlight")
         {
            this._shower.doAnimation("Unhighlight",doneFn);
         }
         else
         {
            this._shower.doAnimation("UnhighlightNoBubble",doneFn);
         }
      }
   }
}
