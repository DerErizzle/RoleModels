package jackboxgames.thewheel.audience
{
   import jackboxgames.algorithm.Promise;
   import jackboxgames.entityinteraction.IEntity;
   import jackboxgames.model.JBGGameState;
   import jackboxgames.settings.SettingsConstants;
   import jackboxgames.settings.SettingsManager;
   import jackboxgames.utils.PromiseUtil;
   
   public class AudienceInteractionHandler
   {
      private var _behavior:IAudienceInteractionBehavior;
      
      private var _gs:JBGGameState;
      
      private var _isActive:Boolean;
      
      private var _entities:AudienceEntities;
      
      public function AudienceInteractionHandler(behavior:IAudienceInteractionBehavior, gs:JBGGameState)
      {
         super();
         this._behavior = behavior;
         this._gs = gs;
         this._isActive = false;
      }
      
      public function reset() : Promise
      {
         if(this._isActive)
         {
            this._isActive = false;
            return this._entities.disposeEntities();
         }
         return PromiseUtil.RESOLVED();
      }
      
      public function get isActive() : Boolean
      {
         return this._isActive;
      }
      
      public function setIsActive(val:Boolean) : Promise
      {
         var entitiesFromInteraction:AudienceEntities = null;
         if(this._isActive == val)
         {
            return PromiseUtil.RESOLVED(true);
         }
         this._isActive = val;
         if(this._isActive)
         {
            if(!SettingsManager.instance.getValue(SettingsConstants.SETTING_AUDIENCE_ON).val)
            {
               return PromiseUtil.RESOLVED();
            }
            this._behavior.setup(this._gs.client,this._gs);
            this._entities = this._behavior.generateEntities();
            return this._entities.createEntities().then(function(... args):void
            {
               _entities.addEventListener(AudienceEntityUpdatedEvent.EVENT_UPDATED,_onEntityUpdated);
               updateEntitiesFromRequest(new AudienceEntityUpdateRequest().withGameToAudienceMainEntity());
            });
         }
         this._behavior.shutdown(this._entities);
         this._entities.removeEventListener(AudienceEntityUpdatedEvent.EVENT_UPDATED,this._onEntityUpdated);
         entitiesFromInteraction = this._entities;
         this._entities = null;
         return entitiesFromInteraction.disposeEntities().then(function(... args):void
         {
            _gs.mainAudienceEntity.setValue({"kind":"waiting"});
         },function(... args):void
         {
            _gs.mainAudienceEntity.setValue({"kind":"waiting"});
         });
      }
      
      public function updateEntitiesFromRequest(req:AudienceEntityUpdateRequest) : Promise
      {
         var updatePromises:Array = null;
         updatePromises = [];
         req.gameToAudienceKeysToUpdate.forEach(function(key:String, ... args):void
         {
            var e:IEntity = _entities.getGameToAudienceEntity(key);
            if(Boolean(e))
            {
               updatePromises.push(e.update(_behavior.getGameToAudienceEntityValue(key,e)));
            }
         });
         return PromiseUtil.ALL(updatePromises);
      }
      
      private function _onEntityUpdated(evt:AudienceEntityUpdatedEvent) : void
      {
         var res:AudienceEntityUpdateRequest = this._behavior.onAudienceToGameEntityUpdated(AudienceEntities(evt.target),evt.key,evt.entity);
         if(!res)
         {
            return;
         }
         this.updateEntitiesFromRequest(res);
      }
   }
}

