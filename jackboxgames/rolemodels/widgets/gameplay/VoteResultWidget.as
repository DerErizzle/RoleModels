package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.rolemodels.widgets.*;
   import jackboxgames.utils.*;
   
   public class VoteResultWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _categoryAndRole:VoteResultCategoryRoleWidget;
      
      private var _avatar0:VoteResultPlayerWidget;
      
      private var _avatar1:VoteResultPlayerWidget;
      
      private var _bucketedAvatar:VoteResultPlayerWidget;
      
      private var _avatarBody0:VoteResultAvatarBodyWidget;
      
      private var _avatarBody1:VoteResultAvatarBodyWidget;
      
      private var _voteResultPlayerLineUp:VoteResultPlayerLineUpWidget;
      
      private var _isAward:Boolean;
      
      private var _isSetupWithNoRole:Boolean;
      
      private var _isSetupWithTwoPlayers:Boolean;
      
      private var _questionMarkShower:MovieClipShower;
      
      public function VoteResultWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._avatar0 = new VoteResultPlayerWidget(this._mc.body.avatar0.avatar,FlippablePlayerNameWidget.NAME_POSITIONS[2]);
         this._avatar1 = new VoteResultPlayerWidget(this._mc.body.avatar1.avatar,FlippablePlayerNameWidget.NAME_POSITIONS[2]);
         this._bucketedAvatar = new VoteResultPlayerWidget(this._mc.bucketedAvatar,FlippablePlayerNameWidget.NAME_POSITIONS[0]);
         this._avatarBody0 = new VoteResultAvatarBodyWidget(this._mc.body.avatar0);
         this._avatarBody1 = new VoteResultAvatarBodyWidget(this._mc.body.avatar1);
         this._voteResultPlayerLineUp = new VoteResultPlayerLineUpWidget(this._mc.voters,FlippablePlayerNameWidget.NAME_POSITIONS[1]);
         this._categoryAndRole = new VoteResultCategoryRoleWidget(this._mc.roleAndCategory);
         this._questionMarkShower = new MovieClipShower(this._mc.questionMark);
      }
      
      public function reset() : void
      {
         JBGUtil.arrayGotoFrame([this._mc,this._mc.questionMark.questionMark],"Park");
         JBGUtil.gotoFrame(this._mc.body,"AvatarsIs1");
         JBGUtil.reset([this._avatar0,this._avatar1,this._bucketedAvatar,this._voteResultPlayerLineUp,this._categoryAndRole,this._questionMarkShower,this._avatarBody0,this._avatarBody1]);
         this._voteResultPlayerLineUp.reset();
         this._isAward = false;
         this._isSetupWithNoRole = false;
         this._isSetupWithTwoPlayers = false;
      }
      
      public function setupAward(player:Player, role:RoleData, categoryText:String) : void
      {
         JBGUtil.gotoFrame(this._mc.body,"AvatarsIs1");
         this.setup(categoryText,role);
         this._avatar0.setup(player,GameState.instance.currentRound.getPlayerVotedForRole(player,role));
         this._avatarBody0.setup();
         this._bucketedAvatar.setup(player,GameState.instance.currentRound.getPlayerVotedForRole(player,role));
         this._isAward = true;
         this._isSetupWithTwoPlayers = false;
      }
      
      public function setup(categoryText:String, role:RoleData) : void
      {
         JBGUtil.gotoFrame(this._mc.body,"AvatarsIs1");
         JBGUtil.gotoFrame(this._mc.questionMark.questionMark,"Loop");
         this._categoryAndRole.setup(categoryText,role);
         this._avatarBody0.setup();
         this.setupPlayerLineup(role);
         this._isAward = false;
         this._isSetupWithTwoPlayers = false;
      }
      
      public function setupNoRole(players:Array, categoryText:String) : void
      {
         if(players.length == 1)
         {
            JBGUtil.gotoFrame(this._mc.body,"AvatarsIs1");
            this._avatar0.setup(players[0],null);
            this._avatarBody0.setup();
            this._isSetupWithTwoPlayers = false;
         }
         else
         {
            JBGUtil.gotoFrame(this._mc.body,"AvatarsIs2");
            this._avatar0.setup(players[0],null);
            this._avatarBody0.setup();
            this._avatar1.setup(players[1],null);
            this._avatarBody1.setup();
            this._isSetupWithTwoPlayers = true;
         }
         this._categoryAndRole.setupNoRole(categoryText);
         this._isSetupWithNoRole = true;
         this._isAward = false;
      }
      
      public function setupPlayerLineup(role:RoleData = null) : void
      {
         this._voteResultPlayerLineUp.setup(role);
      }
      
      public function setCategoryAndRoleShown(isShown:Boolean, doneFn:Function) : void
      {
         this._categoryAndRole.shower.setShown(isShown,doneFn);
      }
      
      public function setPlayerVoteLineUpShown(isShown:Boolean, doneFn:Function) : void
      {
         this._voteResultPlayerLineUp.setShown(isShown,doneFn);
      }
      
      public function setPlayerVotesShown(isShown:Boolean, doneFn:Function) : void
      {
         this._voteResultPlayerLineUp.setVotesShown(isShown,doneFn);
      }
      
      public function hidePlayerBiscuits(doneFn:Function) : void
      {
         this._voteResultPlayerLineUp.hideBiscuits(doneFn);
      }
      
      public function highlightVoters(votersToHighlight:Array, highlight:Boolean, doneFn:Function) : void
      {
         this._voteResultPlayerLineUp.highlightVoters(votersToHighlight,highlight,doneFn);
      }
      
      public function giveBonus(playersGettingBonus:Array, doneFn:Function) : void
      {
         this._voteResultPlayerLineUp.giveBonus(playersGettingBonus,doneFn);
      }
      
      public function shrinkCategoryAndRole(doneFn:Function) : void
      {
         this._categoryAndRole.shower.doAnimation("Shrink",doneFn);
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         if(isShown)
         {
            JBGUtil.gotoFrameWithFn(this._mc,"Appear",MovieClipEvent.EVENT_APPEAR_DONE,doneFn);
         }
         else if(!this._isAward)
         {
            if(this._isSetupWithNoRole)
            {
               JBGUtil.gotoFrameWithFn(this._mc,"DisappearWithPlayer",MovieClipEvent.EVENT_DISAPPEAR_DONE,doneFn);
            }
            else
            {
               this._questionMarkShower.setShown(false,function():void
               {
                  JBGUtil.gotoFrameWithFn(_mc,"Disappear",MovieClipEvent.EVENT_DISAPPEAR_DONE,doneFn);
               });
            }
         }
         else
         {
            JBGUtil.gotoFrameWithFn(this._mc,"DisappearWithRole",MovieClipEvent.EVENT_DISAPPEAR_DONE,doneFn);
         }
      }
      
      public function bucketPlayer(doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc,"BucketPlayer",MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
      }
      
      public function revealPlayerInHand(doneFn:Function) : void
      {
         GameState.instance.audioRegistrationStack.play("HandOpens",Nullable.NULL_FUNCTION);
         if(!this._isAward && !this._isSetupWithNoRole)
         {
            GameState.instance.audioRegistrationStack.play("ShowQuestionMark",Nullable.NULL_FUNCTION);
            this._questionMarkShower.setShown(true,Nullable.NULL_FUNCTION);
            JBGUtil.gotoFrameWithFn(this._mc,"RevealNothing",MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
         }
         else
         {
            if(this._isAward)
            {
               GameState.instance.audioRegistrationStack.play("WinnerRevealed",Nullable.NULL_FUNCTION);
               this._bucketedAvatar.setShown(true,Nullable.NULL_FUNCTION);
            }
            if(this._isSetupWithNoRole)
            {
               this._avatar0.setShown(true,Nullable.NULL_FUNCTION);
               if(this._isSetupWithTwoPlayers)
               {
                  this._avatar1.setShown(true,Nullable.NULL_FUNCTION);
               }
               JBGUtil.gotoFrameWithFn(this._mc,"RevealPlayerNoBucket",MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
            }
            else
            {
               this._avatar0.setShown(true,Nullable.NULL_FUNCTION);
               JBGUtil.gotoFrameWithFn(this._mc,"RevealPlayer",MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
            }
         }
      }
      
      public function showBucket(doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc,"AppearBucket",MovieClipEvent.EVENT_APPEAR_DONE,doneFn);
      }
      
      public function showHand(doneFn:Function) : void
      {
         GameState.instance.audioRegistrationStack.play("ReviewFistOn",Nullable.NULL_FUNCTION);
         JBGUtil.gotoFrameWithFn(this._mc,this._isSetupWithNoRole ? "AppearHandNoBucket" : "AppearHand",MovieClipEvent.EVENT_APPEAR_DONE,doneFn);
      }
      
      public function showHandAndBucket(doneFn:Function) : void
      {
         GameState.instance.audioRegistrationStack.play("ReviewFistOn",Nullable.NULL_FUNCTION);
         JBGUtil.gotoFrameWithFn(this._mc,"AppearBucketAndHand",MovieClipEvent.EVENT_APPEAR_DONE,doneFn);
      }
      
      public function setWinningPlayersPercentShown(isShown:Boolean, doneFn:Function) : void
      {
         this._voteResultPlayerLineUp.setWinningDoubleDownPercentShown(isShown,doneFn);
      }
      
      public function setAllPlayersPercentShown(isShown:Boolean, doneFn:Function) : void
      {
         this._voteResultPlayerLineUp.setAllDoubleDownPercentShown(isShown,doneFn);
      }
      
      public function hideLosingPlayersPercent(doneFn:Function) : void
      {
         this._voteResultPlayerLineUp.hideLosingDoubleDownPercents(doneFn);
      }
      
      public function hideLosingPlayerVotes(doneFn:Function) : void
      {
         this._voteResultPlayerLineUp.hideLosingPlayerVotes(doneFn);
      }
      
      public function hidePlayerVotesForAssignedPlayers(doneFn:Function) : void
      {
         this._voteResultPlayerLineUp.hidePlayerVotesForAssignedPlayers(doneFn);
      }
      
      public function doHandAvatarAnimation(doneFn:Function) : void
      {
         var role:RoleData = null;
         var frameLabel:String = null;
         if(this._isAward && GameState.instance.currentReveal.roleData != null && GameState.instance.currentReveal.roleData.playerAssignedRole == this._avatar0.player)
         {
            role = GameState.instance.currentReveal.roleData;
            frameLabel = GameState.instance.currentRound.playerVotedForSelf(this._avatar0.player,role) ? String(VoteResultAvatarBodyWidget.VOTE_RESULT_ANIMATION_LABELS.SUPER_WIN) : String(VoteResultAvatarBodyWidget.VOTE_RESULT_ANIMATION_LABELS.WIN);
            this._avatarBody0.doAnimation(frameLabel,doneFn);
         }
         else
         {
            doneFn();
         }
      }
      
      public function showAudienceBonus(player:Player, doneFn:Function) : void
      {
         this._voteResultPlayerLineUp.showAudienceBonus(player,doneFn);
      }
   }
}
