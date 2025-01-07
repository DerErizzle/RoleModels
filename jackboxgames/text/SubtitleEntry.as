package jackboxgames.text
{
   public class SubtitleEntry
   {
      private var _id:String;
      
      private var _subtitleLines:Array;
      
      public function SubtitleEntry(id:String, subtitleLines:Array)
      {
         super();
         this._id = id;
         this._subtitleLines = subtitleLines;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get hasLines() : Boolean
      {
         return this._subtitleLines.length > 0;
      }
      
      public function getNextLine() : String
      {
         return this.hasLines ? this._subtitleLines.shift() : null;
      }
   }
}

