package jackboxgames.text
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import jackboxgames.utils.*;
   
   public final class PostEffectFactory
   {
       
      
      public function PostEffectFactory()
      {
         super();
      }
      
      public static function createBalancerEffect(type:String) : Function
      {
         return function(parentMc:MovieClip, tf:TextField, text:String, data:*):void
         {
            if(!parentMc.balancer)
            {
               return;
            }
            TextUtils.balanceTf(tf,parentMc.balancer,type);
         };
      }
      
      public static function createDynamicResizerEffect(maxLines:int = 1, minSize:int = 4, maxSize:int = 128, stepSize:int = 2, splitWords:Boolean = true) : Function
      {
         var hasBeenResized:Boolean = false;
         var initialFontSize:Number = NaN;
         var initialLeading:Number = NaN;
         var initialNumLines:int = 0;
         hasBeenResized = false;
         return function(parentMc:MovieClip, tf:TextField, text:String, data:*):void
         {
            var balancer:*;
            var currentSize:*;
            var wordsAreSplit:Function;
            var allWords:* = undefined;
            var nonSplitSize:* = undefined;
            var adjustTFSize:Function = function(size:int):void
            {
               tf.htmlText = "<font size=\'" + size + "\'>" + text + "</font>";
               var newTextFormat:* = new TextFormat();
               var heightRatio:* = initialFontSize == 0 ? 1 : Number(size) / initialFontSize;
               newTextFormat.leading = initialLeading * heightRatio;
               tf.setTextFormat(newTextFormat);
            };
            if(!hasBeenResized)
            {
               initialFontSize = Number(tf.defaultTextFormat.size);
               initialLeading = Number(tf.defaultTextFormat.leading);
               initialNumLines = Math.floor(tf.height / tf.getLineMetrics(0).height);
               if(initialNumLines != maxLines)
               {
                  trace("ExtendableTextField Warning: maxLines is different from calculated numLines! " + "(" + maxLines + " != " + initialNumLines + ")");
               }
               hasBeenResized = true;
            }
            balancer = parentMc.balancer;
            if(!balancer)
            {
               return;
            }
            currentSize = minSize;
            tf.multiline = tf.wordWrap = true;
            adjustTFSize(currentSize);
            while(tf.textHeight < balancer.height && currentSize < maxSize && tf.numLines <= initialNumLines)
            {
               currentSize += stepSize;
               adjustTFSize(currentSize);
            }
            currentSize -= stepSize;
            adjustTFSize(currentSize);
            if(!splitWords)
            {
               wordsAreSplit = function(words:Array):Boolean
               {
                  var line:* = undefined;
                  var lineWords:* = undefined;
                  var index:* = undefined;
                  var lines:* = tf.numLines;
                  var wordIndex:* = 0;
                  for(var lineIndex:* = 0; lineIndex < lines; lineIndex++)
                  {
                     line = tf.getLineText(lineIndex);
                     lineWords = line.split(" ");
                     for(index = 0; index < lineWords.length; index++)
                     {
                        if(lineWords[index] != " " && lineWords[index] != "" && lineWords[index] != "\r" && lineWords[index] != allWords[wordIndex++])
                        {
                           return true;
                        }
                     }
                  }
                  return false;
               };
               allWords = tf.text.split(" ");
               nonSplitSize = currentSize;
               while(nonSplitSize > minSize && wordsAreSplit(allWords))
               {
                  nonSplitSize -= stepSize;
                  adjustTFSize(nonSplitSize);
               }
               if(wordsAreSplit(allWords))
               {
                  adjustTFSize(currentSize);
               }
            }
         };
      }
   }
}
