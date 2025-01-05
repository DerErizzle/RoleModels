package jackboxgames.utils.audiosystem
{
   import jackboxgames.events.EventWithData;
   import jackboxgames.nativeoverride.AudioFaderGroup;
   import jackboxgames.nativeoverride.AudioSystem;
   import jackboxgames.settings.SettingsManager;
   import jackboxgames.settings.SettingsValue;
   import jackboxgames.utils.Nullable;
   
   public class FaderGroupSettingsHandler
   {
       
      
      private var _setting:SettingsValue;
      
      private var _faderGroup:AudioFaderGroup;
      
      private var _isActive:Boolean;
      
      public function FaderGroupSettingsHandler(setting:String, faderGroupName:String)
      {
         super();
         this._setting = SettingsManager.instance.getValue(setting);
         this._faderGroup = AudioSystem.instance.createFaderGroup(faderGroupName);
         this._faderGroup.load(Nullable.NULL_FUNCTION);
      }
      
      public function dispose() : void
      {
         this.setActive(false);
         AudioSystem.instance.disposeFaderGroup(this._faderGroup);
         this._faderGroup = null;
      }
      
      public function setActive(val:Boolean) : void
      {
         if(this._isActive == val)
         {
            return;
         }
         this._isActive = val;
         if(this._isActive)
         {
            this._setFaderGroupVolumeToSetting();
            this._setting.addEventListener(SettingsValue.EVENT_VALUE_CHANGED,this._onSettingChanged);
         }
         else
         {
            this._setting.removeEventListener(SettingsValue.EVENT_VALUE_CHANGED,this._onSettingChanged);
         }
      }
      
      private function _onSettingChanged(evt:EventWithData) : void
      {
         this._setFaderGroupVolumeToSetting();
      }
      
      private function _setFaderGroupVolumeToSetting() : void
      {
         this._faderGroup.volume = this._setting.val;
      }
   }
}
