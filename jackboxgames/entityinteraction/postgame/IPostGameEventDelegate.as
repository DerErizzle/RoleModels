package jackboxgames.entityinteraction.postgame
{
   import jackboxgames.entityinteraction.EntityUpdateRequest;
   import jackboxgames.model.JBGPlayer;
   
   public interface IPostGameEventDelegate
   {
      function onAction(param1:JBGPlayer, param2:String, param3:EntityUpdateRequest) : void;
      
      function onPostGameDone() : void;
   }
}

