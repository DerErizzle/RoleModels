package jackboxgames.expressionparser
{
   public class MultipleDataDelegate implements IExpressionDataDelegate
   {
      private var _delegates:Array;
      
      public function MultipleDataDelegate()
      {
         super();
         this._delegates = [];
      }
      
      public function add(d:IExpressionDataDelegate) : void
      {
         this._delegates.push(d);
      }
      
      public function getKeywordValue(keyword:String) : *
      {
         var d:IExpressionDataDelegate = null;
         var val:* = undefined;
         for each(d in this._delegates)
         {
            val = d.getKeywordValue(keyword);
            if(val !== undefined)
            {
               return val;
            }
         }
         return undefined;
      }
   }
}

