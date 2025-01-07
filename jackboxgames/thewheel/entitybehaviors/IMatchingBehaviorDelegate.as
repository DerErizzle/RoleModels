package jackboxgames.thewheel.entitybehaviors
{
   import jackboxgames.model.JBGPlayer;
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.data.MatchingData;
   
   public interface IMatchingBehaviorDelegate
   {
      function get content() : MatchingData;
      
      function getControllerItemsForPlayer(param1:Player) : Array;
      
      function playerTriedToMatch(param1:Player, param2:int, param3:int) : Boolean;
      
      function playerIsFrozen(param1:JBGPlayer) : Boolean;
      
      function playerHasMatchedAll(param1:Player) : Boolean;
   }
}

