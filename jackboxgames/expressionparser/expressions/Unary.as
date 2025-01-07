package jackboxgames.expressionparser.expressions
{
   import jackboxgames.expressionparser.IExpression;
   import jackboxgames.expressionparser.IExpressionDataDelegate;
   import jackboxgames.expressionparser.Result;
   import jackboxgames.expressionparser.Token;
   import jackboxgames.expressionparser.TokenType;
   
   public class Unary implements IExpression
   {
      private var _operator:Token;
      
      private var _right:IExpression;
      
      public function Unary(operator:Token, right:IExpression)
      {
         super();
         this._operator = operator;
         this._right = right;
      }
      
      public static function CREATE_RESULT(op:Token, right:Result) : Result
      {
         var payload:Unary = new Unary(op,right.payload);
         return new Result(true,payload);
      }
      
      public function evaluate(del:IExpressionDataDelegate) : *
      {
         switch(this._operator.type)
         {
            case TokenType.NOT:
               return !this._right.evaluate(del);
            case TokenType.NEGATIVE:
               return -this._right.evaluate(del);
            default:
               throw new Error("INVALID UNARY OPERATION");
         }
      }
      
      public function get description() : String
      {
         switch(this._operator.type)
         {
            case TokenType.NOT:
               return "Not: !";
            case TokenType.NEGATIVE:
               return "Negative: -";
            default:
               throw new Error("INVALID UNARY OPERATION");
         }
      }
   }
}

