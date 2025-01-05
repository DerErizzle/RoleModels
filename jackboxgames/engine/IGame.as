package jackboxgames.engine
{
   import flash.display.MovieClip;
   
   public interface IGame
   {
       
      
      function get gameName() : String;
      
      function get gameSavePrefix() : String;
      
      function get gamePath() : String;
      
      function get gameId() : String;
      
      function get serverUrl() : String;
      
      function get protocol() : String;
      
      function get main() : MovieClip;
      
      function get initialSettings() : Object;
      
      function get preventDispose() : Boolean;
      
      function init() : void;
      
      function dispose() : void;
      
      function start() : void;
      
      function restart() : void;
      
      function exit() : void;
      
      function doReset() : void;
      
      function setVisibility(param1:Boolean) : void;
      
      function onSetupFromNative(param1:String, param2:Boolean = false) : void;
   }
}
