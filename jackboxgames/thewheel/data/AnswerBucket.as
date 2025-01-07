package jackboxgames.thewheel.data
{
   import jackboxgames.algorithm.*;
   import jackboxgames.utils.*;
   
   public class AnswerBucket implements IJsonData
   {
      private var _data:Object;
      
      private var _keywords:Array;
      
      private var _sequential:Array;
      
      public function AnswerBucket()
      {
         super();
      }
      
      public function load(data:Object) : Promise
      {
         var toLowerCaseMap:Function = null;
         toLowerCaseMap = function(s:String, ... args):String
         {
            return s.toLowerCase();
         };
         this._data = data;
         this._keywords = this._data.keywords.map(toLowerCaseMap);
         this._sequential = this._data.sequential.map(toLowerCaseMap);
         return PromiseUtil.RESOLVED();
      }
      
      public function get keywords() : Array
      {
         return this._keywords;
      }
      
      public function get sequential() : Array
      {
         return this._sequential;
      }
      
      public function get answers() : Array
      {
         return this._data.answers;
      }
   }
}

