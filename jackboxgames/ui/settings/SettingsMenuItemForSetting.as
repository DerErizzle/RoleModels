package jackboxgames.ui.settings
{
   import flash.display.MovieClip;
   import jackboxgames.events.*;
   import jackboxgames.settings.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class SettingsMenuItemForSetting extends SettingsMenuItem
   {
      protected var _description:ExtendableTextField;
      
      protected var _settingValue:SettingsValue;
      
      public function SettingsMenuItemForSetting(mc:MovieClip, data:ISettingsMenuElementData, menuDelegate:ISettingsMenuItemDelegate)
      {
         super(mc,data,menuDelegate);
         this._description = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.description);
         this._settingValue = SettingsManager.instance.getValue(this._itemData.source);
         this._settingValue.addEventListener(SettingsValue.EVENT_VALUE_CHANGED,_onSettingUpdated);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._description.dispose();
         this._description = null;
         this._settingValue.removeEventListener(SettingsValue.EVENT_VALUE_CHANGED,_onSettingUpdated);
         this._settingValue = null;
      }
      
      protected function get _itemData() : SettingsMenuConfigItem
      {
         return SettingsMenuConfigItem(_data);
      }
      
      protected function _updateDescription() : void
      {
         this._description.text = this._itemData.description;
      }
      
      protected function _getIconFrame() : String
      {
         return this._itemData.source;
      }
      
      override public function onLocaleChanged() : void
      {
         super.onLocaleChanged();
         this._updateDescription();
      }
      
      override public function update(instant:Boolean = false) : void
      {
         super.update(instant);
         this._updateDescription();
         if(Boolean(_mc.icon) && MovieClipUtil.frameExists(_mc.icon.content,this._getIconFrame()))
         {
            JBGUtil.gotoFrame(_mc.icon.content,this._getIconFrame());
            JBGUtil.gotoFrame(_mc.icon,this._settingValue.val ? "Appear" : "Disappear");
         }
      }
   }
}

