package jackboxgames.thewheel.data
{
   import jackboxgames.thewheel.gameplay.*;
   
   public class TappingListChoiceData
   {
      private var _data:Object;
      
      private var _val:ETappingListValue;
      
      public function TappingListChoiceData(data:Object, correct:Boolean)
      {
         super();
         this._data = data;
         this._val = correct ? ETappingListValue.TRUE : ETappingListValue.FALSE;
      }
      
      public function get text() : String
      {
         return this._data.text;
      }
      
      public function get val() : ETappingListValue
      {
         return this._val;
      }
   }
}

