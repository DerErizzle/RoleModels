package jackboxgames.engine.componenets
{
   public interface ILaunchGameComponent
   {
      function launchGame(param1:String, param2:String, param3:String = "") : void;
      
      function hideLoader() : void;
   }
}

