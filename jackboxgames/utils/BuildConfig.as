package jackboxgames.utils
{
   import jackboxgames.configuration.*;
   import jackboxgames.expressionparser.*;
   
   public class BuildConfig implements IExpressionDataDelegate
   {
      private static var _instance:BuildConfig;
      
      private var _sourcesInLoadOrder:Array;
      
      private var _sourcesInLookupOrder:Array;
      
      public function BuildConfig()
      {
         super();
      }
      
      public static function get instance() : BuildConfig
      {
         return Boolean(_instance) ? _instance : (_instance = new BuildConfig());
      }
      
      public function init(paths:Array) : void
      {
         var clSource:IConfigSource = new CommandLineSource();
         var nativeOverrideSource:IConfigSource = new NativeOverrideSource();
         var configFileSource:IConfigSource = new ConfigFileSource(paths);
         var appConfigSource:IConfigSource = new AppConfigSource();
         this._sourcesInLoadOrder = [clSource,nativeOverrideSource,configFileSource,appConfigSource];
         this._sourcesInLookupOrder = [appConfigSource,clSource,nativeOverrideSource,configFileSource];
      }
      
      public function load(doneFn:Function) : void
      {
         var i:int = 0;
         var loadedSources:Array = null;
         var loadCurrentSource:Function = function():void
         {
            var currentlyLoadingSource:IConfigSource = null;
            currentlyLoadingSource = _sourcesInLoadOrder[i];
            currentlyLoadingSource.load(function(key:String):*
            {
               return _getConfigValFromSources(key,loadedSources);
            },function():void
            {
               loadedSources.push(currentlyLoadingSource);
               ++i;
               if(i >= _sourcesInLoadOrder.length)
               {
                  doneFn();
               }
               else
               {
                  loadCurrentSource();
               }
            });
         };
         i = 0;
         loadedSources = [];
         loadCurrentSource();
      }
      
      public function hasConfigVal(key:String) : Boolean
      {
         var s:IConfigSource = null;
         for each(s in this._sourcesInLookupOrder)
         {
            if(s.hasValueForKey(key))
            {
               return true;
            }
         }
         return false;
      }
      
      private function _getConfigValFromSources(key:String, sources:Array) : *
      {
         var s:IConfigSource = null;
         var val:* = undefined;
         for each(s in sources)
         {
            if(s.hasValueForKey(key))
            {
               val = s.getValueForKey(key);
               if(val is String)
               {
                  val = this._convertFromString(val);
               }
               return val;
            }
         }
         return undefined;
      }
      
      private function _convertFromString(val:String) : *
      {
         if(val.toLowerCase() == "true")
         {
            return true;
         }
         if(val.toLowerCase() == "false")
         {
            return false;
         }
         return val;
      }
      
      public function configVal(key:String) : *
      {
         return this._getConfigValFromSources(key,this._sourcesInLookupOrder);
      }
      
      public function getKeywordValue(keyword:String) : *
      {
         return this.configVal(keyword);
      }
   }
}

