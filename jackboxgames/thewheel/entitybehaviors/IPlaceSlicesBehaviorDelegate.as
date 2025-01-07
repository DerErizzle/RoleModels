package jackboxgames.thewheel.entitybehaviors
{
   import jackboxgames.thewheel.Player;
   
   public interface IPlaceSlicesBehaviorDelegate
   {
      function canPlaceSlice(param1:Player, param2:int) : Boolean;
      
      function canRemoveSlice(param1:Player, param2:int) : Boolean;
      
      function doPlaceSlice(param1:Player, param2:int) : void;
      
      function doRemoveSlice(param1:Player, param2:int) : void;
   }
}

