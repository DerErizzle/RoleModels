package jackboxgames.entityinteraction
{
   import jackboxgames.algorithm.*;
   import jackboxgames.utils.*;
   
   public class SharedEntities extends PausableEventDispatcher
   {
      private var _entities:Object;
      
      public function SharedEntities()
      {
         super();
         this._entities = {};
      }
      
      public function withEntity(key:String, e:IEntity) : SharedEntities
      {
         this._entities[key] = new EntityMetadata(key,e);
         return this;
      }
      
      public function createEntities() : Promise
      {
         var entitiesToCreate:Array = ObjectUtil.getValues(this._entities);
         var promises:Array = entitiesToCreate.map(function(e:EntityMetadata, ... args):Promise
         {
            return e.entity.create();
         });
         return PromiseUtil.ALL(promises);
      }
      
      public function disposeEntities() : Promise
      {
         var entitiesToDispose:Array = ObjectUtil.getValues(this._entities);
         var promises:Array = entitiesToDispose.map(function(e:EntityMetadata, ... args):Promise
         {
            return e.entity.dispose();
         });
         return PromiseUtil.ALL(promises);
      }
      
      public function getEntityByKey(key:String) : IEntity
      {
         if(!this._entities.hasOwnProperty(key))
         {
            return null;
         }
         return EntityMetadata(this._entities[key]).entity;
      }
   }
}

class EntityMetadata
{
   private var _key:String;
   
   private var _entity:IEntity;
   
   public function EntityMetadata(key:String, entity:IEntity)
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

