package jackboxgames.configuration
{
   import jackboxgames.loader.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class NativeOverrideSource implements IConfigSource
   {
      private var _config:Object;
      
      public function NativeOverrideSource()
      {
         super();
      }
      
      public function load(earlyLookupFn:Function, doneFn:Function) : void
      {
         this._config = Platform.instance.config;
         doneFn();
      }
      
      public function hasValueForKey(key:String) : Boolean
      {
         return Boolean(this._config) ? Boolean(this._config.hasOwnProperty(key)) : false;
      }
      
      public function getValueForKey(key:String) : *
      {
         return Boolean(this._config) ? this._config[key] : undefined;
      }
   }
}

