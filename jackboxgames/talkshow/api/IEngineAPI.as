package jackboxgames.talkshow.api
{
   import flash.display.Sprite;
   import flash.events.IEventDispatcher;
   import jackboxgames.talkshow.core.InputManager;
   
   public interface IEngineAPI extends ICodeSpace, IEventDispatcher
   {
      function toString() : String;
      
      function get uptime() : uint;
      
      function get activeExport() : IExport;
      
      function get videos() : ICanvas;
      
      function get overlay() : ICanvas;
      
      function get foreground() : ICanvas;
      
      function get background() : ICanvas;
      
      function get container() : Sprite;
      
      function getConfigInfo() : IConfigInfo;
      
      function get scriptBase() : String;
      
      function get pauser() : IPauseManager;
      
      function get internalActionPackage() : IActionPackageRef;
      
      function get flashVars() : Object;
      
      function get loadMonitor() : Object;
      
      function get screenManager() : IScreenManager;
      
      function get inputManager() : InputManager;
      
      function get locale() : String;
      
      function set locale(param1:String) : void;
      
      function stopAllActions() : void;
      
      function input(param1:String, param2:* = null) : void;
      
      function setVariableValue(param1:String, param2:*) : void;
      
      function jumpToCell(param1:String) : void;
      
      function loadCell(param1:String) : void;
      
      function getActionPackage(param1:String) : Object;
      
      function registerPlugin(param1:String, param2:Object) : void;
      
      function getPlugin(param1:String) : Object;
      
      function unregisterPlugin(param1:String) : void;
   }
}

