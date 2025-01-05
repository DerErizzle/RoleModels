package jackboxgames.utils
{
   import flash.display.DisplayObject;
   import flash.geom.Rectangle;
   import flash.text.StyleSheet;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import jackboxgames.algorithm.*;
   import jackboxgames.nativeoverride.*;
   
   public class TextUtils
   {
      
      public static const ALPHABET:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
      
      public static const ALPHANUMERIC:String = "abcdefghijklmnopqrstuvwxyz0123456789";
      
      public static const BALANCE_TOP:String = "top";
      
      public static const BALANCE_CENTER:String = "center";
      
      public static const BALANCE_BOTTOM:String = "bottom";
      
      private static const NOT_ALLOWED:Array = ["FUCK","BITCH","CUNT","SHIT","COCK","FAGGOT","FAG","NIGGER","NIGGA","DICK","DYKE","HOMO","BONER","TWAT","RAPE","PENIS","VAGINA","WANK","DOUCHE","PUSSY","CLIT","CUM","KIKE"];
       
      
      public function TextUtils()
      {
         super();
      }
      
      public static function generateRandomText(length:int, source:String = "abcdefghijklmnopqrstuvwxyz0123456789") : String
      {
         if(!source || source.length <= 0)
         {
            source = ALPHANUMERIC;
         }
         var result:String = "";
         for(var i:int = 0; i < length; i++)
         {
            result += source.charAt(Random.instance.roll(source.length));
         }
         return result;
      }
      
      public static function autoScaleFormat(field:TextField, maxSize:Number) : Number
      {
         field.width -= 0.05;
         var fmt:TextFormat = field.getTextFormat();
         fmt.size = maxSize;
         field.setTextFormat(fmt);
         var x:Number = 40;
         var size:Number = fmt.size == null ? 12 : fmt.size as Number;
         while(field.maxScrollV > 1 || field.height < field.textHeight || field.textWidth > field.width)
         {
            size -= 1;
            fmt.size = size;
            field.setTextFormat(fmt);
            if(--x < 0)
            {
               break;
            }
         }
         field.width += 0.05;
         return size;
      }
      
      public static function autoScaleFont(field:TextField, maxSize:Number) : Number
      {
         if(field.styleSheet == null)
         {
            return autoScaleFormat(field,maxSize);
         }
         field.width -= 0.05;
         var ss:StyleSheet = field.styleSheet;
         var styleObj:Object = new Object();
         styleObj.fontSize = maxSize;
         styleObj.display = "inline";
         ss.setStyle("as",styleObj);
         field.htmlText = "<as>" + field.htmlText + "</as>";
         var x:Number = 20;
         while(field.maxScrollV > 1 || field.height < field.textHeight || field.textWidth > field.width)
         {
            styleObj.fontSize -= 1;
            ss.setStyle("as",styleObj);
            if(--x < 0)
            {
               break;
            }
         }
         field.width += 0.05;
         return styleObj.fontSize;
      }
      
      public static function autoScaleFieldWidth(field:TextField, maxSize:Number) : Number
      {
         var origWidth:Number = field.width;
         var fmt:TextFormat = field.getTextFormat();
         fmt.size = maxSize;
         field.setTextFormat(fmt);
         field.autoSize = fmt.align;
         var x:Number = 40;
         var size:Number = fmt.size == null ? 12 : fmt.size as Number;
         while(field.width > origWidth)
         {
            size -= 1;
            fmt.size = size;
            field.setTextFormat(fmt);
            if(--x < 0)
            {
               break;
            }
         }
         return size;
      }
      
      public static function onePointReduce(field:TextField) : Number
      {
         var fmt:TextFormat = null;
         var ss:StyleSheet = null;
         var styleObj:Object = null;
         var s:Number = 0;
         if(field.styleSheet == null)
         {
            fmt = field.getTextFormat();
            fmt.size = fmt.size == null ? 11 : (fmt.size as Number) - 1;
            field.setTextFormat(fmt);
            s = Number(fmt.size);
         }
         else
         {
            ss = field.styleSheet;
            styleObj = new Object();
            styleObj.display = "inline";
            styleObj.fontSize = Number(field.getTextFormat(0,1).size) - 1;
            ss.setStyle("as",styleObj);
            field.htmlText = "<as>" + field.htmlText + "</as>";
            s = Number(styleObj.fontSize);
         }
         return s;
      }
      
      public static function balanceTf(tf:TextField, balancer:DisplayObject, type:String) : void
      {
         if(type == BALANCE_TOP)
         {
            tf.y = balancer.y;
         }
         else if(type == BALANCE_CENTER)
         {
            tf.y = balancer.y + balancer.height / 2 - tf.textHeight / 2;
            if(EnvUtil.isAIR())
            {
               if(tf.numLines == 1)
               {
                  tf.y += Number(tf.getTextFormat().leading) / 2;
               }
            }
         }
         else if(type == BALANCE_BOTTOM)
         {
            tf.y = balancer.height - tf.textHeight;
            if(EnvUtil.isAIR())
            {
               if(tf.numLines == 1)
               {
                  tf.y -= Number(tf.getTextFormat().leading);
               }
            }
         }
      }
      
      public static function getTextHeight(txt:TextField) : Number
      {
         if(txt.numLines > 1)
         {
            return txt.textHeight;
         }
         var tfmt:TextFormat = txt.getTextFormat();
         var origLeading:Object = tfmt.leading;
         tfmt.leading = 0;
         txt.setTextFormat(tfmt);
         var noLeadingSlh:Number = txt.textHeight;
         tfmt.leading = origLeading;
         txt.setTextFormat(tfmt);
         return noLeadingSlh;
      }
      
      public static function getBounds(tf:TextField) : Rectangle
      {
         var r:Rectangle = null;
         var newR:Rectangle = null;
         if(tf.length == 0)
         {
            return null;
         }
         for(var i:int = 0; i < tf.length; i++)
         {
            newR = tf.getCharBoundaries(i);
            if(newR)
            {
               if(Boolean(r))
               {
                  r = r.union(newR);
               }
               else
               {
                  r = newR;
               }
            }
         }
         return r;
      }
      
      public static function textOverflow(field:TextField) : Boolean
      {
         return field.maxScrollV > 1 || field.height < field.textHeight || field.textWidth > field.width;
      }
      
      public static function stripHTMLTagsSimple(src:String) : String
      {
         var s:Number = NaN;
         var temp:String = "";
         while((s = src.indexOf("<")) != -1)
         {
            temp += src.substr(0,s);
            src = src.substr(src.indexOf(">") + 1);
         }
         return temp + src;
      }
      
      public static function addHTMLTag(txt:String, tpe:String, attributes:Object = null) : String
      {
         var prop:String = null;
         var htmlTxt:String = "<" + tpe;
         if(attributes != null)
         {
            for(prop in attributes)
            {
               htmlTxt += " " + prop + "=\'" + attributes[prop] + "\'";
            }
         }
         return htmlTxt + (">" + txt + "</" + tpe + ">");
      }
      
      public static function insertLineBreaks(txt:String) : String
      {
         var i:int = 0;
         var words:Array = null;
         var half:Number = NaN;
         var c:Number = NaN;
         var splitDiff:Number = NaN;
         var splitPoint:Number = NaN;
         var diff:Number = NaN;
         if(txt.length > 20 && txt.indexOf("\n") == -1)
         {
            words = txt.split(" ");
            if(words.length > 1)
            {
               half = txt.length / 2 > 31 ? 31 : txt.length / 2;
               c = Number(words[0].length);
               splitDiff = Math.abs(c - half);
               splitPoint = 0;
               for(i = 1; i < words.length; i++)
               {
                  c += words[i].length + 1;
                  diff = Math.abs(c - half);
                  if(diff < splitDiff)
                  {
                     splitPoint = i;
                     splitDiff = diff;
                  }
               }
               txt = "";
               for(i = 0; i < words.length; i++)
               {
                  txt += words[i];
                  if(splitPoint == i)
                  {
                     txt += "\n";
                  }
                  else if(i < words.length - 1)
                  {
                     txt += " ";
                  }
               }
            }
         }
         return txt;
      }
      
      public static function stringReplace(text:String, replace:String, replacement:String) : String
      {
         var result:String = "";
         var next:String = "";
         var parts:Array = text.split(replace);
         for(var index:int = 0; index < parts.length; index++)
         {
            result = result + next + parts[index];
            next = replacement;
         }
         return result;
      }
      
      public static function stringReplaceFirst(text:String, replace:String, replacement:String) : String
      {
         var result:String = "";
         var next:String = "";
         var parts:Array = text.split(replace);
         var found:Boolean = false;
         for(var index:int = 0; index < parts.length; index++)
         {
            result = result + next + parts[index];
            next = found ? replace : replacement;
            found = true;
         }
         return result;
      }
      
      private static function _getBytesNeededForCharCode(charCode:int) : int
      {
         if(charCode <= 127)
         {
            return 1;
         }
         if(charCode <= 2047)
         {
            return 2;
         }
         if(charCode <= 65535)
         {
            return 3;
         }
         if(charCode <= 2097151)
         {
            return 4;
         }
         Assert.assert(false);
         return 1;
      }
      
      public static function regexIndexToStringIndex(s:String, regexIndex:int) : int
      {
         if(EnvUtil.isAIR())
         {
            return regexIndex;
         }
         var currentBytes:int = 0;
         for(var i:int = 0; i < s.length; i++)
         {
            if(currentBytes >= regexIndex)
            {
               return i;
            }
            currentBytes += _getBytesNeededForCharCode(s.charCodeAt(i));
         }
         return -1;
      }
      
      public static function isEmail(email:String) : Boolean
      {
         var reg:String = "^([A-Za-z0-9_\\-\\.])+\\@([A-Za-z0-9_\\-\\.])+\\.([A-Za-z]+)";
         return RegEx.Test(reg,"",email);
      }
      
      public static function isUsername(email:String) : Boolean
      {
         return email.length > 6;
      }
      
      public static function stringsAreClose(phraseOne:String, phraseTwo:String) : Boolean
      {
         var trimmedOne:String = TextUtils.trim(phraseOne);
         var trimmedTwo:String = TextUtils.trim(phraseTwo);
         var longestPhrase:String = trimmedOne.length < trimmedTwo.length ? trimmedTwo : trimmedOne;
         return JBGUtil.levenshteinDistance(trimmedOne.toLowerCase(),trimmedTwo.toLowerCase()) > longestPhrase.length / 4 ? false : true;
      }
      
      public static function capitalizeFirstCharacter(input:String) : String
      {
         if(!input)
         {
            return "";
         }
         if(input.length == 1)
         {
            return input.toUpperCase();
         }
         var first:String = input.substr(0,1);
         var rest:String = input.substr(1,input.length);
         return first.toUpperCase() + rest.toLowerCase();
      }
      
      public static function capitalizeForName(input:String) : String
      {
         if(!input)
         {
            return "";
         }
         var name:String = input.substr(0,1).toUpperCase();
         for(var i:int = 1; i < input.length; i++)
         {
            name += RegEx.Test("[ -:_—]","ig",input.charAt(i - 1)) ? input.charAt(i).toUpperCase() : input.charAt(i).toLowerCase();
         }
         return name;
      }
      
      public static function filter(s:String, filters:Array) : String
      {
         for(var i:int = 0; i < filters.length; i++)
         {
            s = String(filters[i](s));
         }
         return s;
      }
      
      public static function replaceFilter(pattern:String, replace:String) : Function
      {
         return function(s:String):String
         {
            return TextUtils.stringReplace(s,pattern,replace);
         };
      }
      
      public static function truncateFilter(maxLength:Number) : Function
      {
         return function(s:String):String
         {
            if(s.length > maxLength)
            {
               s = s.substr(0,maxLength - 1);
               s += "…";
            }
            return s;
         };
      }
      
      public static function sanitize(s:String) : String
      {
         var bad:String = null;
         var returnMe:String = s.toUpperCase();
         for each(bad in NOT_ALLOWED)
         {
            if(EnvUtil.isMobile())
            {
               returnMe = TextUtils.stringReplace(returnMe,bad,"****");
            }
            else
            {
               returnMe = returnMe.replace(bad,"****");
            }
         }
         return returnMe;
      }
      
      public static function htmlEscape(s:String) : String
      {
         return s.replace(/&/g,"&amp;").replace(/"/g,"&quot;").replace(/'/g,"&#39;").replace(/</g,"&lt;").replace(/>/g,"&gt;");
      }
      
      public static function htmlUnescape(s:String) : String
      {
         return s.replace(/&quot;/gi,"\"").replace(/&#39;/gi,"\'").replace(/&lt;/gi,"<").replace(/&gt;/gi,">").replace(/&amp;/gi,"&");
      }
      
      public static function htmlEscapedTruncate(s:String, length:int) : String
      {
         return htmlEscape(htmlUnescape(s).substr(0,length));
      }
      
      public static function ellipsize(s:String, maxLength:int) : String
      {
         if(s.length > maxLength)
         {
            return s.substr(0,maxLength - 1) + "&#8230;";
         }
         return s;
      }
      
      public static function caseInsensitiveCompare(a:String, b:String) : Boolean
      {
         if(!a || !b)
         {
            return a == b;
         }
         return a.toLowerCase() == b.toLowerCase();
      }
      
      public static function trim(s:String) : String
      {
         return s.replace(/^\s+|\s+$/g,"");
      }
      
      public static function fancyCommaConcat(strings:Array, finalSeperator:String) : String
      {
         if(strings.length == 0)
         {
            return null;
         }
         if(strings.length == 1)
         {
            return strings[0];
         }
         if(strings.length == 2)
         {
            return strings[0] + " " + finalSeperator + " " + strings[1];
         }
         var allStringsExceptLast:Array = strings.slice(0,strings.length - 1);
         return allStringsExceptLast.join(", ") + ", " + finalSeperator + " " + ArrayUtil.last(strings);
      }
      
      public static function stringContainsLetter(s:String, letter:String) : Boolean
      {
         return s.toLowerCase().indexOf(letter.toLowerCase()) >= 0;
      }
      
      public static function rarestLetterInStrings(arrayOfStrings:Array) : String
      {
         var s:String = null;
         var minCount:int = 0;
         var rarestLetter:String = null;
         var letter:String = null;
         var i:int = 0;
         var letterCounts:Object = {};
         for each(s in arrayOfStrings)
         {
            for(i = 0; i < s.length; i++)
            {
               if(letterCounts.hasOwnProperty(s.charAt(i)))
               {
                  letterCounts[s.charAt(i)] = letterCounts[s.charAt(i)] + 1;
               }
               else
               {
                  letterCounts[s.charAt(i)] = 1;
               }
            }
         }
         minCount = int.MAX_VALUE;
         rarestLetter = "";
         for(letter in letterCounts)
         {
            if(letterCounts[letter] < minCount)
            {
               minCount = int(letterCounts[letter]);
               rarestLetter = letter;
            }
         }
         return rarestLetter;
      }
      
      public static function reversed(s:String) : String
      {
         return s.split("").reverse().join("");
      }
      
      public static function splitUsingPattern(textToSplit:String, pattern:*) : Array
      {
         var subStrings:Array = [];
         var searchSubstring:String = textToSplit;
         var patternIndex:int = searchSubstring.search(pattern);
         while(patternIndex > 0)
         {
            subStrings.push(searchSubstring.substring(0,patternIndex + 1));
            searchSubstring = searchSubstring.substring(patternIndex + 1);
            patternIndex = searchSubstring.search(pattern);
         }
         return subStrings;
      }
   }
}