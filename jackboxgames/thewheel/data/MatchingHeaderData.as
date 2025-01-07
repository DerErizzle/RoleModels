package jackboxgames.thewheel.data
{
   public class MatchingHeaderData
   {
      private var _data:Object;
      
      public function MatchingHeaderData(data:Object)
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
      
      public function asArray() : Array
      {
         return [this.text,this.match];
      }
   }
}

