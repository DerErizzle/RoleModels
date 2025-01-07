package jackboxgames.expressionparser.expressions
{
   import jackboxgames.expressionparser.IExpression;
   import jackboxgames.expressionparser.IExpressionDataDelegate;
   import jackboxgames.expressionparser.Result;
   
   public class Keyword implements IExpression
   {
      private var _val:*;
      
      public function Keyword(val:*)
      {
         super();
         this._val = val;
      }
      
      public static function CREATE_RESULT(val:String) : Result
      {
         if(val.charAt(val.length - 1) == ".")
         {
            return new Result(false,"INVALID KEYWORD: Keyword \'" + val + "\' ends with \'.\'");
         }
         var payload:Keyword = new Keyword(val);
         return new Result(true,payload);
      }
      
      public function evaluate(del:IExpressionDataDelegate) : *
      {
         if(del == null)
         {
            return undefined;
         }
         return del.getKeywordValue(this._val);
      }
      
      public function get description() : String
      {
         return "[Keyword] " + this._val;
      }
   }
}

