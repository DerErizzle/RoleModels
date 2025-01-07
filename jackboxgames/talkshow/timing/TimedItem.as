package jackboxgames.talkshow.timing
{
   internal class TimedItem
   {
      private var _ref:ActionRef;
      
      private var _time:uint;
      
      public function TimedItem(ref:ActionRef, time:uint)
      {
         super();
         this._ref = ref;
         this._time = time;
      }
      
      public function get ref() : ActionRef
      {
         return this._ref;
      }
      
      public function get time() : uint
      {
         return this._time;
      }
   }
}

