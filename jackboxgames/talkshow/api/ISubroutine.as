package jackboxgames.talkshow.api
{
   public interface ISubroutine extends IFlowchart
   {
      function getSubroutineParams() : Array;
      
      function get firstCell() : ICell;
      
      function setLocalVariableObject(param1:Object) : void;
   }
}

