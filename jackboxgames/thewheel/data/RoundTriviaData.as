package jackboxgames.thewheel.data
{
   import jackboxgames.thewheel.gameplay.TriviaResult;
   
   public class RoundTriviaData
   {
      private var _content:ITriviaContent;
      
      private var _result:TriviaResult;
      
      public function RoundTriviaData(c:ITriviaContent)
      {
         super();
         this._content = c;
      }
      
      public function get content() : ITriviaContent
      {
         return this._content;
      }
      
      public function get result() : TriviaResult
      {
         return this._result;
      }
      
      public function recordResult(result:TriviaResult) : void
      {
         this._result = result;
      }
   }
}

