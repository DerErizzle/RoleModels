package jackboxgames.thewheel.data
{
   public class NumberTargetData implements ITriviaContent
   {
      private var _data:Object;
      
      private var _answer:int;
      
      public function NumberTargetData(data:Object)
      {
         super();
         this._data = data;
         this._answer = int(data.value);
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
      
      public function get unit() : String
      {
         return this._data.unit;
      }
      
      public function get hasUnit() : Boolean
      {
         return this._data.unit is String && this._data.unit.length > 0;
      }
      
      public function get answer() : int
      {
         return this._answer;
      }
   }
}

