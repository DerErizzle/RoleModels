package jackboxgames.expressionparser
{
   public class Token
   {
      private var _type:TokenType;
      
      private var _data:*;
      
      public function Token(type:TokenType, data:* = undefined)
      {
         super();
         this._type = type;
         this._data = data;
      }
      
      public function get type() : TokenType
      {
         return this._type;
      }
      
      public function get data() : *
      {
         return this._data;
      }
      
      public function get description() : String
      {
         switch(this.type)
         {
            case TokenType.AND:
               return "AND [keyword]";
            case TokenType.OR:
               return "OR [keyword]";
            case TokenType.EQUAL:
               return "==  [symbol]";
            case TokenType.NOT_EQUAL:
               return "!=  [symbol]";
            case TokenType.GREATER_THAN:
               return ">  [symbol]";
            case TokenType.GREATER_THAN_OR_EQUAL_TO:
               return ">=  [symbol]";
            case TokenType.LESS_THAN:
               return "<  [symbol]";
            case TokenType.LESS_THAN_OR_EQUAL_TO:
               return "<=  [symbol]";
            case TokenType.MINUS:
               return "-  [symbol]";
            case TokenType.PLUS:
               return "+  [symbol]";
            case TokenType.DIVIDE:
               return "/  [symbol]";
            case TokenType.MULTIPLY:
               return "*  [symbol]";
            case TokenType.PAREN_START:
               return "(  [symbol]";
            case TokenType.PAREN_END:
               return ")  [symbol]";
            case TokenType.NOT:
               return "!  [symbol]";
            case TokenType.TRUE:
               return "TRUE [keyword]";
            case TokenType.FALSE:
               return "FALSE [keyword]";
            case TokenType.NULL:
               return "NULL [keyword]";
            case TokenType.EOF:
               return "[End of File]";
            case TokenType.NUMBER:
               return String(this.data) + " [number]";
            case TokenType.STRING:
               return this.data + " [string]";
            case TokenType.VAR:
               return this.data + " [variable]";
            default:
               return "[[ INVALID TOKEN ]]";
         }
      }
   }
}

