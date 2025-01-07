package jackboxgames.entityinteraction.commonbehaviors
{
   import jackboxgames.model.JBGPlayer;
   
   public interface IChooseEventDelegate
   {
      function setupChoose() : void;
      
      function onPlayerChose(param1:JBGPlayer, param2:int) : void;
      
      function onChooseDone(param1:*, param2:Boolean) : void;
   }
}

