package jackboxgames.engine.componentLists
{
   import jackboxgames.engine.GameEngine;
   
   public interface IComponentList
   {
       
      
      function get components() : Array;
      
      function build(param1:GameEngine) : void;
   }
}
