package jackboxgames.thewheel.entitybehaviors
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.data.GuessingData;
   
   public interface IGuessingBehaviorDelegate
   {
      function get content() : GuessingData;
      
      function get revealedClues() : Array;
      
      function onPlayerGuessed(param1:Player, param2:String) : void;
      
      function hasPlayerGuessed(param1:Player) : Boolean;
   }
}

