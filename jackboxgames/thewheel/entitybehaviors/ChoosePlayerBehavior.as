package jackboxgames.thewheel.entitybehaviors
{
   import jackboxgames.algorithm.*;
   import jackboxgames.ecast.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.entityinteraction.entities.*;
   import jackboxgames.model.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.utils.*;
   
   public class ChoosePlayerBehavior implements IEntityInteractionBehavior
   {
      private var _delegate:IChoosePlayerDelegate;
      
      private var _ws:WSClient;
      
      private var _players:Array;
      
      private var _choices:PerPlayerContainer;
      
      private var _isSubmitted:PerPlayerContainer;
      
      public function ChoosePlayerBehavior(delegate:IChoosePlayerDelegate)
      {
         super();
         this._delegate = delegate;
      }
      
      private function _playerIsChosenAtLeastOnce(p:Player) : Boolean
      {
         return MapFold.process(this._players,function(otherPlayer:Player, ... args):Boolean
         {
            return ArrayUtil.arrayContainsElement(_choices.getDataForPlayer(otherPlayer),p);
         },MapFold.FOLD_OR);
      }
      
      public function setup(ws:WSClient, players:Array) : void
      {
         var p:Player = null;
         this._ws = ws;
         this._players = players;
         this._choices = PerPlayerContainerUtil.MAP(this._players,function(... args):Array
         {
            return [];
         });
         this._isSubmitted = PerPlayerContainerUtil.MAP(this._players,function(... args):Boolean
         {
            return false;
         });
         for each(p in this._delegate.playersToChooseFrom)
         {
            p.widget.setSelectable(true);
         }
      }
      
      public function shutdown(finishedOnPlayerInput:Boolean) : void
      {
         var p:Player = null;
         for each(p in this._delegate.playersToChooseFrom)
         {
            p.widget.setSelectable(false);
         }
         this._delegate.onChoosePlayerDone(this._choices,finishedOnPlayerInput);
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
         return new PlayerEntities(p).withInput("main",new ObjectEntity(this._ws,"chooseplayers:" + p.sessionId.val,{},["rw id:" + p.sessionId.val]));
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
               "kind":"choosePlayers",
               "numChoicesToMake":this._delegate.numPlayersToChoose,
               "prompt":this._delegate.choosePlayersPrompt,
               "players":this._delegate.playersToChooseFrom.map(function(otherPlayer:Player, ... args):Object
               {
                  return {
                     "id":otherPlayer.sessionId.val,
                     "isSelected":ArrayUtil.arrayContainsElement(_choices.getDataForPlayer(p),otherPlayer)
                  };
               }),
               "responseKey":"chooseplayers:" + p.sessionId.val
            };
         }
         return null;
      }
      
      public function onPlayerInputEntityUpdated(p:JBGPlayer, pe:PlayerEntities, se:SharedEntities, key:String, e:IEntity) : EntityUpdateRequest
      {
         var mainInput:ObjectEntity = null;
         var choicesMade:Array = null;
         var chosenPlayer:Player = null;
         if(key == "main")
         {
            mainInput = ObjectEntity(e);
            if(this._isSubmitted.getDataForPlayer(p))
            {
               return null;
            }
            choicesMade = this._choices.getDataForPlayer(p);
            if(mainInput.getValue().action == "choose")
            {
               chosenPlayer = this._delegate.playersToChooseFrom[mainInput.getValue().index];
               if(!chosenPlayer)
               {
                  return null;
               }
               if(ArrayUtil.arrayContainsElement(choicesMade,chosenPlayer))
               {
                  ArrayUtil.removeElementFromArray(choicesMade,chosenPlayer);
               }
               else if(choicesMade.length < this._delegate.numPlayersToChoose)
               {
                  choicesMade.push(chosenPlayer);
               }
               if(this._delegate.showSelectedPlayerWidgets)
               {
                  chosenPlayer.widget.setSelected(this._playerIsChosenAtLeastOnce(chosenPlayer));
               }
               return new EntityUpdateRequest().withPlayerMainEntity(p);
            }
            if(mainInput.getValue().action == "submit")
            {
               if(choicesMade.length < this._delegate.numPlayersToChoose)
               {
                  return null;
               }
               this._isSubmitted.setDataForPlayer(p,true);
               this._delegate.onChoosePlayerSubmitted(Player(p),choicesMade);
               return new EntityUpdateRequest().withPlayerMainEntity(p);
            }
         }
         return null;
      }
      
      public function playerIsDone(p:JBGPlayer) : Boolean
      {
         return this._isSubmitted.getDataForPlayer(p);
      }
   }
}

