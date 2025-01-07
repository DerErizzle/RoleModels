package jackboxgames.nativeoverride
{
   import flash.external.ExternalInterface;
   import flash.utils.getTimer;
   import jackboxgames.engine.IPreparable;
   import jackboxgames.events.*;
   import jackboxgames.localizy.*;
   import jackboxgames.logger.*;
   import jackboxgames.utils.*;
   
   public class Platform extends PausableEventDispatcher implements IPreparable
   {
      private static var _instance:Platform;
      
      public static const MESSAGE_BACKGROUND_STATE_CHANGED:String = "BackgroundStateChanged";
      
      public static const MESSAGE_SET_FULLSCREEN:String = "SetFullScreen";
      
      public static const MESSAGE_HANDLE_ERROR:String = "HandleError";
      
      public static const MESSAGE_RETURN_TO_START:String = "ReturnToStart";
      
      public static const MESSAGE_CHANGE_USER:String = "ChangeUser";
      
      public static const MESSAGE_USER_ACCESS:String = "UserAccess";
      
      public static const EVENT_NATIVE_MESSAGE_RECEIVED:String = "Platform.NativeMessagedReceived";
      
      public static const EVENT_URL_RECEIVED:String = "Platform.URLReceived";
      
      public static const PLATFORM_FIDELITY_LOW:String = "LOW";
      
      public static const PLATFORM_FIDELITY_MEDIUM:String = "MEDIUM";
      
      public static const PLATFORM_FIDELITY_HIGH:String = "HIGH";
      
      private static var _platformId:String = null;
      
      private static var _platformIdUpperCase:String = null;
      
      private static var _platformLocale:String = null;
      
      private static var _platformFidelity:String = null;
      
      private var _prepareFailError:String;
      
      private var _prepareDoneFn:Function;
      
      public var getPlatformIdNative:Function = null;
      
      public var getPlatformLocaleNative:Function = null;
      
      public var getPlatformFidelityNative:Function = null;
      
      public var getPlatformHasTouchscreenNative:Function = null;
      
      public var supportsWindowNative:Function = null;
      
      public var getCommandLineArgumentsNative:Function = null;
      
      public var getConfigNative:Function = null;
      
      public var getScreenDimensionsNative:Function = null;
      
      public var getTimerNative:Function = null;
      
      public var openURLNative:Function = null;
      
      public var getPushNotificationTokenNative:Function = null;
      
      public var sendLogToNativeNative:Function = null;
      
      public var sendMessageToNativeNative:Function = null;
      
      public var hideSplashScreenNative:Function = null;
      
      public var getLastInputTypeNative:Function = null;
      
      public var needsUserNative:Function = null;
      
      public var getUserNative:Function = null;
      
      public var getUserHasAccessNative:Function = null;
      
      public var isUserOfflineNative:Function = null;
      
      private var _checkPrivilegeDoneFn:Function = null;
      
      public var checkPrivilegeNative:Function = null;
      
      public var getPlatformInformationNative:Function = null;
      
      private var _userIsBlockedDoneFn:Function = null;
      
      public var userIsBlockedNative:Function = null;
      
      public function Platform()
      {
         this.PLATFORM_FIDELITY_SUPPORTED = [PLATFORM_FIDELITY_LOW,PLATFORM_FIDELITY_MEDIUM,PLATFORM_FIDELITY_HIGH];
         this.PLATFORMS_THAT_ARE_CONSOLES = ["XBONE","PS3","PS4","PS5"];
         this.PLATFORMS_THAT_ARE_SET_TOP_BOXES = ["AFT","AFTM","OUYA","GOOGLETV"];
         this.PLATFORMS_THAT_ARE_HANDHELD_DEVICES = ["IOS","ANDROID"];
         this.PLATFORMS_THAT_ARE_HANDHELD_ANDROID_DEVICES = ["ANDROID"];
         this.PLATFORMS_THAT_ARE_HANDHELD_IOS_DEVICES = ["IOS"];
         this.USER_AGENTS = {
            "PS3":"Mozilla/5.0 (PLAYSTATION 3 4.21) AppleWebKit/531.22.8 (KHTML, like Gecko)",
            "PS4":"Mozilla/5.0 (PlayStation 4 1.51) AppleWebKit/536.26 (KHTML, like Gecko)",
            "XBONE":"Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0; Xbox; Xbox One)",
            "IOS":"Mozilla/5.0 (iPad; CPU OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53",
            "ANDROID":"Mozilla/5.0 (Linux; Android 4.3; Nexus 10 Build/JWR66Y) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.72 Safari/537.36",
            "GOOGLETV":"Mozilla/5.0 (Linux; Android 4.3; Nexus 10 Build/JWR66Y) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.72 Safari/537.36",
            "AFT":"Mozilla/5.0 (Linux; U; Android 2.3.4; en-us; Kindle Fire Build/GINGERBREAD) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1",
            "OUYA":"Mozilla/5.0 (Linux; U; Android OUYA 4.1.2; en-us; OUYA Build/JZO54L-OUYA) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Safari/534.30"
         };
         super();
         if(!EnvUtil.isAIR())
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("InitializeNativeOverride","Platform",this);
            }
         }
      }
      
      public static function get instance() : Platform
      {
         if(!_instance)
         {
            _instance = new Platform();
         }
         return _instance;
      }
      
      public static function Initialize() : void
      {
      }
      
      public function get needsPrepare() : Boolean
      {
         return true;
      }
      
      public function get prepareFailError() : String
      {
         return this._prepareFailError;
      }
      
      public function prepare(id:String, doneFn:Function) : void
      {
         this._prepareFailError = "";
         this._prepareDoneFn = doneFn;
         if(Platform.instance.needsUser && !Platform.instance.user)
         {
            this.sendMessageToNative("LaunchAccountPicker",id);
            this._prepareFailError = "";
            this._prepareDoneFn(false);
            return;
         }
         if(!Platform.instance.userHasAccess)
         {
            this._prepareDoneFn(false);
            return;
         }
         if(BuildConfig.instance.configVal("require-start-privilege"))
         {
            this.checkPrivilege("Start",function(success:Boolean):void
            {
               _prepareDoneFn(success);
            });
         }
         else
         {
            this._prepareDoneFn(true);
         }
      }
      
      public function prepareDone(success:Boolean) : void
      {
         Logger.debug("Platform::prepareDone( " + success + " )");
         this._prepareDoneFn(success);
      }
      
      public function get PlatformId() : String
      {
         if(_platformId != null)
         {
            return _platformId;
         }
         if(this.getPlatformIdNative == null)
         {
            return "None";
         }
         _platformId = this.getPlatformIdNative();
         _platformIdUpperCase = _platformId.toUpperCase();
         return _platformId;
      }
      
      public function get PlatformIdUpperCase() : String
      {
         if(_platformIdUpperCase != null)
         {
            return _platformIdUpperCase;
         }
         return this.PlatformId.toUpperCase();
      }
      
      public function get PlatformLocale() : String
      {
         if(_platformLocale != null)
         {
            return _platformLocale;
         }
         if(this.getPlatformLocaleNative == null)
         {
            return LocalizationManager.defaultLocale;
         }
         _platformLocale = this.getPlatformLocaleNative();
         return _platformLocale;
      }
      
      public function get PlatformFidelity() : String
      {
         if(_platformFidelity != null)
         {
            return _platformFidelity;
         }
         if(this.getPlatformFidelityNative == null)
         {
            return "HIGH";
         }
         _platformFidelity = this.getPlatformFidelityNative();
         if(this.PLATFORM_FIDELITY_SUPPORTED.indexOf(_platformFidelity) < 0)
         {
            Logger.error("Unsupported platform fidelity of: " + _platformFidelity + ". Using " + PLATFORM_FIDELITY_HIGH + " instead");
            _platformFidelity = PLATFORM_FIDELITY_HIGH;
         }
         return _platformFidelity;
      }
      
      public function get PlatformHasTouchscreen() : Boolean
      {
         if(this.getPlatformHasTouchscreenNative == null)
         {
            return true;
         }
         return this.getPlatformHasTouchscreenNative();
      }
      
      public function get supportsWindow() : Boolean
      {
         if(this.supportsWindowNative == null)
         {
            return EnvUtil.isAIR();
         }
         return this.supportsWindowNative();
      }
      
      public function get PlatformUserAgent() : String
      {
         var platform:String = this.PlatformId;
         if(this.USER_AGENTS.hasOwnProperty(platform))
         {
            return this.USER_AGENTS(platform);
         }
         return "None";
      }
      
      public function get isConsole() : Boolean
      {
         return this.PlatformId != null ? this.PLATFORMS_THAT_ARE_CONSOLES.indexOf(_platformIdUpperCase) >= 0 : false;
      }
      
      public function get isFlash() : Boolean
      {
         return this.PlatformId != null ? this.PlatformId == "flash" : false;
      }
      
      public function get isSetTopBox() : Boolean
      {
         return this.PlatformId != null ? this.PLATFORMS_THAT_ARE_SET_TOP_BOXES.indexOf(_platformIdUpperCase) >= 0 : false;
      }
      
      public function get isHandheld() : Boolean
      {
         return this.PlatformId != null ? this.PLATFORMS_THAT_ARE_HANDHELD_DEVICES.indexOf(_platformIdUpperCase) >= 0 : false;
      }
      
      public function get isHandheldAndroid() : Boolean
      {
         return this.PlatformId != null ? this.PLATFORMS_THAT_ARE_HANDHELD_ANDROID_DEVICES.indexOf(_platformIdUpperCase) >= 0 : false;
      }
      
      public function get isHandheldIos() : Boolean
      {
         return this.PlatformId != null ? this.PLATFORMS_THAT_ARE_HANDHELD_IOS_DEVICES.indexOf(_platformIdUpperCase) >= 0 : false;
      }
      
      public function get commandLineArguments() : Object
      {
         if(this.getCommandLineArgumentsNative == null)
         {
            return {};
         }
         return this.getCommandLineArgumentsNative();
      }
      
      public function get config() : Object
      {
         if(this.getConfigNative == null)
         {
            return {};
         }
         return this.getConfigNative();
      }
      
      public function get screenDimensions() : Object
      {
         if(this.getScreenDimensionsNative == null)
         {
            return null;
         }
         return this.getScreenDimensionsNative();
      }
      
      public function getTimer() : uint
      {
         if(this.getTimerNative == null)
         {
            return getTimer();
         }
         return this.getTimerNative();
      }
      
      public function openURL(url:String) : void
      {
         if(this.openURLNative != null)
         {
            this.openURLNative(url);
         }
      }
      
      public function get pushNotificationToken() : String
      {
         if(this.getPushNotificationTokenNative != null)
         {
            return this.getPushNotificationTokenNative();
         }
         return null;
      }
      
      public function sendLogToNative(message:String) : void
      {
         if(this.sendLogToNativeNative != null)
         {
            this.sendLogToNativeNative(message);
         }
      }
      
      public function sendMessageToNative(message:String, parameter:*) : void
      {
         if(this.sendMessageToNativeNative != null)
         {
            this.sendMessageToNativeNative(message,parameter);
         }
      }
      
      public function onNativeMessageReceived(message:String, parameter:*) : void
      {
         Logger.debug("Platform::onNativeMessageReceived w/ message => " + message + ", " + TraceUtil.objectRecursive(parameter,"parameter"));
         dispatchEvent(new EventWithData(EVENT_NATIVE_MESSAGE_RECEIVED,{
            "message":message,
            "parameter":parameter
         }));
         dispatchEvent(new EventWithData(message,parameter));
      }
      
      public function onURLReceived(page:String, parameters:Object) : void
      {
         dispatchEvent(new EventWithData(EVENT_URL_RECEIVED,{
            "page":page,
            "parameters":parameters
         }));
      }
      
      public function hideSplashScreen() : void
      {
         if(!EnvUtil.isAIR())
         {
            ExternalInterface.call("hideLoader");
         }
         if(this.hideSplashScreenNative == null)
         {
            return;
         }
         this.hideSplashScreenNative();
      }
      
      public function get lastInputType() : String
      {
         if(this.getLastInputTypeNative != null)
         {
            return this.getLastInputTypeNative();
         }
         return null;
      }
      
      public function get needsUser() : Boolean
      {
         if(this.needsUserNative == null)
         {
            return false;
         }
         return this.needsUserNative();
      }
      
      public function get user() : Object
      {
         if(this.getUserNative == null)
         {
            return null;
         }
         return this.getUserNative();
      }
      
      public function get userHasAccess() : Boolean
      {
         if(this.getUserHasAccessNative == null)
         {
            return true;
         }
         return this.getUserHasAccessNative();
      }
      
      public function get isUserOffline() : Boolean
      {
         if(this.isUserOfflineNative == null)
         {
            return false;
         }
         return this.isUserOfflineNative();
      }
      
      public function onCheckPrivilegeDone(success:Boolean) : void
      {
         if(this._checkPrivilegeDoneFn == null)
         {
            return;
         }
         this._checkPrivilegeDoneFn(success);
         this._checkPrivilegeDoneFn = null;
      }
      
      public function checkPrivilege(p:String, cb:Function) : void
      {
         if(this.checkPrivilegeNative == null)
         {
            cb(true);
            return;
         }
         if(this._checkPrivilegeDoneFn != null)
         {
            cb(false);
            return;
         }
         this._checkPrivilegeDoneFn = cb;
         this.checkPrivilegeNative(p);
      }
      
      public function get platformInformation() : Object
      {
         if(this.getPlatformInformationNative == null)
         {
            return {};
         }
         return this.getPlatformInformationNative();
      }
      
      public function onUserIsBlockedDone(isBlocked:Boolean, returnValue:int) : void
      {
         if(this._userIsBlockedDoneFn == null)
         {
            return;
         }
         this._userIsBlockedDoneFn(isBlocked,returnValue);
         this._userIsBlockedDoneFn = null;
      }
      
      public function userIsBlocked(userId:String, cb:Function) : void
      {
         if(this.userIsBlockedNative == null)
         {
            cb(false,0);
            return;
         }
         if(this._userIsBlockedDoneFn != null)
         {
            cb(true,-1);
            return;
         }
         this._userIsBlockedDoneFn = cb;
         this.userIsBlockedNative(userId);
      }
      
      public function parseMetrics() : Object
      {
         var platformInfo:Object = this.platformInformation;
         platformInfo.BuildVersion = BuildConfig.instance.configVal("buildVersion");
         return platformInfo;
      }
   }
}

