package jackboxgames.thewheel.audience
{
   import jackboxgames.thewheel.Player;
   
   public interface IAudienceDataProvider
   {
      function get numSlices() : int;
      
      function get chosenTriviaWinner() : Player;
      
      function get earnedSlice() : Boolean;
   }
}

