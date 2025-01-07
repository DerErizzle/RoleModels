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
      
      function get settings() : Array;
      
      function get preventDispose() : Boolean;
      
      function init(param1:Function) : void;
      
      function dispose() : void;
      
      function start() : void;
      
      function restart() : void;
      
      function exit() : void;
      
      function doReset(param1:String = "") : void;
      
      function setVisibility(param1:Boolean) : void;
      
      function onSetupFromNative(param1:String, param2:Boolean = false) : void;
   }
}

