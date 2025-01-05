package jackboxgames.bbparser
{
   public class Tag
   {
       
      
      private var _tagName:String;
      
      private var _insertLineBreaks:Boolean;
      
      private var _suppressLineBreaks:Boolean;
      
      private var _noNesting:Boolean;
      
      private var _markupGenerator:Function;
      
      public function Tag(tagName:String, insertLineBreaks:Boolean, suppressLineBreaks:Boolean, noNesting:Boolean, markupGenerator:Function)
      {
         super();
         this._tagName = tagName;
         this._insertLineBreaks = insertLineBreaks;
         this._suppressLineBreaks = suppressLineBreaks;
         this._noNesting = noNesting;
         this._markupGenerator = markupGenerator;
      }
      
      public static function create(tagName:String, markupGenerator:Function, insertLineBreaks:Boolean = false, suppressLineBreaks:Boolean = false, noNesting:Boolean = false) : Tag
      {
         return new Tag(tagName,insertLineBreaks,suppressLineBreaks,noNesting,markupGenerator);
      }
      
      public function get tagName() : String
      {
         return this._tagName;
      }
      
      public function get insertLineBreaks() : Boolean
      {
         return this._insertLineBreaks;
      }
      
      public function get suppressLineBreaks() : Boolean
      {
         return this._suppressLineBreaks;
      }
      
      public function get noNesting() : Boolean
      {
         return this._noNesting;
      }
      
      public function get markupGenerator() : Function
      {
         return this._markupGenerator;
      }
   }
}
