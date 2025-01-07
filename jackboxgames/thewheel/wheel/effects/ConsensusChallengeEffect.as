package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.Promise;
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.wheel.DoSpinResultParam;
   import jackboxgames.thewheel.wheel.ISliceEffect;
   import jackboxgames.thewheel.wheel.SpinResult;
   import jackboxgames.thewheel.wheel.slicedata.BonusSliceData;
   import jackboxgames.utils.PromiseUtil;
   
   public class ConsensusChallengeEffect implements ISliceEffect
   {
      private var _param:DoSpinResultParam;
      
      private var _playersWereSuccessful:Boolean;
      
      private var _playerThatGetsTheBonus:Player;
      
      public function ConsensusChallengeEffect()
      {
         super();
      }
      
      public function get playersWereSuccessful() : Boolean
      {
         return this._playersWereSuccessful;
      }
      
      public function get playerThatGetsTheBonus() : Player
      {
         return this._playerThatGetsTheBonus;
      }
      
      public function setup(param:DoSpinResultParam, spinResult:SpinResult) : void
      {
         this._param = param;
      }
      
      public function prepareForEvaluation(p:Player) : void
      {
         this._playersWereSuccessful = p != null;
         this._playerThatGetsTheBonus = this._playersWereSuccessful ? p : BonusSliceData(this._param.spunSlice.params.data).owner;
      }
      
      public function evaluate() : Promise
      {
         return PromiseUtil.RESOLVED();
      }
   }
}

