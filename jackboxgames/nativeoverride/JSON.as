package jackboxgames.nativeoverride
{
   import flash.external.ExternalInterface;
   import jackboxgames.flash.FlashNativeOverrider;
   
   public class JSON
   {
      private static var _isInitialized:Boolean = false;
      
      public static var deserializeNative:Function = null;
      
      public static var serializeNative:Function = null;
      
      public function JSON()
      {
         super();
      }
      
      public static function Initialize() : void
      {
         if(_isInitialized)
         {
            return;
         }
         if(ExternalInterface.available)
         {
            ExternalInterface.call("InitializeNativeOverride","JSON",JSON);
         }
         else
         {
            FlashNativeOverrider.initializeNativeOverride("JSON",JSON);
         }
         _isInitialized = true;
      }
      
      public static function deserialize(source:String) : *
      {
         if(deserializeNative == null)
         {
            return null;
         }
         return deserializeNative(source);
      }
      
      public static function serialize(o:*) : String
      {
         if(serializeNative == null)
         {
            return null;
         }
         return serializeNative(o);
      }
   }
}

