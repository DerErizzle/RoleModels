package jackboxgames.entityinteraction.postgame
{
   import jackboxgames.model.JBGPlayer;
   
   public interface IPostGameDataDelegate
   {
      function getPostGameStatus() : String;
      
      function finalizePlayerEntity(param1:JBGPlayer, param2:Object) : void;
      
      function finalizeSharedEntity(param1:Object) : void;
   }
}

