package jackboxgames.entityinteraction.commonbehaviors
{
   import jackboxgames.model.JBGPlayer;
   
   public interface IEnterTextEventDelegate
   {
      function setupEnterText() : void;
      
      function onPlayerEnteredText(param1:JBGPlayer, param2:String) : void;
      
      function onEnterTextDone(param1:*, param2:Boolean) : void;
   }
}

