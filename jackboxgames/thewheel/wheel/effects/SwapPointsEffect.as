package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.Promise;
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.gameplay.ScoreChange;
   import jackboxgames.thewheel.wheel.DoSpinResultParam;
   import jackboxgames.thewheel.wheel.ISliceEffect;
   import jackboxgames.thewheel.wheel.SpinResult;
   import jackboxgames.utils.PromiseUtil;
   
   public class SwapPointsEffect implements ISliceEffect
   {
      private var _playerA:Player;
      
      private var _playerB:Player;
      
      public function SwapPointsEffect()
      {
         super();
      }
      
      public function get playerA() : Player
      {
         return this._playerA;
      }
      
      public function set playerA(val:Player) : void
      {
         this._playerA = val;
      }
      
      public function get playerB() : Player
      {
         return this._playerB;
      }
      
      public function set playerB(val:Player) : void
      {
         this._playerB = val;
      }
      
      public function get affectedPlayers() : Array
      {
         return [this._playerA,this._playerB];
      }
      
      public function setup(param:DoSpinResultParam, spinResult:SpinResult) : void
      {
      }
      
      public function evaluate() : Promise
      {
         this._playerA.addScoreChange(new ScoreChange().withAmount(this._playerB.score.val - this._playerA.score.val));
         this._playerB.addScoreChange(new ScoreChange().withAmount(this._playerA.score.val - this._playerB.score.val));
         return PromiseUtil.RESOLVED();
      }
   }
}

