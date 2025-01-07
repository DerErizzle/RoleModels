package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.gameplay.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.utils.*;
   
   public class BadSplitEffect implements ISliceEffect
   {
      private var _param:DoSpinResultParam;
      
      public function BadSplitEffect()
      {
         super();
      }
      
      public function setup(param:DoSpinResultParam, spinResult:SpinResult) : void
      {
         this._param = param;
      }
      
      public function evaluate() : Promise
      {
         var playersGettingPoints:Array;
         var pointsPerPlayer:int = 0;
         var totalAmount:int = GameState.instance.jsonData.gameConfig.getBadSplitAmountForCurrentRound();
         this._param.spinningPlayer.addScoreChange(new ScoreChange().withAmount(-totalAmount));
         playersGettingPoints = GameState.instance.players.filter(ArrayUtil.GENERATE_FILTER_EXCEPT(this._param.spinningPlayer));
         pointsPerPlayer = Math.round(Number(totalAmount) / playersGettingPoints.length);
         playersGettingPoints.forEach(function(p:Player, ... args):void
         {
            p.addScoreChange(new ScoreChange().withAmount(pointsPerPlayer));
         });
         return PromiseUtil.RESOLVED();
      }
   }
}

