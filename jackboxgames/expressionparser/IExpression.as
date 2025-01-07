package jackboxgames.expressionparser
{
   public interface IExpression
   {
      function evaluate(param1:IExpressionDataDelegate) : *;
      
      function get description() : String;
   }
}

