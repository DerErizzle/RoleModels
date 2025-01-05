package jackboxgames.rolemodels.data
{
   import jackboxgames.rolemodels.Player;
   import jackboxgames.utils.ArrayUtil;
   import jackboxgames.utils.Assert;
   
   public class AbundanceData implements IRevealData
   {
       
      
      private var _revealConstants:RevealConstants;
      
      private var _roleData:RoleData;
      
      private var _roles:Array;
      
      private var _primaryPlayer:Player;
      
      private var _votingPlayers:Array;
      
      public function AbundanceData(revealConstants:RevealConstants, roles:Array, primaryPlayer:Player, votingPlayers:Array)
      {
         super();
         this._revealConstants = revealConstants;
         this._roles = roles;
         this._primaryPlayer = primaryPlayer;
         this._votingPlayers = votingPlayers;
      }
      
      public function get revealConstants() : RevealConstants
      {
         return this._revealConstants;
      }
      
      public function get rolesInvolved() : Array
      {
         return this._roles;
      }
      
      public function get primaryPlayer() : Player
      {
         return this._primaryPlayer;
      }
      
      public function get primaryPlayers() : Array
      {
         return [this._primaryPlayer];
      }
      
      public function get votingPlayers() : Array
      {
         return this._votingPlayers;
      }
      
      public function get roleData() : RoleData
      {
         return this._roleData;
      }
      
      public function setWinningRole(role:RoleData) : void
      {
         Assert.assert(ArrayUtil.arrayContainsElement(this._roles,role));
         this._roleData = role;
      }
   }
}
