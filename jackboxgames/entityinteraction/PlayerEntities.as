package jackboxgames.entityinteraction
{
   import jackboxgames.algorithm.*;
   import jackboxgames.model.*;
   import jackboxgames.utils.*;
   
   public class PlayerEntities extends PausableEventDispatcher
   {
      private var _player:JBGPlayer;
      
      private var _inputs:Object;
      
      private var _outputs:Object;
      
      private var _updateMainOnCreate:Boolean;
      
      public function PlayerEntities(p:JBGPlayer, updateMainOnCreate:Boolean = true)
      {
         super();
         this._player = p;
         this._inputs = {};
         this._outputs = {};
         this._updateMainOnCreate = updateMainOnCreate;
      }
      
      public function get player() : JBGPlayer
      {
         return this._player;
      }
      
      public function get updateMainOnCreate() : Boolean
      {
         return this._updateMainOnCreate;
      }
      
      public function withInput(key:String, e:IEntity) : PlayerEntities
      {
         e.addEventListener(EntityUpdatedEvent.EVENT_UPDATED,this._onInputContainerUpdated);
         this._inputs[key] = new EntityMetadata(key,e);
         return this;
      }
      
      public function withOutput(key:String, e:IEntity) : PlayerEntities
      {
         this._outputs[key] = new EntityMetadata(key,e);
         return this;
      }
      
      public function createEntities() : Promise
      {
         var entitiesToCreate:Array = this.allInputs.concat(this.allOutputs);
         var promises:Array = entitiesToCreate.map(function(e:EntityMetadata, ... args):Promise
         {
            return e.entity.create();
         });
         return PromiseUtil.ALL(promises);
      }
      
      public function disposeEntities() : Promise
      {
         var entitiesToDispose:Array = this.allInputs.concat(this.allOutputs);
         var promises:Array = entitiesToDispose.map(function(e:EntityMetadata, ... args):Promise
         {
            return e.entity.dispose();
         });
         return PromiseUtil.ALL(promises);
      }
      
      public function get allInputs() : Array
      {
         return ObjectUtil.getValues(this._inputs);
      }
      
      public function get allOutputs() : Array
      {
         return ObjectUtil.getValues(this._outputs);
      }
      
      public function getInput(key:String) : IEntity
      {
         if(!this._inputs.hasOwnProperty(key))
         {
            return null;
         }
         return EntityMetadata(this._inputs[key]).entity;
      }
      
      public function getEntityByKey(key:String) : IEntity
      {
         if(key == "main")
         {
            return this._player.mainEntity;
         }
         if(!this._outputs.hasOwnProperty(key))
         {
            return null;
         }
         return EntityMetadata(this._outputs[key]).entity;
      }
      
      private function _getInputEntityMetadataFromEntity(e:IEntity) : EntityMetadata
      {
         var key:String = null;
         for(key in this._inputs)
         {
            if(EntityMetadata(this._inputs[key]).entity == e)
            {
               return this._inputs[key];
            }
         }
         return null;
      }
      
      private function _onInputContainerUpdated(evt:EntityUpdatedEvent) : void
      {
         var entity:IEntity = IEntity(evt.target);
         var metadata:EntityMetadata = this._getInputEntityMetadataFromEntity(entity);
         dispatchEvent(new PlayerEntityUpdatedEvent(metadata.key,entity,evt.oldValue,evt.newValue));
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

