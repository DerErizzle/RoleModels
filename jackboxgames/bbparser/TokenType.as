package jackboxgames.bbparser
{
   public class TokenType
   {
      
      public static const TEXT:TokenType = new TokenType();
      
      public static const STARTTAG:TokenType = new TokenType();
      
      public static const ENDTAG:TokenType = new TokenType();
      
      private static var _enumCreated:Boolean = false;
      
      {
         _enumCreated = true;
      }
      
      public function TokenType()
      {
         super();
         if(_enumCreated)
         {
            throw new Error("Token Type is already defined!");
         }
      }
   }
}
