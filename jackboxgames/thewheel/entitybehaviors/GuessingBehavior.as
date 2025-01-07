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
   
   public class GuessingBehavior implements IEntityInteractionBehavior
   {
      private var _delegate:IGuessingBehaviorDelegate;
      
      private var _ws:WSClient;
      
      public function GuessingBehavior(delegate:IGuessingBehaviorDelegate)
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
         return new PlayerEntities(p).withInput("main",new ObjectEntity(this._ws,"guessing:" + p.sessionId.val,{},["rw id:" + p.sessionId.val]));
      }
      
      public function onPlayerInputEntityUpdated(p:JBGPlayer, pe:PlayerEntities, se:SharedEntities, key:String, e:IEntity) : EntityUpdateRequest
      {
         var mainInput:ObjectEntity = null;
         var guess:String = null;
         if(key == "main")
         {
            mainInput = ObjectEntity(e);
            if(mainInput.getValue().hasOwnProperty("answer"))
            {
               guess = mainInput.getValue().answer;
               this._delegate.onPlayerGuessed(Player(p),guess);
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
            if(this.playerIsDone(p))
            {
               return {
                  "kind":"waiting",
                  "category":"correct",
                  "answer":this._delegate.content.answer
               };
            }
            return {
               "kind":"guessing",
               "prompt":LocalizationUtil.getPrintfText("GUESSING_PROMPT"),
               "responseKey":"guessing:" + p.sessionId.val,
               "clues":this._delegate.revealedClues
            };
         }
         return null;
      }
      
      public function playerIsDone(p:JBGPlayer) : Boolean
      {
         return this._delegate.hasPlayerGuessed(Player(p));
      }
   }
}

