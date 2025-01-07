package jackboxgames.entityinteraction.commonbehaviors
{
   import jackboxgames.ecast.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.entityinteraction.entities.*;
   import jackboxgames.model.*;
   import jackboxgames.utils.*;
   
   public class Choose implements IEntityInteractionBehavior
   {
      private var _dataDelegate:IChooseDataDelegate;
      
      private var _eventDelegate:IChooseEventDelegate;
      
      private var _compiler:IChooseCompiler;
      
      private var _ws:WSClient;
      
      private var _playersThatHaveErrored:Array;
      
      public function Choose(dataDelegate:IChooseDataDelegate, eventDelegate:IChooseEventDelegate, compiler:IChooseCompiler)
      {
         super();
         this._dataDelegate = dataDelegate;
         this._eventDelegate = eventDelegate;
         this._compiler = compiler;
      }
      
      public function setup(ws:WSClient, players:Array) : void
      {
         this._ws = ws;
         this._playersThatHaveErrored = [];
         this._compiler.setupChooseCompiler(players);
         this._eventDelegate.setupChoose();
      }
      
      public function shutdown(finishedOnPlayerInput:Boolean) : void
      {
         this._eventDelegate.onChooseDone(this._compiler.payload,finishedOnPlayerInput);
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
         return new PlayerEntities(p).withInput("main",new ObjectEntity(this._ws,"choose:" + p.sessionId.val,{},["rw id:" + p.sessionId.val]));
      }
      
      public function getPlayerEntityValue(p:JBGPlayer, entityKey:String, entity:IEntity) : *
      {
         if(entityKey == "main")
         {
            if(this._compiler.playerIsDone(p))
            {
               return {"kind":"waiting"};
            }
            return {
               "kind":"choices",
               "category":this._dataDelegate.getChooseCategory(p),
               "prompt":this._dataDelegate.getChoosePrompt(p),
               "choices":this._dataDelegate.getChooseChoices(p).map(function(text:String, ... args):Object
               {
                  return {"text":text};
               }),
               "responseKey":"choose:" + p.sessionId.val
            };
         }
         return null;
      }
      
      public function onPlayerInputEntityUpdated(p:JBGPlayer, pe:PlayerEntities, se:SharedEntities, key:String, e:IEntity) : EntityUpdateRequest
      {
         var mainInput:ObjectEntity = null;
         if(key == "main")
         {
            mainInput = ObjectEntity(e);
            return this._onPlayerChoice(p,mainInput.getValue());
         }
         return null;
      }
      
      private function _onPlayerChoice(p:JBGPlayer, choice:Object) : EntityUpdateRequest
      {
         if(choice.action != "choice")
         {
            return null;
         }
         if(!choice.hasOwnProperty("value") || isNaN(choice.value))
         {
            return null;
         }
         var choiceIndex:int = int(choice.value);
         if(choiceIndex < 0 || choiceIndex >= this._dataDelegate.getChooseChoices(p).length)
         {
            return null;
         }
         if(!this._compiler.canAdd(p,choiceIndex))
         {
            ArrayUtil.deduplicatedPush(this._playersThatHaveErrored,p);
            return new EntityUpdateRequest().withPlayerMainEntity(p);
         }
         this._eventDelegate.onPlayerChose(p,choiceIndex);
         this._compiler.add(p,choiceIndex);
         return new EntityUpdateRequest().withPlayerMainEntity(p);
      }
      
      public function playerIsDone(p:JBGPlayer) : Boolean
      {
         return this._compiler.playerIsDone(p);
      }
   }
}

