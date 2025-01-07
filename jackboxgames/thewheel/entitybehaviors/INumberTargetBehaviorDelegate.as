package jackboxgames.thewheel.entitybehaviors
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.data.NumberTargetData;
   
   public interface INumberTargetBehaviorDelegate
   {
      function get content() : NumberTargetData;
      
      function onPlayerGuessChanged(param1:Player, param2:int) : void;
      
      function onPlayerSubmittedGuess(param1:Player) : void;
   }
}

