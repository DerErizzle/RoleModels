package jackboxgames.utils
{
   public final class Nullable
   {
      
      public static function NULL_FUNCTION(... args):*
      {
         return null;
      } 
      
      public function Nullable()
      {
         super();
      }
      
      public static function isNull(n:*) : Boolean
      {
         if(n is Function)
         {
            return n == NULL_FUNCTION;
         }
         return false;
      }
      
      public static function getNullForClass(c:Class) : *
      {
         var returnMe:* = undefined;
         if(c == Function)
         {
            returnMe = NULL_FUNCTION;
         }
         return returnMe;
      }
      
      public static function getNullForVal(n:*) : *
      {
         return getNullForClass(Object(n).constructor);
      }
      
      public static function convertToNullableIfNecessary(n:*, c:Class) : *
      {
         return n == null ? getNullForClass(c) : n;
      }
   }
}
