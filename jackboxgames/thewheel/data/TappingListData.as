package jackboxgames.thewheel.data
{
   public class TappingListData implements ITriviaContent
   {
      private var _data:Object;
      
      private var _answers:Array;
      
      private var _decoys:Array;
      
      public function TappingListData(data:Object)
      {
         super();
         this._data = data;
         this._answers = this._data.answers.map(function(answerData:Object, ... args):TappingListChoiceData
         {
            return new TappingListChoiceData(answerData,true);
         });
         this._decoys = this._data.decoys.map(function(decoyData:Object, ... args):TappingListChoiceData
         {
            return new TappingListChoiceData(decoyData,false);
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
      
      public function get decoys() : Array
      {
         return this._decoys;
      }
   }
}

