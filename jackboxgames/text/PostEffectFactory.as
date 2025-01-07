package jackboxgames.text
{
   import flash.display.*;
   import flash.geom.*;
   import flash.text.*;
   import flash.utils.*;
   import jackboxgames.logger.*;
   import jackboxgames.utils.*;
   
   public final class PostEffectFactory
   {
      private static const WORD_DELIMITERS:Array = [""," ","\r"];
      
      private static const MIN_LENGTH_OF_ORPHANED_WORD:int = 5;
      
      private static const TOTAL_GUTTER_HEIGHT:Number = 4;
      
      public function PostEffectFactory()
      {
         super();
      }
      
      public static function createBalancerEffect(type:String) : Function
      {
         var hasBeenBalanced:Boolean = false;
         var initialRectangle:Rectangle = null;
         hasBeenBalanced = false;
         return function(root:DisplayObjectContainer, tf:TextField, text:String, data:*):void
         {
            if(!hasBeenBalanced)
            {
               initialRectangle = new Rectangle(tf.x,tf.y,tf.width,tf.height - TOTAL_GUTTER_HEIGHT);
               hasBeenBalanced = true;
            }
            TextUtils.balanceTf(tf,initialRectangle,type);
         };
      }
      
      private static function _wordsAreSplit(tf:TextField) : Boolean
      {
         var line:String = null;
         var lineWords:Array = null;
         var index:int = 0;
         var lineWord:String = null;
         var completeWord:String = null;
         var completeWords:Array = tf.text.split(" ");
         var wordIndex:int = 0;
         var numLines:int = tf.numLines;
         for(var lineIndex:int = 0; lineIndex < numLines; lineIndex++)
         {
            line = tf.getLineText(lineIndex);
            lineWords = line.split(" ");
            for(index = 0; index < lineWords.length; index++)
            {
               lineWord = lineWords[index];
               if(!ArrayUtil.arrayContainsElement(WORD_DELIMITERS,lineWord))
               {
                  completeWord = completeWords[wordIndex++];
                  if(lineWord != completeWord)
                  {
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      private static function _wordIsOrphaned(tf:TextField) : Boolean
      {
         var delimiter:String = null;
         var lastLine:String = tf.getLineText(tf.numLines - 1);
         if(lastLine.length < MIN_LENGTH_OF_ORPHANED_WORD)
         {
            for each(delimiter in WORD_DELIMITERS)
            {
               if(lastLine.indexOf(delimiter) != -1)
               {
                  return true;
               }
            }
            return false;
         }
         return false;
      }
      
      public static function createDynamicResizerEffect(minSize:int = 4, maxSize:int = 128, stepSize:int = 2, splitWords:Boolean = true, preventOrphans:Boolean = true) : Function
      {
         var hasBeenResized:Boolean = false;
         var initialFontSize:int = 0;
         var initialLeading:int = 0;
         var initialLetterSpacing:Number = NaN;
         var initialNumLines:int = 0;
         var sizeConstraintFunctions:Array = null;
         hasBeenResized = false;
         sizeConstraintFunctions = [];
         if(!splitWords)
         {
            sizeConstraintFunctions.push(_wordsAreSplit);
         }
         if(preventOrphans)
         {
            sizeConstraintFunctions.push(_wordIsOrphaned);
         }
         return function(root:DisplayObjectContainer, tf:TextField, text:String, data:*):void
         {
            var currentSize:*;
            var sizeConstraintFunction:* = undefined;
            var nonConstrainedSize:* = undefined;
            var adjustTFSize:Function = function(size:int):void
            {
               var newTextFormat:* = new TextFormat();
               var heightRatio:* = initialFontSize == 0 ? 1 : Number(size) / initialFontSize;
               newTextFormat.leading = Math.round(initialLeading * heightRatio);
               newTextFormat.letterSpacing = initialLetterSpacing * heightRatio;
               newTextFormat.size = size;
               tf.setTextFormat(newTextFormat);
            };
            if(!hasBeenResized)
            {
               if(tf.scaleX != 1 || tf.scaleY != 1)
               {
                  Logger.warning("There\'s scaling on a dynamic text field named " + DisplayObjectUtil.getInstancePath(tf) + " with text set to " + tf.text + ", this will cause resizing issues.");
               }
               initialFontSize = int(tf.defaultTextFormat.size);
               initialLeading = int(tf.defaultTextFormat.leading);
               initialLetterSpacing = Number(tf.getTextFormat().letterSpacing);
               initialNumLines = tf.numLines;
               if(initialNumLines == 0)
               {
                  Logger.error("The initial number of lines is 0 on a dynamic text field named " + DisplayObjectUtil.getInstancePath(tf) + " with text set to " + tf.text + ", this will break resizing.");
               }
               hasBeenResized = true;
            }
            tf.multiline = tf.wordWrap = true;
            tf.htmlText = text;
            currentSize = minSize;
            adjustTFSize(currentSize);
            while(TextUtils.getTextHeight(tf) <= tf.height - TOTAL_GUTTER_HEIGHT && currentSize < maxSize && tf.numLines <= initialNumLines)
            {
               currentSize += stepSize;
               adjustTFSize(currentSize);
            }
            currentSize -= stepSize;
            adjustTFSize(currentSize);
            for each(sizeConstraintFunction in sizeConstraintFunctions)
            {
               nonConstrainedSize = currentSize;
               while(nonConstrainedSize > minSize && sizeConstraintFunction(tf))
               {
                  nonConstrainedSize -= stepSize;
                  adjustTFSize(nonConstrainedSize);
               }
               if(sizeConstraintFunction(tf))
               {
                  adjustTFSize(currentSize);
               }
            }
         };
      }
      
      public static function createDynamicOffseterEffect(mc:MovieClip) : Function
      {
         var tfOffsets:Dictionary = null;
         var allTfs:Array = null;
         tfOffsets = new Dictionary();
         if(Boolean(mc))
         {
            allTfs = MovieClipUtil.getChildrenOfType(mc,"TextField");
            allTfs.forEach(function(tf:TextField, ... args):void
            {
               tfOffsets[tf] = {"yOffset":tf.y - allTfs[0].y};
            });
         }
         return function(root:DisplayObjectContainer, tf:TextField, text:String, data:*):void
         {
            var offsets:* = tfOffsets[tf];
            if(!offsets)
            {
               return;
            }
            tf.y += offsets.yOffset;
         };
      }
   }
}

