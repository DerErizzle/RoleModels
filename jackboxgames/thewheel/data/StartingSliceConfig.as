package jackboxgames.thewheel.data
{
   import jackboxgames.algorithm.*;
   import jackboxgames.expressionparser.*;
   import jackboxgames.utils.*;
   
   public class StartingSliceConfig implements IJsonData
   {
      private var _data:Object;
      
      private var _isValid:IExpression;
      
      private var _slices:Array;
      
      public function StartingSliceConfig()
      {
         super();
      }
      
      public function load(data:Object) : Promise
      {
         var parser:ExpressionParser = null;
         var res:Result = null;
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
         this._slices = this._data.slices.map(function(sliceData:Object, ... args):StartingSlice
         {
            return new StartingSlice(sliceData);
         });
         return PromiseUtil.RESOLVED();
      }
      
      public function get id() : String
      {
         return this._data.id;
      }
      
      public function getIsValid(delegate:IExpressionDataDelegate) : Boolean
      {
         return Boolean(this._isValid) ? Boolean(this._isValid.evaluate(delegate)) : true;
      }
      
      public function get slices() : Array
      {
         return this._slices;
      }
   }
}

