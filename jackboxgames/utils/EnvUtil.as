package jackboxgames.utils
{
   public final class EnvUtil
   {
      private static const ENV_AIR:String = "air";
      
      private static const ENV_CONSOLE:String = "console";
      
      private static const ENV_MOBILE:String = "mobile";
      
      private static const ENV_PC:String = "pc";
      
      public function EnvUtil()
      {
         super();
      }
      
      public static function isAIR() : Boolean
      {
         return BuildConfig.instance.configVal("env") == ENV_AIR;
      }
      
      public static function isConsole() : Boolean
      {
         return BuildConfig.instance.configVal("env") == ENV_CONSOLE;
      }
      
      public static function isMobile() : Boolean
      {
         return BuildConfig.instance.configVal("env") == ENV_MOBILE;
      }
      
      public static function isPC() : Boolean
      {
         return BuildConfig.instance.configVal("env") == ENV_PC;
      }
      
      public static function isDebug() : Boolean
      {
         return BuildConfig.instance.configVal("debug");
      }
   }
}

