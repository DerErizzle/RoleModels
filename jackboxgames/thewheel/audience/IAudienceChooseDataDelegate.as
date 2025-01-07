package jackboxgames.thewheel.audience
{
   public interface IAudienceChooseDataDelegate
   {
      function getAudienceChooseCategory() : String;
      
      function getAudienceChoosePrompt() : String;
      
      function getAudienceChooseChoices() : Array;
   }
}

