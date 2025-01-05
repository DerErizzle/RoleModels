package jackboxgames.widgets
{
   import flash.display.*;
   import jackboxgames.audio.*;
   import jackboxgames.events.*;
   import jackboxgames.settings.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class SubtitleWidget
   {
       
      
      private const TIME_BETWEEN_LAST_UPDATE_AND_DISAPPEAR:Number = 0.2;
      
      private const MAX_CHARACTER_LIMIT_PER_LINE:int = 45;
      
      private const MIN_CHARACTER_LIMIT_PER_LINE:int = 35;
      
      private const MAXIMUM_NUMBER_OF_LINES:int = 2;
      
      private const CHARACTERS_PER_SECOND:int = 20;
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _tf:ExtendableTextField;
      
      private var _doExtraStyleFn:Function;
      
      private var _disallowedCategories:Array;
      
      private var _currentSubtitle:SubtitleEntry;
      
      private var _disappearCanceler:Function;
      
      private var _updateCanceller:Function;
      
      public function SubtitleWidget(mc:MovieClip, doExtraStyleFn:Function)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._tf = new ExtendableTextField(this._mc.subtitleDisplay,[],[]);
         this._doExtraStyleFn = doExtraStyleFn;
         this._disallowedCategories = [];
         AudioNotifier.instance.addEventListener(AudioNotificationEvent.AUDIO_STARTED,this._onAudioStarted);
         AudioNotifier.instance.addEventListener(AudioNotificationEvent.AUDIO_ENDED,this._onAudioEnded);
         this._currentSubtitle = null;
         this._disappearCanceler = Nullable.NULL_FUNCTION;
         this._updateCanceller = Nullable.NULL_FUNCTION;
      }
      
      public function dispose() : void
      {
         this.reset();
         this._shower.dispose();
         AudioNotifier.instance.removeEventListener(AudioNotificationEvent.AUDIO_STARTED,this._onAudioStarted);
         AudioNotifier.instance.removeEventListener(AudioNotificationEvent.AUDIO_ENDED,this._onAudioEnded);
      }
      
      public function reset() : void
      {
         this._currentSubtitle = null;
         this._shower.reset();
         this._disappearCanceler = Nullable.NULL_FUNCTION;
         this._updateCanceller = Nullable.NULL_FUNCTION;
      }
      
      public function addDisallowedCategory(category:String) : void
      {
         ArrayUtil.deduplicatedPush(this._disallowedCategories,category);
      }
      
      private function _onAudioStarted(evt:AudioNotificationEvent) : void
      {
         if(!SettingsManager.instance.getValue(SettingsConstants.SETTING_SUBTITLES).val)
         {
            return;
         }
         if(evt.metadata.hasOwnProperty("Unsubtitled"))
         {
            return;
         }
         if(ArrayUtil.arrayContainsElement(this._disallowedCategories,evt.category))
         {
            return;
         }
         if(!evt.text)
         {
            return;
         }
         this._disappearCanceler();
         this._updateCanceller();
         this._currentSubtitle = new SubtitleEntry(evt.id,this._formatSubtitle(evt.text));
         this._updateSubtitleTextField();
         this._shower.setShown(true,Nullable.NULL_FUNCTION);
      }
      
      private function _formatSubtitle(text:String) : Array
      {
         var subtitles:Array;
         var subtitleText:String = null;
         var pattern:RegExp = null;
         var textLines:Array = null;
         var line:String = null;
         var closestSpaceToLimitIndex:int = 0;
         subtitleText = text;
         subtitleText.match(/\[.+\]/g).forEach(function(match:*, ... args):void
         {
            subtitleText = subtitleText.replace(match,"");
         });
         subtitleText = TextUtils.trim(subtitleText);
         subtitles = [];
         if(subtitleText.length <= this.MAX_CHARACTER_LIMIT_PER_LINE)
         {
            subtitles.push(subtitleText);
         }
         else
         {
            pattern = /([.,!?;:](?![.,!?;:]))|$/;
            textLines = TextUtils.splitUsingPattern(subtitleText,pattern);
            while(textLines.length > 0)
            {
               line = textLines.shift();
               while(line.length < this.MIN_CHARACTER_LIMIT_PER_LINE && textLines.length > 0)
               {
                  line += textLines.shift();
               }
               if(line.length > this.MAX_CHARACTER_LIMIT_PER_LINE)
               {
                  closestSpaceToLimitIndex = line.lastIndexOf(" ",this.MAX_CHARACTER_LIMIT_PER_LINE);
                  subtitles.push(line.slice(0,closestSpaceToLimitIndex));
                  textLines.unshift(line.slice(closestSpaceToLimitIndex));
               }
               else
               {
                  subtitles.push(line);
               }
            }
         }
         subtitles = subtitles.map(function(text:String, ... args):String
         {
            return TextUtils.trim(text);
         });
         return subtitles;
      }
      
      private function _updateSubtitleTextField() : void
      {
         var numberOfLines:int;
         var textToDisplay:String;
         if(!this._currentSubtitle)
         {
            return;
         }
         numberOfLines = 0;
         textToDisplay = "";
         while(numberOfLines < this.MAXIMUM_NUMBER_OF_LINES && this._currentSubtitle.hasLines)
         {
            textToDisplay += this._currentSubtitle.getNextLine() + "\n";
            numberOfLines++;
         }
         if(textToDisplay.length == 0)
         {
            return;
         }
         this._tf.text = textToDisplay;
         this._doExtraStyleFn(this._mc,this._tf);
         this._updateCanceller = JBGUtil.runFunctionAfter(function():void
         {
            _updateCanceller = Nullable.NULL_FUNCTION;
            _updateSubtitleTextField();
         },Duration.fromSec(Number(textToDisplay.length / this.CHARACTERS_PER_SECOND)));
      }
      
      private function _onAudioEnded(evt:AudioNotificationEvent) : void
      {
         if(!this._currentSubtitle)
         {
            return;
         }
         if(this._currentSubtitle.id != evt.id)
         {
            return;
         }
         this._currentSubtitle = null;
         this._disappearCanceler = JBGUtil.runFunctionAfter(function():void
         {
            _disappearCanceler = Nullable.NULL_FUNCTION;
            _shower.setShown(false,Nullable.NULL_FUNCTION);
         },Duration.fromSec(this.TIME_BETWEEN_LAST_UPDATE_AND_DISAPPEAR));
      }
   }
}
