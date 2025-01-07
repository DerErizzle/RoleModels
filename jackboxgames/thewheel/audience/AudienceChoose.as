package jackboxgames.thewheel.audience
{
   import jackboxgames.ecast.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.model.*;
   import jackboxgames.utils.*;
   
   public class AudienceChoose implements IAudienceInteractionBehavior
   {
      private var _dataDelegate:IAudienceChooseDataDelegate;
      
      private var _eventDelegate:IAudienceChooseEventDelegate;
      
      private var _ws:WSClient;
      
      private var _gs:JBGGameState;
      
      public function AudienceChoose(dataDelegate:IAudienceChooseDataDelegate, eventDelegate:IAudienceChooseEventDelegate)
      {
         super();
         this._dataDelegate = dataDelegate;
         this._eventDelegate = eventDelegate;
      }
      
      public function setup(ws:WSClient, gs:JBGGameState) : void
      {
         this._ws = ws;
         this._gs = gs;
      }
      
      public function shutdown(entitiesFromInteraction:AudienceEntities) : void
      {
         this._ws = null;
         this._gs = null;
         this._eventDelegate.onAudienceChooseDone(CountGroupEntity(entitiesFromInteraction.getAudienceToGameEntity("main")).counts);
      }
      
      public function generateEntities() : AudienceEntities
      {
         var choices:Array = ArrayUtil.getArrayOfIndicesUpTo(0,this._dataDelegate.getAudienceChooseChoices().length).map(function(num:int, ... args):String
         {
            return String(num);
         });
         return new AudienceEntities(this._gs).withAudienceToGame("main",new CountGroupEntity(this._ws,Duration.fromSec(2),"audienceChoose",choices));
      }
      
      public function onAudienceToGameEntityUpdated(entities:AudienceEntities, key:String, entity:IEntity) : AudienceEntityUpdateRequest
      {
         if(key == "main")
         {
            this._eventDelegate.onAudienceVotesUpdated(CountGroupEntity(entities.getAudienceToGameEntity("main")).counts);
         }
         return null;
      }
      
      public function getGameToAudienceEntityValue(key:String, e:IEntity) : *
      {
         if(key == "main")
         {
            return {
               "kind":"choices",
               "category":this._dataDelegate.getAudienceChooseCategory(),
               "prompt":this._dataDelegate.getAudienceChoosePrompt(),
               "choices":this._dataDelegate.getAudienceChooseChoices().map(function(choice:Object, i:int, a:Array):Object
               {
                  if(choice is String)
                  {
                     return {
                        "value":String(i),
                        "text":choice
                     };
                  }
                  choice.value = String(i);
                  return choice;
               }),
               "responseKey":"audienceChoose"
            };
         }
         return null;
      }
   }
}

