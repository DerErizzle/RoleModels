package jackboxgames.configuration
{
   import jackboxgames.nativeoverride.*;
   import jackboxgames.services.*;
   
   public class AppConfigSource implements IConfigSource
   {
      private var _restAPI:RestAPI;
      
      private var _serverConfig:Object;
      
      public function AppConfigSource()
      {
         super();
      }
      
      public function load(earlyLookupFn:Function, doneFn:Function) : void
      {
         var version:String;
         var platform:String;
         var params:Object;
         var domainWithAPIVersion:String;
         var domain:String = earlyLookupFn("serverUrl");
         var protocol:String = earlyLookupFn("protocol");
         var appId:String = earlyLookupFn("gameName");
         if(!domain || !protocol || !appId)
         {
            doneFn();
            return;
         }
         version = earlyLookupFn("uaVersionId");
         platform = Platform.instance.PlatformId;
         params = {};
         if(Boolean(version))
         {
            params.app_version = version;
         }
         if(Boolean(platform))
         {
            params.platform = platform;
         }
         domainWithAPIVersion = domain + "/api/v2";
         this._restAPI = new RestAPI(domainWithAPIVersion,protocol + "://");
         this._restAPI.GET("/app-configs/" + appId,params,function(result:Object):void
         {
            if(!result.ok || !result.body || !result.body.settings)
            {
               _serverConfig = null;
               doneFn();
               return;
            }
            _serverConfig = result.body.settings;
            doneFn();
         });
      }
      
      public function hasValueForKey(key:String) : Boolean
      {
         return Boolean(this._serverConfig) ? Boolean(this._serverConfig.hasOwnProperty(key)) : false;
      }
      
      public function getValueForKey(key:String) : *
      {
         return Boolean(this._serverConfig) ? this._serverConfig[key] : null;
      }
   }
}

