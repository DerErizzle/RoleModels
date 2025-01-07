package jackboxgames.thewheel.wheel
{
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.entitybehaviors.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.utils.*;
   
   public class WheelControllerProvider implements IWheelControllerDelegate
   {
      private var _delegate:IWheelDataDelegate;
      
      private var _controllerMode:String;
      
      public function WheelControllerProvider(delegate:IWheelDataDelegate, controllerMode:String)
      {
         super();
         this._delegate = delegate;
         this._controllerMode = controllerMode;
      }
      
      private function _getSliceToShowAtPosition(p:Player, position:int) : Slice
      {
         var playerSlice:Slice = null;
         var multiplierSlice:Slice = null;
         var slices:Array = this._delegate.getWheel().getSlicesAt(position,false);
         if(slices.length == 0)
         {
            return null;
         }
         if(slices.length == 1)
         {
            return ArrayUtil.first(slices);
         }
         if(slices.length == 2)
         {
            playerSlice = ArrayUtil.find(slices,Slice.GENERATE_FIND_FN_FOR_TYPE(GameConstants.SLICE_TYPE_PLAYER));
            multiplierSlice = ArrayUtil.find(slices,Slice.GENERATE_FIND_FN_FOR_TYPE(GameConstants.SLICE_TYPE_MULTIPLIER));
            if(Boolean(playerSlice) && Boolean(multiplierSlice))
            {
               return PlayerSliceData(playerSlice.params.data).getMultiplierForPlayer(p) > 0 ? playerSlice : multiplierSlice;
            }
         }
         Assert.assert(false);
         return null;
      }
      
      public function get wheelId() : String
      {
         return this._delegate.getWheel().id;
      }
      
      public function getControllerSlices(p:Player) : Array
      {
         return this._delegate.getWheel().slicePositions.map(function(position:int, ... args):Object
         {
            var data:* = undefined;
            var sliceObj:* = {
               "position":position,
               "size":GameState.instance.jsonData.gameConfig.sliceSize
            };
            var slice:* = _getSliceToShowAtPosition(p,position);
            if(slice && Boolean(slice.params.data.isSliceVisibleToController(p,_controllerMode)))
            {
               sliceObj.type = slice.params.type.id;
               data = slice.params.data.getControllerData(p,_controllerMode);
               if(data)
               {
                  sliceObj.data = data;
               }
            }
            else
            {
               sliceObj.type = "empty";
            }
            return sliceObj;
         });
      }
      
      public function getControllerWheelSpin() : int
      {
         return this._delegate.getWheel().spin;
      }
      
      public function get slicePositions() : Array
      {
         return this._delegate.getWheel().slicePositions;
      }
      
      private function _getSliceForVisualsChange(pos:int) : Slice
      {
         return this._delegate.getWheel().getSliceAt(pos,false);
      }
      
      public function setSliceVisualState(pos:int, state:String) : void
      {
         var s:Slice = this._getSliceForVisualsChange(pos);
         s.setVisualState(state);
      }
   }
}

