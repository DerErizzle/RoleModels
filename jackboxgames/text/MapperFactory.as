package jackboxgames.text
{
   import jackboxgames.bbparser.BBCodeParser;
   import jackboxgames.utils.NumberUtil;
   
   public final class MapperFactory
   {
      
      private static const BBCODE_PARSER:BBCodeParser = new BBCodeParser(BBCodeParser.defaultTags);
       
      
      public function MapperFactory()
      {
         super();
      }
      
      public static function createPrePostMapper(getPreFn:Function, getPostFn:Function) : Function
      {
         return function(s:String, data:*):String
         {
            return getPreFn() + s + getPostFn();
         };
      }
      
      public static function createNumberFormaterMapper(decimals:int = 0) : Function
      {
         return function(s:String, data:*):String
         {
            return NumberUtil.format(Number(s),decimals);
         };
      }
      
      public static function createCurrencyNumberFormaterMapper(decimals:int = -1, preSymbol:String = "$", postSymbol:String = "") : Function
      {
         return function(s:String, data:*):String
         {
            return preSymbol + NumberUtil.format(Number(s),decimals) + postSymbol;
         };
      }
      
      public static function createSubstringMapper(substringLength:int) : Function
      {
         return function(s:String, data:*):String
         {
            return s.substr(0,substringLength);
         };
      }
      
      public static function createBBCodeMapper() : Function
      {
         return function(s:String, data:*):String
         {
            return BBCODE_PARSER.parse(s);
         };
      }
   }
}
