package jackboxgames.settings
{
   import flash.utils.Dictionary;
   import jackboxgames.events.*;
   import jackboxgames.utils.*;
   
   public class SettingsManager extends PausableEventDispatcher
   {
      private static var _instance:SettingsManager;
      
      public static const EVENT_SETTING_CHANGED:String = "SettingChanged";
      
      private var _settingsValues:Dictionary;
      
      public function SettingsManager()
      {
         super();
         SettingsDataStore.instance.addEventListener(SettingsDataStore.EVENT_SETTING_DATA_CHANGED,this._onSettingDataChanged);
         this._settingsValues = new Dictionary();
      }
      
      public static function initialize() : void
      {
         _instance = new SettingsManager();
      }
      
      public static function get instance() : SettingsManager
      {
         return _instance;
      }
      
      public function getValue(key:String) : SettingsValue
      {
         var _this:SettingsManager = this;
         if(!this._settingsValues[key])
         {
            this._settingsValues[key] = new SettingsValue(function():*
            {
               return SettingsDataStore.instance.getData(key);
            },function(newVal:*):void
            {
               SettingsDataStore.instance.setData(key,newVal);
            },function():*
            {
               return SettingsDataStore.instance.getDefaultData(key);
            });
         }
         return this._settingsValues[key];
      }
      
      private function _onSettingDataChanged(evt:EventWithData) : void
      {
         var key:String = evt.data.key;
         var setting:SettingsValue = this.getValue(key);
         var oldVal:* = evt.data.oldVal;
         var newVal:* = evt.data.newVal;
         dispatchEvent(new EventWithData(EVENT_SETTING_CHANGED,{
            "settingName":key,
            "setting":setting,
            "oldVal":oldVal,
            "newVal":newVal
         }));
         if(Boolean(setting))
         {
            setting.dispatchEvent(new EventWithData(SettingsValue.EVENT_VALUE_CHANGED,{
               "oldVal":oldVal,
               "newVal":newVal
            }));
         }
      }
   }
}

