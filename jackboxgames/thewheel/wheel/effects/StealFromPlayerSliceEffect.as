package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.gameplay.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.utils.*;
   
   public class StealFromPlayerSliceEffect implements ISliceEffect
   {
      private var _wheel:Wheel;
      
      private var _stealingPlayer:Player;
      
      private var _sliceToStealFrom:Slice;
      
      private var _playersToStealFrom:Array;
      
      public function StealFromPlayerSliceEffect()
      {
         super();
      }
      
      public function get wheel() : Wheel
      {
         return this._wheel;
      }
      
      public function get stealingPlayer() : Player
      {
         return this._stealingPlayer;
      }
      
      public function get sliceToStealFrom() : Slice
      {
         return this._sliceToStealFrom;
      }
      
      public function get playersToStealFrom() : Array
      {
         return this._playersToStealFrom;
      }
      
      public function get participatingPlayers() : Array
      {
         return [this._stealingPlayer].concat(this._playersToStealFrom);
      }
      
      public function set sliceToStealFrom(val:Slice) : void
      {
         var data:PlayerSliceData;
         this._sliceToStealFrom = val;
         data = PlayerSliceData(this._sliceToStealFrom.params.data);
         this._playersToStealFrom = data.playersWithStake.filter(function(p2:Player, ... args):Boolean
         {
            return p2 != _stealingPlayer;
         });
      }
      
      public function setup(param:DoSpinResultParam, spinResult:SpinResult) : void
      {
         this._wheel = param.wheel;
         this._stealingPlayer = BonusSliceData(param.spunSlice.params.data).owner;
      }
      
      public function evaluate() : Promise
      {
         var totalPointsToSteal:int;
         var pointsToStealFromEachPlayer:int = 0;
         if(this._playersToStealFrom.length == 0)
         {
            return PromiseUtil.RESOLVED();
         }
         totalPointsToSteal = GameState.instance.jsonData.gameConfig.stealFromPlayerSliceAmount;
         pointsToStealFromEachPlayer = Math.floor(Number(totalPointsToSteal) / this._playersToStealFrom.length);
         this._playersToStealFrom.forEach(function(p:Player, ... args):void
         {
            p.addScoreChange(new ScoreChange().withAmount(-pointsToStealFromEachPlayer));
            _stealingPlayer.addScoreChange(new ScoreChange().withAmount(pointsToStealFromEachPlayer));
         });
         return PromiseUtil.RESOLVED();
      }
   }
}

