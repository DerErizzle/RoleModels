package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.Promise;
   import jackboxgames.thewheel.GameConstants;
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.wheel.DoSpinResultParam;
   import jackboxgames.thewheel.wheel.ISliceEffect;
   import jackboxgames.thewheel.wheel.Slice;
   import jackboxgames.thewheel.wheel.SliceParameters;
   import jackboxgames.thewheel.wheel.SpinResult;
   import jackboxgames.thewheel.wheel.Wheel;
   import jackboxgames.thewheel.wheel.slicedata.BonusSliceData;
   import jackboxgames.thewheel.wheel.slicedata.PlayerSliceData;
   import jackboxgames.utils.PromiseUtil;
   
   public class ReplaceSliceEffect implements ISliceEffect
   {
      private var _wheel:Wheel;
      
      private var _player:Player;
      
      private var _sliceToReplace:Slice;
      
      public function ReplaceSliceEffect()
      {
         super();
      }
      
      public function get wheel() : Wheel
      {
         return this._wheel;
      }
      
      public function get player() : Player
      {
         return this._player;
      }
      
      public function get sliceToReplace() : Slice
      {
         return this._sliceToReplace;
      }
      
      public function set sliceToReplace(val:Slice) : void
      {
         this._sliceToReplace = val;
      }
      
      public function setup(param:DoSpinResultParam, spinResult:SpinResult) : void
      {
         this._wheel = param.wheel;
         this._player = BonusSliceData(param.spunSlice.params.data).owner;
      }
      
      public function evaluate() : Promise
      {
         if(!this._sliceToReplace)
         {
            return PromiseUtil.RESOLVED();
         }
         var param:SliceParameters = SliceParameters.CREATE(GameConstants.SLICE_TYPE_PLAYER);
         var data:PlayerSliceData = PlayerSliceData(param.data);
         data.addStakeForPlayer(this._player);
         if(this._sliceToReplace.params.type == GameConstants.SLICE_TYPE_PLAYER)
         {
            data.multiplier = PlayerSliceData(this._sliceToReplace.params.data).multiplier;
         }
         var p:Promise = new Promise();
         this._wheel.replaceSliceWithNewSlice(this._sliceToReplace,param,Wheel.REPLACE_TYPE_FLIP,PromiseUtil.doneFnResolved(p,undefined));
         return p;
      }
   }
}

