package jackboxgames.thewheel.wheel.slicedata
{
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.utils.*;
   
   public class PointsForPlayerSliceData implements ISliceData
   {
      private var _player:Player;
      
      private var _value:int;
      
      public function PointsForPlayerSliceData()
      {
         super();
      }
      
      public function get player() : Player
      {
         return this._player;
      }
      
      public function get value() : int
      {
         return this._value;
      }
      
      public function setup(owner:Player) : void
      {
         this._player = owner;
         this._value = GameState.instance.jsonData.gameConfig.pointsForPlayerSliceAmount;
      }
      
      public function get name() : String
      {
         return LocalizationUtil.getPrintfText("SLICE_TYPE_POINTS_FOR_PLAYER_NAME");
      }
      
      public function get description() : String
      {
         return LocalizationUtil.getPrintfText("SLICE_TYPE_POINTS_FOR_PLAYER_DESCRIPTION",this._player,this.value);
      }
      
      public function isSliceVisibleToController(p:Player, controllerMode:String) : Boolean
      {
         return true;
      }
      
      public function getControllerData(p:Player, controllerMode:String) : Object
      {
         if(!this._player)
         {
            return {};
         }
         return {"player":this._player.sessionId.val};
      }
      
      public function clone() : *
      {
         var newData:PointsForPlayerSliceData = new PointsForPlayerSliceData();
         newData._player = this._player;
         newData._value = this._value;
         return newData;
      }
   }
}

