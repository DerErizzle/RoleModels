package jackboxgames.ui.settings
{
   public interface ISettingsMenuItemDelegate
   {
      function get isListeningForInput() : Boolean;
      
      function handleSelectionRequest(param1:SettingsMenuItem) : void;
      
      function handleSwitchToTabRequest(param1:SettingsMenuConfigTab) : void;
   }
}

