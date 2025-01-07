package jackboxgames.thewheel.entitybehaviors
{
   import jackboxgames.thewheel.Player;
   
   public interface IWheelControllerDelegate
   {
      function get wheelId() : String;
      
      function getControllerSlices(param1:Player) : Array;
      
      function getControllerWheelSpin() : int;
      
      function get slicePositions() : Array;
      
      function setSliceVisualState(param1:int, param2:String) : void;
   }
}

