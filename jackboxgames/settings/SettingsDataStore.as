package jackboxgames.settings
{
   import jackboxgames.events.*;
   import jackboxgames.intermoviecommunication.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class SettingsDataStore extends IMCModule
   {
      private static var _instance:SettingsDataStore;
      
      public static const EVENT_RELOADED_FROM_SAVE:String = "reloadedFromSave";
      
      public static const EVENT_SETTING_DATA_CHANGED:String = "SettingDataChanged";
      
      private const SETTINGS_KEY:String = "SETTINGS";
      
      private var _settingConfigs:Array;
      
      private var _values:Object;
      
      public function SettingsDataStore()
      {
         super("Settings",IMCModule.MOVIE_ID_MANAGER);
      }
      
      public static function initialize() : void
      {
         trace("Initializing data store: " + _instance);
         if(Boolean(_instance))
         {
            return;
         }
         _instance = new SettingsDataStore();
      }
      
      public static function get instance() : SettingsDataStore
      {
         return _instance;
      }
      
      override protected function _doPrimaryInitialization() : void
      {
         this.reloadFromSave();
      }
      
      public function setSettingConfigs(configs:Array) : void
      {
         _doFunctionBehavior("setSettingConfigs",function(configs:Array):void
         {
            _settingConfigs = configs;
         },configs);
      }
      
      public function reloadFromSave() : void
      {
         _doFunctionBehavior("reloadFromSave",function():void
         {
            _values = Save.instance.loadGlobalObject(SETTINGS_KEY);
            if(!_values)
            {
               _values = {};
            }
            dispatchEvent(new EventWithData(EVENT_RELOADED_FROM_SAVE,null));
         });
      }
      
      private function _getSettingConfig(key:String) : SettingConfig
      {
         return ArrayUtil.find(this._settingConfigs,function(s:SettingConfig, ... args):Boolean
         {
            return s.key == key;
         });
      }
      
      public function getData(key:String) : *
      {
         return _doFunctionBehavior("getData",function(key:String):*
         {
            var config:* = _getSettingConfig(key);
            if(!config)
            {
               return undefined;
            }
            var saveKey:* = config.saveKey;
            return !!_values.hasOwnProperty(saveKey) ? _values[saveKey] : config.defaultVal;
         },key);
      }
      
      public function getDefaultData(key:String) : *
      {
         return _doFunctionBehavior("getDefaultData",function(key:String):*
         {
            var config:* = _getSettingConfig(key);
            if(!config)
            {
               return undefined;
            }
            return config.defaultVal;
         },key);
      }
      
      public function setData(key:String, val:*) : void
      {
         _doFunctionBehavior("setData",function(key:String, val:*):void
         {
            var config:SettingConfig = _getSettingConfig(key);
            if(!config)
            {
               return;
            }
            var saveKey:String = config.saveKey;
            var oldVal:* = _values[saveKey];
            if(val == oldVal)
            {
               return;
            }
            _values[saveKey] = val;
            Save.instance.saveGlobalObject(SETTINGS_KEY,_values);
            dispatchEvent(new EventWithData(EVENT_SETTING_DATA_CHANGED,{
               "key":key,
               "oldVal":oldVal,
               "newVal":val
            }));
         },key,val);
      }
      
      public function parseMetrics() : Object
      {
         return _doFunctionBehavior("parseMetrics",function():Object
         {
            var metrics:* = undefined;
            metrics = {};
            _settingConfigs.forEach(function(s:SettingConfig, ... args):void
            {
               metrics[s.key] = getData(s.key);
            });
            return metrics;
         });
      }
   }
}

