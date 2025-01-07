package jackboxgames.expressionparser
{
   public class PropertyDataDelegate implements IExpressionDataDelegate
   {
      private var _target:Object;
      
      public function PropertyDataDelegate(target:Object)
      {
         super();
         this._target = target;
      }
      
      public function getKeywordValue(keyword:String) : *
      {
         var i:uint = 0;
         var splits:Array = keyword.split(".");
         var obj:* = this._target;
         try
         {
            for(i = 0; i < splits.length; i++)
            {
               obj = obj[splits[i]];
               if(obj is Function)
               {
                  obj = obj();
               }
            }
         }
         catch(e:Error)
         {
            return undefined;
         }
         return obj;
      }
   }
}

