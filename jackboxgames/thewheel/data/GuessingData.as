package jackboxgames.thewheel.data
{
   import flash.utils.*;
   import jackboxgames.bbparser.*;
   import jackboxgames.utils.*;
   
   public class GuessingData implements ITriviaContent
   {
      private var _data:Object;
      
      private var _answerNoBBCode:String;
      
      private var _clues:Array;
      
      public function GuessingData(data:Object)
      {
         var parser:BBCodeParser;
         super();
         this._data = data;
         parser = new BBCodeParser(new Dictionary(),false);
         this._answerNoBBCode = parser.parse(this._data.answer,true,false,false);
         this._clues = this._data.clues.map(function(clueData:Object, ... args):GuessingClueData
         {
            return new GuessingClueData(clueData);
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
      
      public function get answer() : String
      {
         return this._data.answer;
      }
      
      public function get clues() : Array
      {
         return this._clues;
      }
      
      public function isCorrectGuess(guess:String) : Boolean
      {
         var altSpelling:String = null;
         if(TextUtils.stringsAreClose(guess,this._answerNoBBCode))
         {
            return true;
         }
         for each(altSpelling in this._data.altSpellings)
         {
            if(TextUtils.stringsAreClose(guess,altSpelling))
            {
               return true;
            }
         }
         return false;
      }
   }
}

