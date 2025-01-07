package jackboxgames.thewheel.wheel
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.utils.ICloneable;
   
   public interface ISliceData extends ICloneable
   {
      function setup(param1:Player) : void;
      
      function get name() : String;
      
      function get description() : String;
      
      function isSliceVisibleToController(param1:Player, param2:String) : Boolean;
      
      function getControllerData(param1:Player, param2:String) : Object;
   }
}

