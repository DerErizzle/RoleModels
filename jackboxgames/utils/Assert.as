package jackboxgames.utils
{
   public class Assert
   {
       
      
      public function Assert()
      {
         super();
      }
      
      public static function assert(exp:Boolean) : void
      {
         if(EnvUtil.isDebug())
         {
            if(!exp)
            {
               throw new Error("Assertion failed!");
            }
         }
      }
   }
}
