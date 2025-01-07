package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.Promise;
   import jackboxgames.thewheel.GameState;
   import jackboxgames.thewheel.wheel.DoSpinResultParam;
   import jackboxgames.thewheel.wheel.ISliceEffect;
   import jackboxgames.thewheel.wheel.SpinResult;
   import jackboxgames.thewheel.wheel.slicedata.WinnerSliceData;
   import jackboxgames.utils.PromiseUtil;
   
   public class WinnerSliceEffect implements ISliceEffect
   {
      private var _param:DoSpinResultParam;
      
      public function WinnerSliceEffect()
      {
         super();
      }
      
      public function setup(param:DoSpinResultParam, spinResult:SpinResult) : void
      {
         this._param = param;
      }
      
      public function evaluate() : Promise
      {
         var data:WinnerSliceData = WinnerSliceData(this._param.spunSlice.params.data);
         GameState.instance.setPlayerAsWinner(data.playerThatWins);
         return PromiseUtil.RESOLVED();
      }
   }
}

