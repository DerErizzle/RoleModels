package jackboxgames.talkshow.api
{
   import flash.events.IEventDispatcher;
   
   public interface IFlowchart extends IEventDispatcher, ILoadable
   {
       
      
      function get qualifiedID() : QualifiedID;
      
      function get fileName() : String;
      
      function get fileID() : String;
      
      function get id() : uint;
      
      function get flowchartName() : String;
      
      function evalCell(param1:uint) : void;
      
      function evalBranch(param1:uint, param2:uint, param3:*) : Boolean;
      
      function getCell(param1:String) : ICell;
      
      function getCellByID(param1:uint) : ICell;
      
      function getParentExport() : IExport;
   }
}
