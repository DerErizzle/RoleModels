package jackboxgames.entityinteraction.commonbehaviors
{
   import jackboxgames.model.JBGPlayer;
   
   public interface IEnterTextDataDelegate
   {
      function get maxLength() : int;
      
      function get filterContent() : Boolean;
      
      function getEnterTextCategory(param1:JBGPlayer) : String;
      
      function getEnterTextPrompt(param1:JBGPlayer) : String;
      
      function getEnterTextPlaceholder(param1:JBGPlayer) : String;
      
      function getEnterTextSubmitText(param1:JBGPlayer) : String;
      
      function getEnterTextDoneText(param1:JBGPlayer) : String;
   }
}

