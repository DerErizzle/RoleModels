package jackboxgames.talkshow.api
{
   public interface IActionPackageRef extends ILoadable
   {
      function get id() : int;
      
      function get name() : String;
      
      function get type() : String;
      
      function getAction(param1:int) : IAction;
      
      function get actionPackage() : IActionPackage;
      
      function getExport() : IExport;
   }
}

