package jackboxgames.localizy
{
   import jackboxgames.events.*;
   import jackboxgames.loader.*;
   import jackboxgames.logger.*;
   import jackboxgames.settings.*;
   import jackboxgames.utils.*;
   
   public class LocalizationManager extends PausableEventDispatcher
   {
      private static var _instance:LocalizationManager;
      
      public static var GameSource:String = "";
      
      public static const EVENT_LOAD_COMPLETE:String = "LocalizationManager.LoadComplete";
      
      public static const EVENT_LOCALE_CHANGED:String = "LocalizationManager.LocaleChanged";
      
      public static const SETTING_LOCALE:String = "Locale";
      
      public static const DEFAULT_LOCALE:String = "en";
      
      public static const LOCALIZATION_FILE:String = "Localization.json";
      
      private var _currentLocale:String;
      
      private var _localizationPerSource:Object;
      
      private var _supportedLocales:Object;
      
      public function LocalizationManager()
      {
         super();
         this._currentLocale = defaultLocale;
         this._localizationPerSource = {};
         this._supportedLocales = {};
         var localeVal:SettingsValue = SettingsManager.instance.getValue(SETTING_LOCALE);
         localeVal.addEventListener(SettingsValue.EVENT_VALUE_CHANGED,this._onLocaleChanged);
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
      
      public function load(url:String, source:String) : void
      {
         var _this:LocalizationManager = null;
         this._localizationPerSource[source] = {};
         this._supportedLocales[source] = [];
         _this = this;
         JBGLoader.instance.loadFile(url,function(result:Object):void
         {
            _localizationPerSource[source] = null;
            if(Boolean(result.success))
            {
               _localizationPerSource[source] = result.loader.contentAsJSON;
            }
            _this.dispatchEvent(new EventWithData(EVENT_LOAD_COMPLETE,result));
         });
      }
      
      public function unload(source:String) : void
      {
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
            Logger.info("Already using locale \"" + value + "\".");
            return;
         }
         if(this.supportedLocales.indexOf(value) < 0)
         {
            Logger.info("Trying to set an unsupported locale \"" + value + "\". Keeping \"" + this._currentLocale + "\" instead.");
            return;
         }
         Logger.info("Switching to locale \"" + value + "\".");
         this._currentLocale = value;
         dispatchEvent(new EventWithData(EVENT_LOCALE_CHANGED,{"locale":this._currentLocale}));
      }
      
      private function _onLocaleChanged(event:EventWithData) : void
      {
         var newLocale:String = event.data.newVal;
         this.currentLocale = event.data.newVal;
      }
      
      private function _getDataForKey(key:String, source:String, strict:Boolean = false) : *
      {
         if(source == null)
         {
            source = GameSource;
         }
         var _data:Object = this._localizationPerSource[source];
         if(!_data || !_data.hasOwnProperty("table"))
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
            if(strict || this._currentLocale == defaultLocale)
            {
               return null;
            }
            return "(" + this._currentLocale + ")" + (Boolean(_data.table[defaultLocale].hasOwnProperty(key)) ? _data.table[defaultLocale][key] : "[\"" + key + "\"]");
         }
         return _data.table[this._currentLocale][key];
      }
      
      public function getLinesForKey(key:String, source:String = null) : Array
      {
         var data:Array;
         var _data:* = this._getDataForKey(key,source);
         if(_data == null)
         {
            return null;
         }
         data = _data is Array ? _data : [_data];
         if(BuildConfig.instance.configVal("pseudoLocale"))
         {
            data.forEach(function(value:String, index:int, array:Array):void
            {
               array[index] = LocalizationUtil.pseudoLocalize(value);
            });
         }
         return data;
      }
      
      public function hasValueForKey(key:String, source:String = null) : Boolean
      {
         return this._getDataForKey(key,source,true) != null;
      }
      
      public function getValueForKey(key:String, source:String = null) : String
      {
         var altKey:String = null;
         var stackTrace:String = null;
         var _data:* = this._getDataForKey(key,source);
         if(_data == null)
         {
            if(key == null)
            {
               TraceUtil.backTrace("LocalizationManager.getValueForKey");
               return "(null)";
            }
            altKey = key.toUpperCase().replace(/[^A-Z_0-9]+/g,"_");
            if(altKey != key && this.getValueForKey(altKey,source) != null)
            {
               stackTrace = new Error().getStackTrace();
               Logger.error("Did you mean \"" + altKey + "\"? Called from: " + stackTrace);
            }
            return key;
         }
         var value:String = _data is Array ? ArrayUtil.getRandomElement(_data) : _data;
         if(BuildConfig.instance.configVal("pseudoLocale"))
         {
            value = LocalizationUtil.pseudoLocalize(value);
         }
         else if(BuildConfig.instance.configVal("showLocaleKeys"))
         {
            value = "~" + key + "~";
         }
         return value;
      }
      
      public function getText(key:String, source:String = null) : String
      {
         return this.getValueForKey(key,source);
      }
      
      public function hasDataFor(source:String) : Boolean
      {
         var _data:Object = this._localizationPerSource[source];
         return Boolean(_data) && Boolean(_data.hasOwnProperty("table"));
      }
      
      public function get supportedLocales() : Array
      {
         var locale:String = null;
         var source:String = GameSource;
         var _data:Object = this._localizationPerSource[source];
         if(!_data || !_data.hasOwnProperty("table"))
         {
            return [];
         }
         if(this._supportedLocales[source].length == 0)
         {
            for(locale in _data.table)
            {
               if(!ObjectUtil.isEmpty(_data.table[locale]))
               {
                  this._supportedLocales[source].push(locale);
                  Logger.debug("Found locale: " + locale + " in " + source);
               }
            }
         }
         return this._supportedLocales[source];
      }
   }
}

