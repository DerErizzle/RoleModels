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
   
   public class NumberTargetBehavior implements IEntityInteractionBehavior
   {
      private var _delegate:INumberTargetBehaviorDelegate;
      
      private var _ws:WSClient;
      
      private var _isSubmitted:PerPlayerContainer;
      
      public function NumberTargetBehavior(delegate:INumberTargetBehaviorDelegate)
      {
         super();
         this._delegate = delegate;
      }
      
      public function setup(ws:WSClient, players:Array) : void
      {
         this._ws = ws;
         this._isSubmitted = PerPlayerContainerUtil.MAP(players,function(p:Player, ... args):Boolean
         {
            return false;
         });
      }
      
      public function shutdown(finishedOnPlayerInput:Boolean) : void
      {
         if(finishedOnPlayerInput)
         {
            TSInputHandler.instance.input("Done");
         }
         this._ws = null;
         this._isSubmitted = null;
      }
      
      public function generateSharedEntities() : SharedEntities
      {
         return new SharedEntities();
      }
      
      public function generatePlayerEntities(p:JBGPlayer) : PlayerEntities
      {
         return new PlayerEntities(p).withInput("main",new ObjectEntity(this._ws,"numeric:" + p.sessionId.val,{},["rw id:" + p.sessionId.val]));
      }
      
      public function onPlayerInputEntityUpdated(p:JBGPlayer, pe:PlayerEntities, se:SharedEntities, key:String, e:IEntity) : EntityUpdateRequest
      {
         var mainInput:ObjectEntity = null;
         var guess:int = 0;
         if(key == "main")
         {
            if(this._isSubmitted.getDataForPlayer(p))
            {
               return new EntityUpdateRequest();
            }
            mainInput = ObjectEntity(e);
            if(mainInput.getValue().hasOwnProperty("answer"))
            {
               guess = int(mainInput.getValue().answer);
               this._delegate.onPlayerGuessChanged(Player(p),guess);
               return new EntityUpdateRequest().withPlayerMainEntity(p);
            }
            if(mainInput.getValue().action == "submit")
            {
               this._isSubmitted.setDataForPlayer(p,true);
               this._delegate.onPlayerSubmittedGuess(Player(p));
               return new EntityUpdateRequest().withPlayerMainEntity(p);
            }
         }
         return null;
      }
      
      public function playerIsDone(p:JBGPlayer) : Boolean
      {
         return this._isSubmitted.getDataForPlayer(p);
      }
      
      public function getSharedEntityValue(entityKey:String, entity:IEntity) : *
      {
         return undefined;
      }
      
      public function getPlayerEntityValue(p:JBGPlayer, entityKey:String, entity:IEntity) : *
      {
         if(entityKey == "main")
         {
            if(this.playerIsDone(p))
            {
               return {"kind":"waiting"};
            }
            return {
               "kind":"numeric",
               "prompt":this._delegate.content.prompt,
               "unit":this._delegate.content.unit,
               "responseKey":"numeric:" + p.sessionId.val
            };
         }
         return null;
      }
   }
}

