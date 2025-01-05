package jackboxgames.rolemodels.actionpackages
{
   import jackboxgames.nativeoverride.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.utils.*;
   
   public class Majority extends JBGActionPackage
   {
       
      
      private var _revealData:MajorityData;
      
      public function Majority(sourceURL:String)
      {
         super(sourceURL);
      }
      
      public function get roleIndex() : int
      {
         return this._revealData.roleData.indexInContent;
      }
      
      public function get winningPlayerUserID() : String
      {
         return this._revealData.winningPlayer.userId.val;
      }
      
      public function get role() : RoleData
      {
         return this._revealData.roleData;
      }
      
      public function get playerVotedForSelf() : Boolean
      {
         return this._revealData.playerVotedForSelf;
      }
      
      public function get playerGotOneVote() : Boolean
      {
         return this._revealData.votes.getDataForPlayer(this._revealData.winningPlayer).length == 1;
      }
      
      public function get wasSuperVote() : Boolean
      {
         return this._revealData.wasSuperVote;
      }
      
      public function get numSuperRight() : int
      {
         return this._revealData.numSuperRightSoFar;
      }
      
      public function get numSuperWrong() : int
      {
         return this._revealData.numSuperWrongSoFar;
      }
      
      public function handleActionInit(ref:IActionRef, params:Object) : void
      {
         _setLoaded(true,function():void
         {
            _onLoaded();
            ref.end();
         });
      }
      
      private function _onLoaded() : void
      {
         _ts.g.majority = this;
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         JBGUtil.reset([]);
         ref.end();
      }
      
      public function handleActionSetupReveal(ref:IActionRef, params:Object) : void
      {
         var winnerGotPoints:Boolean;
         this._revealData.winningPlayer.broadcast("VotesReceived",{"votingPlayers":this._revealData.votes.getDataForPlayer(this._revealData.winningPlayer)});
         winnerGotPoints = false;
         this._revealData.votes.getDataForPlayer(this._revealData.winningPlayer).forEach(function(votingPlayer:Player, ... args):void
         {
            if(votingPlayer.userId.val == _revealData.winningPlayer.userId.val)
            {
               votingPlayer.pendingPoints.val += _revealData.revealConstants.getProperty("pointsSelf");
               winnerGotPoints = true;
            }
            else
            {
               votingPlayer.pendingPoints.val += _revealData.revealConstants.getProperty("pointsNotSelf");
            }
         });
         if(!winnerGotPoints)
         {
            this._revealData.winningPlayer.pendingPoints.val += this._revealData.revealConstants.getProperty("pointsNotSelf");
            winnerGotPoints = true;
         }
         this._revealData.roleData.playerAssignedRole = this._revealData.winningPlayer;
         if(!this.playerVotedForSelf && this._revealData.votes.getDataForPlayer(this._revealData.winningPlayer).length == GameState.instance.players.length - 1)
         {
            Trophy.instance.unlock(GameConstants.TROPHY_OBLIVIOUS_MAJORITY);
         }
         if(GameState.instance.currentRound.getPreviousRevealsOfName(GameConstants.REVEAL_CONSTANTS.majority.name).length == 5)
         {
            Trophy.instance.unlock(GameConstants.TROPHY_SIX_MAJORITIES_ONE_ROUND);
         }
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         this._revealData = MajorityData(GameState.instance.currentReveal);
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         ref.end();
      }
   }
}
