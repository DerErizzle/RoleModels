package jackboxgames.utils
{
   public class Assert
   {
      public function Assert()
      {
         super();
      }
      
      public static function assert(exp:Boolean, description:String = null) : void
      {
         if(EnvUtil.isDebug())
         {
            if(!exp)
            {
               throw new Error(description != null ? description : "Assertion failed!");
            }
         }
      }
   }
}

