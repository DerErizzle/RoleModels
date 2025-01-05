package jackboxgames.rolemodels.data
{
   import jackboxgames.rolemodels.Player;
   
   public class FreebieData implements IRevealData
   {
       
      
      private var _revealConstants:RevealConstants;
      
      private var _roleData:RoleData;
      
      private var _receivingPlayer:Player;
      
      public function FreebieData(revealConstants:RevealConstants, roleData:RoleData, receivingPlayer:Player)
      {
         super();
         this._revealConstants = revealConstants;
         this._roleData = roleData;
         this._receivingPlayer = receivingPlayer;
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
      
      public function get receivingPlayer() : Player
      {
         return this._receivingPlayer;
      }
      
      public function get primaryPlayers() : Array
      {
         return [this._receivingPlayer];
      }
   }
}
