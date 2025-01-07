package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.Promise;
   import jackboxgames.thewheel.wheel.DoSpinResultParam;
   import jackboxgames.thewheel.wheel.ISliceEffect;
   import jackboxgames.thewheel.wheel.SpinResult;
   import jackboxgames.thewheel.wheel.slicedata.PlayerSliceData;
   import jackboxgames.utils.PromiseUtil;
   
   public class PlayerSliceEffect implements ISliceEffect
   {
      private var _param:DoSpinResultParam;
      
      private var _winWheelPlayers:Array;
      
      public function PlayerSliceEffect()
      {
         super();
      }
      
      public function get playersWhoWonJackpot() : Array
      {
         return PlayerSliceData(this._param.spunSlice.params.data).playersWhoWonJackpot;
      }
      
      public function setup(param:DoSpinResultParam, spinResult:SpinResult) : void
      {
         this._param = param;
      }
      
      public function evaluate() : Promise
      {
         return PromiseUtil.RESOLVED();
      }
   }
}

