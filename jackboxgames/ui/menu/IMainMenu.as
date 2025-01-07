package jackboxgames.ui.menu
{
   import flash.events.Event;
   import jackboxgames.settings.SettingsValue;
   import jackboxgames.ui.menu.components.IMainMenuItem;
   
   public interface IMainMenu
   {
      function get selectedIndex() : int;
      
      function get selectedItem() : IMainMenuItem;
      
      function get items() : Array;
      
      function show(param1:Function, param2:Object) : void;
      
      function dismiss(param1:Function, param2:Object) : void;
      
      function disableMenu() : void;
      
      function enableMenu() : void;
      
      function onPause(param1:Event) : void;
      
      function onResume(param1:Event) : void;
      
      function onMainMenuHighlight(param1:int, param2:int) : void;
      
      function onMainMenuSelect(param1:int, param2:String) : void;
      
      function onSettingChanged(param1:String, param2:SettingsValue) : void;
      
      function onSettingHighlight(param1:int, param2:int) : void;
      
      function onSettingsShown() : void;
      
      function onSettingsClosing() : void;
      
      function onSettingsClosed() : void;
   }
}

