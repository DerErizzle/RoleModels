package jackboxgames.rolemodels.data
{
   public class RecountData implements IRevealData
   {
       
      
      private var _revealConstants:RevealConstants;
      
      private var _roleData:RoleData;
      
      private var _primaryPlayers:Array;
      
      private var _votingPlayers:Array;
      
      private var _result:String;
      
      public function RecountData(revealConstants:RevealConstants, roleData:RoleData, primaryPlayers:Array, votingPlayers:Array)
      {
         super();
         this._revealConstants = revealConstants;
         this._roleData = roleData;
         this._primaryPlayers = primaryPlayers;
         this._votingPlayers = votingPlayers;
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
      
      public function get primaryPlayers() : Array
      {
         return this._primaryPlayers;
      }
      
      public function get votingPlayers() : Array
      {
         return this._votingPlayers;
      }
      
      public function get result() : String
      {
         return this._result;
      }
      
      public function set result(val:String) : void
      {
         this._result = val;
      }
   }
}
