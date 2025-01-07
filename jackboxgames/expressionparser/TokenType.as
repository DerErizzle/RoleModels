package jackboxgames.expressionparser
{
   public class TokenType
   {
      public static const NUMBER:TokenType = new TokenType();
      
      public static const STRING:TokenType = new TokenType();
      
      public static const VAR:TokenType = new TokenType();
      
      public static const AND:TokenType = new TokenType();
      
      public static const OR:TokenType = new TokenType();
      
      public static const EQUAL:TokenType = new TokenType();
      
      public static const NOT_EQUAL:TokenType = new TokenType();
      
      public static const GREATER_THAN:TokenType = new TokenType();
      
      public static const GREATER_THAN_OR_EQUAL_TO:TokenType = new TokenType();
      
      public static const LESS_THAN:TokenType = new TokenType();
      
      public static const LESS_THAN_OR_EQUAL_TO:TokenType = new TokenType();
      
      public static const MINUS:TokenType = new TokenType();
      
      public static const PLUS:TokenType = new TokenType();
      
      public static const DIVIDE:TokenType = new TokenType();
      
      public static const MULTIPLY:TokenType = new TokenType();
      
      public static const PAREN_START:TokenType = new TokenType();
      
      public static const PAREN_END:TokenType = new TokenType();
      
      public static const NOT:TokenType = new TokenType();
      
      public static const NEGATIVE:TokenType = new TokenType();
      
      public static const TRUE:TokenType = new TokenType();
      
      public static const FALSE:TokenType = new TokenType();
      
      public static const NULL:TokenType = new TokenType();
      
      public static const EOF:TokenType = new TokenType();
      
      private static var _enumCreated:Boolean = false;
      
      _enumCreated = true;
      
      public function TokenType()
      {
         super();
         if(_enumCreated)
         {
            throw new Error("The Enum is already defined.");
         }
      }
   }
}

