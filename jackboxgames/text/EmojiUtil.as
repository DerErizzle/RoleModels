package jackboxgames.text
{
   import flash.utils.ByteArray;
   import jackboxgames.utils.*;
   
   public final class EmojiUtil
   {
      public function EmojiUtil()
      {
         super();
      }
      
      public static function charCount(str:String) : uint
      {
         if(str == null || str.length == 0)
         {
            return 0;
         }
         var eff:EmojiEffect = new EmojiEffect();
         return eff.preprocessEmoji(str).length;
      }
      
      public static function toUpperCase(str:String) : String
      {
         var charCode:uint = 0;
         var s:String = "";
         for(var i:uint = 0; i < str.length; i++)
         {
            charCode = uint(str.charCodeAt(i));
            if(charCode < 8191)
            {
               s += str.charAt(i).toUpperCase();
            }
            else
            {
               s += str.charAt(i);
            }
         }
         return s;
      }
      
      public static function toLowerCase(str:String) : String
      {
         var charCode:uint = 0;
         var s:String = "";
         for(var i:uint = 0; i < str.length; i++)
         {
            charCode = uint(str.charCodeAt(i));
            if(charCode < 8191)
            {
               s += str.charAt(i).toLowerCase();
            }
            else
            {
               s += str.charAt(i);
            }
         }
         return s;
      }
      
      public static function truncate(str:String, maxLen:uint) : String
      {
         var bc:uint = 0;
         var b:uint = 0;
         if(str.length < maxLen)
         {
            return str;
         }
         var unescaped:String = TextUtils.htmlUnescape(str);
         var eff:EmojiEffect = new EmojiEffect();
         eff.preprocessEmoji(unescaped);
         var map:Array = eff.emojiMap;
         var dest:ByteArray = new ByteArray();
         var src:ByteArray = new ByteArray();
         src.writeUTFBytes(unescaped);
         var glyphs:uint = 0;
         var e:uint = 0;
         var cps:uint = 0;
         var THREE_BYTE_PREFIX:uint = 14;
         var FOUR_BYTE_PREFIX:uint = 30;
         var k:uint = 0;
         while(k < src.length && glyphs < maxLen)
         {
            if(e < map.length && (map[e].idx == glyphs && cps <= 0))
            {
               cps = uint(map[e].codepoints.length);
               e++;
            }
            if(uint(src[k] >>> 7) == 0)
            {
               dest.writeByte(src[k]);
               k++;
            }
            else
            {
               bc = 2;
               if(uint(src[k]) >>> 3 == FOUR_BYTE_PREFIX)
               {
                  bc = 4;
               }
               else if(uint(src[k]) >>> 4 == THREE_BYTE_PREFIX)
               {
                  bc = 3;
               }
               for(b = 0; b < bc; b++)
               {
                  dest.writeByte(src[k]);
                  k++;
               }
            }
            if(cps > 0)
            {
               cps--;
            }
            if(cps == 0)
            {
               glyphs++;
            }
         }
         return TextUtils.htmlEscape(dest.toString());
      }
   }
}

