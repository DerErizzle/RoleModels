package jackboxgames.nativeoverride
{
   import flash.external.ExternalInterface;
   import jackboxgames.utils.JSON;
   
   public class JSON
   {
      
      public static var deserializeNative:Function = null;
      
      public static var serializeNative:Function = null;
       
      
      public function JSON()
      {
         super();
      }
      
      public static function Initialize() : void
      {
         ExternalInterface.call("InitializeNativeOverride","JSON",JSON);
      }
      
      public static function deserialize(source:String) : *
      {
         if(deserializeNative == null)
         {
            return JSON.deserialize(source);
         }
         return deserializeNative(source);
      }
      
      public static function serialize(o:*) : String
      {
         if(serializeNative == null)
         {
            return JSON.serialize(o);
         }
         return serializeNative(o);
      }
   }
}
