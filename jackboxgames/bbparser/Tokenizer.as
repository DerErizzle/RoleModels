package jackboxgames.bbparser
{
   import flash.utils.Dictionary;
   import jackboxgames.utils.*;
   
   public class Tokenizer
   {
      private var _tags:Dictionary;
      
      public function Tokenizer(tags:Dictionary)
      {
         super();
         this._tags = tags;
      }
      
      private static function createTextToken(content:String) : Token
      {
         return new Token(TokenType.TEXT,content);
      }
      
      private static function createTagToken(match:Array) : Token
      {
         var tagName:String = null;
         var attributes:Dictionary = null;
         var attrPattern:RegExp = null;
         var attrStr:String = null;
         var attrMatch:Array = null;
         if(!match[1])
         {
            tagName = match[2];
            attributes = new Dictionary();
            attrPattern = /([a-zA-Z0-9\.\-_:;\/]+)?=(["])([a-zA-Z0-9\.\-_:;#\/\s]+)\2/g;
            attrStr = match[0].substr(1 + tagName.length,match[0].length - 2 - tagName.length);
            attrMatch = attrPattern.exec(attrStr);
            while(attrMatch != null)
            {
               if(!attrMatch[1])
               {
                  attributes[tagName] = attrMatch[3];
               }
               else
               {
                  attributes[attrMatch[1]] = attrMatch[3];
               }
            }
            return new Token(TokenType.STARTTAG,tagName,attributes,match[0]);
         }
         return new Token(TokenType.ENDTAG,match[1].substr(1,match[1].length - 1));
      }
      
      private function _getBytesNeededForCharCode(charCode:int) : int
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
         Assert.assert(false,"WHAT IS THIS CODE POINT?!");
         return 1;
      }
      
      private function _regexIndexToStringIndex(s:String, regexIndex:int) : int
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
            currentBytes += this._getBytesNeededForCharCode(s.charCodeAt(i));
         }
         return -1;
      }
      
      private function getTokens(str:String) : Array
      {
         var delta:int = 0;
         var tagPattern:RegExp = /\[(\/\w*)\]|\[(\w*)(=([\"])[a-zA-Z0-9\\.\\-_:;\/]*\4)?( ([a-zA-Z0-9\\.\\-_:;\/]+)?=([\"])([a-zA-Z0-9\.\-_:;#\/\s]+)\7)*\]/g;
         var tokens:Array = [];
         var match:Array = tagPattern.exec(str);
         var lastIndex:int = 0;
         while(match != null)
         {
            delta = this._regexIndexToStringIndex(str,match.index) - lastIndex;
            if(delta > 0)
            {
               tokens.push(Tokenizer.createTextToken(str.substr(lastIndex,delta)));
            }
            tokens.push(Tokenizer.createTagToken(match));
            lastIndex = this._regexIndexToStringIndex(str,tagPattern.lastIndex);
            match = tagPattern.exec(str);
         }
         if(lastIndex >= 0)
         {
            delta = str.length - lastIndex;
            if(delta > 0)
            {
               tokens.push(Tokenizer.createTextToken(str.substr(lastIndex,delta)));
            }
         }
         return tokens;
      }
      
      public function tokenizeString(str:String) : Array
      {
         var token:Token = null;
         var tag:Tag = null;
         var tagNoNesting:Boolean = false;
         var addTag:Boolean = false;
         var tokens:Array = this.getTokens(str);
         var newTokens:Array = [];
         var noNesting:Boolean = false;
         var noNestingTag:String = "";
         var noNestedTagContent:String = "";
         for each(token in tokens)
         {
            tag = this._tags[token.content];
            tagNoNesting = Boolean(tag) ? tag.noNesting : false;
            addTag = true;
            if(noNesting)
            {
               if(token.type == TokenType.ENDTAG && token.content == noNestingTag)
               {
                  noNesting = false;
                  newTokens.push(Tokenizer.createTextToken(noNestedTagContent));
               }
               else
               {
                  token.convertToTextToken();
                  noNestedTagContent += token.content;
                  addTag = false;
               }
            }
            else if(tagNoNesting && token.type == TokenType.STARTTAG)
            {
               noNesting = true;
               noNestingTag = token.content;
               noNestedTagContent = "";
            }
            if(addTag)
            {
               newTokens.push(token);
            }
         }
         return newTokens;
      }
   }
}

