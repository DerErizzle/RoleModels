package jackboxgames.localizy
{
   import jackboxgames.events.*;
   import jackboxgames.loader.*;
   import jackboxgames.logger.*;
   import jackboxgames.utils.*;
   
   public class LocalizationManager extends PausableEventDispatcher
   {
      
      public static var GameSource:String = "";
      
      public static const EVENT_LOAD_COMPLETE:String = "LocalizationManager.LoadComplete";
      
      public static const EVENT_LOCALE_CHANGED:String = "LocalizationManager.LocaleChanged";
      
      public static const SETTING_LOCALE:String = "Locale";
      
      public static const DEFAULT_LOCALE:String = "en";
      
      public static const LOCALIZATION_FILE:String = "Localization.json";
      
      public static const MAIN__LOCALIZATION_SOURCE:String = "Localization_Default";
      
      private static var _instance:LocalizationManager;
       
      
      private var _currentLocale:String;
      
      private var _localizationPerSource:Object;
      
      private var _supportedLocales:Object;
      
      public function LocalizationManager()
      {
         super();
         this._currentLocale = DEFAULT_LOCALE;
         this._localizationPerSource = {};
         this._supportedLocales = {};
      }
      
      public static function get defaultLocale() : String
      {
         return BuildConfig.instance.hasConfigVal("defaultLocale") ? BuildConfig.instance.configVal("defaultLocale") : LocalizationManager.DEFAULT_LOCALE;
      }
      
      public static function get instance() : LocalizationManager
      {
         if(!_instance)
         {
            _instance = new LocalizationManager();
         }
         return _instance;
      }
      
      public function load(url:String) : void
      {
         var source:String = null;
         var _this:LocalizationManager = null;
         source = GameSource;
         this._localizationPerSource[source] = {};
         this._supportedLocales[source] = [];
         _this = this;
         JBGLoader.instance.loadFile(url,function(result:Object):void
         {
            _localizationPerSource[source] = null;
            if(Boolean(result.success))
            {
               _localizationPerSource[source] = JSON.deserialize(result.data);
            }
            _this.dispatchEvent(new EventWithData(EVENT_LOAD_COMPLETE,result));
         });
      }
      
      public function unload() : void
      {
         var source:String = GameSource;
         this._localizationPerSource[source] = {};
         this._supportedLocales[source] = [];
         delete this._localizationPerSource[source];
         delete this._supportedLocales[source];
      }
      
      public function get currentLocale() : String
      {
         return this._currentLocale;
      }
      
      public function set currentLocale(value:String) : void
      {
         if(this._currentLocale == value)
         {
            return;
         }
         this._currentLocale = value;
         dispatchEvent(new EventWithData(EVENT_LOCALE_CHANGED,null));
      }
      
      private function _getDataForKey(key:String) : *
      {
         var source:String = GameSource;
         var _data:Object = this._localizationPerSource[source];
         if(!_data)
         {
            Logger.error("_getDataForKey (\"" + key + "\", \"" + source + "\") is missing source for: \"" + source + "\"!");
            return null;
         }
         if(!_data.table.hasOwnProperty(this._currentLocale))
         {
            Logger.error("_getDataForKey (\"" + key + "\", \"" + source + "\") is missing locale: \"" + this._currentLocale + "\"!");
            return null;
         }
         if(!_data.table[this._currentLocale].hasOwnProperty(key))
         {
            Logger.error("_getDataForKey (\"" + key + "\", \"" + source + "\" ) is missing key \"" + key + "\" for locale: \"" + this._currentLocale + "\"!");
            if(this._currentLocale == DEFAULT_LOCALE)
            {
               return null;
            }
            return "(" + this._currentLocale + ")" + (Boolean(_data.table[DEFAULT_LOCALE].hasOwnProperty(key)) ? _data.table[DEFAULT_LOCALE][key] : "[\"" + key + "\"]");
         }
         return _data.table[this._currentLocale][key];
      }
      
      public function getLinesForKey(key:String) : Array
      {
         var _data:* = this._getDataForKey(key);
         if(_data == null)
         {
            return null;
         }
         return _data is Array ? _data : [_data];
      }
      
      public function getValueForKey(key:String) : String
      {
         var _data:* = this._getDataForKey(key);
         if(_data == null)
         {
            return null;
         }
         return _data is Array ? ArrayUtil.getRandomElement(_data) : _data;
      }
      
      public function getText(key:String) : String
      {
         var stackTrace:String = null;
         var result:String = this.getValueForKey(key);
         if(result != null)
         {
            return result;
         }
         var altKey:String = key.toUpperCase().replace(/[^A-Z_0-9]+/g,"_");
         if(altKey != key && this.getValueForKey(altKey) != null)
         {
            stackTrace = new Error().getStackTrace();
            Logger.error("Did you mean \"" + altKey + "\"? Called from: " + stackTrace);
         }
         return key;
      }
      
      public function supportedLocales() : Array
      {
         var locale:String = null;
         var source:String = GameSource;
         var _data:Object = this._localizationPerSource[source];
         if(!_data)
         {
            return null;
         }
         if(this._supportedLocales[source] == null)
         {
            for(locale in _data)
            {
               this._supportedLocales[source].push(locale);
               Logger.debug("Found locale: " + locale + " in " + source);
            }
         }
         return this._supportedLocales[source];
      }
   }
}
