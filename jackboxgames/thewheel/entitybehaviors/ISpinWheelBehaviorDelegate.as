package jackboxgames.thewheel.entitybehaviors
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.data.SpinType;
   
   public interface ISpinWheelBehaviorDelegate
   {
      function get spinWheelSpinner() : Player;
      
      function get spinWheelSpinTypeCategory() : String;
      
      function onWheelSpun(param1:Player, param2:SpinType) : void;
   }
}

