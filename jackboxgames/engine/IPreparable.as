package jackboxgames.engine
{
   public interface IPreparable
   {
      function get needsPrepare() : Boolean;
      
      function get prepareFailError() : String;
      
      function prepare(param1:String, param2:Function) : void;
      
      function prepareDone(param1:Boolean) : void;
   }
}

