package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.Promise;
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.gameplay.ScoreChange;
   import jackboxgames.thewheel.wheel.DoSpinResultParam;
   import jackboxgames.thewheel.wheel.ISliceEffect;
   import jackboxgames.thewheel.wheel.SpinResult;
   import jackboxgames.thewheel.wheel.slicedata.PointsSliceData;
   import jackboxgames.utils.PromiseUtil;
   
   public class PointsSliceEffect implements ISliceEffect
   {
      private var _param:DoSpinResultParam;
      
      private var _playersThatWonPoints:Array;
      
      public function PointsSliceEffect()
      {
         super();
      }
      
      public function get playersThatWonPoints() : Array
      {
         return this._playersThatWonPoints;
      }
      
      public function setup(param:DoSpinResultParam, spinResult:SpinResult) : void
      {
         this._param = param;
         this._playersThatWonPoints = [this._param.spinningPlayer];
      }
      
      public function evaluate() : Promise
      {
         this._playersThatWonPoints.forEach(function(p:Player, ... args):void
         {
            p.addScoreChange(new ScoreChange().withAmount(PointsSliceData(_param.spunSlice.params.data).value));
         });
         return PromiseUtil.RESOLVED();
      }
   }
}

