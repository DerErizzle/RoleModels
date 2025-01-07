package jackboxgames.ui.settings
{
   import flash.display.MovieClip;
   import jackboxgames.localizy.*;
   
   public class SettingsMenuLanguageItem extends SettingsMenuListItem
   {
      private var _icons:Array;
      
      private var _displayValues:Array;
      
      public function SettingsMenuLanguageItem(mc:MovieClip, data:ISettingsMenuElementData, menu:SettingsMenu)
      {
         super(mc,data,menu);
         this._icons = _itemData.icons.concat();
         _options = _itemData.values.concat();
         this._displayValues = _itemData.options.concat();
         _valueTf.text = LocalizationManager.instance.getValueForKey("LANGUAGE_NAME",SettingsMenu.SETTINGS_LOCALIZATION_SOURCE);
      }
      
      override protected function _getIconFrame() : String
      {
         return this._icons[selectedIndex];
      }
      
      override public function onLocaleChanged() : void
      {
         super.onLocaleChanged();
         _valueTf.text = LocalizationManager.instance.getValueForKey("LANGUAGE_NAME",SettingsMenu.SETTINGS_LOCALIZATION_SOURCE);
      }
      
      override public function update(instant:Boolean = false) : void
      {
         super.update(instant);
         _valueTf.text = LocalizationManager.instance.getValueForKey("LANGUAGE_NAME",SettingsMenu.SETTINGS_LOCALIZATION_SOURCE);
      }
   }
}

