package jackboxgames.thewheel.data
{
   import jackboxgames.talkshow.utils.*;
   import jackboxgames.utils.*;
   
   public class RapidFireData implements ITriviaContent
   {
      private static const SORT_ASCENDING:String = "ascending";
      
      private static const SORT_DESCENDING:String = "descending";
      
      private var _data:Object;
      
      private var _allChoices:Array;
      
      public function RapidFireData(data:Object)
      {
         super();
         this._data = data;
         this._allChoices = this._data.answers.map(function(answerData:Object, ... args):RapidFireChoiceData
         {
            return new RapidFireChoiceData(answerData);
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
      
      public function get unit() : String
      {
         return this._data.unit;
      }
      
      public function get allChoices() : Array
      {
         return this._allChoices;
      }
      
      public function generateSelector() : RandomLowRepeat
      {
         return new RandomLowRepeat(this._allChoices.length);
      }
      
      public function selectChoices(num:int, selector:RandomLowRepeat) : Array
      {
         var index:uint = 0;
         var candidate:RapidFireChoiceData = null;
         var selectedWithSameValue:Array = null;
         var selected:Array = [];
         var rejected:Array = [];
         while(selected.length < num && rejected.length + selected.length < this._allChoices.length)
         {
            index = selector.getNextIndex();
            candidate = this._allChoices[index];
            if(ArrayUtil.arrayContainsElement(rejected,candidate))
            {
               selector.commit();
            }
            else
            {
               selectedWithSameValue = selected.filter(function(c:RapidFireChoiceData, ... args):Boolean
               {
                  return c.value == candidate.value;
               });
               if(selectedWithSameValue.length == 0)
               {
                  selected.push(candidate);
               }
               else
               {
                  rejected.push(candidate);
               }
               selector.commit();
            }
         }
         return selected;
      }
      
      public function getCorrectIndex(choiceSubList:Array) : int
      {
         var correctAnswerValue:int = 0;
         var correctAnswerIndex:int = -1;
         correctAnswerValue = this._data.sort == SORT_DESCENDING ? int.MIN_VALUE : int.MAX_VALUE;
         choiceSubList.forEach(function(c:RapidFireChoiceData, i:int, a:Array):void
         {
            if(_data.sort == SORT_DESCENDING ? c.value > correctAnswerValue : c.value < correctAnswerValue)
            {
               correctAnswerValue = c.value;
               correctAnswerIndex = i;
            }
         });
         return correctAnswerIndex;
      }
   }
}

