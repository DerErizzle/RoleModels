package jackboxgames.utils
{
   import flash.external.ExternalInterface;
   import flash.utils.describeType;
   import jackboxgames.logger.*;
   
   public final class TraceUtil
   {
      public function TraceUtil()
      {
         super();
      }
      
      public static function log(msg:String) : void
      {
         if(Logger.isEnabled())
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("console.log",msg);
            }
            else
            {
               trace(msg);
            }
         }
      }
      
      public static function object(obj:Object, parent:String) : String
      {
         var item:* = undefined;
         var objectString:String = "";
         if(Logger.isEnabled())
         {
            try
            {
               objectString += TraceUtil.objectProperties(obj,parent);
               if(Boolean(obj))
               {
                  for(item in obj)
                  {
                     if(item != null && obj[item] != null)
                     {
                        objectString += parent + "." + item + " => " + obj[item] + "\n";
                     }
                  }
               }
            }
            catch(e:Error)
            {
            }
         }
         return objectString;
      }
      
      public static function objectRecursive(obj:Object, parent:String, tCount:int = 0) : String
      {
         var parentString:String = null;
         var childString:String = null;
         var i:int = 0;
         var item:* = undefined;
         var objectString:String = "";
         if(Logger.isEnabled())
         {
            parentString = "";
            childString = "";
            try
            {
               parentString += TraceUtil.objectProperties(obj,parent,tCount + 1);
               if(Boolean(obj))
               {
                  for(item in obj)
                  {
                     if(item != null && obj[item] != null)
                     {
                        childString += TraceUtil.objectRecursive(obj[item],item,tCount + 1) + "\n";
                     }
                  }
                  if(childString != "")
                  {
                     childString = childString.substr(0,childString.length - 1);
                  }
               }
            }
            catch(e:Error)
            {
            }
            for(i = 0; i < tCount; i++)
            {
               objectString += "   ";
            }
            objectString += "[" + parent + "]" + " => " + obj;
            if(parentString != "" || childString != "")
            {
               objectString += "\n";
               for(i = 0; i < tCount; i++)
               {
                  objectString += "   ";
               }
               objectString += "{\n";
               objectString += parentString;
               objectString += childString;
               objectString += "\n";
               for(i = 0; i < tCount; i++)
               {
                  objectString += "   ";
               }
               objectString += "}";
            }
         }
         return objectString;
      }
      
      public static function objectProperties(obj:Object, parent:String, tCount:int = 0) : String
      {
         var def:XML = null;
         var properties:XMLList = null;
         var property:String = null;
         var i:int = 0;
         var objectString:String = "";
         if(Logger.isEnabled())
         {
            try
            {
               def = describeType(obj);
               properties = def..variable.@name + def..accessor.@name;
               for each(property in properties)
               {
                  if(property != "length")
                  {
                     for(i = 0; i < tCount; i++)
                     {
                        objectString += "   ";
                     }
                     objectString += "[" + property + "]" + " => " + obj[property] + "\n";
                  }
               }
            }
            catch(e:Error)
            {
            }
         }
         return objectString;
      }
      
      public static function dictionary(obj:Object) : String
      {
         var item:String = null;
         var objectString:String = "";
         if(Logger.isEnabled())
         {
            if(Boolean(obj))
            {
               for(item in obj)
               {
                  if(item != null && obj[item] != null)
                  {
                     objectString += item + ": " + String(obj[item]) + "\n";
                  }
               }
            }
         }
         return objectString;
      }
      
      public static function backTraceString() : String
      {
         var tempError:Error = null;
         var stackTrace:String = "";
         if(Logger.isEnabled())
         {
            tempError = new Error();
            stackTrace = tempError.getStackTrace().substring(6);
         }
         return stackTrace;
      }
      
      public static function backTrace(label:String) : void
      {
         if(Logger.isEnabled())
         {
            log("backTrace (" + label + ") = ");
            log(backTraceString());
         }
      }
   }
}

