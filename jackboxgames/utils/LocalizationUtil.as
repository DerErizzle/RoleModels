package jackboxgames.utils
{
   import jackboxgames.localizy.LocalizationManager;
   
   public class LocalizationUtil
   {
       
      
      public function LocalizationUtil()
      {
         super();
      }
      
      public static function getPrintfText(key:String, ... args) : String
      {
         var text:String = LocalizationManager.instance.getText(key);
         if(!text)
         {
            return null;
         }
         var pattern:RegExp = /%[sd]/;
         while(text.search(pattern) != -1 && args.length > 0)
         {
            text = text.replace(pattern,String(args.shift()));
         }
         return text;
      }
   }
}
