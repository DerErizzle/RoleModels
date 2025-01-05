package jackboxgames.rolemodels.data
{
   public class SplitData implements IRevealData
   {
       
      
      private var _revealConstants:RevealConstants;
      
      private var _roleData:RoleData;
      
      private var _primaryPlayers:Array;
      
      private var _votingPlayers:Array;
      
      private var _prompt:String;
      
      private var _splitRoles:Array;
      
      private var _idx:int;
      
      private var _result:String;
      
      public function SplitData(revealConstants:RevealConstants, roleData:RoleData, primaryPlayers:Array, votingPlayers:Array, prompt:String, splitRoles:Array, idx:int)
      {
         super();
         this._revealConstants = revealConstants;
         this._roleData = roleData;
         this._primaryPlayers = primaryPlayers;
         this._votingPlayers = votingPlayers;
         this._prompt = prompt;
         this._splitRoles = splitRoles;
         this._idx = idx;
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
         return [this._roleData].concat(this._splitRoles);
      }
      
      public function get primaryPlayers() : Array
      {
         return this._primaryPlayers;
      }
      
      public function get votingPlayers() : Array
      {
         return this._votingPlayers;
      }
      
      public function get prompt() : String
      {
         return this._prompt;
      }
      
      public function get splitRoles() : Array
      {
         return this._splitRoles;
      }
      
      public function get idx() : int
      {
         return this._idx;
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
