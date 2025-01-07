package jackboxgames.thewheel.data
{
   public class GuessingClueData
   {
      private var _data:Object;
      
      public function GuessingClueData(data:Object)
      {
         super();
         this._data = data;
      }
      
      public function get text() : String
      {
         return this._data.clue;
      }
   }
}

