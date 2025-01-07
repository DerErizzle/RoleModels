package jackboxgames.expressionparser.expressions
{
   import flash.utils.getQualifiedClassName;
   import jackboxgames.expressionparser.IExpression;
   import jackboxgames.expressionparser.IExpressionDataDelegate;
   import jackboxgames.expressionparser.Result;
   
   public class Literal implements IExpression
   {
      private var _val:*;
      
      public function Literal(val:*)
      {
         super();
         this._val = val;
      }
      
      public static function CREATE_RESULT(val:*) : Result
      {
         var payload:Literal = new Literal(val);
         return new Result(true,payload);
      }
      
      public function evaluate(del:IExpressionDataDelegate) : *
      {
         return this._val;
      }
      
      public function get description() : String
      {
         return "[" + getQualifiedClassName(this._val) + "] " + this._val;
      }
   }
}

