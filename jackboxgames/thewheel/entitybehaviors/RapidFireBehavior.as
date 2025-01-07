package jackboxgames.thewheel.entitybehaviors
{
   import jackboxgames.algorithm.*;
   import jackboxgames.ecast.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.entityinteraction.entities.*;
   import jackboxgames.model.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.utils.*;
   
   public class RapidFireBehavior implements IEntityInteractionBehavior
   {
      private var _delegate:IRapidFireBehaviorDelegate;
      
      private var _ws:WSClient;
      
      public function RapidFireBehavior(delegate:IRapidFireBehaviorDelegate)
      {
         super();
         this._delegate = delegate;
      }
      
      public function setup(ws:WSClient, players:Array) : void
      {
         this._ws = ws;
      }
      
      public function shutdown(finishedOnPlayerInput:Boolean) : void
      {
         if(finishedOnPlayerInput)
         {
            TSInputHandler.instance.input("Done");
         }
         this._ws = null;
      }
      
      public function generateSharedEntities() : SharedEntities
      {
         return new SharedEntities();
      }
      
      public function generatePlayerEntities(p:JBGPlayer) : PlayerEntities
      {
         return new PlayerEntities(p).withInput("main",new ObjectEntity(this._ws,"rapidfire:" + p.sessionId.val,{},["rw id:" + p.sessionId.val]));
      }
      
      public function onPlayerInputEntityUpdated(p:JBGPlayer, pe:PlayerEntities, se:SharedEntities, key:String, e:IEntity) : EntityUpdateRequest
      {
         var mainInput:ObjectEntity = null;
         var choiceIndex:int = 0;
         if(key == "main" && !this._delegate.playerIsFrozen(p))
         {
            mainInput = ObjectEntity(e);
            if(mainInput.getValue().hasOwnProperty("answer"))
            {
               choiceIndex = int(mainInput.getValue().answer);
               this._delegate.onPlayerAnswered(Player(p),choiceIndex);
               return new EntityUpdateRequest().withPlayerMainEntity(p);
            }
         }
         return null;
      }
      
      public function getSharedEntityValue(entityKey:String, entity:IEntity) : *
      {
         return undefined;
      }
      
      public function getPlayerEntityValue(p:JBGPlayer, entityKey:String, entity:IEntity) : *
      {
         if(entityKey == "main")
         {
            if(this._delegate.playerIsFrozen(p))
            {
               return {
                  "kind":"tappingRapid",
                  "prompt":this._delegate.content.prompt,
                  "unit":this._delegate.content.unit,
                  "choices":[],
                  "freezeMs":GameState.instance.jsonData.gameConfig.rapidFireFreezeTime.inMs,
                  "responseKey":"rapidfire:" + p.sessionId.val
               };
            }
            return {
               "kind":"tappingRapid",
               "prompt":this._delegate.content.prompt,
               "unit":this._delegate.content.unit,
               "choices":this._delegate.getChoicesForPlayer(Player(p)),
               "freezeMs":0,
               "responseKey":"rapidfire:" + p.sessionId.val
            };
         }
         return null;
      }
      
      public function playerIsDone(p:JBGPlayer) : Boolean
      {
         return false;
      }
   }
}

