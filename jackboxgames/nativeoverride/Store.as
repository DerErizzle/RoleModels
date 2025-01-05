package jackboxgames.nativeoverride
{
   import flash.external.ExternalInterface;
   import jackboxgames.events.EventWithData;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class Store extends PausableEventDispatcher
   {
      
      private static var _instance:Store;
      
      public static const EVENT_PRODUCTS_RETRIEVED:String = "Store.ProductsRetrieved";
      
      public static const EVENT_PURCHASE_SUCCESSFUL:String = "Store.PurchaseSuccessful";
      
      public static const EVENT_PURCHASE_FAILED:String = "Store.PurchaseFailed";
      
      public static const EVENT_PURCHASE_CANCELLED:String = "Store.PurchaseCancelled";
      
      public static const EVENT_PURCHASED_ITEM_DISCOVERED:String = "Store.ItemPurchased";
      
      public static const EVENT_RESTORE_PURCHASES_COMPLETE:String = "Store.RestorePurchasesComplete";
      
      private static const SAVED_PURCHASES_KEY:String = "SAVED_PURCHASES";
       
      
      private var _purchasedProducts:Array;
      
      private var _purchasableProducts:Array;
      
      public var ctorNative:Function = null;
      
      public var setJvidNative:Function = null;
      
      public var retrieveProductsNative:Function = null;
      
      public var releaseNative:Function = null;
      
      public var purchaseNative:Function = null;
      
      public var isEnabledNative:Function = null;
      
      public var restorePurchasesNative:Function = null;
      
      public function Store()
      {
         super();
         if(ExternalInterface.available)
         {
            ExternalInterface.call("InitializeNativeOverride","Store",this);
         }
         if(this.ctorNative != null)
         {
            this.ctorNative();
         }
      }
      
      public static function get instance() : Store
      {
         if(!_instance)
         {
            _instance = new Store();
         }
         return _instance;
      }
      
      public static function Initialize() : void
      {
      }
      
      public function setJvid(jvid:String) : void
      {
         if(this.setJvidNative != null)
         {
            this.setJvidNative(jvid);
         }
      }
      
      public function retrieveProducts(storeIds:Array) : void
      {
         if(this.retrieveProductsNative != null)
         {
            this.retrieveProductsNative(storeIds);
         }
      }
      
      public function release() : void
      {
         if(this.releaseNative != null)
         {
            this.releaseNative();
         }
      }
      
      public function purchase(id:String) : void
      {
         if(this.purchaseNative != null)
         {
            this.purchaseNative(id);
         }
      }
      
      public function get isEnabled() : Boolean
      {
         if(this.isEnabledNative == null)
         {
            return false;
         }
         return this.isEnabledNative();
      }
      
      public function restorePurchases() : void
      {
         if(this.restorePurchasesNative != null)
         {
            this.restorePurchasesNative();
         }
      }
      
      public function onProductsRetrieved(products:Array) : void
      {
         var item:Object = null;
         this._purchasedProducts = Boolean(Save.instance.loadSecureString(SAVED_PURCHASES_KEY)) ? Save.instance.loadSecureString(SAVED_PURCHASES_KEY).split(",") : [];
         this._purchasableProducts = [];
         for each(item in products)
         {
            this._purchasableProducts.push(item);
         }
         dispatchEvent(new EventWithData(EVENT_PRODUCTS_RETRIEVED,products));
      }
      
      public function onPurchaseSuccessful(transactionInfo:Object) : void
      {
         if(this._savePurchase(transactionInfo.productId))
         {
            dispatchEvent(new EventWithData(EVENT_PURCHASE_SUCCESSFUL,transactionInfo));
            dispatchEvent(new EventWithData(EVENT_PURCHASED_ITEM_DISCOVERED,transactionInfo));
         }
      }
      
      public function onPurchaseFailed(transactionInfo:Object) : void
      {
         dispatchEvent(new EventWithData(EVENT_PURCHASE_FAILED,transactionInfo));
      }
      
      public function onPurchaseCancelled(transactionInfo:Object) : void
      {
         dispatchEvent(new EventWithData(EVENT_PURCHASE_CANCELLED,transactionInfo));
      }
      
      public function onPurchaseRestored(transactionInfo:Object) : void
      {
         dispatchEvent(new EventWithData(EVENT_PURCHASED_ITEM_DISCOVERED,transactionInfo));
         this._savePurchase(transactionInfo.productId);
      }
      
      public function onRestorePurchasesComplete(success:Boolean) : void
      {
         dispatchEvent(new EventWithData(EVENT_RESTORE_PURCHASES_COMPLETE,success));
      }
      
      private function _savePurchase(productId:String) : Boolean
      {
         if(this._purchasedProducts.indexOf(productId) >= 0)
         {
            return false;
         }
         this._purchasedProducts.push(productId);
         Save.instance.saveSecureString(SAVED_PURCHASES_KEY,this._purchasedProducts.join(","));
         return true;
      }
      
      public function isProductPurchased(productId:String) : Boolean
      {
         var p:String = null;
         for each(p in this._purchasedProducts)
         {
            if(p == productId)
            {
               return true;
            }
         }
         return false;
      }
      
      public function itemData(itemId:String) : Object
      {
         var item:Object = null;
         for each(item in this._purchasableProducts)
         {
            if(item.id == itemId)
            {
               return item;
            }
         }
         return null;
      }
      
      public function itemPrice(itemId:String) : String
      {
         var item:Object = this.itemData(itemId);
         if(item != null)
         {
            return item.price;
         }
         return null;
      }
      
      public function forgetAboutPurchases() : void
      {
         Save.instance.deleteSecureString(SAVED_PURCHASES_KEY);
         this._purchasedProducts = [];
      }
   }
}
