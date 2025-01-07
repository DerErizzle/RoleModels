package jackboxgames.thewheel.data
{
   public class MatchingAnswerData
   {
      private var _data:Object;
      
      public function MatchingAnswerData(data:Object)
      {
         super();
         this._data = data;
      }
      
      public function get text() : String
      {
         return this._data.text;
      }
      
      public function get match() : String
      {
         return this._data.match;
      }
   }
}

