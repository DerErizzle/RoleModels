package jackboxgames.thewheel.data
{
   import jackboxgames.algorithm.Promise;
   import jackboxgames.expressionparser.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.utils.*;
   
   public class RoundSetup implements IJsonData
   {
      private var _data:Object;
      
      private var _isValid:IExpression;
      
      private var _skeleton:TriviaListSkeleton;
      
      public function RoundSetup()
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
            if(!res.succeeded)
            {
               return PromiseUtil.REJECTED();
            }
            this._isValid = res.payload;
         }
         this._skeleton = new TriviaListSkeleton(this._data.skeleton);
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
      
      public function get skeleton() : TriviaListSkeleton
      {
         return this._skeleton;
      }
      
      public function get numSpinsBeforeFinal() : int
      {
         return this._data.numSpinsBeforeFinal;
      }
   }
}

