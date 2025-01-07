package jackboxgames.settings
{
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public final class SettingsUtil
   {
      public function SettingsUtil()
      {
         super();
      }
      
      public static function FAMILY_FRIENDLY_CONTENT_FILTER(o:Object, ... args) : Boolean
      {
         if(SettingsManager.instance.getValue(SettingsConstants.SETTING_FAMILY_FRIENDLY).val && Boolean(o.x))
         {
            return false;
         }
         return true;
      }
      
      public static function US_CENTRIC_CONTENT_FILTER(o:Object, ... args) : Boolean
      {
         if(SettingsManager.instance.getValue(SettingsConstants.SETTING_FILTER_US_CENTRIC_CONTENT).val && Boolean(o.us))
         {
            return false;
         }
         return true;
      }
      
      public static function supportsTogglingFullScreen() : Boolean
      {
         return Platform.instance.supportsWindow && BuildConfig.instance.configVal("supportsFullScreen") == true;
      }
   }
}

