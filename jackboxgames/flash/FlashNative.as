package jackboxgames.flash
{
   import flash.utils.getTimer;
   import jackboxgames.blobcast.client.BlobCastClient;
   import jackboxgames.nativeoverride.AudioSystem;
   import jackboxgames.nativeoverride.BlobCast;
   import jackboxgames.nativeoverride.DLC;
   import jackboxgames.nativeoverride.Gamepad;
   import jackboxgames.nativeoverride.Input;
   import jackboxgames.nativeoverride.JSON;
   import jackboxgames.nativeoverride.Platform;
   import jackboxgames.nativeoverride.Save;
   import jackboxgames.nativeoverride.Store;
   import jackboxgames.utils.StageRef;
   
   public class FlashNative
   {
      
      public static const MAXIMUM_NUMBER_OF_GAMEPADS:int = 4;
      
      protected static var _blobCast:BlobCastClient;
      
      private static var _pauseDuration:uint = 0;
      
      private static var _pauseTime:uint = 0;
      
      private static var _isPaused:Boolean = false;
      
      private static var _inputCounter:int = 0;
       
      
      public function FlashNative()
      {
         super();
      }
      
      public static function Initialize(server:String, appId:String) : void
      {
         BlobCast.Initialize(server,appId);
         _blobCast = new BlobCastClient(BlobCast.instance);
         BlobCast.instance.createRoomNative = _blobCast.createRoom;
         BlobCast.instance.disconnectFromServiceNative = _blobCast.disconnectFromService;
         BlobCast.instance.joinRoomNative = _blobCast.joinRoom;
         BlobCast.instance.sendMessageToRoomOwnerNative = _blobCast.sendMessageToRoomOwner;
         BlobCast.instance.setCustomerBlobNative = _blobCast.setCustomer;
         BlobCast.instance.setRoomBlobNative = _blobCast.setRoomBlob;
         BlobCast.instance.lockRoomNative = _blobCast.lockRoom;
         BlobCast.instance.startSessionNative = _blobCast.startSession;
         BlobCast.instance.stopSessionNative = _blobCast.stopSession;
         BlobCast.instance.getSessionStatusNative = _blobCast.getSessionStatus;
         BlobCast.instance.sendSessionMessageNative = _blobCast.sendSessionMessage;
         BlobCast.instance.getUserIdNative = _blobCast.getUserId;
         BlobCast.instance.setLicenseNative = _blobCast.setLicense;
         Gamepad.Initialize();
         Gamepad.instance.ctorNative = ctorGamepad;
         Gamepad.instance.ctorNative();
         Gamepad.instance.getNumberOfJoysticksNative = getNumberOfJoysticks;
         Platform.instance.getPlatformIdNative = getPlatformId;
         Platform.instance.getPushNotificationTokenNative = getPushNotificationToken;
         Platform.instance.getScreenDimensionsNative = getScreenDimensions;
         Platform.instance.getTimerNative = getTimer;
         Platform.instance.hideSplashScreenNative = hideSplashScreen;
         Platform.instance.openURLNative = openURL;
         Platform.instance.sendMessageToNativeNative = sendMessageToNative;
         Platform.instance.getPlatformFidelityNative = getPlatformFidelity;
         Platform.instance.needsUserNative = needsUser;
         Platform.instance.getUserNative = getUser;
         Platform.instance.getUserHasAccessNative = getUserHasAccess;
         Platform.instance.isUserOfflineNative = isUserOffline;
         Save.instance.deleteObjectNative = deleteObject;
         Save.instance.deleteSecureStringNative = deleteSecureString;
         Save.instance.loadObjectNative = loadObject;
         Save.instance.loadSecureStringNative = loadSecureString;
         Save.instance.prepareNative = prepareSave;
         Save.instance.saveObjectNative = saveObject;
         Save.instance.saveSecureStringNative = saveSecureString;
         Store.instance.ctorNative = ctorStore;
         Store.instance.isEnabledNative = isEnabled;
         Store.instance.purchaseNative = purchase;
         Store.instance.releaseNative = release;
         Store.instance.restorePurchasesNative = restorePurchases;
         Store.instance.retrieveProductsNative = retrieveProducts;
         Store.instance.setJvidNative = setJvid;
         JSON.deserializeNative = JSON.parse;
         JSON.serializeNative = JSON.stringify;
         DLC.Initialize();
         DLC.instance.prepareNative = function():void
         {
            DLC.instance.onPrepareDone(true);
         };
         DLC.instance.getInstalledDLCNative = function():void
         {
            var dlcList:Array = [];
            DLC.instance.onGetInstalledDLCDone(dlcList);
         };
         DLC.instance.displayStoreFrontNative = function():void
         {
         };
         Input.instance.getKeyboardInputNative = getKeyboardInput;
         AudioSystem.Initialize();
      }
      
      public static function ctorGamepad() : void
      {
      }
      
      public static function getNumberOfJoysticks() : int
      {
         return InputManager.instance.gamepadsConnected ? 1 : 0;
      }
      
      public static function getPlatformId() : String
      {
         return "flash";
      }
      
      public static function getPushNotificationToken() : String
      {
         return null;
      }
      
      public static function getScreenDimensions() : Object
      {
         var object:Object = {};
         object.width = StageRef.stageWidth;
         object.height = StageRef.stageHeight;
         return object;
      }
      
      public static function pauseTimer() : void
      {
         _pauseTime = Platform.instance.getTimer();
         _isPaused = true;
      }
      
      public static function resumeTimer() : void
      {
         var currentTime:int = getTimer() - _pauseDuration;
         _pauseDuration += currentTime - _pauseTime;
         _isPaused = false;
         _pauseTime = Platform.instance.getTimer();
      }
      
      public static function getTimer() : uint
      {
         if(_isPaused)
         {
            return _pauseTime;
         }
         return getTimer() - _pauseDuration;
      }
      
      public static function hideSplashScreen() : void
      {
      }
      
      public static function openURL(url:String) : void
      {
      }
      
      public static function sendMessageToNative(message:String, parameter:*) : void
      {
      }
      
      public static function getPlatformFidelity() : String
      {
         return Platform.PLATFORM_FIDELITY_HIGH;
      }
      
      public static function needsUser() : Boolean
      {
         return false;
      }
      
      public static function getUser() : Object
      {
         return null;
      }
      
      public static function getUserHasAccess() : Boolean
      {
         return true;
      }
      
      public static function isUserOffline() : Boolean
      {
         return false;
      }
      
      public static function deleteObject(key:String) : void
      {
         SharedObjectUtil.instance.clearData(key);
      }
      
      public static function deleteSecureString(key:String) : void
      {
      }
      
      public static function loadObject(key:String) : Object
      {
         var id:String = null;
         var o:Object = SharedObjectUtil.instance.getData(key);
         var count:int = 0;
         for(id in o)
         {
            count++;
         }
         return count > 0 ? o : null;
      }
      
      public static function loadSecureString(key:String) : String
      {
         return null;
      }
      
      public static function prepareSave() : void
      {
         Save.instance.prepareDone(true);
      }
      
      public static function saveObject(key:String, obj:Object) : void
      {
         SharedObjectUtil.instance.writeData(key,obj);
      }
      
      public static function saveSecureString(key:String, s:String) : void
      {
      }
      
      public static function ctorStore() : void
      {
      }
      
      public static function retrieveProducts(storeIds:Array) : void
      {
      }
      
      public static function release() : void
      {
      }
      
      public static function purchase(productId:String) : void
      {
      }
      
      public static function isEnabled() : Boolean
      {
         return false;
      }
      
      public static function restorePurchases() : void
      {
      }
      
      public static function setJvid() : void
      {
      }
      
      public static function getKeyboardInput(inputText:String, title:String, message:String, hidden:Boolean, keyboardType:String) : void
      {
         Input.instance.onKeyboardInputReceived("Sparky" + _inputCounter);
         ++_inputCounter;
      }
      
      public static function prepareTrophy() : void
      {
      }
      
      public static function unlockTrophy(trophyName:String) : void
      {
      }
   }
}
