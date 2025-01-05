package jackboxgames.rolemodels.data
{
   import jackboxgames.utils.PerPlayerContainer;
   
   public class FightJustPlayingData implements IRevealData
   {
       
      
      private var _revealConstants:RevealConstants;
      
      private var _primaryPlayers:Array;
      
      private var _votingPlayers:Array;
      
      private var _tagsPerPlayer:PerPlayerContainer;
      
      private var _rolesInvolved:Array;
      
      private var _tags:Array;
      
      private var _prompt:String;
      
      private var _result:String;
      
      public function FightJustPlayingData(revealConstants:RevealConstants, primaryPlayers:Array, votingPlayers:Array, tagsPerPlayer:PerPlayerContainer, rolesInvolved:Array, tags:Array, prompt:String)
      {
         super();
         this._revealConstants = revealConstants;
         this._primaryPlayers = primaryPlayers;
         this._votingPlayers = votingPlayers;
         this._tagsPerPlayer = tagsPerPlayer;
         this._rolesInvolved = rolesInvolved;
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
         return this._rolesInvolved;
      }
      
      public function get primaryPlayers() : Array
      {
         return this._primaryPlayers;
      }
      
      public function get votingPlayers() : Array
      {
         return this._votingPlayers;
      }
      
      public function get tagsPerPlayer() : PerPlayerContainer
      {
         return this._tagsPerPlayer;
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
