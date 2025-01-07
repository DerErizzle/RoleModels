package jackboxgames.utils
{
   public class NumberUtil
   {
      public static const LANGUAGE_ENGLISH:String = "en";
      
      public static const LANGUAGE_FRENCH:String = "fr";
      
      public static const LANGUAGE_GERMAN:String = "de";
      
      public static const LANGUAGE_ITALIAN:String = "it";
      
      public static const LANGUAGE_SPANISH:String = "es";
      
      private static const localeData:Object = {
         "en":{
            "grouping":",",
            "decimal":"."
         },
         "fr":{
            "grouping":" ",
            "decimal":","
         },
         "de":{
            "grouping":" ",
            "decimal":","
         },
         "es":{
            "grouping":".",
            "decimal":","
         },
         "it":{
            "grouping":".",
            "decimal":","
         }
      };
      
      public function NumberUtil()
      {
         super();
      }
      
      public static function format(number:Number, decimalDigits:int = -1, language:String = "en") : String
      {
         return getFormatOfNumber(number,decimalDigits,localeData[language]);
      }
      
      private static function getFormatOfNumber(number:Number, decimalDigits:int, locale:Object) : String
      {
         var splitByDecimal:Array = null;
         var chunk:String = null;
         var sign:String = number < 0 ? "-" : "";
         var numString:String = String(Math.abs(number));
         var index:Number = Number(numString.indexOf("."));
         var decimal:String = "";
         if(index > 0)
         {
            splitByDecimal = numString.split(".");
            numString = splitByDecimal[0];
            if(decimalDigits == -1)
            {
               decimal = splitByDecimal[1];
            }
            else
            {
               decimal = splitByDecimal[1].substr(0,decimalDigits);
            }
         }
         else if(index === 0)
         {
            if(decimalDigits != -1)
            {
               numString = numString.substr(0,decimalDigits);
            }
            return "0" + numString;
         }
         while(decimal.length < decimalDigits)
         {
            decimal += "0";
         }
         var result:String = "";
         while(numString.length > 3)
         {
            chunk = numString.substr(-3);
            numString = numString.substr(0,numString.length - 3);
            result = locale.grouping + chunk + result;
         }
         result = numString + result;
         if(Boolean(decimal))
         {
            result = result + locale.decimal + decimal;
         }
         return sign + result;
      }
      
      public static function getEnglishSpellingOfInt(i:int) : String
      {
         switch(i)
         {
            case 0:
               return "Zero";
            case 1:
               return "One";
            case 2:
               return "Two";
            case 3:
               return "Three";
            case 4:
               return "Four";
            case 5:
               return "Five";
            case 6:
               return "Six";
            case 7:
               return "Seven";
            case 8:
               return "Eight";
            case 9:
               return "Nine";
            case 10:
               return "Ten";
            case 11:
               return "Eleven";
            case 12:
               return "Twelve";
            case 13:
               return "Thirteen";
            case 14:
               return "Fourteen";
            case 15:
               return "Fifteen";
            case 16:
               return "Sixteen";
            case 17:
               return "Seventeen";
            case 18:
               return "Eighteen";
            case 19:
               return "Nineteen";
            case 20:
               return "Twenty";
            default:
               return "No Spelling For : " + i;
         }
      }
      
      public static function getOrdinalOfInt(i:int) : String
      {
         switch(i)
         {
            case 1:
               return "First";
            case 2:
               return "Second";
            case 3:
               return "Third";
            case 4:
               return "Fourth";
            case 5:
               return "Fifth";
            case 6:
               return "Sixth";
            case 7:
               return "Seventh";
            case 8:
               return "Eighth";
            case 9:
               return "Ninth";
            case 10:
               return "Tenth";
            case 11:
               return "Eleventh";
            case 12:
               return "Twelfth";
            case 13:
               return "Thirteenth";
            case 14:
               return "Fourteenth";
            case 15:
               return "Fifteenth";
            case 16:
               return "Sixteenth";
            case 17:
               return "Seventeenth";
            case 18:
               return "Eighteenth";
            case 19:
               return "Nineteenth";
            case 20:
               return "Twentieth";
            default:
               return "No Ordinal For : " + i;
         }
      }
      
      public static function isValidIndexForArray(i:int, a:Array) : Boolean
      {
         return !isNaN(i) && i >= 0 && i < a.length;
      }
      
      public static function toStringWithLeadingZeroes(val:int, places:int) : String
      {
         var result:String = val.toString();
         for(var i:int = result.length; i < places; i++)
         {
            result = "0" + result;
         }
         return result;
      }
      
      public static function toStringWithTrailingZeroes(val:int, places:int) : String
      {
         var result:String = val.toString();
         for(var i:int = result.length; i < places; i++)
         {
            result += "0";
         }
         return result;
      }
      
      public static function compareNumbers(a:Number, b:Number) : int
      {
         if(a < b)
         {
            return -1;
         }
         if(a > b)
         {
            return 1;
         }
         return 0;
      }
      
      public static function clamp(value:Number, min:Number, max:Number) : Number
      {
         return Math.max(min,Math.min(max,value));
      }
      
      public static function getRandomInRange(min:Number, max:Number) : Number
      {
         return min + (max - min) * Math.random();
      }
      
      public static function getRandomInt(range:int, start:int = 0) : int
      {
         return Math.floor(range * Math.random()) + start;
      }
      
      public static function getRandomEvenInt(range:int, start:int = 0) : int
      {
         if(isOdd(start))
         {
            start += 1;
         }
         return start + Math.floor(range / 2 * Math.random()) * 2;
      }
      
      public static function getRandomOddInt(range:int, start:int = 0) : int
      {
         if(isEven(start))
         {
            start += 1;
         }
         return start + Math.floor(range / 2 * Math.random()) * 2;
      }
      
      public static function isEven(num:int) : Boolean
      {
         return (num & 1) == 0;
      }
      
      public static function isOdd(num:int) : Boolean
      {
         return (num & 1) == 1;
      }
      
      public static function checkParity(num:int, parity:int) : Boolean
      {
         if(isEven(parity))
         {
            return isEven(num);
         }
         return !isEven(num);
      }
      
      public static function isAdjacent(target:int, adjacent:int) : Boolean
      {
         return target - 1 == adjacent || target + 1 == adjacent;
      }
      
      public static function lerp(a:Number, b:Number, t:Number) : Number
      {
         return (1 - t) * a + t * b;
      }
      
      public static function moveTowards(start:Number, target:Number, maxMove:Number) : Number
      {
         var result:Number = NaN;
         if(target < start)
         {
            result = start - maxMove;
            if(result < target)
            {
               result = target;
            }
         }
         if(target > start)
         {
            result = start + maxMove;
            if(result > target)
            {
               result = target;
            }
         }
         return result;
      }
      
      public static function roundToMultiple(numToRound:Number, multiple:Number) : Number
      {
         Assert.assert(multiple != 0,"Attempted to round to a multiple of zero.");
         return multiple * Math.round(numToRound / multiple);
      }
      
      public static function roundDownToMultiple(numToRound:Number, multiple:Number) : Number
      {
         Assert.assert(multiple != 0,"Attempted to round to a multiple of zero.");
         return multiple * Math.floor(numToRound / multiple);
      }
      
      public static function roundToDecimalPlace(numToRound:Number, numDecimalPlaces:int) : Number
      {
         return int(numToRound * Math.pow(10,numDecimalPlaces)) / Math.pow(10,numDecimalPlaces);
      }
   }
}

