package jackboxgames.thewheel.data
{
   import flash.utils.Dictionary;
   import jackboxgames.bbparser.*;
   import jackboxgames.utils.*;
   
   public class TypingListAnswerData
   {
      private var _index:int;
      
      private var _data:Object;
      
      private var _textNoBBCode:String;
      
      private var _exactSpelling:Boolean;
      
      public function TypingListAnswerData(index:int, data:Object, exactSpelling:Boolean)
      {
         super();
         this._index = index;
         this._data = data;
         var parser:BBCodeParser = new BBCodeParser(new Dictionary(),false);
         this._textNoBBCode = parser.parse(this._data.text,true,false,false);
         this._exactSpelling = exactSpelling;
      }
      
      public function get index() : int
      {
         return this._index;
      }
      
      public function get text() : String
      {
         return this._data.text;
      }
      
      public function get hasClue() : Boolean
      {
         return Boolean(this._data.hint) && this._data.hint.length > 0;
      }
      
      public function get clue() : String
      {
         return this._data.hint;
      }
      
      public function isValid(ans:String) : Boolean
      {
         var altSpelling:String = null;
         if(this._exactSpelling)
         {
            if(TextUtils.caseInsensitiveCompare(ans,this._textNoBBCode))
            {
               return true;
            }
            for each(altSpelling in this._data.altSpellings)
            {
               if(TextUtils.caseInsensitiveCompare(ans,altSpelling))
               {
                  return true;
               }
            }
         }
         else
         {
            if(TextUtils.stringsAreClose(ans,this._textNoBBCode))
            {
               return true;
            }
            for each(altSpelling in this._data.altSpellings)
            {
               if(TextUtils.stringsAreClose(ans,altSpelling))
               {
                  return true;
               }
            }
         }
         return false;
      }
   }
}

