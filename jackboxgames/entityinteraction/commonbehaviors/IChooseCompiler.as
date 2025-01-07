package jackboxgames.entityinteraction.commonbehaviors
{
   import jackboxgames.model.JBGPlayer;
   
   public interface IChooseCompiler
   {
      function setupChooseCompiler(param1:Array) : void;
      
      function canAdd(param1:JBGPlayer, param2:int) : Boolean;
      
      function add(param1:JBGPlayer, param2:int) : void;
      
      function playerIsDone(param1:JBGPlayer) : Boolean;
      
      function get payload() : *;
   }
}

