package jackboxgames.utils
{
   public final class ObjectUtil
   {
       
      
      public function ObjectUtil()
      {
         super();
      }
      
      public static function countProperties(o:Object) : int
      {
         return getProperties(o).length;
      }
      
      public static function hasProperties(o:Object, properties:Array) : Boolean
      {
         var p:String = null;
         for each(p in properties)
         {
            if(!o.hasOwnProperty(p))
            {
               return false;
            }
         }
         return true;
      }
      
      public static function getProperties(o:Object) : Array
      {
         var p:String = null;
         var properties:Array = [];
         for(p in o)
         {
            properties.push(p);
         }
         return properties;
      }
      
      public static function getValues(o:Object) : Array
      {
         var p:String = null;
         var values:Array = [];
         for(p in o)
         {
            values.push(o[p]);
         }
         return values;
      }
      
      public static function getTotal(o:Object) : int
      {
         var key:String = null;
         var total:int = 0;
         for(key in o)
         {
            if(!isNaN(Number(o[key])))
            {
               total += o[key];
            }
         }
         return total;
      }
      
      public static function forEach(o:Object, f:Function) : void
      {
         var key:String = null;
         for(key in o)
         {
            f(o[key],key,o);
         }
      }
      
      public static function filter(o:Object, f:Function) : Object
      {
         var key:String = null;
         var returnMe:Object = {};
         for(key in o)
         {
            if(f(o[key],key,o))
            {
               returnMe[key] = o[key];
            }
         }
         return returnMe;
      }
      
      public static function find(o:Object, f:Function) : *
      {
         var key:String = null;
         for(key in o)
         {
            if(f(o[key],key,o))
            {
               return o[key];
            }
         }
         return null;
      }
      
      public static function map(o:Object, f:Function) : Object
      {
         var key:String = null;
         var returnMe:Object = {};
         for(key in o)
         {
            returnMe[key] = f(o[key],key,o);
         }
         return returnMe;
      }
      
      public static function mapFromArrayOfStrings(strings:Array, f:Function) : Object
      {
         var returnMe:Object = null;
         returnMe = {};
         strings.forEach(function(key:String, i:int, a:Array):void
         {
            returnMe[key] = f(key,i,a);
         });
         return returnMe;
      }
      
      public static function valuesAreEqual(a:Object, b:Object) : Boolean
      {
         var p:String = null;
         var aProperties:Array = getProperties(a);
         var bProperties:Array = getProperties(b);
         var intersection:Array = ArrayUtil.intersection(aProperties,bProperties);
         if(intersection.length != aProperties.length || intersection.length != bProperties.length)
         {
            return false;
         }
         var properties:Array = aProperties;
         for each(p in properties)
         {
            if(a[p] != b[p])
            {
               return false;
            }
         }
         return true;
      }
      
      public static function concat(... args) : Object
      {
         var o:Object = null;
         var key:String = null;
         var returnMe:Object = {};
         for each(o in args)
         {
            for(key in o)
            {
               returnMe[key] = o[key];
            }
         }
         return returnMe;
      }
      
      public static function getObjectWithoutKeys(o:Object, k:*) : Object
      {
         var disallowedKeys:Array = null;
         disallowedKeys = ArrayUtil.makeArrayIfNecessary(k);
         return filter(o,function(value:*, key:String, source:Object):Boolean
         {
            return !ArrayUtil.arrayContainsElement(disallowedKeys,key);
         });
      }
      
      public static function getChildAtPath(o:*, path:String) : *
      {
         var pathParts:Array;
         var current:Object;
         var part:String = null;
         if(!o)
         {
            return undefined;
         }
         pathParts = path.split(".");
         current = o;
         try
         {
            for each(part in pathParts)
            {
               current = current[part];
               if(current is Function)
               {
                  current = current();
               }
            }
         }
         catch(e:Error)
         {
            return undefined;
         }
         return current;
      }
      
      public static function getChildrenWithNameInOrder(o:Object, name:String, startingIndex:int = 0) : Array
      {
         var returnMe:Array = new Array();
         var i:int = startingIndex;
         while(Boolean(o[name + i]))
         {
            returnMe.push(o[name + i]);
            i++;
         }
         return returnMe;
      }
   }
}
