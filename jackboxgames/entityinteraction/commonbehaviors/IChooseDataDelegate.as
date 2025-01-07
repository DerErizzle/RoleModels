package jackboxgames.entityinteraction.commonbehaviors
{
   import jackboxgames.model.JBGPlayer;
   
   public interface IChooseDataDelegate
   {
      function getChooseCategory(param1:JBGPlayer) : String;
      
      function getChoosePrompt(param1:JBGPlayer) : String;
      
      function getChooseChoices(param1:JBGPlayer) : Array;
   }
}

