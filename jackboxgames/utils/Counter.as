package jackboxgames.utils
{
   public class Counter
   {
      private var _finalCount:int;
      
      private var _fn:Function;
      
      private var _count:int;
      
      public function Counter(finalCount:int, fn:Function)
      {
         super();
         this._finalCount = finalCount;
         this._fn = fn;
         this.reset();
      }
      
      public function reset() : void
      {
         this._count = 0;
      }
      
      public function tick() : void
      {
         ++this._count;
         if(this._count == this._finalCount)
         {
            this._fn();
         }
      }
      
      public function generateDoneFn() : Function
      {
         return function(... args):*
         {
            tick();
         };
      }
   }
}

