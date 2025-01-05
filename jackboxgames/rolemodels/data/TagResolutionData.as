package jackboxgames.rolemodels.data
{
   public class TagResolutionData implements IRevealData
   {
       
      
      private var _revealConstants:RevealConstants;
      
      private var _roles:Array;
      
      private var _primaryPlayers:Array;
      
      private var _votingPlayers:Array;
      
      private var _printfTag:String;
      
      private var _tags:Array;
      
      private var _prompt:String;
      
      private var _result:String;
      
      public function TagResolutionData(revealConstants:RevealConstants, roles:Array, primaryPlayers:Array, votingPlayers:Array, printfTag:String, tags:Array, prompt:String)
      {
         super();
         this._revealConstants = revealConstants;
         this._roles = roles;
         this._primaryPlayers = primaryPlayers;
         this._votingPlayers = votingPlayers;
         this._printfTag = printfTag;
         this._tags = tags;
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
      
      public function get primaryPlayers() : Array
      {
         return this._primaryPlayers;
      }
      
      public function get votingPlayers() : Array
      {
         return this._votingPlayers;
      }
      
      public function get printfTag() : String
      {
         return this._printfTag;
      }
      
      public function get tags() : Array
      {
         return this._tags;
      }
      
      public function get prompt() : String
      {
         return this._prompt;
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
