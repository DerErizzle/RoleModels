package jackboxgames.thewheel.wheel
{
   import jackboxgames.algorithm.Promise;
   
   public interface ISliceEffect
   {
      function setup(param1:DoSpinResultParam, param2:SpinResult) : void;
      
      function evaluate() : Promise;
   }
}

