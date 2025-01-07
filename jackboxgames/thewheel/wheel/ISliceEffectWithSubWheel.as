package jackboxgames.thewheel.wheel
{
   public interface ISliceEffectWithSubWheel extends ISliceEffect
   {
      function get bgClassName() : String;
      
      function get flapperClassName() : String;
      
      function fillWheel(param1:Wheel) : void;
   }
}

