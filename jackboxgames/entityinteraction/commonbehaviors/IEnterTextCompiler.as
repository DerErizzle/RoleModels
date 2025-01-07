package jackboxgames.entityinteraction.commonbehaviors
{
   import jackboxgames.model.JBGPlayer;
   
   public interface IEnterTextCompiler
   {
      function setup(param1:Array) : void;
      
      function canAdd(param1:JBGPlayer, param2:String) : Boolean;
      
      function add(param1:JBGPlayer, param2:String) : void;
      
      function playerIsDone(param1:JBGPlayer) : Boolean;
      
      function get payload() : *;
   }
}

