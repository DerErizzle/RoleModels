package jackboxgames.thewheel.entitybehaviors
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.data.TypingListData;
   
   public interface ITypingListBehaviorDelegate
   {
      function get content() : TypingListData;
      
      function getMappedGuesses(param1:Player) : Array;
      
      function playerHasGuessed(param1:Player, param2:int) : Boolean;
      
      function onPlayerGuessedCorrect(param1:Player, param2:int) : void;
      
      function onPlayerGuessedIncorrect(param1:Player, param2:String) : void;
      
      function onPlayerGuessedCorrectButGuessedAlready(param1:Player, param2:int) : void;
   }
}

