package jackboxgames.thewheel.data
{
   import jackboxgames.utils.*;
   
   public class MatchingData implements ITriviaContent
   {
      private var _data:Object;
      
      private var _answers:Array;
      
      private var _header:MatchingHeaderData;
      
      public function MatchingData(data:Object)
      {
         super();
         this._data = data;
         Assert.assert(Boolean(this._data.headers) && this._data.headers.length == 1);
         this._header = new MatchingHeaderData(this._data.headers[0]);
         this._answers = this._data.answers.map(function(answerData:Object, ... args):MatchingAnswerData
         {
            return new MatchingAnswerData(answerData);
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
         return this._data.promptHeader;
      }
      
      public function get instructions() : String
      {
         return this._data.prompt;
      }
      
      public function get header() : MatchingHeaderData
      {
         return this._header;
      }
      
      public function get answers() : Array
      {
         return this._answers;
      }
   }
}

