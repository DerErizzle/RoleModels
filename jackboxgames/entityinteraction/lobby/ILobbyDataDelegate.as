package jackboxgames.entityinteraction.lobby
{
   import jackboxgames.model.JBGPlayer;
   
   public interface ILobbyDataDelegate
   {
      function getLobbyStatus() : String;
      
      function finalizePlayerEntity(param1:JBGPlayer, param2:Object) : void;
      
      function finalizeSharedEntity(param1:Object) : void;
   }
}

