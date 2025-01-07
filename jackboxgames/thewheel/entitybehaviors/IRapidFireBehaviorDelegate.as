package jackboxgames.thewheel.entitybehaviors
{
   import jackboxgames.model.JBGPlayer;
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.data.RapidFireData;
   
   public interface IRapidFireBehaviorDelegate
   {
      function get content() : RapidFireData;
      
      function onPlayerAnswered(param1:Player, param2:int) : Boolean;
      
      function playerIsFrozen(param1:JBGPlayer) : Boolean;
      
      function getChoicesForPlayer(param1:Player) : Array;
   }
}

