package jackboxgames.rolemodels.data.analysis
{
   import jackboxgames.rolemodels.Player;
   
   public class PlayerWithPowerfulRoles
   {
       
      
      private var _p:Player;
      
      private var _powerfulRoles:Array;
      
      public function PlayerWithPowerfulRoles(p:Player, powerfulRoles:Array)
      {
         super();
         this._p = p;
         this._powerfulRoles = powerfulRoles;
      }
      
      public function get p() : Player
      {
         return this._p;
      }
      
      public function get powerfulRoles() : Array
      {
         return this._powerfulRoles;
      }
   }
}
