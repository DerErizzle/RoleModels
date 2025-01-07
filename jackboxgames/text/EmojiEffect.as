package jackboxgames.text
{
   import flash.display.*;
   import flash.geom.*;
   import flash.text.*;
   import jackboxgames.logger.*;
   import jackboxgames.utils.*;
   
   public class EmojiEffect
   {
      private static const EMOJI_CHARACTER_PLACEHOLDER:String = "―";
      
      private static const EMOJI_VARIATION_SELECTOR_16:uint = 65039;
      
      private static const EMOJI_KEYCAP:uint = 8419;
      
      private static const EMOJI_ZERO_WIDTH_JOINER:uint = 8205;
      
      private static const UTF16MAX:uint = 65535;
      
      private static const EMOJI_DEFAULT_GLYPH:String = "2b1c";
      
      private static const SMALL_LATIN_PREFIX:uint = 56128;
      
      private static const CANCEL_TAG:uint = 917631;
      
      private static const BASIC_PLANE_EMOJI:Array = [[169],[174],[8252],[8265],[8419],[8482],[8505],[8596,8601],[8617,8618],[8986,8987],[9000],[9167],[9193,9210],[9410],[9642,9643],[9654],[9664],[9723,9726],[9728,9732],[9742],[9745],[9748,9752],[9757],[9760],[9762,9763],[9766],[9770],[9774,9775],[9784,9786],[9792],[9794],[9800,9811],[9823],[9824],[9827],[9829,9830],[9832],[9851],[9854,9855],[9874,9881],[9883,9884],[9888,9889],[9895],[9898,9899],[9904,9905],[9917],[9918],[9924,9925],[9928],[9934,9935],[9937],[9939,9940],[9961,9962],[9968,9978],[9981],[9986],[9989],[9992,9997],[9999],[10002],[10004],[10006],[10013],[10017],[10024],[10035,10036],[10052],[10055],[10060],[10062],[10067,10069],[10071],[10083,10085],[10133,10135],[10145],[10160],[10175],[10548,10549],[11013,11015],[11035,11036],[11088],[11093],[12336],[12349],[12951],[12953],[58634],[65039]];
      
      private static const STATE_TEXT:String = "State.Text";
      
      private static const STATE_EMOJI:String = "State.Emoji";
      
      private static const STATE_JOINER:String = "State.Joiner";
      
      private static const STATE_REGIONAL:String = "State.Regional";
      
      private var _emojiMap:Array;
      
      private var _clips:Array;
      
      private var _verticalOffsetScaleX:Number;
      
      private var _percentScale:Number;
      
      private var _prevCharState:String;
      
      public function EmojiEffect()
      {
         super();
         this._clips = [];
      }
      
      private static function _isModifier(codepoint:uint) : Boolean
      {
         if(codepoint >= 127995 && codepoint <= 127999 || codepoint == 65039 || codepoint == 8419)
         {
            return true;
         }
         return false;
      }
      
      private static function _toCodePoint(H:uint, L:uint) : uint
      {
         return (H - 55296) * 1024 + (L - 56320) + 65536;
      }
      
      private static function _fromCodePoint(cp:uint) : Object
      {
         var H:uint = Math.floor((cp - 65536) / 1024) + 55296;
         var L:uint = (cp - 65536) % 1024 + 56320;
         return [H,L];
      }
      
      private static function _isEmoji(charCode:uint) : Boolean
      {
         var check:Array = null;
         if(_isDoubleCharCodeEmoji(charCode))
         {
            return true;
         }
         for each(check in BASIC_PLANE_EMOJI)
         {
            if(check.length == 1)
            {
               if(charCode == check[0])
               {
                  return true;
               }
            }
            else if(charCode >= check[0] && charCode <= check[1])
            {
               return true;
            }
         }
         return false;
      }
      
      private static function _isDoubleCharCodeEmoji(charCode:uint) : Boolean
      {
         if(charCode > UTF16MAX)
         {
            charCode = uint(_fromCodePoint(charCode)[0]);
         }
         if(charCode >= 55356 && charCode <= 55358)
         {
            return true;
         }
         return false;
      }
      
      private static function _isSmallLatinCharacter(charCode:uint) : Boolean
      {
         if(charCode > UTF16MAX)
         {
            charCode = uint(_fromCodePoint(charCode)[0]);
         }
         return charCode == SMALL_LATIN_PREFIX;
      }
      
      private static function _isZeroWidthJoiner(charCode:uint) : Boolean
      {
         return charCode == EMOJI_ZERO_WIDTH_JOINER;
      }
      
      private static function _isRegionalIndicator(codePoint:uint) : Boolean
      {
         return codePoint >= 127462 && codePoint <= 127487;
      }
      
      public static function _getGlyphId(codePointArray:Array) : String
      {
         if(codePointArray.length == 2 && codePointArray[1] == "fe0f")
         {
            codePointArray.pop();
         }
         return "E" + codePointArray.join("M");
      }
      
      public function getEmojiMapper(percentScale:Number = 1, verticalOffsetScale:Number = 0) : Function
      {
         var effect:EmojiEffect = null;
         effect = this;
         this._percentScale = percentScale;
         this._verticalOffsetScaleX = verticalOffsetScale;
         return function(s:String, data:*):String
         {
            return effect.preprocessEmoji(s);
         };
      }
      
      public function getEmojiPostEffect() : Function
      {
         var effect:EmojiEffect = null;
         effect = this;
         return function(root:DisplayObjectContainer, tf:TextField, text:String, data:*):void
         {
            effect.applyEmoji(root,tf);
         };
      }
      
      private function _convertPreviousCharToEmoji(text:String) : String
      {
         if(text.length == 0)
         {
            return text;
         }
         var prevChar:uint = uint(text.charCodeAt(text.length - 1));
         text = text.substr(0,text.length - 1) + EMOJI_CHARACTER_PLACEHOLDER;
         this._createNewMapping(text.length - 1,prevChar);
         this._prevCharState = STATE_EMOJI;
         return text;
      }
      
      public function preprocessEmoji(txt:String) : String
      {
         var charCode:uint = 0;
         var codePoint:uint = 0;
         txt = TextUtils.htmlUnescape(txt);
         var newTxt:String = "";
         this._emojiMap = [];
         this._prevCharState = STATE_TEXT;
         for(var i:uint = 0; i < txt.length; i++)
         {
            charCode = uint(txt.charCodeAt(i));
            if(_isEmoji(charCode) || this._prevCharState == STATE_EMOJI && _isZeroWidthJoiner(charCode))
            {
               codePoint = charCode;
               if(_isDoubleCharCodeEmoji(charCode))
               {
                  if(charCode < UTF16MAX)
                  {
                     codePoint = _toCodePoint(charCode,txt.charCodeAt(++i));
                  }
               }
               if(this._prevCharState == STATE_TEXT && codePoint == EMOJI_VARIATION_SELECTOR_16)
               {
                  newTxt = this._convertPreviousCharToEmoji(newTxt);
               }
               else if(_isModifier(codePoint))
               {
                  if(codePoint == EMOJI_KEYCAP)
                  {
                     if(this._prevCharState == STATE_TEXT)
                     {
                        newTxt = this._convertPreviousCharToEmoji(newTxt);
                     }
                  }
                  if(this.lastCodepointInHex == codePoint.toString(16))
                  {
                     continue;
                  }
                  this._addToLastMapping(codePoint);
               }
               else if(_isRegionalIndicator(codePoint))
               {
                  if(this._prevCharState == STATE_REGIONAL)
                  {
                     this._addToLastMapping(codePoint);
                     this._prevCharState = STATE_EMOJI;
                  }
                  else
                  {
                     this._createNewMapping(newTxt.length,codePoint);
                     newTxt += EMOJI_CHARACTER_PLACEHOLDER;
                     this._prevCharState = STATE_REGIONAL;
                  }
               }
               else if(this._prevCharState == STATE_EMOJI && _isZeroWidthJoiner(codePoint))
               {
                  this._prevCharState = STATE_JOINER;
               }
               else if(this._prevCharState == STATE_JOINER)
               {
                  this._addToLastMapping(EMOJI_ZERO_WIDTH_JOINER);
                  this._addToLastMapping(codePoint);
                  this._prevCharState = STATE_EMOJI;
               }
               else
               {
                  this._createNewMapping(newTxt.length,codePoint);
                  newTxt += EMOJI_CHARACTER_PLACEHOLDER;
                  this._prevCharState = STATE_EMOJI;
               }
            }
            else if(_isSmallLatinCharacter(charCode))
            {
               codePoint = charCode < UTF16MAX ? _toCodePoint(charCode,txt.charCodeAt(++i)) : charCode;
               if(this._prevCharState == STATE_EMOJI)
               {
                  this._addToLastMapping(codePoint);
               }
            }
            else
            {
               newTxt += txt.charAt(i);
               this._prevCharState = STATE_TEXT;
            }
         }
         return TextUtils.htmlUnescapeValidTags(TextUtils.htmlEscape(newTxt));
      }
      
      private function _createNewMapping(idx:uint, codePoint:uint) : void
      {
         var emoji:Object = {
            "idx":idx,
            "codepoints":[codePoint.toString(16)]
         };
         this._emojiMap.push(emoji);
      }
      
      private function _addToLastMapping(codePoint:uint) : void
      {
         if(this._emojiMap.length <= 0)
         {
            return;
         }
         var emoji:Object = this._emojiMap[this._emojiMap.length - 1];
         emoji.codepoints.push(codePoint.toString(16));
      }
      
      private function get lastCodepointInHex() : String
      {
         if(this.emojiMap.length <= 0)
         {
            return null;
         }
         var emoji:Object = this._emojiMap[this._emojiMap.length - 1];
         return ArrayUtil.last(emoji.codepoints);
      }
      
      public function applyEmoji(root:DisplayObjectContainer, tf:TextField) : void
      {
         var rect:Rectangle = null;
         var adjustX:Number = NaN;
         var adjustY:Number = NaN;
         var line:int = 0;
         var lineMetrics:TextLineMetrics = null;
         var descent:Number = NaN;
         var glyphId:String = null;
         var emojiInstance:Sprite = null;
         var emojiData:BitmapData = null;
         var emojiBitmap:Bitmap = null;
         for(var i:uint = 0; i < this._emojiMap.length; i++)
         {
            rect = tf.getCharBoundaries(this._emojiMap[i].idx);
            if(rect == null)
            {
               Logger.debug("**** How did we get here? \"" + tf.text + "\" emojiMap[" + i + "].idx = " + this._emojiMap[i].idx);
            }
            else
            {
               adjustX = rect.width * (1 - this._percentScale);
               adjustY = rect.height * (1 - this._percentScale);
               rect.x += adjustX / 2;
               rect.y += adjustY / 2 + rect.height * this._verticalOffsetScaleX;
               rect.width -= adjustX;
               rect.height -= adjustY;
               rect.x += tf.x;
               rect.y += tf.y;
               line = tf.getLineIndexOfChar(this._emojiMap[i].idx);
               lineMetrics = tf.getLineMetrics(line);
               descent = lineMetrics.descent;
               if(rect.width > rect.height)
               {
                  rect.x += (rect.width - rect.height) / 2;
                  rect.width = rect.height;
               }
               else
               {
                  rect.y += (rect.height - rect.width) / 2;
                  rect.height = rect.width;
               }
               glyphId = _getGlyphId(this._emojiMap[i].codepoints);
               if(!EmojiLibWrapper.hasId(glyphId))
               {
                  Logger.debug("Missing emoji glyph: " + glyphId);
                  glyphId = _getGlyphId([EMOJI_DEFAULT_GLYPH]);
               }
               emojiInstance = new Sprite();
               emojiData = EmojiLibWrapper.getId(glyphId);
               if(!emojiData)
               {
                  Logger.debug("Bitmap data empty for glyph: " + glyphId);
               }
               emojiBitmap = new Bitmap(emojiData,"auto",true);
               emojiInstance.addChild(emojiBitmap);
               emojiBitmap.y = -emojiBitmap.height;
               this._clips.push(emojiInstance);
               emojiInstance.width = rect.width;
               emojiInstance.scaleY = emojiInstance.scaleX;
               root.addChild(emojiInstance);
               emojiInstance.x = rect.x;
               emojiInstance.y = rect.y + rect.height;
            }
         }
      }
      
      public function clearEmoji() : void
      {
         var sprite:Sprite = null;
         for each(sprite in this._clips)
         {
            if(sprite.parent != null)
            {
               JBGUtil.safeRemoveChild(sprite.parent,sprite);
            }
         }
         this._clips = [];
      }
      
      public function get emojiMap() : Array
      {
         return this._emojiMap;
      }
   }
}

