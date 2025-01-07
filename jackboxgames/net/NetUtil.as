package jackboxgames.net
{
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import jackboxgames.nativeoverride.URLLoader;
   import jackboxgames.nativeoverride.URLRequest;
   import jackboxgames.utils.EnvUtil;
   
   public final class NetUtil
   {
      public function NetUtil()
      {
         super();
      }
      
      public static function createURLRequest(url:String) : *
      {
         if(EnvUtil.isAIR())
         {
            return new flash.net.URLRequest(url);
         }
         return new jackboxgames.nativeoverride.URLRequest(url);
      }
      
      public static function createURLLoader() : *
      {
         if(EnvUtil.isAIR())
         {
            return new flash.net.URLLoader();
         }
         return new jackboxgames.nativeoverride.URLLoader();
      }
   }
}

