package jackboxgames.configuration
{
   import jackboxgames.loader.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class ConfigFileSource implements IConfigSource
   {
       
      
      private var _paths:Array;
      
      private var _config:Object;
      
      public function ConfigFileSource(paths:Array)
      {
         super();
         this._paths = paths;
      }
      
      public function load(earlyLookupFn:Function, doneFn:Function) : void
      {
         var loadFromPath:Function;
         var currentPathIndex:int = 0;
         this._config = {};
         loadFromPath = function(i:int):void
         {
            if(i >= _paths.length)
            {
               doneFn();
               return;
            }
            JBGLoader.instance.loadFile(_paths[i],function(result:Object):void
            {
               if(Boolean(result.success))
               {
                  _config = ObjectUtil.concat(_config,JSON.deserialize(result.data));
                  doneFn();
               }
               else
               {
                  loadFromPath(++i);
               }
            });
         };
         loadFromPath(0);
      }
      
      public function hasValueForKey(key:String) : Boolean
      {
         return Boolean(this._config) ? this._config.hasOwnProperty(key) : false;
      }
      
      public function getValueForKey(key:String) : *
      {
         return Boolean(this._config) ? this._config[key] : undefined;
      }
   }
}
