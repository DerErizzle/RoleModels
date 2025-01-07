package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.Promise;
   import jackboxgames.thewheel.wheel.DoSpinResultParam;
   import jackboxgames.thewheel.wheel.ISliceEffect;
   import jackboxgames.thewheel.wheel.Slice;
   import jackboxgames.thewheel.wheel.SpinResult;
   import jackboxgames.thewheel.wheel.Wheel;
   import jackboxgames.utils.Nullable;
   import jackboxgames.utils.PromiseUtil;
   
   public class ExpandEffect implements ISliceEffect
   {
      private var _wheel:Wheel;
      
      private var _thisSlice:Slice;
      
      private var _sliceToExpand:Slice;
      
      public function ExpandEffect()
      {
         super();
      }
      
      public function get wheel() : Wheel
      {
         return this._wheel;
      }
      
      public function get thisSlice() : Slice
      {
         return this._thisSlice;
      }
      
      public function get sliceToExpand() : Slice
      {
         return this._sliceToExpand;
      }
      
      public function set sliceToExpand(val:Slice) : void
      {
         this._sliceToExpand = val;
      }
      
      public function setup(param:DoSpinResultParam, spinResult:SpinResult) : void
      {
         this._wheel = param.wheel;
         this._thisSlice = param.spunSlice;
      }
      
      public function evaluate() : Promise
      {
         var adjacent:Array = this._wheel.getSlicesAdjacentTo(this._sliceToExpand);
         adjacent.forEach(function(s:Slice, ... args):void
         {
            _wheel.replaceSliceWithNewSlice(s,_sliceToExpand.params.clone(),Wheel.REPLACE_TYPE_FLIP,Nullable.NULL_FUNCTION);
         });
         return PromiseUtil.RESOLVED();
      }
   }
}

