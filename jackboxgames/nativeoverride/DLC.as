package jackboxgames.nativeoverride
{
   import flash.external.ExternalInterface;
   import jackboxgames.events.EventWithData;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class DLC extends PausableEventDispatcher
   {
      
      public static const EVENT_INSTALLED_DLC_CHANGED:String = "InstalledDLCChanged";
      
      private static var _instance:DLC;
       
      
      private var _prepareCallback:Function;
      
      public var prepareNative:Function;
      
      private var _getInstalledDLCCallback:Function;
      
      public var getInstalledDLCNative:Function;
      
      public var displayStoreFrontNative:Function;
      
      public function DLC()
      {
         super();
         if(ExternalInterface.available)
         {
            ExternalInterface.call("InitializeNativeOverride","DLC",this);
         }
      }
      
      public static function Initialize() : void
      {
         _instance = new DLC();
      }
      
      public static function get instance() : DLC
      {
         return _instance;
      }
      
      public function prepare(callback:Function) : void
      {
         if(this.prepareNative != null)
         {
            this._prepareCallback = callback;
            this.prepareNative();
         }
         else if(callback != null)
         {
            callback(true);
         }
      }
      
      public function onPrepareDone(success:Boolean) : void
      {
         if(this._prepareCallback != null)
         {
            this._prepareCallback(success);
            this._prepareCallback = null;
         }
      }
      
      public function getInstalledDLC(callback:Function) : void
      {
         if(this.getInstalledDLCNative != null)
         {
            this._getInstalledDLCCallback = callback;
            this.getInstalledDLCNative();
         }
         else if(callback != null)
         {
            callback([]);
         }
      }
      
      public function onGetInstalledDLCDone(dlc:Array) : void
      {
         if(this._getInstalledDLCCallback != null)
         {
            this._getInstalledDLCCallback(dlc);
            this._getInstalledDLCCallback = null;
         }
      }
      
      public function displayStoreFront() : void
      {
         if(this.displayStoreFrontNative == null)
         {
            return;
         }
         this.displayStoreFrontNative();
      }
      
      public function onInstalledDLCChanged(added:Array, removed:Array) : void
      {
         dispatchEvent(new EventWithData(EVENT_INSTALLED_DLC_CHANGED,{
            "added":added,
            "removed":removed
         }));
      }
   }
}
