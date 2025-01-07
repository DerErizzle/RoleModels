package jackboxgames.configuration
{
   public interface IConfigSource
   {
      function load(param1:Function, param2:Function) : void;
      
      function hasValueForKey(param1:String) : Boolean;
      
      function getValueForKey(param1:String) : *;
   }
}

