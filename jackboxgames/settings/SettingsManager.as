package jackboxgames.settings
{
   import flash.utils.Dictionary;
   import jackboxgames.events.EventWithData;
   import jackboxgames.logger.Logger;
   import jackboxgames.nativeoverride.Save;
   import jackboxgames.utils.*;
   
   public class SettingsManager extends PausableEventDispatcher
   {
      
      public static const EVENT_SETTING_CHANGED:String = "SettingChanged";
      
      private static var _instance:SettingsManager;
       
      
      private const SETTINGS_MANAGER_KEY:String = "SETTINGS_MANAGER_KEY";
      
      private var _settingsValues:Dictionary;
      
      private var _initialValues:Object;
      
      private var _values:Object;
      
      public function SettingsManager(initialValues:Object)
      {
         var key:String = null;
         super();
         this._settingsValues = new Dictionary();
         this._initialValues = initialValues;
         this._values = Save.instance.loadGlobalObject(this.SETTINGS_MANAGER_KEY);
         if(!this._values)
         {
            this._values = JBGUtil.primitiveDeepCopy(initialValues);
         }
         for(key in this._initialValues)
         {
            if(this._values[key] == null)
            {
               this._values[key] = this._initialValues[key];
            }
         }
      }
      
      public static function initialize(initialValues:Object) : void
      {
         _instance = new SettingsManager(initialValues);
      }
      
      public static function get instance() : SettingsManager
      {
         return _instance;
      }
      
      public function setInitialValues(initialValues:Object) : void
      {
         var key:String = null;
         for(key in initialValues)
         {
            if(this._values[key] == null)
            {
               this._values[key] = initialValues[key];
            }
            if(this._initialValues[key] == null)
            {
               this._initialValues[key] = initialValues[key];
            }
         }
      }
      
      public function reloadFromSave() : void
      {
         var key:String = null;
         Logger.debug("Reloading from save...");
         var values:Object = Save.instance.loadGlobalObject(this.SETTINGS_MANAGER_KEY);
         if(!values)
         {
            trace("Could not find values, using initial ones");
            values = JBGUtil.primitiveDeepCopy(this._initialValues);
         }
         for(key in values)
         {
            Logger.debug(key + " = " + values[key]);
            this.getValue(key).val = values[key];
         }
      }
      
      public function getValue(key:String) : SettingsValue
      {
         var _this:SettingsManager = null;
         var potentialGameSpecificKey:String = BuildConfig.instance.configVal("gameName") + key;
         if(this._values.hasOwnProperty(potentialGameSpecificKey))
         {
            key = potentialGameSpecificKey;
         }
         _this = this;
         if(!this._settingsValues[key])
         {
            this._settingsValues[key] = new SettingsValue(function():*
            {
               return _values[key];
            },function(newVal:*):void
            {
               if(_values[key] == newVal)
               {
                  return;
               }
               var oldVal:* = _values[key];
               _values[key] = newVal;
               _this.dispatchEvent(new EventWithData(EVENT_SETTING_CHANGED,{
                  "settingName":key,
                  "setting":_settingsValues[key],
                  "oldVal":oldVal,
                  "newVal":newVal
               }));
               _settingsValues[key].dispatchEvent(new EventWithData(SettingsValue.EVENT_VALUE_CHANGED,{
                  "oldVal":oldVal,
                  "newVal":newVal
               }));
               Save.instance.saveGlobalObject(SETTINGS_MANAGER_KEY,_values);
            },function():*
            {
               return _initialValues[key];
            });
         }
         return this._settingsValues[key];
      }
   }
}
