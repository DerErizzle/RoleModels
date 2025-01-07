package jackboxgames.thewheel.wheel.slicedata
{
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.utils.*;
   
   public class PointsSliceData implements ISliceData
   {
      private var _value:int;
      
      public function PointsSliceData()
      {
         super();
      }
      
      public function get value() : int
      {
         return this._value;
      }
      
      public function setup(owner:Player) : void
      {
         this._value = ArrayUtil.getRandomElement(GameState.instance.jsonData.gameConfig.getPointsSliceAmountsForCurrentRound());
      }
      
      public function get name() : String
      {
         return LocalizationUtil.getPrintfText("SLICE_TYPE_POINTS_NAME");
      }
      
      public function get description() : String
      {
         return LocalizationUtil.getPrintfText("SLICE_TYPE_POINTS_DESCRIPTION",this.value);
      }
      
      public function isSliceVisibleToController(p:Player, controllerMode:String) : Boolean
      {
         return true;
      }
      
      public function getControllerData(p:Player, controllerMode:String) : Object
      {
         return {"points":this._value};
      }
      
      public function clone() : *
      {
         var newData:PointsSliceData = new PointsSliceData();
         newData._value = this._value;
         return newData;
      }
   }
}

