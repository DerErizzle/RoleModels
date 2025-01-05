package jackboxgames.widgets.mainmenu
{
   import jackboxgames.settings.SettingsValue;
   
   public interface IMainMenuAudioHandler
   {
       
      
      function setup(param1:Object) : void;
      
      function shutdown() : void;
      
      function onMenuHighlightChanged(param1:int, param2:int) : void;
      
      function onMenuItemSelected(param1:int, param2:String) : void;
      
      function onSettingsMenuShownChanged(param1:Boolean) : void;
      
      function onSettingsMenuHighlightChanged(param1:int, param2:int) : void;
      
      function onSettingToggled(param1:String, param2:SettingsValue) : void;
   }
}
