package jackboxgames.text
{
   import jackboxgames.utils.NumberUtil;
   
   public final class MapperFactory
   {
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
   }
}

