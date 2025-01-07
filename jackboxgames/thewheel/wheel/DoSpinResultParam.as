package jackboxgames.thewheel.wheel
{
   import jackboxgames.thewheel.Player;
   
   public class DoSpinResultParam
   {
      private var _spinningPlayer:Player;
      
      private var _spunSlice:Slice;
      
      private var _wheel:Wheel;
      
      private var _spinDelegate:ISpinDelegate;
      
      public function DoSpinResultParam(spinningPlayer:Player, spunSlice:Slice, wheel:Wheel, spinDelegate:ISpinDelegate)
      {
         super();
         this._spinningPlayer = spinningPlayer;
         this._spunSlice = spunSlice;
         this._wheel = wheel;
         this._spinDelegate = spinDelegate;
      }
      
      public function get spinningPlayer() : Player
      {
         return this._spinningPlayer;
      }
      
      public function get spunSlice() : Slice
      {
         return this._spunSlice;
      }
      
      public function get wheel() : Wheel
      {
         return this._wheel;
      }
      
      public function get spinDelegate() : ISpinDelegate
      {
         return this._spinDelegate;
      }
   }
}

