package jackboxgames.thewheel.data
{
   public class TriviaList
   {
      private var _skeleton:TriviaListSkeleton;
      
      private var _types:Array;
      
      public function TriviaList(s:TriviaListSkeleton, t:Array)
      {
         super();
         this._skeleton = s;
         this._types = t;
      }
      
      public function get skeleton() : TriviaListSkeleton
      {
         return this._skeleton;
      }
      
      public function get types() : Array
      {
         return this._types;
      }
   }
}

