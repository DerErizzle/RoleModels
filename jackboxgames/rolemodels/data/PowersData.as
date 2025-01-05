package jackboxgames.rolemodels.data
{
   import jackboxgames.rolemodels.Player;
   
   public class PowersData implements IRevealData
   {
       
      
      private var _revealConstants:RevealConstants;
      
      private var _roleData:RoleData;
      
      private var _powerfulTag:TagData;
      
      private var _powerfulPlayer:Player;
      
      private var _secondaryPlayers:Array;
      
      private var _power:String;
      
      public function PowersData(revealConstants:RevealConstants, roleData:RoleData, powerfulTag:TagData, powerfulPlayer:Player, secondaryPlayers:Array, power:String)
      {
         super();
         this._revealConstants = revealConstants;
         this._roleData = roleData;
         this._powerfulTag = powerfulTag;
         this._powerfulPlayer = powerfulPlayer;
         this._secondaryPlayers = secondaryPlayers;
         this._power = power;
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
      
      public function get powerfulTag() : TagData
      {
         return this._powerfulTag;
      }
      
      public function get powerfulPlayer() : Player
      {
         return this._powerfulPlayer;
      }
      
      public function get primaryPlayers() : Array
      {
         return [this._powerfulPlayer].concat(this._secondaryPlayers);
      }
      
      public function get secondaryPlayers() : Array
      {
         return this._secondaryPlayers;
      }
      
      public function get power() : String
      {
         return this._power;
      }
   }
}
