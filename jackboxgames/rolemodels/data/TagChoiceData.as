package jackboxgames.rolemodels.data
{
   public class TagChoiceData implements IRevealData
   {
       
      
      private var _revealConstants:RevealConstants;
      
      private var _roles:Array;
      
      private var _tags:Array;
      
      private var _primaryPlayers:Array;
      
      private var _votingPlayers:Array;
      
      private var _result:String;
      
      public function TagChoiceData(revealConstants:RevealConstants, roles:Array, tags:Array, primaryPlayers:Array, votingPlayers:Array)
      {
         super();
         this._revealConstants = revealConstants;
         this._roles = roles;
         this._tags = tags;
         this._primaryPlayers = primaryPlayers;
         this._votingPlayers = votingPlayers;
      }
      
      public function get revealConstants() : RevealConstants
      {
         return this._revealConstants;
      }
      
      public function get roleData() : RoleData
      {
         return null;
      }
      
      public function get rolesInvolved() : Array
      {
         return this._roles;
      }
      
      public function get tags() : Array
      {
         return this._tags;
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
