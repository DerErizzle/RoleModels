package jackboxgames.entityinteraction.lobby
{
   import jackboxgames.entityinteraction.EntityUpdateRequest;
   import jackboxgames.model.JBGPlayer;
   
   public interface ILobbyEventDelegate
   {
      function onAction(param1:JBGPlayer, param2:String, param3:EntityUpdateRequest) : void;
      
      function onLobbyDone() : void;
   }
}

