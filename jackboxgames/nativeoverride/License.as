package jackboxgames.nativeoverride
{
   import flash.external.ExternalInterface;
   import jackboxgames.engine.IPreparable;
   import jackboxgames.events.EventWithData;
   import jackboxgames.utils.EnvUtil;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class License extends PausableEventDispatcher implements IPreparable
   {
      
      public static const EVENT_LICENSE_CHANGED:String = "License.LicenseChanged";
      
      private static var _instance:License;
       
      
      private var _prepareCallback:Function;
      
      public var prepareNative:Function = null;
      
      public var isDemoNative:Function = null;
      
      public var getPriceNative:Function = null;
      
      private var _purchaseCallback:Function = null;
      
      public var purchaseNative:Function = null;
      
      public function License()
      {
         super();
         if(!EnvUtil.isAIR())
         {
            ExternalInterface.call("InitializeNativeOverride","License",this);
         }
      }
      
      public static function Initialize() : void
      {
      }
      
      public static function get instance() : License
      {
         if(!_instance)
         {
            _instance = new License();
         }
         return _instance;
      }
      
      public function get prepareFailError() : String
      {
         return "LICENSE_ERROR";
      }
      
      public function get needsPrepare() : Boolean
      {
         return this.prepareNative != null;
      }
      
      public function prepare(id:String, doneFn:Function) : void
      {
         if(this.prepareNative != null)
         {
            this._prepareCallback = doneFn;
            this.prepareNative();
         }
         else if(doneFn != null)
         {
            doneFn(true);
         }
      }
      
      public function prepareDone(success:Boolean) : void
      {
         if(this._prepareCallback == null)
         {
            return;
         }
         var temp:Function = this._prepareCallback;
         this._prepareCallback = null;
         temp(success);
      }
      
      public function get isDemo() : Boolean
      {
         return this.isDemoNative != null ? this.isDemoNative() : false;
      }
      
      public function get price() : String
      {
         return this.getPriceNative != null ? this.getPriceNative() : "";
      }
      
      public function purchase(callback:Function) : void
      {
         if(this.purchaseNative != null)
         {
            this._purchaseCallback = callback;
            this.purchaseNative();
         }
         else if(this._purchaseCallback != null)
         {
            this._purchaseCallback(false);
         }
      }
      
      public function onPurchaseComplete(success:Boolean) : void
      {
         if(this._purchaseCallback == null)
         {
            return;
         }
         var temp:Function = this._purchaseCallback;
         this._purchaseCallback = null;
         temp(success);
      }
      
      public function onLicenseChanged(demo:Boolean) : void
      {
         dispatchEvent(new EventWithData(EVENT_LICENSE_CHANGED,{"IsDemo":demo}));
      }
   }
}
