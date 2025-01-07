package jackboxgames.ecast
{
   public class Analytics
   {
      private static var _instance:Analytics;
      
      private var _uaAppName:String;
      
      private var _uaAppVersion:String;
      
      private var _uaAppId:String;
      
      private var _analytics:Array;
      
      public function Analytics(appName:String, appId:String, appVersion:String)
      {
         super();
         this._uaAppName = appName;
         this._uaAppId = appId;
         this._uaAppVersion = appVersion;
         this._analytics = [];
      }
      
      public static function get instance() : Analytics
      {
         return _instance;
      }
      
      public static function initialize(appName:String, appId:String, appVersion:String) : void
      {
         _instance = new Analytics(appName,appId,appVersion);
      }
      
      public function get analytics() : Array
      {
         var copyToReturn:Array = this._analytics.concat();
         this._analytics = [];
         return copyToReturn;
      }
      
      public function uaEvent(eventCategory:String, eventAction:String, eventLabel:String = null, eventValue:* = null) : void
      {
         if(!this._uaAppName)
         {
            return;
         }
         var obj:Object = {
            "appname":this._uaAppName,
            "appid":this._uaAppId,
            "appversion":this._uaAppVersion,
            "category":eventCategory,
            "action":eventAction
         };
         if(eventLabel != null)
         {
            obj.label = eventLabel;
         }
         if(eventValue != null)
         {
            obj.value = eventValue;
         }
         this._analytics.push(obj);
      }
      
      public function uaScreen(screenName:String) : void
      {
         if(!this._uaAppName)
         {
            return;
         }
         var obj:Object = {
            "appname":this._uaAppName,
            "appid":this._uaAppId,
            "appversion":this._uaAppVersion,
            "screen":screenName
         };
         this._analytics.push(obj);
      }
   }
}

