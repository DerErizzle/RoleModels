package jackboxgames.talkshow.api
{
   public interface IAction
   {
       
      
      function get id() : int;
      
      function get name() : String;
      
      function get actionPackage() : IActionPackageRef;
      
      function getParameter(param1:uint) : IParameter;
      
      function getPrimaryMediaParameterIdx() : int;
      
      function getParameterIdx(param1:IParameter) : int;
      
      function getParameterIdxByName(param1:String) : int;
   }
}
