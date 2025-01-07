package jackboxgames.thewheel.audience
{
   import jackboxgames.ecast.WSClient;
   import jackboxgames.entityinteraction.IEntity;
   import jackboxgames.model.JBGGameState;
   
   public interface IAudienceInteractionBehavior
   {
      function setup(param1:WSClient, param2:JBGGameState) : void;
      
      function shutdown(param1:AudienceEntities) : void;
      
      function generateEntities() : AudienceEntities;
      
      function onAudienceToGameEntityUpdated(param1:AudienceEntities, param2:String, param3:IEntity) : AudienceEntityUpdateRequest;
      
      function getGameToAudienceEntityValue(param1:String, param2:IEntity) : *;
   }
}

