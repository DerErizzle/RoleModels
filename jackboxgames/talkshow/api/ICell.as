package jackboxgames.talkshow.api
{
   public interface ICell extends ILoadable
   {
      function get flowchart() : IFlowchart;
      
      function get id() : uint;
      
      function get target() : String;
      
      function start() : void;
   }
}

