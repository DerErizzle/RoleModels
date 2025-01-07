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
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.utils.*;
   
   public class ChooseSliceBehavior implements IEntityInteractionBehavior
   {
      private var _wheelDelegate:IWheelControllerDelegate;
      
      private var _chooseDelegate:IChooseSliceDelegate;
      
      private var _ws:WSClient;
      
      private var _players:Array;
      
      private var _chosenSlices:PerPlayerContainer;
      
      private var _isSubmitted:PerPlayerContainer;
      
      public function ChooseSliceBehavior(chooseDelegate:IChooseSliceDelegate, wheelDelegate:IWheelControllerDelegate)
      {
         super();
         this._wheelDelegate = wheelDelegate;
         this._chooseDelegate = chooseDelegate;
      }
      
      private function atLeastOnePlayerCanChoose(pos:int) : Boolean
      {
         return MapFold.process(this._players,function(p:Player, ... args):Boolean
         {
            return _chooseDelegate.canChooseSlice(p,pos);
         },MapFold.FOLD_OR);
      }
      
      public function setup(ws:WSClient, players:Array) : void
      {
         var pos:int = 0;
         this._ws = ws;
         this._players = players;
         this._chosenSlices = new PerPlayerContainer();
         this._isSubmitted = PerPlayerContainerUtil.MAP(players,function(... args):Boolean
         {
            return false;
         });
         for each(pos in this._wheelDelegate.slicePositions)
         {
            if(this.atLeastOnePlayerCanChoose(pos))
            {
               this._wheelDelegate.setSliceVisualState(pos,Slice.STATE_SELECTABLE);
            }
         }
      }
      
      public function shutdown(finishedOnPlayerInput:Boolean) : void
      {
         var pos:int = 0;
         for each(pos in this._wheelDelegate.slicePositions)
         {
            this._wheelDelegate.setSliceVisualState(pos,Slice.STATE_DEFAULT);
         }
         this._players = null;
         this._ws = null;
         this._chooseDelegate.onChooseSliceDone(this._chosenSlices,finishedOnPlayerInput);
      }
      
      public function generateSharedEntities() : SharedEntities
      {
         return new SharedEntities();
      }
      
      public function generatePlayerEntities(p:JBGPlayer) : PlayerEntities
      {
         return new PlayerEntities(p).withInput("main",new ObjectEntity(this._ws,"chooseslice:" + p.sessionId.val,{},["rw id:" + p.sessionId.val]));
      }
      
      public function onPlayerInputEntityUpdated(p:JBGPlayer, pe:PlayerEntities, se:SharedEntities, key:String, e:IEntity) : EntityUpdateRequest
      {
         var mainInput:ObjectEntity = null;
         var position:int = 0;
         if(key == "main")
         {
            mainInput = ObjectEntity(e);
            if(this._isSubmitted.getDataForPlayer(p))
            {
               return null;
            }
            if(mainInput.getValue().action == "choose")
            {
               if(this._wheelDelegate.slicePositions[mainInput.getValue().index] === undefined)
               {
                  return null;
               }
               position = int(this._wheelDelegate.slicePositions[mainInput.getValue().index]);
               if(this._chosenSlices.hasDataForPlayer(p) && this._chosenSlices.getDataForPlayer(p) == position)
               {
                  this._wheelDelegate.setSliceVisualState(this._chosenSlices.getDataForPlayer(p),Slice.STATE_SELECTABLE);
                  this._chosenSlices.removeDataForPlayer(p);
               }
               else
               {
                  if(!this._chooseDelegate.canChooseSlice(Player(p),position))
                  {
                     return new EntityUpdateRequest().withPlayerMainEntity(p);
                  }
                  if(this._chosenSlices.hasDataForPlayer(p))
                  {
                     this._wheelDelegate.setSliceVisualState(this._chosenSlices.getDataForPlayer(p),Slice.STATE_SELECTABLE);
                  }
                  this._chosenSlices.setDataForPlayer(p,position);
                  if(this._chooseDelegate.showSelectedSlices)
                  {
                     this._wheelDelegate.setSliceVisualState(position,Slice.STATE_SELECTED);
                  }
               }
               return new EntityUpdateRequest().withPlayerMainEntity(p);
            }
            if(mainInput.getValue().action == "submit")
            {
               if(!this._chosenSlices.hasDataForPlayer(p))
               {
                  return null;
               }
               this._isSubmitted.setDataForPlayer(p,true);
               this._chooseDelegate.onChooseSliceSubmitted(Player(p),this._chosenSlices.getDataForPlayer(p));
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
         var slices:Array = null;
         if(entityKey == "main")
         {
            if(this.playerIsDone(p))
            {
               return {"kind":"waiting"};
            }
            slices = this._wheelDelegate.getControllerSlices(Player(p));
            slices.forEach(function(controllerSlice:Object, ... args):void
            {
               controllerSlice.isSelectable = _chooseDelegate.canChooseSlice(Player(p),controllerSlice.position);
               controllerSlice.isSelected = _chosenSlices.getDataForPlayer(p) == controllerSlice.position;
            });
            return {
               "kind":"chooseSlices",
               "prompt":this._chooseDelegate.getChooseSlicePrompt(Player(p)),
               "numChoicesToMake":1,
               "initialDegrees":this._wheelDelegate.getControllerWheelSpin(),
               "slices":slices,
               "responseKey":"chooseslice:" + p.sessionId.val
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

