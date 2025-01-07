package jackboxgames.thewheel.wheel.slicedata
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.utils.TheWheelTextUtil;
   import jackboxgames.thewheel.wheel.ISliceData;
   import jackboxgames.utils.LocalizationUtil;
   
   public class WinnerSliceData implements ISliceData
   {
      private var _playerThatWins:Player;
      
      public function WinnerSliceData()
      {
         super();
      }
      
      public function get playerThatWins() : Player
      {
         return this._playerThatWins;
      }
      
      public function set playerThatWins(p:Player) : void
      {
         this._playerThatWins = p;
      }
      
      public function setup(owner:Player) : void
      {
      }
      
      public function get name() : String
      {
         return LocalizationUtil.getPrintfText("SLICE_TYPE_WINNER_NAME",TheWheelTextUtil.formattedPlayerName(this._playerThatWins));
      }
      
      public function get description() : String
      {
         return LocalizationUtil.getPrintfText("SLICE_TYPE_WINNER_DESCRIPTION",TheWheelTextUtil.formattedPlayerName(this._playerThatWins));
      }
      
      public function isSliceVisibleToController(p:Player, controllerMode:String) : Boolean
      {
         return true;
      }
      
      public function getControllerData(p:Player, controllerMode:String) : Object
      {
         if(!this._playerThatWins)
         {
            return {};
         }
         return {"player":this._playerThatWins.sessionId.val};
      }
      
      public function clone() : *
      {
         var newData:WinnerSliceData = new WinnerSliceData();
         newData._playerThatWins = this._playerThatWins;
         return newData;
      }
   }
}

