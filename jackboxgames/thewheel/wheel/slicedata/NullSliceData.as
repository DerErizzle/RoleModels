package jackboxgames.thewheel.wheel.slicedata
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.wheel.ISliceData;
   
   public class NullSliceData implements ISliceData
   {
      public function NullSliceData()
      {
         super();
      }
      
      public function setup(owner:Player) : void
      {
      }
      
      public function get name() : String
      {
         return "";
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
         return new NullSliceData();
      }
   }
}

