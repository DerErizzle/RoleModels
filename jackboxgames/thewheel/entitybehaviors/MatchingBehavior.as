package jackboxgames.thewheel.entitybehaviors
{
   import jackboxgames.algorithm.*;
   import jackboxgames.ecast.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.entityinteraction.entities.*;
   import jackboxgames.model.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.utils.*;
   
   public class MatchingBehavior implements IEntityInteractionBehavior
   {
      private var _delegate:IMatchingBehaviorDelegate;
      
      private var _ws:WSClient;
      
      public function MatchingBehavior(delegate:IMatchingBehaviorDelegate)
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
         return new PlayerEntities(p).withInput("main",new ObjectEntity(this._ws,"matching:" + p.sessionId.val,{},["rw id:" + p.sessionId.val]));
      }
      
      public function onPlayerInputEntityUpdated(p:JBGPlayer, pe:PlayerEntities, se:SharedEntities, key:String, e:IEntity) : EntityUpdateRequest
      {
         var mainInput:ObjectEntity = null;
         var indexA:Number = NaN;
         var indexB:Number = NaN;
         if(key == "main" && !this._delegate.playerIsFrozen(p))
         {
            mainInput = ObjectEntity(e);
            if(Boolean(mainInput.getValue().hasOwnProperty("answer")) && mainInput.getValue().answer is Array && mainInput.getValue().answer.length == 2)
            {
               indexA = Number(mainInput.getValue().answer[0]);
               indexB = Number(mainInput.getValue().answer[1]);
               if(isNaN(indexA) || isNaN(indexB))
               {
                  return null;
               }
               this._delegate.playerTriedToMatch(Player(p),indexA,indexB);
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
         var e:Object = null;
         if(entityKey == "main")
         {
            if(this.playerIsDone(p))
            {
               return {"kind":"waiting"};
            }
            e = {
               "kind":"matching",
               "prompt":this._delegate.content.prompt,
               "headers":this._delegate.content.header.asArray(),
               "items":this._delegate.getControllerItemsForPlayer(Player(p)),
               "freezeMs":0,
               "responseKey":"matching:" + p.sessionId.val
            };
            if(this._delegate.playerIsFrozen(p))
            {
               e.freezeMs = GameState.instance.jsonData.gameConfig.matchingFreezeTime.inMs;
            }
            return e;
         }
         return null;
      }
      
      public function playerIsDone(p:JBGPlayer) : Boolean
      {
         return this._delegate.playerHasMatchedAll(Player(p));
      }
   }
}

