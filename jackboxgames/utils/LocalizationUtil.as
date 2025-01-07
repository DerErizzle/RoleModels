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
      
      public static function pseudoLocalize(s:String) : String
      {
         var additionText:String = null;
         var added:int = 0;
         var oldCharacter:String = null;
         var newCharacter:String = null;
         var choices:String = null;
         if(LocalizationManager.instance.currentLocale != LocalizationManager.DEFAULT_LOCALE)
         {
            return s;
         }
         var character_map:Object = {
            "A":"ÀÁÂÃÄÅÆ",
            "E":"ÈÉÊË",
            "I":"ÍÎÏÌ",
            "O":"ÒÓÔÕÖØŒ",
            "U":"ÙÚÛÜ",
            "Y":"Ý",
            "a":"àáâãäåæ",
            "e":"èéêë",
            "i":"ìíîï",
            "o":"òóôõöøœ",
            "u":"ùúûü",
            "y":"ýÿ",
            "B":"ß",
            "C":"Ç",
            "D":"Ð",
            "N":"Ñ",
            "b":"þ",
            "c":"ç",
            "n":"ñ",
            "p":"Þ",
            "!":"¡",
            "?":"¿",
            "\'":"‘’",
            ".":"\"#$&\'()*+,-/×÷_=<>«»“„”"
         };
         var extraCharacters:int = Math.ceil(Number(s.length) * 1.4);
         if(extraCharacters <= 2)
         {
            s += "[]";
         }
         else
         {
            additionText = "The quick brown fox jumps over the lazy dog. ";
            s += " [";
            extraCharacters -= 3;
            while(extraCharacters > 0)
            {
               added = Math.min(extraCharacters,additionText.length);
               s += additionText.substr(0,added);
               extraCharacters -= added;
            }
            s += "]";
         }
         var newText:String = "";
         var lastCharacter:String = "";
         for(var index:int = 0; index < s.length; index++)
         {
            oldCharacter = s.charAt(index);
            newCharacter = oldCharacter;
            if(character_map[oldCharacter] != undefined && lastCharacter != "%" && oldCharacter != "s" && oldCharacter != "d")
            {
               choices = character_map[oldCharacter];
               newCharacter = choices.charAt(Math.floor(Math.random() * choices.length));
            }
            newText += newCharacter;
            lastCharacter = oldCharacter;
         }
         return newText;
      }
      
      public static function createPseudoLocaleMapper() : Function
      {
         return function(s:String, data:*):String
         {
            return pseudoLocalize(s);
         };
      }
   }
}

