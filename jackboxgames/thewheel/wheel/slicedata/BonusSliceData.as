package jackboxgames.thewheel.wheel.slicedata
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.wheel.ISliceData;
   import jackboxgames.utils.LocalizationUtil;
   
   public class BonusSliceData implements ISliceData
   {
      private var _owner:Player;
      
      public function BonusSliceData()
      {
         super();
      }
      
      public function get owner() : Player
      {
         return this._owner;
      }
      
      public function setup(owner:Player) : void
      {
         this._owner = owner;
      }
      
      public function get name() : String
      {
         return LocalizationUtil.getPrintfText("SLICE_TYPE_BONUS_NAME");
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
         return {"owner":this._owner.sessionId.val};
      }
      
      public function clone() : *
      {
         var newData:BonusSliceData = new BonusSliceData();
         newData._owner = this._owner;
         return newData;
      }
   }
}

