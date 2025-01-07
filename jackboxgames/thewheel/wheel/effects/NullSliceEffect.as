package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.Promise;
   import jackboxgames.thewheel.wheel.DoSpinResultParam;
   import jackboxgames.thewheel.wheel.ISliceEffect;
   import jackboxgames.thewheel.wheel.SpinResult;
   import jackboxgames.utils.PromiseUtil;
   
   public class NullSliceEffect implements ISliceEffect
   {
      public function NullSliceEffect()
      {
         super();
      }
      
      public function setup(param:DoSpinResultParam, spinResult:SpinResult) : void
      {
      }
      
      public function get description() : String
      {
         return "";
      }
      
      public function evaluate() : Promise
      {
         return PromiseUtil.RESOLVED();
      }
   }
}

