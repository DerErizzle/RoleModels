package jackboxgames.rolemodels.data
{
   import jackboxgames.rolemodels.Player;
   
   public class TagContradictionData implements IRevealData
   {
       
      
      private var _revealConstants:RevealConstants;
      
      private var _roles:Array;
      
      private var _tags:Array;
      
      private var _primaryPlayer:Player;
      
      private var _votingPlayers:Array;
      
      private var _prompt:String;
      
      private var _result:String;
      
      public function TagContradictionData(revealConstants:RevealConstants, roles:Array, tags:Array, primaryPlayer:Player, votingPlayers:Array, prompt:String)
      {
         super();
         this._revealConstants = revealConstants;
         this._roles = roles;
         this._tags = tags;
         this._primaryPlayer = primaryPlayer;
         this._votingPlayers = votingPlayers;
         this._prompt = prompt;
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
      
      public function get prompt() : String
      {
         return this._prompt;
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
