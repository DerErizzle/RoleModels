package jackboxgames.rolemodels.data
{
   import jackboxgames.rolemodels.Player;
   import jackboxgames.utils.PerPlayerContainer;
   
   public class MajorityData implements IRevealData
   {
       
      
      private var _revealConstants:RevealConstants;
      
      private var _roleData:RoleData;
      
      private var _winningPlayer:Player;
      
      private var _votes:PerPlayerContainer;
      
      private var _playerVotedForSelf:Boolean;
      
      private var _wasSuperVote:Boolean;
      
      private var _numSuperRightSoFar:int;
      
      private var _numSuperWrongSoFar:int;
      
      public function MajorityData(revealConstants:RevealConstants, roleData:RoleData, winningPlayer:Player, votes:PerPlayerContainer, playerVotedForSelf:Boolean, wasSuperVote:Boolean, numSuperRightSoFar:int, numSuperWrongSoFar:int)
      {
         super();
         this._revealConstants = revealConstants;
         this._roleData = roleData;
         this._winningPlayer = winningPlayer;
         this._votes = votes;
         this._playerVotedForSelf = playerVotedForSelf;
         this._wasSuperVote = wasSuperVote;
         this._numSuperRightSoFar = numSuperRightSoFar;
         this._numSuperWrongSoFar = numSuperWrongSoFar;
      }
      
      public function get revealConstants() : RevealConstants
      {
         return this._revealConstants;
      }
      
      public function get roleData() : RoleData
      {
         return this._roleData;
      }
      
      public function get rolesInvolved() : Array
      {
         return [this._roleData];
      }
      
      public function get winningPlayer() : Player
      {
         return this._winningPlayer;
      }
      
      public function get primaryPlayers() : Array
      {
         return [this._winningPlayer];
      }
      
      public function get votes() : PerPlayerContainer
      {
         return this._votes;
      }
      
      public function get playerVotedForSelf() : Boolean
      {
         return this._playerVotedForSelf;
      }
      
      public function get wasSuperVote() : Boolean
      {
         return this._wasSuperVote;
      }
      
      public function get numSuperRightSoFar() : int
      {
         return this._numSuperRightSoFar;
      }
      
      public function get numSuperWrongSoFar() : int
      {
         return this._numSuperWrongSoFar;
      }
   }
}
