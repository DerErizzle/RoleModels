package jackboxgames.thewheel.wheel.slicedata
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.wheel.ISliceData;
   import jackboxgames.utils.LocalizationUtil;
   
   public class BadSliceData implements ISliceData
   {
      public function BadSliceData()
      {
         super();
      }
      
      public function setup(owner:Player) : void
      {
      }
      
      public function get name() : String
      {
         return LocalizationUtil.getPrintfText("SLICE_TYPE_BAD_NAME");
      }
      
      public function get description() : String
      {
         return LocalizationUtil.getPrintfText("SLICE_TYPE_BAD_DESCRIPTION");
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
         return new BadSliceData();
      }
   }
}

