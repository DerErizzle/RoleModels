package jackboxgames.thewheel.wheel.slicedata
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.wheel.ISliceData;
   
   public class ReservedSliceData implements ISliceData
   {
      private var _reservedFor:String;
      
      public function ReservedSliceData()
      {
         super();
      }
      
      public function get reservedFor() : String
      {
         return this._reservedFor;
      }
      
      public function set reservedFor(val:String) : void
      {
         this._reservedFor = val;
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
         return {"reservedFor":this._reservedFor};
      }
      
      public function clone() : *
      {
         return new ReservedSliceData();
      }
   }
}

