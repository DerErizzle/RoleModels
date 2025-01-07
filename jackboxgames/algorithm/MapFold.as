package jackboxgames.algorithm
{
   public final class MapFold
   {
      public static function MAP_IDENTITY(v:*, ... args):*
      {
         return v;
      }
      public static function FOLD_SUM(current:*, newValue:*):*
      {
         return current + newValue;
      }
      public static function FOLD_MIN(current:*, newValue:*):*
      {
         return Math.min(current,newValue);
      }
      public static function FOLD_MAX(current:*, newValue:*):*
      {
         return Math.max(current,newValue);
      }
      public static function FOLD_AND(current:*, newValue:*):*
      {
         return current && newValue;
      }
      public static function FOLD_OR(current:*, newValue:*):*
      {
         return current || newValue;
      }
      public function MapFold()
      {
         super();
      }
      
      public static function process(array:Array, map:Function, fold:Function) : *
      {
         if(!array || array.length == 0)
         {
            return null;
         }
         var mappedArray:Array = array.map(map);
         if(mappedArray.length == 1)
         {
            return mappedArray[0];
         }
         var result:* = fold(mappedArray[0],mappedArray[1]);
         for(var i:int = 2; i < mappedArray.length; i++)
         {
            result = fold(result,mappedArray[i]);
         }
         return result;
      }
   }
}

