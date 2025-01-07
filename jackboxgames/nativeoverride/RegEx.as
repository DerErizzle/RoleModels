package jackboxgames.nativeoverride
{
   import flash.external.ExternalInterface;
   
   public class RegEx
   {
      public static var TestNative:Function = null;
      
      public static var ReplaceNative:Function = null;
      
      public static var MatchNative:Function = null;
      
      public static var SearchNative:Function = null;
      
      public function RegEx()
      {
         super();
      }
      
      public static function Initialize() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("InitializeNativeOverride","RegEx",RegEx);
         }
      }
      
      public static function Test(pattern:String, flags:String, testMe:String) : Boolean
      {
         if(TestNative != null)
         {
            return TestNative(pattern,flags,testMe);
         }
         var r:RegExp = new RegExp(pattern,flags);
         return r.test(testMe);
      }
      
      public static function Replace(pattern:String, flags:String, input:String, replaceWith:Object) : String
      {
         if(ReplaceNative != null)
         {
            return ReplaceNative(pattern,flags,input,replaceWith);
         }
         var r:RegExp = new RegExp(pattern,flags);
         return input.replace(r,replaceWith);
      }
      
      public static function Match(pattern:String, flags:String, input:String) : Array
      {
         if(MatchNative != null)
         {
            return MatchNative(pattern,flags,input);
         }
         var r:RegExp = new RegExp(pattern,flags);
         return input.match(r);
      }
      
      public static function Search(pattern:String, flags:String, input:String) : int
      {
         if(SearchNative != null)
         {
            return SearchNative(pattern,flags,input);
         }
         var r:RegExp = new RegExp(pattern,flags);
         return input.search(r);
      }
   }
}

