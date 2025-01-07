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
   
   public class TappingListBehavior implements IEntityInteractionBehavior
   {
      private var _delegate:ITappingListBehaviorDelegate;
      
      private var _ws:WSClient;
      
      private var _choices:PerPlayerContainer;
      
      private var _donePlayers:Array;
      
      public function TappingListBehavior(delegate:ITappingListBehaviorDelegate)
      {
         super();
         this._delegate = delegate;
      }
      
      public function setup(ws:WSClient, players:Array) : void
      {
         this._ws = ws;
         this._choices = new PerPlayerContainer();
         this._donePlayers = [];
      }
      
      public function shutdown(finishedOnPlayerInput:Boolean) : void
      {
         if(finishedOnPlayerInput)
         {
            TSInputHandler.instance.input("Done");
         }
         this._ws = null;
         this._choices = null;
         this._donePlayers = [];
      }
      
      public function generateSharedEntities() : SharedEntities
      {
         return new SharedEntities();
      }
      
      public function generatePlayerEntities(p:JBGPlayer) : PlayerEntities
      {
         return new PlayerEntities(p).withInput("main",new ObjectEntity(this._ws,"tappinglist:" + p.sessionId.val,{},["rw id:" + p.sessionId.val]));
      }
      
      public function onPlayerInputEntityUpdated(p:JBGPlayer, pe:PlayerEntities, se:SharedEntities, key:String, e:IEntity) : EntityUpdateRequest
      {
         var mainInput:ObjectEntity = null;
         var action:String = null;
         var choiceIndex:int = 0;
         var value:Boolean = false;
         if(key == "main" && !ArrayUtil.arrayContainsElement(this._donePlayers,p))
         {
            mainInput = ObjectEntity(e);
            action = mainInput.getValue().action;
            if(action == "choose")
            {
               if(!mainInput.getValue().hasOwnProperty("choice") || !mainInput.getValue().hasOwnProperty("value"))
               {
                  return null;
               }
               choiceIndex = int(mainInput.getValue().choice);
               value = Boolean(mainInput.getValue().value);
               this._delegate.setAnswer(Player(p),choiceIndex,value);
               return new EntityUpdateRequest().withPlayerMainEntity(p);
            }
            if(action == "submit")
            {
               this._donePlayers.push(p);
               this._delegate.onPlayerIsDone(Player(p));
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
               return {"kind":"waiting"};
            }
            return {
               "kind":"tappingList",
               "prompt":this._delegate.content.prompt,
               "subtype":this._delegate.content.subtype,
               "choices":this._delegate.getAnswers(Player(p)),
               "responseKey":"tappinglist:" + p.sessionId.val
            };
         }
         return null;
      }
      
      public function playerIsDone(p:JBGPlayer) : Boolean
      {
         return ArrayUtil.arrayContainsElement(this._donePlayers,p);
      }
   }
}

