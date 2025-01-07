package jackboxgames.entityinteraction.commonbehaviors
{
   import jackboxgames.ecast.WSClient;
   import jackboxgames.entityinteraction.EntityUpdateRequest;
   import jackboxgames.entityinteraction.IEntity;
   import jackboxgames.entityinteraction.IEntityInteractionBehavior;
   import jackboxgames.entityinteraction.PlayerEntities;
   import jackboxgames.entityinteraction.SharedEntities;
   import jackboxgames.entityinteraction.entities.TextEntity;
   import jackboxgames.model.JBGPlayer;
   import jackboxgames.settings.SettingsConstants;
   import jackboxgames.settings.SettingsManager;
   import jackboxgames.utils.TextUtils;
   
   public class EnterText implements IEntityInteractionBehavior
   {
      private var _dataDelegate:IEnterTextDataDelegate;
      
      private var _eventDelegate:IEnterTextEventDelegate;
      
      private var _compiler:IEnterTextCompiler;
      
      private var _ws:WSClient;
      
      public function EnterText(dataDelegate:IEnterTextDataDelegate, eventDelegate:IEnterTextEventDelegate, compiler:IEnterTextCompiler)
      {
         super();
         this._dataDelegate = dataDelegate;
         this._eventDelegate = eventDelegate;
         this._compiler = compiler;
      }
      
      public function setup(ws:WSClient, players:Array) : void
      {
         this._ws = ws;
         this._compiler.setup(players);
         this._eventDelegate.setupEnterText();
      }
      
      public function shutdown(finishedOnPlayerInput:Boolean) : void
      {
         this._eventDelegate.onEnterTextDone(this._compiler.payload,finishedOnPlayerInput);
      }
      
      public function generateSharedEntities() : SharedEntities
      {
         return new SharedEntities();
      }
      
      public function getSharedEntityValue(entityKey:String, entity:IEntity) : *
      {
         return undefined;
      }
      
      public function generatePlayerEntities(p:JBGPlayer) : PlayerEntities
      {
         var containers:PlayerEntities = new PlayerEntities(p);
         var filterSetting:String = !!this._dataDelegate.filterContent ? SettingsManager.instance.getValue(SettingsConstants.SETTING_PLAYER_CONTENT_FILTERING).val : SettingsConstants.PLAYER_CONTENT_FILTERING_OFF;
         containers.withInput("main",new TextEntity(this._ws,"entertext:" + p.sessionId.val,"",filterSetting,["rw id:" + p.sessionId.val]));
         return containers;
      }
      
      public function getPlayerEntityValue(p:JBGPlayer, entityKey:String, entity:IEntity) : *
      {
         var isDone:Boolean = false;
         if(entityKey == "main")
         {
            isDone = this._compiler.playerIsDone(p);
            if(isDone)
            {
               return {
                  "kind":"waiting",
                  "message":this._dataDelegate.getEnterTextDoneText(p)
               };
            }
            return {
               "kind":"singleTextEntry",
               "category":this._dataDelegate.getEnterTextCategory(p),
               "prompt":this._dataDelegate.getEnterTextPrompt(p),
               "isMultiline":false,
               "placeholder":this._dataDelegate.getEnterTextPlaceholder(p),
               "isDisabled":false,
               "submitText":this._dataDelegate.getEnterTextSubmitText(p),
               "responseKey":"entertext:" + p.sessionId.val,
               "maxLength":this._dataDelegate.maxLength
            };
         }
         return null;
      }
      
      public function onPlayerInputEntityUpdated(p:JBGPlayer, pe:PlayerEntities, se:SharedEntities, key:String, e:IEntity) : EntityUpdateRequest
      {
         var mainInput:TextEntity = null;
         if(key == "main")
         {
            mainInput = TextEntity(e);
            return this._onEntry(p,mainInput.getValue());
         }
         return null;
      }
      
      private function _onEntry(p:JBGPlayer, entry:String) : EntityUpdateRequest
      {
         if(entry.length <= 0)
         {
            return null;
         }
         var updateRequest:EntityUpdateRequest = new EntityUpdateRequest();
         entry = TextUtils.htmlEscapedTruncate(entry,this._dataDelegate.maxLength);
         if(!this._compiler.canAdd(p,entry))
         {
            return updateRequest.withPlayerMainEntity(p);
         }
         this._eventDelegate.onPlayerEnteredText(p,entry);
         this._compiler.add(p,entry);
         return updateRequest.withPlayerMainEntity(p);
      }
      
      public function playerIsDone(p:JBGPlayer) : Boolean
      {
         return this._compiler.playerIsDone(p);
      }
   }
}

