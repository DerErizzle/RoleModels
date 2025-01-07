package jackboxgames.entityinteraction
{
   import jackboxgames.ecast.WSClient;
   import jackboxgames.model.JBGPlayer;
   
   public interface IEntityInteractionBehavior
   {
      function setup(param1:WSClient, param2:Array) : void;
      
      function shutdown(param1:Boolean) : void;
      
      function generateSharedEntities() : SharedEntities;
      
      function generatePlayerEntities(param1:JBGPlayer) : PlayerEntities;
      
      function onPlayerInputEntityUpdated(param1:JBGPlayer, param2:PlayerEntities, param3:SharedEntities, param4:String, param5:IEntity) : EntityUpdateRequest;
      
      function getSharedEntityValue(param1:String, param2:IEntity) : *;
      
      function getPlayerEntityValue(param1:JBGPlayer, param2:String, param3:IEntity) : *;
      
      function playerIsDone(param1:JBGPlayer) : Boolean;
   }
}

