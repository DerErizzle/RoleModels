package jackboxgames.rolemodels.data
{
   public interface IRevealData
   {
       
      
      function get revealConstants() : RevealConstants;
      
      function get roleData() : RoleData;
      
      function get rolesInvolved() : Array;
      
      function get primaryPlayers() : Array;
   }
}
