package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.Promise;
   import jackboxgames.thewheel.GameConstants;
   import jackboxgames.thewheel.wheel.DoSpinResultParam;
   import jackboxgames.thewheel.wheel.ISliceEffect;
   import jackboxgames.thewheel.wheel.Slice;
   import jackboxgames.thewheel.wheel.SpinResult;
   import jackboxgames.thewheel.wheel.slicedata.BonusSliceData;
   import jackboxgames.thewheel.wheel.slicedata.PlayerSliceData;
   import jackboxgames.utils.PromiseUtil;
   
   public class NeighborSliceEffect implements ISliceEffect
   {
      private var _param:DoSpinResultParam;
      
      private var _neighborSlices:Array;
      
      private var _playersWhoWonJackpot:Array;
      
      public function NeighborSliceEffect()
      {
         super();
      }
      
      public function get neighborSlices() : Array
      {
         return this._neighborSlices;
      }
      
      public function get playersWhoWonJackpot() : Array
      {
         return this._playersWhoWonJackpot;
      }
      
      public function setup(param:DoSpinResultParam, spinResult:SpinResult) : void
      {
         this._param = param;
         this._neighborSlices = param.wheel.getSlicesAdjacentTo(param.spunSlice).filter(function(s:Slice, ... args):Boolean
         {
            return s.params.type == GameConstants.SLICE_TYPE_PLAYER || s.params.type == GameConstants.SLICE_TYPE_BONUS;
         });
         this._playersWhoWonJackpot = [param.spinningPlayer];
         this._neighborSlices.forEach(function(s:Slice, ... args):void
         {
            var psd:PlayerSliceData = null;
            var bsd:BonusSliceData = null;
            if(s.params.type == GameConstants.SLICE_TYPE_PLAYER)
            {
               psd = PlayerSliceData(s.params.data);
               _playersWhoWonJackpot = _playersWhoWonJackpot.concat(psd.playersWithStake);
            }
            else if(s.params.type == GameConstants.SLICE_TYPE_BONUS)
            {
               bsd = BonusSliceData(s.params.data);
               _playersWhoWonJackpot.push(bsd.owner);
            }
         });
      }
      
      public function evaluate() : Promise
      {
         return PromiseUtil.RESOLVED();
      }
   }
}

