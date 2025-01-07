package jackboxgames.expressionparser.expressions
{
   import jackboxgames.expressionparser.IExpression;
   import jackboxgames.expressionparser.IExpressionDataDelegate;
   import jackboxgames.expressionparser.Result;
   import jackboxgames.expressionparser.Token;
   import jackboxgames.expressionparser.TokenType;
   
   public class Binary implements IExpression
   {
      private var _left:IExpression;
      
      private var _operator:Token;
      
      private var _right:IExpression;
      
      public function Binary(left:IExpression, operator:Token, right:IExpression)
      {
         super();
         this._left = left;
         this._operator = operator;
         this._right = right;
      }
      
      public static function CREATE_RESULT(left:Result, op:Token, right:Result) : Result
      {
         var payload:Binary = new Binary(left.payload,op,right.payload);
         return new Result(true,payload);
      }
      
      public function evaluate(del:IExpressionDataDelegate) : *
      {
         switch(this._operator.type)
         {
            case TokenType.AND:
               return this._left.evaluate(del) && this._right.evaluate(del);
            case TokenType.OR:
               return this._left.evaluate(del) || this._right.evaluate(del);
            case TokenType.EQUAL:
               return this._left.evaluate(del) == this._right.evaluate(del);
            case TokenType.NOT_EQUAL:
               return this._left.evaluate(del) != this._right.evaluate(del);
            case TokenType.GREATER_THAN:
               return this._left.evaluate(del) > this._right.evaluate(del);
            case TokenType.GREATER_THAN_OR_EQUAL_TO:
               return this._left.evaluate(del) >= this._right.evaluate(del);
            case TokenType.LESS_THAN:
               return this._left.evaluate(del) < this._right.evaluate(del);
            case TokenType.LESS_THAN_OR_EQUAL_TO:
               return this._left.evaluate(del) <= this._right.evaluate(del);
            case TokenType.MINUS:
               return this._left.evaluate(del) - this._right.evaluate(del);
            case TokenType.PLUS:
               return this._left.evaluate(del) + this._right.evaluate(del);
            case TokenType.DIVIDE:
               return this._left.evaluate(del) / this._right.evaluate(del);
            case TokenType.MULTIPLY:
               return this._left.evaluate(del) * this._right.evaluate(del);
            default:
               return "INVALID OPERATION";
         }
      }
      
      public function get description() : String
      {
         switch(this._operator.type)
         {
            case TokenType.AND:
               return "And";
            case TokenType.OR:
               return "Or";
            case TokenType.EQUAL:
               return "==";
            case TokenType.NOT_EQUAL:
               return "!=";
            case TokenType.GREATER_THAN:
               return "Greater: >";
            case TokenType.GREATER_THAN_OR_EQUAL_TO:
               return "Greater/Equal: >=";
            case TokenType.LESS_THAN:
               return "Less: <";
            case TokenType.LESS_THAN_OR_EQUAL_TO:
               return "Less/Equal: <=";
            case TokenType.MINUS:
               return "Minus: -";
            case TokenType.PLUS:
               return "Plus: +";
            case TokenType.DIVIDE:
               return "Divide: /";
            case TokenType.MULTIPLY:
               return "Multiply: *";
            default:
               return "INVALID OPERATION";
         }
      }
   }
}

