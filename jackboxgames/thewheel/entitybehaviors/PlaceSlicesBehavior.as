package jackboxgames.thewheel.entitybehaviors
{
   import jackboxgames.ecast.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.entityinteraction.entities.*;
   import jackboxgames.model.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.utils.*;
   
   public class PlaceSlicesBehavior implements IEntityInteractionBehavior
   {
      private var _delegate:IPlaceSlicesBehaviorDelegate;
      
      private var _wheelDelegate:IWheelControllerDelegate;
      
      private var _ws:WSClient;
      
      private var _players:Array;
      
      private var _isSubmitted:PerPlayerContainer;
      
      private var _placedIndicesHistory:PerPlayerContainer;
      
      public function PlaceSlicesBehavior(delegate:IPlaceSlicesBehaviorDelegate, wheelDelegate:IWheelControllerDelegate)
      {
         super();
         this._delegate = delegate;
         this._wheelDelegate = wheelDelegate;
      }
      
      public function setup(ws:WSClient, players:Array) : void
      {
         this._ws = ws;
         this._players = players;
         this._isSubmitted = PerPlayerContainerUtil.MAP(this._players,function(p:Player, ... args):Boolean
         {
            return false;
         });
         this._placedIndicesHistory = PerPlayerContainerUtil.MAP(this._players,function(p:Player, ... args):Array
         {
            return [];
         });
      }
      
      public function shutdown(finishedOnPlayerInput:Boolean) : void
      {
         if(finishedOnPlayerInput)
         {
            TSInputHandler.instance.input("Done");
         }
         this._players.forEach(function(p:Player, ... args):void
         {
            p.clearSlices();
         });
         this._players = null;
         this._ws = null;
      }
      
      public function generateSharedEntities() : SharedEntities
      {
         return new SharedEntities();
      }
      
      public function generatePlayerEntities(p:JBGPlayer) : PlayerEntities
      {
         return new PlayerEntities(p).withInput("main",new ObjectEntity(this._ws,"placeslice:" + p.sessionId.val,{},["rw id:" + p.sessionId.val]));
      }
      
      public function onPlayerInputEntityUpdated(p:JBGPlayer, pe:PlayerEntities, se:SharedEntities, key:String, e:IEntity) : EntityUpdateRequest
      {
         var mainInput:ObjectEntity = null;
         var val:Object = null;
         var action:String = null;
         if(key == "main")
         {
            mainInput = ObjectEntity(e);
            val = mainInput.getValue();
            action = val.action;
            if(this._isSubmitted.getDataForPlayer(p))
            {
               return null;
            }
            if(action == "place")
            {
               return this._placeSlice(Player(p),val);
            }
            if(action == "undo")
            {
               return this._undoSlice(Player(p),val);
            }
            if(action == "submit")
            {
               return this._submit(Player(p),val);
            }
         }
         return null;
      }
      
      private function _placeSlice(p:Player, val:Object) : EntityUpdateRequest
      {
         if(p.numPlaceableSlices == 0)
         {
            return null;
         }
         if(this._wheelDelegate.slicePositions[val.index] === undefined)
         {
            return null;
         }
         var position:int = int(this._wheelDelegate.slicePositions[val.index]);
         if(!this._delegate.canPlaceSlice(Player(p),position))
         {
            return new EntityUpdateRequest();
         }
         this._placedIndicesHistory.getDataForPlayer(p).push(val.index);
         this._delegate.doPlaceSlice(Player(p),position);
         p.changePlaceableSlices(-1);
         p.widget.addSlices(-1);
         return new EntityUpdateRequest().withPlayerMainEntity(p);
      }
      
      private function _undoSlice(p:Player, val:Object) : EntityUpdateRequest
      {
         if(this._placedIndicesHistory.getDataForPlayer(p).length == 0)
         {
            return null;
         }
         var indexToUndo:int = ArrayUtil.last(this._placedIndicesHistory.getDataForPlayer(p));
         var position:int = int(this._wheelDelegate.slicePositions[indexToUndo]);
         if(!this._delegate.canRemoveSlice(Player(p),position))
         {
            return new EntityUpdateRequest();
         }
         this._placedIndicesHistory.getDataForPlayer(p).pop();
         this._delegate.doRemoveSlice(Player(p),position);
         p.changePlaceableSlices(1);
         p.widget.addSlices(1);
         return new EntityUpdateRequest().withPlayerMainEntity(p);
      }
      
      private function _submit(p:Player, val:Object) : EntityUpdateRequest
      {
         this._isSubmitted.setDataForPlayer(p,true);
         return new EntityUpdateRequest().withPlayerMainEntity(p);
      }
      
      public function getSharedEntityValue(entityKey:String, entity:IEntity) : *
      {
         return undefined;
      }
      
      public function getPlayerEntityValue(p:JBGPlayer, entityKey:String, entity:IEntity) : *
      {
         var controllerSlices:Array = null;
         if(entityKey == "main")
         {
            if(this.playerIsDone(p))
            {
               return {"kind":"waiting"};
            }
            controllerSlices = this._wheelDelegate.getControllerSlices(Player(p));
            controllerSlices.forEach(function(controllerSlice:Object, ... args):void
            {
               controllerSlice.isSelectable = _delegate.canPlaceSlice(Player(p),controllerSlice.position);
            });
            return {
               "kind":"placeSlices",
               "unplacedSlices":Player(p).numPlaceableSlices,
               "initialDegrees":this._wheelDelegate.getControllerWheelSpin(),
               "slices":controllerSlices,
               "history":this._placedIndicesHistory.getDataForPlayer(p),
               "responseKey":"placeslice:" + p.sessionId.val
            };
         }
         return null;
      }
      
      public function playerIsDone(p:JBGPlayer) : Boolean
      {
         return this._isSubmitted.getDataForPlayer(p);
      }
   }
}

