package jackboxgames.ecast
{
   import jackboxgames.settings.SettingsConstants;
   
   public final class EcastUtil
   {
      public function EcastUtil()
      {
         super();
      }
      
      public static function getExtraCreateParamsForContentFilter(setting:String) : Object
      {
         if(!setting)
         {
            return {};
         }
         switch(setting)
         {
            case SettingsConstants.PLAYER_CONTENT_FILTERING_OFF:
               return {};
            case SettingsConstants.PLAYER_CONTENT_FILTERING_HATE_SPEECH:
               return {"reject":{"lexicon":["hate"]}};
            case SettingsConstants.PLAYER_CONTENT_FILTERING_PROFANITY:
               return {"reject":{"lexicon":["hate","profanity"]}};
            default:
               return {};
         }
      }
   }
}

