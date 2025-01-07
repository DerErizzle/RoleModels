package jackboxgames.thewheel.data
{
   public class TypingListData implements ITriviaContent
   {
      private var _data:Object;
      
      private var _answers:Array;
      
      public function TypingListData(data:Object)
      {
         super();
         this._data = data;
         this._answers = this._data.answers.map(function(answerData:Object, i:int, a:Array):TypingListAnswerData
         {
            return new TypingListAnswerData(i,answerData,_data.exactSpelling);
         });
      }
      
      public function get id() : String
      {
         return this._data.id;
      }
      
      public function get category() : String
      {
         return this._data.category;
      }
      
      public function get subtype() : String
      {
         return this._data.subtype;
      }
      
      public function get prompt() : String
      {
         return this._data.prompt;
      }
      
      public function get answers() : Array
      {
         return this._answers;
      }
   }
}

