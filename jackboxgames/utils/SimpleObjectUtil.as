package jackboxgames.utils
{
   import flash.utils.getQualifiedClassName;
   
   public final class SimpleObjectUtil
   {
       
      
      public function SimpleObjectUtil()
      {
         super();
      }
      
      public static function deepCopyWithSimpleObjectReplacement(o:Object) : Object
      {
         if(o is IToSimpleObject)
         {
            return deepCopyWithSimpleObjectReplacement(o.toSimpleObject());
         }
         if(o is Array)
         {
            return o.map(function(c:*, ... args):*
            {
               return deepCopyWithSimpleObjectReplacement(c);
            });
         }
         if(getQualifiedClassName(o) == "Object")
         {
            return ObjectUtil.map(o,function(c:*, ... args):*
            {
               return deepCopyWithSimpleObjectReplacement(c);
            });
         }
         return o;
      }
   }
}
