package jackboxgames.utils
{
   import jackboxgames.algorithm.*;
   
   public final class PromiseUtil
   {
      public function PromiseUtil()
      {
         super();
      }
      
      public static function ALL(promises:Array) : Promise
      {
         var bigPromise:Promise = null;
         var data:Array = null;
         var completed:int = 0;
         if(promises.length == 0)
         {
            return RESOLVED([]);
         }
         bigPromise = new Promise();
         data = new Array(promises.length);
         completed = 0;
         promises.forEach(function(p:Promise, i:int, a:Array):void
         {
            p.then(function(val:*):void
            {
               data[i] = val;
               ++completed;
               if(completed == promises.length)
               {
                  bigPromise.resolve(data);
               }
            },function(val:*):void
            {
               bigPromise.reject(val);
            });
         });
         return bigPromise;
      }
      
      public static function RESOLVED(val:* = null) : Promise
      {
         var p:Promise = new Promise();
         p.resolve(val);
         return p;
      }
      
      public static function REJECTED(val:* = null) : Promise
      {
         var p:Promise = new Promise();
         p.reject(val);
         return p;
      }
      
      public static function setShowerShown(s:MovieClipShower, isShown:Boolean) : Promise
      {
         var p:Promise = null;
         p = new Promise();
         s.setShown(isShown,function():void
         {
            p.resolve(undefined);
         });
         return p;
      }
      
      public static function wait(d:Duration) : Promise
      {
         var p:Promise = null;
         p = new Promise();
         JBGUtil.runFunctionAfter(function():void
         {
            p.resolve(undefined);
         },d);
         return p;
      }
      
      public static function doneFnResolved(p:Promise, value:*) : Function
      {
         return function():void
         {
            p.resolve(value);
         };
      }
   }
}

