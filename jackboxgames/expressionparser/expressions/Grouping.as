package jackboxgames.expressionparser.expressions
{
   import jackboxgames.expressionparser.IExpression;
   import jackboxgames.expressionparser.IExpressionDataDelegate;
   import jackboxgames.expressionparser.Result;
   
   public class Grouping implements IExpression
   {
      private var _expr:IExpression;
      
      public function Grouping(expr:IExpression)
      {
         super();
         this._expr = expr;
      }
      
      public static function CREATE_RESULT(expr:Result) : Result
      {
         return new Result(true,new Grouping(expr.payload));
      }
      
      public function evaluate(del:IExpressionDataDelegate) : *
      {
         return this._expr.evaluate(del);
      }
      
      public function get description() : String
      {
         return "Grouping: ()";
      }
   }
}

