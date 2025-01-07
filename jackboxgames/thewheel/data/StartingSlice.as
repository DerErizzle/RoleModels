package jackboxgames.thewheel.data
{
   import jackboxgames.expressionparser.*;
   import jackboxgames.utils.*;
   
   public class StartingSlice
   {
      private var _data:Object;
      
      private var _isValid:IExpression;
      
      public function StartingSlice(data:Object)
      {
         var parser:ExpressionParser = null;
         var res:Result = null;
         super();
         this._data = data;
         if(this._data.hasOwnProperty("isValid"))
         {
            parser = new ExpressionParser();
            res = parser.parse(this._data.isValid);
            if(res.succeeded)
            {
               this._isValid = res.payload;
            }
            else
            {
               Assert.assert(false,res.payload);
            }
         }
      }
      
      public function get type() : String
      {
         return this._data.type;
      }
      
      public function get pos() : int
      {
         return this._data.pos;
      }
      
      public function get data() : Object
      {
         return this._data.data;
      }
      
      public function getIsValid(delegate:IExpressionDataDelegate) : Boolean
      {
         return Boolean(this._isValid) ? Boolean(this._isValid.evaluate(delegate)) : true;
      }
   }
}

