package jackboxgames.thewheel.data
{
   public class RapidFireChoiceData
   {
      private var _data:Object;
      
      public function RapidFireChoiceData(data:Object)
      {
         super();
         this._data = data;
      }
      
      public function get text() : String
      {
         return this._data.text;
      }
      
      public function get value() : int
      {
         return this._data.value;
      }
   }
}

