package jackboxgames.utils
{
   import flash.utils.*;
   import jackboxgames.logger.*;
   
   public class AsyncFunctionSequence
   {
       
      
      private var _array:Array;
      
      private var _fn:String;
      
      private var _doneFn:Function;
      
      private var _count:int = 0;
      
      public function AsyncFunctionSequence(array:Array, sequenceFn:String)
      {
         super();
         this._array = array;
         this._fn = sequenceFn;
      }
      
      public function run(doneFn:Function) : void
      {
         this._count = 0;
         Logger.debug("Beginning " + this._fn + " sequence...");
         this._processFn(doneFn);
      }
      
      private function _processFn(doneFn:Function) : void
      {
         var item:* = undefined;
         item = this._array[this._count];
         Logger.debug(getQualifiedClassName(item) + "::" + this._fn + ".");
         item[this._fn](function():void
         {
            Logger.debug(getQualifiedClassName(item) + "::" + _fn + " complete.");
            ++_count;
            if(_count < _array.length)
            {
               _processFn(doneFn);
            }
            else
            {
               doneFn();
            }
         });
      }
   }
}
