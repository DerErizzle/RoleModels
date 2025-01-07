package jackboxgames.text
{
   import flash.display.*;
   import flash.text.*;
   import jackboxgames.utils.*;
   
   public class ExtendableTextField
   {
      private static var _enableManualInlineStyling:Boolean = false;
      
      public static function NULL_MAPPER(s:String, data:*):String
      {
         return s;
      }
      public static function NULL_EFFECT(root:DisplayObjectContainer, tf:TextField, text:String, data:*):void
      {
      }
      private var _root:DisplayObjectContainer;
      
      private var _tfs:Array;
      
      private var _mappers:Array;
      
      private var _postEffects:Array;
      
      private var _lastData:*;
      
      private var _lastTextRaw:String;
      
      private var _lastTextMapped:String;
      
      private var _letterSpacingTextFormat:TextFormat;
      
      private var _boldFontName:String;
      
      private var _italicFontName:String;
      
      private var _boldItalicFontName:String;
      
      public function ExtendableTextField(root:DisplayObjectContainer, mappers:Array, postEffects:Array)
      {
         var allText:String;
         var i:int = 0;
         var child:* = undefined;
         var tf:TextField = null;
         var lines:int = 0;
         var separator:String = null;
         var index:int = 0;
         var textLine:String = null;
         super();
         this._root = root;
         this._tfs = [];
         if(Boolean(this._root))
         {
            for(i = 0; i < this._root.numChildren; i++)
            {
               child = this._root.getChildAt(i);
               if(child is TextField)
               {
                  if(child.name.indexOf("instance") != 0)
                  {
                     this._setupTf(child);
                     this._tfs.push(child);
                  }
               }
            }
         }
         this._mappers = ArrayUtil.copy(mappers);
         this._postEffects = ArrayUtil.copy(postEffects);
         allText = "";
         if(this._tfs.length > 0)
         {
            tf = this._tfs[0];
            if(!_enableManualInlineStyling)
            {
               if(tf.htmlText.search(/<B>.*<\/B>/i) >= 0)
               {
                  this._mappers.push(MapperFactory.createPrePostMapper(function():String
                  {
                     return "<B>";
                  },function():String
                  {
                     return "</B>";
                  }));
               }
               if(tf.htmlText.search(/<I>.*<\/I>/i) >= 0)
               {
                  this._mappers.push(MapperFactory.createPrePostMapper(function():String
                  {
                     return "<I>";
                  },function():String
                  {
                     return "</I>";
                  }));
               }
            }
            lines = tf.numLines;
            separator = "";
            for(index = 0; index < lines; index++)
            {
               textLine = tf.getLineText(index);
               textLine = textLine.replace(/[\x01-\x20]+$/g,"");
               allText += separator + textLine;
               separator = "<br/>";
            }
         }
         this.text = allText;
      }
      
      public static function enableManualInlineStyling(val:Boolean) : void
      {
         _enableManualInlineStyling = val;
      }
      
      public function dispose() : void
      {
         this._root = null;
         this._tfs = [];
         this._mappers = [];
         this._postEffects = [];
         this._lastData = null;
         this._lastTextRaw = null;
         this._lastTextMapped = null;
         this._boldFontName = null;
         this._italicFontName = null;
      }
      
      private function _setupTf(tf:TextField) : void
      {
         tf.mouseWheelEnabled = false;
         this._letterSpacingTextFormat = new TextFormat();
         this._letterSpacingTextFormat.letterSpacing = tf.getTextFormat().letterSpacing;
      }
      
      public function get root() : DisplayObjectContainer
      {
         return this._root;
      }
      
      public function get tfs() : Array
      {
         return this._tfs;
      }
      
      public function setTextWithData(val:String, data:*) : void
      {
         var mapperFn:Function = null;
         var tf:TextField = null;
         var postEffectFn:Function = null;
         this._lastTextRaw = val;
         this._lastTextMapped = val;
         this._lastData = data;
         for each(mapperFn in this._mappers)
         {
            this._lastTextMapped = mapperFn(this._lastTextMapped,data);
         }
         for each(tf in this._tfs)
         {
            if(_enableManualInlineStyling)
            {
               this._lastTextMapped = this.styleText(tf,this._lastTextMapped);
            }
            tf.htmlText = this._lastTextMapped;
            tf.setTextFormat(this._letterSpacingTextFormat);
            for each(postEffectFn in this._postEffects)
            {
               postEffectFn(this._root,tf,this._lastTextMapped,data);
            }
         }
      }
      
      private function styleText(tf:TextField, txt:String) : String
      {
         var styleToStrip:String = null;
         var boldFont:String = null;
         var fmt:TextFormat = tf.defaultTextFormat;
         var baseFont:String = fmt.font;
         var stylesToStrip:Array = ["Regular"];
         for each(styleToStrip in stylesToStrip)
         {
            if(baseFont.indexOf(" " + stylesToStrip) == baseFont.length - stylesToStrip.length - 1)
            {
               baseFont = baseFont.substr(0,baseFont.length - stylesToStrip.length - 1);
               break;
            }
         }
         boldFont = this._boldFontName == null ? baseFont + " Bold" : this._boldFontName;
         var italicFont:String = this._italicFontName == null ? baseFont + " Italic" : this._italicFontName;
         var boldItalicFont:String = this._boldItalicFontName == null ? baseFont + " Bold Italic" : this._boldItalicFontName;
         txt = txt.replace(/<b><i>/gi,"<font face=\"" + boldItalicFont + "\">");
         txt = txt.replace(/<b>/gi,"<font face=\"" + boldFont + "\">");
         txt = txt.replace(/<i>/gi,"<font face=\"" + italicFont + "\">");
         return txt.replace(/<\/b><\/i>|<\/b>|<\/i>/gi,"</font>");
      }
      
      public function setStyleFonts(italicFontName:String, boldFontName:String = null, boldItalicFontName:String = null) : void
      {
         this._italicFontName = italicFontName;
         this._boldFontName = boldFontName;
         this._boldItalicFontName = boldItalicFontName;
      }
      
      public function set text(val:String) : void
      {
         this.setTextWithData(val,null);
      }
      
      public function get text() : String
      {
         return this._lastTextRaw;
      }
      
      public function get mappedText() : String
      {
         return this._lastTextMapped;
      }
      
      public function get numLines() : Number
      {
         if(Boolean(this._tfs) && this._tfs.length > 0)
         {
            return (this._tfs[0] as TextField).numLines;
         }
         return 0;
      }
      
      public function get textHeight() : Number
      {
         if(Boolean(this._tfs) && this._tfs.length > 0)
         {
            return TextUtils.getTextHeight(this._tfs[0]);
         }
         return 0;
      }
      
      public function getLineMetrics(lineIndex:Number) : TextLineMetrics
      {
         if(Boolean(this._tfs) && this._tfs.length > 0)
         {
            return (this._tfs[0] as TextField).getLineMetrics(lineIndex);
         }
         return null;
      }
      
      public function addMapper(mapperFn:Function) : void
      {
         this._mappers.push(mapperFn);
         this.text = this.text;
      }
      
      public function addPostEffect(postEffectFn:Function) : void
      {
         this._postEffects.push(postEffectFn);
         this.text = this.text;
      }
      
      public function setColor(c:uint, a:Number) : void
      {
         var tf:TextField = null;
         for each(tf in this._tfs)
         {
            ColorUtil.tint(tf,c,a);
         }
      }
   }
}

