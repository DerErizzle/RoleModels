package jackboxgames.rolemodels.widgets
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.utils.*;
   
   public class PlayerWidget
   {
      
      public static const AVATAR_ANIMATION_LABELS:Object = {
         "LOSE":"Lose",
         "WIN":"Win",
         "SUPER_WIN":"SuperWin"
      };
      
      public static const BUCKET_DISAPPEAR_DIRECTION:Object = {
         "RIGHT":"Right",
         "LEFT":"Left"
      };
       
      
      private var _mc:MovieClip;
      
      private var _animationMC:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _avatar:PlayerAvatarWidget;
      
      private var _name:PlayerNameWidget;
      
      private var _nameShower:MovieClipShower;
      
      private var _biscuits:BiscuitLineupWidget;
      
      private var _votes:VoteLineupWidget;
      
      private var _bucketDisappearDirection:String;
      
      private var _isAvatarBucketed:Boolean;
      
      private var _player:Player;
      
      public function PlayerWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc.avatar);
         this._shower.behaviorTranslator = function(s:String):String
         {
            if(s == "Appear")
            {
               return GameState.instance.currentReveal.revealConstants.type == RevealConstants.REVEAL_DATA_TYPES.justPlaying ? "AppearOnPinkBG" : "Appear";
            }
            if(s == "Disappear")
            {
               if(_isAvatarBucketed)
               {
                  return "DisappearBucket" + _bucketDisappearDirection;
               }
               return GameState.instance.currentReveal.revealConstants.type == RevealConstants.REVEAL_DATA_TYPES.justPlaying ? "DisappearOnPinkBG" : "Disappear";
            }
            return s;
         };
         this._animationMC = this._mc.avatar;
         this._avatar = new PlayerAvatarWidget(this._mc.avatar.avatar);
         this._nameShower = new MovieClipShower(this._mc.avatar.playerName);
         this._name = new PlayerNameWidget(this._mc.avatar.playerName.playerName.playerName);
         this._votes = new VoteLineupWidget(this._mc.votes);
         this._biscuits = new BiscuitLineupWidget(this._mc.biscuitsTF);
         this._isAvatarBucketed = false;
      }
      
      public function get player() : Player
      {
         return this._player;
      }
      
      public function reset() : void
      {
         JBGUtil.reset([this._shower,this._avatar,this._name,this._votes,this._biscuits,this._nameShower]);
         JBGUtil.gotoFrame(this._animationMC,"Park");
         if(Boolean(this._player))
         {
            this._player.removeEventListener(PlayerBroadcastEvent.EVENT_PLAYER_BROADCAST,this._onPlayerBroadcast);
         }
         this._player = null;
         this._isAvatarBucketed = false;
      }
      
      public function setup(p:Player, bucketDisappearDirection:String) : void
      {
         this._player = p;
         this._bucketDisappearDirection = bucketDisappearDirection;
         if(Boolean(this._avatar))
         {
            this._avatar.setup(this._player);
         }
         if(Boolean(this._name))
         {
            this._name.setup(this._player);
         }
         this._nameShower.setShown(true,Nullable.NULL_FUNCTION);
         this._player.addEventListener(PlayerBroadcastEvent.EVENT_PLAYER_BROADCAST,this._onPlayerBroadcast);
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         if(!isShown && this._shower.isShown)
         {
            GameState.instance.audioRegistrationStack.play("AvatarFall",Nullable.NULL_FUNCTION);
         }
         this._shower.setShown(isShown,function():void
         {
            JBGUtil.gotoFrame(_animationMC,isShown ? "Idle" : "Park");
            if(!isShown)
            {
               reset();
            }
            doneFn();
         });
      }
      
      public function setVotesShown(isShown:Boolean, doneFn:Function) : void
      {
         this._votes.setVotesShown(isShown,doneFn);
      }
      
      public function bucketAvatar(doneFn:Function) : void
      {
         this._isAvatarBucketed = true;
         GameState.instance.audioRegistrationStack.play("AvatarFall",Nullable.NULL_FUNCTION);
         this._shower.doAnimation("BucketAvatar",doneFn);
      }
      
      private function _onPlayerBroadcast(evt:PlayerBroadcastEvent) : void
      {
         if(!this._shower.isShown)
         {
            return;
         }
         var name:String = evt.broadcastName;
         var doneFn:Function = Nullable.NULL_FUNCTION;
         if(name == "PointsDistributed")
         {
            this._handlePointsDistributed(evt.data.from,evt.data.to,evt.data.diff,evt.data.numberOverride,doneFn);
         }
         else if(name == "VotesReceived")
         {
            this._handleVotesReceived(evt.data.votingPlayers,doneFn);
         }
         else if(name == "AvatarAnimation")
         {
            this._handleAvatarAnimation(evt.data.frameLabel,doneFn);
         }
      }
      
      private function _handlePointsDistributed(from:int, to:int, diff:int, numberOverride:String, doneFn:Function) : void
      {
         this._biscuits.doScoreChange(diff,doneFn);
      }
      
      private function _handleVotesReceived(players:Array, doneFn:Function) : void
      {
         this._votes.setup(players);
      }
      
      private function _handleAvatarAnimation(frameLabel:String, doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._animationMC,frameLabel,MovieClipEvent.EVENT_ANIMATION_DONE,function():void
         {
            JBGUtil.gotoFrame(_animationMC,"Idle");
         });
      }
   }
}
