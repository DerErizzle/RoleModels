package jackboxgames.thewheel.audience
{
   import jackboxgames.algorithm.Promise;
   import jackboxgames.entityinteraction.EntityUpdatedEvent;
   import jackboxgames.entityinteraction.IEntity;
   import jackboxgames.model.JBGGameState;
   import jackboxgames.utils.ArrayUtil;
   import jackboxgames.utils.PausableEventDispatcher;
   import jackboxgames.utils.PromiseUtil;
   
   public class AudienceEntities extends PausableEventDispatcher
   {
      private var _gs:JBGGameState;
      
      private var _gameToAudienceEntities:Array;
      
      private var _audienceToGameEntities:Array;
      
      public function AudienceEntities(gs:JBGGameState)
      {
         super();
         this._gs = gs;
         this._gameToAudienceEntities = [];
         this._audienceToGameEntities = [];
      }
      
      public function withGameToAudience(key:String, e:IEntity) : AudienceEntities
      {
         this._gameToAudienceEntities.push(new AudienceEntityMetadata(key,e));
         return this;
      }
      
      public function withAudienceToGame(key:String, e:IEntity) : AudienceEntities
      {
         e.addEventListener(EntityUpdatedEvent.EVENT_UPDATED,this._onAudienceToGameEntityUpdated);
         this._audienceToGameEntities.push(new AudienceEntityMetadata(key,e));
         return this;
      }
      
      public function createEntities() : Promise
      {
         return PromiseUtil.ALL(this._getAllEntities().map(function(e:AudienceEntityMetadata, ... args):Promise
         {
            return e.entity.create();
         }));
      }
      
      public function disposeEntities() : Promise
      {
         return PromiseUtil.ALL(this._getAllEntities().map(function(e:AudienceEntityMetadata, ... args):Promise
         {
            return e.entity.dispose();
         }));
      }
      
      public function getGameToAudienceEntity(key:String) : IEntity
      {
         var em:AudienceEntityMetadata = null;
         if(key == "main")
         {
            return this._gs.mainAudienceEntity;
         }
         for each(em in this._gameToAudienceEntities)
         {
            if(em.key == key)
            {
               return em.entity;
            }
         }
         return null;
      }
      
      public function getAudienceToGameEntity(key:String) : IEntity
      {
         var em:AudienceEntityMetadata = null;
         for each(em in this._audienceToGameEntities)
         {
            if(em.key == key)
            {
               return em.entity;
            }
         }
         return null;
      }
      
      private function _getAllEntities() : Array
      {
         return ArrayUtil.concat(this._gameToAudienceEntities,this._audienceToGameEntities);
      }
      
      private function _getAudienceToGameEntityMetadataFromEntity(e:IEntity) : AudienceEntityMetadata
      {
         return ArrayUtil.find(this._audienceToGameEntities,function(em:AudienceEntityMetadata, ... args):Boolean
         {
            return em.entity == e;
         });
      }
      
      private function _onAudienceToGameEntityUpdated(evt:EntityUpdatedEvent) : void
      {
         var entity:IEntity = IEntity(evt.target);
         var metadata:AudienceEntityMetadata = this._getAudienceToGameEntityMetadataFromEntity(entity);
         dispatchEvent(new AudienceEntityUpdatedEvent(metadata.key,entity,evt.oldValue,evt.newValue));
      }
   }
}

import jackboxgames.entityinteraction.IEntity;
import jackboxgames.utils.PausableEventDispatcher;

class AudienceEntityMetadata extends PausableEventDispatcher
{
   private var _key:String;
   
   private var _entity:IEntity;
   
   public function AudienceEntityMetadata(key:String, entity:IEntity)
   {
      super();
      this._key = key;
      this._entity = entity;
   }
   
   public function get key() : String
   {
      return this._key;
   }
   
   public function get entity() : IEntity
   {
      return this._entity;
   }
}

import flash.events.EventDispatcher;
import jackboxgames.utils.PausableEventDispatcher;

