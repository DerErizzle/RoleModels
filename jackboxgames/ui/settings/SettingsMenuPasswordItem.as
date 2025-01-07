package jackboxgames.ui.settings
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.localizy.*;
   import jackboxgames.model.*;
   import jackboxgames.settings.*;
   import jackboxgames.ui.settings.components.*;
   import jackboxgames.utils.*;
   
   public class SettingsMenuPasswordItem extends SettingsMenuToggleItem
   {
      private var _passwordLabel:String;
      
      private var _passwordWidget:PasswordWidget;
      
      private var _passwordManager:RoomPasswordManager;
      
      public function SettingsMenuPasswordItem(mc:MovieClip, data:ISettingsMenuElementData, menu:SettingsMenu, passwordManager:RoomPasswordManager)
      {
         super(mc,data,menu);
         this._passwordManager = passwordManager;
         this._passwordWidget = new PasswordWidget(_mc.password,LocalizationManager.instance.getValueForKey(_itemData.password,SettingsMenu.SETTINGS_LOCALIZATION_SOURCE));
         this._passwordWidget.password.text = passwordManager.hasPasswordForSetting(_itemData.source) ? passwordManager.getPasswordForSetting(_itemData.source) : "";
         this._passwordManager.addEventListener(RoomPasswordManager.EVENT_PASSWORD_CHANGED,this._onPasswordChanged);
      }
      
      public function get passwordLabel() : String
      {
         return this._passwordLabel;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._passwordWidget.dispose();
         this._passwordManager.removeEventListener(RoomPasswordManager.EVENT_PASSWORD_CHANGED,this._onPasswordChanged);
      }
      
      override public function onLocaleChanged() : void
      {
         super.onLocaleChanged();
         this._passwordWidget.label.text = LocalizationManager.instance.getValueForKey(_itemData.password,SettingsMenu.SETTINGS_LOCALIZATION_SOURCE);
      }
      
      override public function update(instant:Boolean = false) : void
      {
         super.update(instant);
         if(instant)
         {
            this._passwordWidget.shower.behaviorTranslator = function(label:String):String
            {
               return label + "Static";
            };
         }
         else
         {
            this._passwordWidget.shower.behaviorTranslator = null;
         }
         this._passwordWidget.shower.setShown(_settingValue.val,function():void
         {
            _passwordWidget.shower.behaviorTranslator = null;
         });
      }
      
      private function _onPasswordChanged(evt:EventWithData) : void
      {
         if(evt.data.source != _itemData.source)
         {
            return;
         }
         if(evt.data.password != null)
         {
            this._passwordWidget.password.text = evt.data.password;
            this._passwordWidget.shower.setShown(true,Nullable.NULL_FUNCTION);
         }
         else
         {
            this._passwordWidget.shower.setShown(false,Nullable.NULL_FUNCTION);
         }
      }
   }
}

