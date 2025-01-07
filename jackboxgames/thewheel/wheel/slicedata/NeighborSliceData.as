package jackboxgames.thewheel.wheel.slicedata
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.wheel.ISliceData;
   import jackboxgames.utils.LocalizationUtil;
   
   public class NeighborSliceData implements ISliceData
   {
      public function NeighborSliceData()
      {
         super();
      }
      
      public function setup(owner:Player) : void
      {
      }
      
      public function get name() : String
      {
         return LocalizationUtil.getPrintfText("SLICE_TYPE_NEIGHBOR_NAME");
      }
      
      public function get description() : String
      {
         return "";
      }
      
      public function isSliceVisibleToController(p:Player, controllerMode:String) : Boolean
      {
         return true;
      }
      
      public function getControllerData(p:Player, controllerMode:String) : Object
      {
         return undefined;
      }
      
      public function clone() : *
      {
         return new NeighborSliceData();
      }
   }
}

