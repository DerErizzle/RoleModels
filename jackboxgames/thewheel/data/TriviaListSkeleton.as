package jackboxgames.thewheel.data
{
   import jackboxgames.thewheel.*;
   import jackboxgames.utils.*;
   
   public class TriviaListSkeleton
   {
      private var _data:Object;
      
      private var _types:Array;
      
      public function TriviaListSkeleton(data:Object)
      {
         super();
         this._data = data;
         this._types = this._data.types;
      }
      
      public function skin() : TriviaList
      {
         var triviaTypeIds:Array = this._types.map(function(triviaTypeId:*, ... args):String
         {
            if(triviaTypeId is String)
            {
               return triviaTypeId;
            }
            if(triviaTypeId is Array)
            {
               return ArrayUtil.getRandomElement(triviaTypeId);
            }
            Assert.assert(false);
            return null;
         });
         var types:Array = triviaTypeIds.map(function(triviaTypeId:String, ... args):TriviaType
         {
            return GameConstants.GET_TRIVIA_TYPE_BY_ID(triviaTypeId);
         });
         return new TriviaList(this,types);
      }
   }
}

