package jackboxgames.entityinteraction.postgame
{
   import jackboxgames.ecast.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.entityinteraction.entities.*;
   import jackboxgames.model.*;
   import jackboxgames.settings.*;
   import jackboxgames.utils.*;
   
   public class PostGameInteraction extends PausableEventDispatcher implements IEntityInteractionBehavior
   {
      private var _ws:WSClient;
      
      private var _gs:JBGGameState;
      
      private var _dataDelegate:IPostGameDataDelegate;
      
      private var _eventDelegate:IPostGameEventDelegate;
      
      public function PostGameInteraction(gs:JBGGameState, dataDelegate:IPostGameDataDelegate, eventDelegate:IPostGameEventDelegate)
      {
         super();
         this._gs = gs;
         this._dataDelegate = dataDelegate;
         this._eventDelegate = eventDelegate;
      }
      
      public function setup(ws:WSClient, players:Array) : void
      {
         this._ws = ws;
      }
      
      public function shutdown(finishedOnPlayerInput:Boolean) : void
      {
         this._eventDelegate.onPostGameDone();
      }
      
      public function generatePlayerEntities(p:JBGPlayer) : PlayerEntities
      {
         return new PlayerEntities(p).withInput("main",new ObjectEntity(this._ws,"postGame:" + p.sessionId.val,{},["rw id:" + p.sessionId.val]));
      }
      
      public function generateSharedEntities() : SharedEntities
      {
         return new SharedEntities();
      }
      
      public function getSharedEntityValue(entityKey:String, entity:IEntity) : *
      {
         var entityData:Object = {};
         this._dataDelegate.finalizeSharedEntity(entityData);
         return entityData;
      }
      
      public function getPlayerEntityValue(p:JBGPlayer, entityKey:String, entity:IEntity) : *
      {
         var entityData:Object = {};
         if(entityKey == "main")
         {
            entityData.kind = "postGame";
            entityData.hasControls = p.isVIP && !SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val;
            entityData.responseKey = "postGame:" + p.sessionId.val;
            entityData.status = this._dataDelegate.getPostGameStatus();
            entityData.vipName = this._gs.VIP.name.val;
            entityData.gamepadStart = SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val;
            this._dataDelegate.finalizePlayerEntity(p,entityData);
         }
         return entityData;
      }
      
      public function onPlayerInputEntityUpdated(p:JBGPlayer, pe:PlayerEntities, se:SharedEntities, key:String, e:IEntity) : EntityUpdateRequest
      {
         var mainInput:ObjectEntity = null;
         if(key == "main")
         {
            mainInput = ObjectEntity(e);
            if(mainInput.getValue().hasOwnProperty("action"))
            {
               return this._onAction(p,mainInput.getValue().action);
            }
         }
         return null;
      }
      
      private function _onAction(p:JBGPlayer, action:String) : EntityUpdateRequest
      {
         var updateRequest:EntityUpdateRequest = new EntityUpdateRequest();
         this._eventDelegate.onAction(p,action,updateRequest);
         return updateRequest;
      }
      
      public function playerIsDone(p:JBGPlayer) : Boolean
      {
         return false;
      }
   }
}

