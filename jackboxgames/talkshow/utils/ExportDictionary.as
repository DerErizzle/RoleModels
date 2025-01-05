package jackboxgames.talkshow.utils
{
   import jackboxgames.utils.*;
   
   public class ExportDictionary
   {
       
      
      private var _data:Array;
      
      public function ExportDictionary(d:String)
      {
         var i:uint = 0;
         super();
         this._data = d.split("^");
         if(EnvUtil.isMobile())
         {
            for(i = 0; i < this._data.length; i++)
            {
               this._data[i] = stringReplace(this._data[i],"&#8248;","^");
            }
         }
         else
         {
            for(i = 0; i < this._data.length; i++)
            {
               while(this._data[i].indexOf("&#8248;") != -1)
               {
                  this._data[i] = this._data[i].replace("&#8248;","^");
               }
            }
         }
      }
      
      private static function stringReplace(text:String, replace:String, replacement:String) : String
      {
         var result:String = "";
         var next:String = text.indexOf(replace) == 0 ? replacement : "";
         var parts:Array = text.split(replace);
         for(var index:int = 0; index < parts.length; index++)
         {
            result = result + next + parts[index];
            next = replacement;
         }
         return result;
      }
      
      public function toString() : String
      {
         return this._data.toString();
      }
      
      public function lookup(id:uint) : String
      {
         return this._data[id];
      }
   }
}
