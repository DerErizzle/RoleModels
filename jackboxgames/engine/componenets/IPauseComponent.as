package jackboxgames.engine.componenets
{
   public interface IPauseComponent
   {
       
      
      function get isPaused() : Boolean;
      
      function get canPause() : Boolean;
      
      function setPauseEnabled(param1:Boolean) : void;
      
      function setPauseType(param1:String) : void;
      
      function pause() : Boolean;
      
      function resume() : void;
   }
}
