package jackboxgames.thewheel.wheel.slicedata
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.wheel.ISliceData;
   
   public class MultiplierSliceData implements ISliceData
   {
      private var _multiplier:Number;
      
      public function MultiplierSliceData()
      {
         super();
      }
      
      public function get multiplier() : Number
      {
         return this._multiplier;
      }
      
      public function set multiplier(val:Number) : void
      {
         this._multiplier = val;
      }
      
      public function setup(owner:Player) : void
      {
         this._multiplier = 1;
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
         return {"multiplier":this._multiplier};
      }
      
      public function clone() : *
      {
         var newData:MultiplierSliceData = new MultiplierSliceData();
         newData._multiplier = this._multiplier;
         return newData;
      }
   }
}

