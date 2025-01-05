package jackboxgames.rolemodels.data
{
   public class TriviaData implements IRevealData
   {
       
      
      private var _revealConstants:RevealConstants;
      
      private var _roleData:RoleData;
      
      private var _primaryPlayers:Array;
      
      private var _prompt:String;
      
      private var _answers:Array;
      
      private var _idx:int;
      
      public function TriviaData(revealConstants:RevealConstants, roleData:RoleData, primaryPlayers:Array, prompt:String, answers:Array, idx:int)
      {
         super();
         this._revealConstants = revealConstants;
         this._roleData = roleData;
         this._primaryPlayers = primaryPlayers;
         this._prompt = prompt;
         this._answers = answers;
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
         return [this._roleData];
      }
      
      public function get primaryPlayers() : Array
      {
         return this._primaryPlayers;
      }
      
      public function get prompt() : String
      {
         return this._prompt;
      }
      
      public function get answers() : Array
      {
         return this._answers;
      }
      
      public function get idx() : int
      {
         return this._idx;
      }
   }
}
