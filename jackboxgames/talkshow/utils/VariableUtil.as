package jackboxgames.talkshow.utils
{
   import flash.xml.*;
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.core.PlaybackEngine;
   
   public class VariableUtil
   {
      
      public static const VALID_VAR_NAME:String = "^[a-z_\\$]{1}(\\w|\\$)*$";
      
      public static const REPLACE_VARIABLES:String = "\\{\\{(((g|l)\\.[A-Za-z_$][A-Za-z0-9_$]*)((.[A-Za-z_$][A-Za-z0-9_$]*)*))\\}\\}";
       
      
      public function VariableUtil()
      {
         super();
      }
      
      public static function isValidID(id:String) : Boolean
      {
         var regExp:RegExp = new RegExp(VALID_VAR_NAME);
         return regExp.test(id);
      }
      
      public static function replaceVariables(s:String) : *
      {
         var match:String = null;
         var trimmed:String = null;
         var value:String = null;
         if(s == null)
         {
            return null;
         }
         var regex:RegExp = new RegExp(REPLACE_VARIABLES,"i");
         var end:String = s;
         var result:Object = regex.exec(end);
         while(result != null)
         {
            match = String(result[0]);
            trimmed = match.substr(2,match.length - 4);
            value = getVariableValue(trimmed);
            if(s == match)
            {
               return value;
            }
            end = end.substr(0,result.index) + value + end.substr(result.index + match.length);
            result = regex.exec(end);
         }
         return end;
      }
      
      private static function lookupVariableValue() : String
      {
         return getVariableValue(arguments[1]);
      }
      
      public static function getVariableValue(varName:String) : *
      {
         var obj:Object = null;
         var i:uint = 0;
         var objToLookAt:* = undefined;
         var splits:Array = varName.split(".");
         if(splits[0] == "g")
         {
            obj = PlaybackEngine.getInstance().g;
         }
         else
         {
            if(splits[0] != "l")
            {
               return null;
            }
            obj = PlaybackEngine.getInstance().l;
         }
         try
         {
            for(i = 1; i < splits.length; i++)
            {
               objToLookAt = obj[splits[i]];
               if(objToLookAt is Function)
               {
                  objToLookAt = objToLookAt();
               }
               if(i == splits.length - 1)
               {
                  return objToLookAt;
               }
               obj = objToLookAt;
            }
         }
         catch(e:Error)
         {
         }
         return null;
      }
      
      public static function setVariableValue(varName:String, varValue:*, convertNumbers:Boolean = false) : void
      {
         var splits:Array;
         var obj:Object = null;
         var i:uint = 0;
         if(varValue === "true")
         {
            varValue = true;
         }
         else if(varValue === "false")
         {
            varValue = false;
         }
         else if(convertNumbers && !isNaN(varValue))
         {
            varValue = Number(varValue);
         }
         splits = varName.split(".");
         if(splits[0] == "g")
         {
            obj = PlaybackEngine.getInstance().g;
         }
         else if(splits[0] == "l")
         {
            obj = PlaybackEngine.getInstance().l;
         }
         try
         {
            for(i = 1; i < splits.length; i++)
            {
               if(i == splits.length - 1)
               {
                  obj[splits[i]] = varValue;
               }
               else
               {
                  if(obj[splits[i]] == null)
                  {
                     obj[splits[i]] = {};
                  }
                  obj[splits[i]][splits[i + 1]];
                  obj = obj[splits[i]];
               }
            }
         }
         catch(e:ReferenceError)
         {
            Logger.warning("Cannot set variable value " + varName + ": " + e);
         }
      }
   }
}
