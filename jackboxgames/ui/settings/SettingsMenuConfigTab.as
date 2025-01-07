package jackboxgames.ui.settings
{
   import jackboxgames.localizy.*;
   import jackboxgames.utils.*;
   
   public class SettingsMenuConfigTab implements ISettingsMenuElementData, IToSimpleObject
   {
      private var _data:Object;
      
      public function SettingsMenuConfigTab(data:Object)
      {
         super();
         this._data = data;
      }
      
      public static function fromSimpleObject(o:Object) : SettingsMenuConfigTab
      {
         return new SettingsMenuConfigTab(o);
      }
      
      public function get title() : String
      {
         return LocalizationManager.instance.getValueForKey(this._data.title,SettingsMenu.SETTINGS_LOCALIZATION_SOURCE);
      }
      
      public function get sources() : Array
      {
         return this._data.sources;
      }
      
      public function toSimpleObject() : Object
      {
         return this._data;
      }
   }
}

