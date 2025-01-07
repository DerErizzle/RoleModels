package jackboxgames.thewheel.wheel
{
   import jackboxgames.utils.Duration;
   
   public interface ISpinDelegate
   {
      function get currentPot() : Number;
      
      function set currentPot(param1:Number) : void;
      
      function setNumSpinsAndAnimateSpinMeter(param1:int, param2:Duration) : void;
   }
}

