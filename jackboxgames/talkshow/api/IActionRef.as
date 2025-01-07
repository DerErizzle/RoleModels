package jackboxgames.talkshow.api
{
   public interface IActionRef
   {
      function get action() : IAction;
      
      function get isPrimary() : Boolean;
      
      function getValueByIndex(param1:int) : *;
      
      function getValueByName(param1:String) : *;
      
      function getPrimaryMediaParamValue() : IMediaParamValue;
      
      function start(param1:Boolean = false) : void;
      
      function end() : void;
   }
}

