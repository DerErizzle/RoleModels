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
      
      private var _args:Array;
      
      public function AsyncFunctionSequence(array:Array, sequenceFn:String)
      {
         super();
         this._array = array;
         this._fn = sequenceFn;
      }
      
      public function run(doneFn:Function, ... args) : void
      {
         this._args = args;
         this._count = 0;
         if(!this._array || this._array.length == 0)
         {
            doneFn();
            return;
         }
         this._processFn(doneFn);
      }
      
      private function _processFn(doneFn:Function) : void
      {
         var item:* = this._array[this._count];
         var vaArgs:Array = this._args.concat();
         vaArgs.unshift(function():void
         {
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
         item[this._fn].apply(item,vaArgs);
      }
   }
}

