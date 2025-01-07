package jackboxgames.utils
{
   import jackboxgames.algorithm.*;
   
   public class ArrayUtil
   {
      public function ArrayUtil()
      {
         super();
      }
      
      public static function FOLD_CONCAT(a:Array, b:Array) : Array
      {
         return a.concat(b);
      }
      
      public static function GENERATE_FILTER_EXCEPT(obj:*) : Function
      {
         return function(o:*, i:int, a:Array):Boolean
         {
            return o != obj;
         };
      }
      
      public static function getElement(array:Array, index:int) : *
      {
         if(array == null || index >= array.length)
         {
            return null;
         }
         return array[index];
      }
      
      public static function getElementWrap(array:Array, index:int) : *
      {
         return array[(index % array.length + array.length) % array.length];
      }
      
      public static function getRandomElement(array:Array, removeSelected:Boolean = false) : *
      {
         return getRandomElements(array,1,removeSelected)[0];
      }
      
      public static function getRandomElements(array:Array, numToChoose:int = 1, removeSelected:Boolean = false) : Array
      {
         var index:int = 0;
         Assert.assert(array.length >= numToChoose);
         var arrayToUse:Array = removeSelected ? array : array.concat();
         var returnMe:Array = [];
         for(var i:int = 0; i < numToChoose; i++)
         {
            index = Random.instance.roll(arrayToUse.length);
            returnMe.push(arrayToUse[index]);
            arrayToUse.splice(index,1);
         }
         return returnMe;
      }
      
      public static function getRandomElementsWeighted(array:Array, chances:*, numToChoose:int = 1, removeSelected:Boolean = false) : *
      {
         var totalRandom:Number = NaN;
         var j:int = 0;
         var randValue:Number = NaN;
         var accumulated:Number = NaN;
         var k:int = 0;
         var value:* = undefined;
         var arrayToUse:Array = removeSelected ? array : array.concat();
         var returnMe:Array = [];
         for(var i:int = 0; i < numToChoose; i++)
         {
            totalRandom = 0;
            for(j = 0; j < arrayToUse.length; j++)
            {
               totalRandom += chances[j];
            }
            randValue = Random.instance.roll(totalRandom);
            accumulated = 0;
            for(k = 0; k < arrayToUse.length; k++)
            {
               accumulated += chances[k];
               if(accumulated >= randValue)
               {
                  value = arrayToUse[k];
                  arrayToUse.splice(k,1);
                  returnMe.push(value);
                  break;
               }
            }
         }
         if(returnMe.length == 0)
         {
            Assert.assert(returnMe.length >= 0);
            return null;
         }
         return numToChoose == 1 ? returnMe[0] : returnMe;
      }
      
      public static function flatten(array:Array) : Array
      {
         var element:* = undefined;
         var returnMe:Array = [];
         for each(element in array)
         {
            if(element is Array)
            {
               returnMe = returnMe.concat(flatten(element));
            }
            else
            {
               returnMe.push(element);
            }
         }
         return returnMe;
      }
      
      public static function shuffled(array:Array) : Array
      {
         return makeArrayIfNecessary(getRandomElements(array,array.length));
      }
      
      public static function rotate(array:Array, numberOfRotations:int, rotateArrayForward:Boolean = true) : Array
      {
         var rotationsDone:int = 0;
         var tempForward:* = undefined;
         var tempBackward:* = undefined;
         if(array.length == 0)
         {
            return array;
         }
         var result:Array = copy(array);
         var rotationsToDo:int = numberOfRotations % result.length;
         if(rotateArrayForward)
         {
            for(rotationsDone = 0; rotationsDone < rotationsToDo; rotationsDone++)
            {
               tempForward = result.shift();
               result.push(tempForward);
            }
         }
         else
         {
            for(rotationsDone = 0; rotationsDone < rotationsToDo; rotationsDone++)
            {
               tempBackward = result.pop();
               result.unshift(tempBackward);
            }
         }
         return result;
      }
      
      public static function deranged(array:Array) : Array
      {
         var j:int = 0;
         var temp:* = undefined;
         var returnMe:Array = array.concat();
         for(var i:int = 0; i < returnMe.length - 1; i++)
         {
            j = i + 1 + Math.floor(Math.random() * (returnMe.length - i - 1));
            temp = returnMe[j];
            returnMe[j] = returnMe[i];
            returnMe[i] = temp;
         }
         return returnMe;
      }
      
      public static function deduplicated(array:Array) : Array
      {
         var v:* = undefined;
         var returnMe:Array = [];
         for each(v in array)
         {
            if(returnMe.indexOf(v) < 0)
            {
               returnMe.push(v);
            }
         }
         return returnMe;
      }
      
      public static function getArrayOfIndicesUpTo(start:int, num:int) : Array
      {
         var indices:Array = [];
         for(var i:int = start; i < num - start; i++)
         {
            indices.push(i);
         }
         return indices;
      }
      
      public static function arrayContainsElement(array:Array, element:*) : Boolean
      {
         return array.indexOf(element) >= 0;
      }
      
      public static function arrayContainsArray(twoDimensionalArray:Array, array:Array) : Boolean
      {
         var subArray:Array = null;
         var elementsInCommon:Array = null;
         var i:int = 0;
         for each(subArray in twoDimensionalArray)
         {
            if(array.length == subArray.length)
            {
               elementsInCommon = [];
               for(i = 0; i < array.length; i++)
               {
                  if(array[i] == subArray[i])
                  {
                     elementsInCommon.push(array[i]);
                  }
               }
               if(elementsInCommon.length == array.length)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public static function deduplicatedPush(array:Array, element:*) : Boolean
      {
         if(arrayContainsElement(array,element))
         {
            return false;
         }
         array.push(element);
         return true;
      }
      
      public static function removeElementFromArray(array:Array, element:*) : Boolean
      {
         var lengthBefore:int = int(array.length);
         while(array.indexOf(element) >= 0)
         {
            array.splice(array.indexOf(element),1);
         }
         return lengthBefore != array.length;
      }
      
      public static function removeElementAtIndex(array:Array, i:int) : *
      {
         return first(array.splice(i,1));
      }
      
      public static function parallelForEach(forEachFn:Function, ... args) : void
      {
         var i:int = 0;
         var forEachArgs:Array = null;
         if(args.length == 0)
         {
            return;
         }
         for(i = 1; i < args.length; i++)
         {
            Assert.assert(args[i].length == args[i - 1].length);
         }
         for(i = 0; i < args[0].length; i++)
         {
            forEachArgs = args.map(function(a:Array, ... args):*
            {
               return a[i];
            });
            forEachFn.apply(null,forEachArgs);
         }
      }
      
      public static function numTimesElementAppearsInArray(a:Array, e:*) : int
      {
         var i:* = undefined;
         var n:int = 0;
         for each(i in a)
         {
            if(e == i)
            {
               n++;
            }
         }
         return n;
      }
      
      public static function copy(array:Array) : Array
      {
         return array.slice();
      }
      
      public static function reverse(array:Array) : Array
      {
         return copy(array).reverse();
      }
      
      public static function swap(a:Array, i:int, j:int) : void
      {
         var temp:* = a[i];
         a[i] = a[j];
         a[j] = temp;
      }
      
      public static function arrayContainsOneOf(array:Array, these:Array) : Boolean
      {
         var t:* = undefined;
         for each(t in these)
         {
            if(arrayContainsElement(array,t))
            {
               return true;
            }
         }
         return false;
      }
      
      public static function areEqual(a:Array, b:Array) : Boolean
      {
         if(a.length != b.length)
         {
            return false;
         }
         for(var i:int = 0; i < a.length; i++)
         {
            if(a[i] != b[i])
            {
               return false;
            }
         }
         return true;
      }
      
      public static function makeArrayIfNecessary(a:*) : Array
      {
         if(!a)
         {
            return [];
         }
         if(a is Array)
         {
            return a;
         }
         return [a];
      }
      
      public static function makeArray(count:int, val:*) : Array
      {
         var a:Array = new Array(count);
         for(var i:int = 0; i < count; i++)
         {
            a[i] = val is Function ? val(i) : val;
         }
         return a;
      }
      
      public static function count(a:Array, countMe:*) : int
      {
         return MapFold.process(a,function(o:*, ... args):int
         {
            return o == countMe ? 1 : 0;
         },MapFold.FOLD_SUM);
      }
      
      public static function average(a:Array) : Number
      {
         var n:Number = NaN;
         n = 0;
         a.forEach(function(num:Number, ... args):void
         {
            n += num;
         });
         return n / a.length;
      }
      
      public static function replaceOrPush(a:Array, existingElement:*, newElement:*) : void
      {
         if(!existingElement)
         {
            a.push(newElement);
            return;
         }
         var i:int = int(a.indexOf(existingElement));
         if(i >= 0)
         {
            a[i] = newElement;
         }
         else
         {
            a.push(newElement);
         }
      }
      
      public static function find(a:Array, delegateFn:Function) : *
      {
         if(!a)
         {
            return null;
         }
         for(var i:int = 0; i < a.length; i++)
         {
            if(delegateFn(a[i],i,a))
            {
               return a[i];
            }
         }
         return null;
      }
      
      public static function search(a:Array, delegateFn:Function) : *
      {
         var r:* = undefined;
         if(!a)
         {
            return null;
         }
         for(var i:int = 0; i < a.length; i++)
         {
            r = delegateFn(a[i],i,a);
            if(r)
            {
               return r;
            }
         }
         return null;
      }
      
      public static function union(a:Array, b:Array) : Array
      {
         return deduplicated(a.concat(b));
      }
      
      public static function intersection(a:Array, b:Array) : Array
      {
         return a.filter(function(item:*, ... args):Boolean
         {
            return arrayContainsElement(b,item);
         });
      }
      
      public static function difference(a:Array, b:Array) : Array
      {
         return a.filter(function(item:*, ... args):Boolean
         {
            return !arrayContainsElement(b,item);
         });
      }
      
      public static function concat(... args) : Array
      {
         if(args.length == 0)
         {
            return [];
         }
         var a:Array = args[0];
         for(var i:int = 1; i < args.length; i++)
         {
            if(args[i] is Array)
            {
               a = a.concat(args[i]);
            }
            else
            {
               a.push(args[i]);
            }
         }
         return a;
      }
      
      public static function foldInArrayAtIndex(target:Array, foldMe:Array, index:int) : Array
      {
         var copy:Array = ArrayUtil.copy(target);
         for(var i:int = foldMe.length - 1; i >= 0; i--)
         {
            copy.splice(index,0,foldMe[i]);
         }
         return copy;
      }
      
      public static function first(a:Array) : *
      {
         return a.length > 0 ? a[0] : undefined;
      }
      
      public static function last(a:Array) : *
      {
         return a.length > 0 ? a[a.length - 1] : undefined;
      }
   }
}

