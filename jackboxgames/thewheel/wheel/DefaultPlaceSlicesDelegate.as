package jackboxgames.thewheel.wheel
{
   import jackboxgames.thewheel.GameConstants;
   import jackboxgames.thewheel.GameState;
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.entitybehaviors.IPlaceSlicesBehaviorDelegate;
   import jackboxgames.thewheel.wheel.slicedata.MultiplierSliceData;
   import jackboxgames.thewheel.wheel.slicedata.PlayerSliceData;
   import jackboxgames.utils.ArrayUtil;
   
   public class DefaultPlaceSlicesDelegate implements IPlaceSlicesBehaviorDelegate
   {
      private var _wheelDelegate:IWheelDataDelegate;
      
      public function DefaultPlaceSlicesDelegate(wheelDelegate:IWheelDataDelegate)
      {
         super();
         this._wheelDelegate = wheelDelegate;
      }
      
      public function canPlaceSlice(p:Player, position:int) : Boolean
      {
         var w:Wheel = this._wheelDelegate.getWheel();
         var slices:Array = w.getSlicesAt(position,false);
         if(slices.length == 0)
         {
            return true;
         }
         return ArrayUtil.find(slices,Slice.GENERATE_FIND_FN_FOR_TYPE(GameConstants.SLICE_TYPE_PLAYER)) || ArrayUtil.find(slices,Slice.GENERATE_FIND_FN_FOR_TYPE(GameConstants.SLICE_TYPE_MULTIPLIER));
      }
      
      public function canRemoveSlice(p:Player, position:int) : Boolean
      {
         var w:Wheel = this._wheelDelegate.getWheel();
         var slices:Array = w.getSlicesAt(position,false);
         if(slices.length == 0)
         {
            return false;
         }
         var playerSlice:Slice = ArrayUtil.find(slices,Slice.GENERATE_FIND_FN_FOR_TYPE(GameConstants.SLICE_TYPE_PLAYER));
         return Boolean(playerSlice) && PlayerSliceData(playerSlice.params.data).getNumStakesForPlayer(p) > 0;
      }
      
      public function doPlaceSlice(p:Player, position:int) : void
      {
         var newSlice:Slice = null;
         var playerSlice:Slice = null;
         var multiplierSlice:Slice = null;
         var data:PlayerSliceData = null;
         var w:Wheel = this._wheelDelegate.getWheel();
         var existingSlices:Array = w.getSlicesAt(position,false);
         if(existingSlices.length > 0)
         {
            playerSlice = ArrayUtil.find(existingSlices,Slice.GENERATE_FIND_FN_FOR_TYPE(GameConstants.SLICE_TYPE_PLAYER));
            multiplierSlice = ArrayUtil.find(existingSlices,Slice.GENERATE_FIND_FN_FOR_TYPE(GameConstants.SLICE_TYPE_MULTIPLIER));
            if(Boolean(playerSlice))
            {
               data = PlayerSliceData(playerSlice.params.data);
               data.addStakeForPlayer(p);
               playerSlice.updateVisuals();
            }
            else if(Boolean(multiplierSlice))
            {
               newSlice = w.addSlice(GameState.instance.generatePlayerSlice(),multiplierSlice.position);
               PlayerSliceData(newSlice.params.data).addStakeForPlayer(p);
               PlayerSliceData(newSlice.params.data).multiplier = MultiplierSliceData(multiplierSlice.params.data).multiplier;
               newSlice.updateVisuals();
            }
         }
         else
         {
            newSlice = w.addSlice(GameState.instance.generatePlayerSlice(),position);
            PlayerSliceData(newSlice.params.data).addStakeForPlayer(p);
            newSlice.updateVisuals();
         }
      }
      
      public function doRemoveSlice(p:Player, position:int) : void
      {
         var w:Wheel = this._wheelDelegate.getWheel();
         var existingSlices:Array = w.getSlicesAt(position,false);
         var playerSlice:Slice = ArrayUtil.find(existingSlices,Slice.GENERATE_FIND_FN_FOR_TYPE(GameConstants.SLICE_TYPE_PLAYER));
         if(Boolean(playerSlice))
         {
            PlayerSliceData(playerSlice.params.data).removeStakeForPlayer(p);
            if(PlayerSliceData(playerSlice.params.data).playersWithStake.length == 0)
            {
               w.removeSlice(playerSlice);
            }
         }
      }
   }
}

