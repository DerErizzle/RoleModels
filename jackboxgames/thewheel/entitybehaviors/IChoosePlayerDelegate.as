package jackboxgames.thewheel.entitybehaviors
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.utils.PerPlayerContainer;
   
   public interface IChoosePlayerDelegate
   {
      function get choosePlayersPrompt() : String;
      
      function get playersToChooseFrom() : Array;
      
      function get numPlayersToChoose() : int;
      
      function get showSelectedPlayerWidgets() : Boolean;
      
      function onChoosePlayerSubmitted(param1:Player, param2:Array) : void;
      
      function onChoosePlayerDone(param1:PerPlayerContainer, param2:Boolean) : void;
   }
}

