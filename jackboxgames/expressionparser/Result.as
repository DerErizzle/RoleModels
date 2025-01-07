package jackboxgames.expressionparser
{
   public class Result
   {
      private var _succeeded:Boolean;
      
      private var _payload:*;
      
      public function Result(success:Boolean, payload:*)
      {
         super();
         this._succeeded = success;
         this._payload = payload;
      }
      
      public function evaluate(del:IExpressionDataDelegate) : Boolean
      {
         return this._succeeded ? Boolean(this._payload.evaluate(del)) : false;
      }
      
      public function get succeeded() : Boolean
      {
         return this._succeeded;
      }
      
      public function get payload() : *
      {
         return this._payload;
      }
   }
}

