package jackboxgames.bbparser
{
   import flash.utils.Dictionary;
   
   public class Token
   {
       
      
      private var _type:TokenType;
      
      private var _content:String;
      
      private var _attributes:Dictionary;
      
      private var _text:String;
      
      public function Token(type:TokenType, content:String, attributes:Dictionary = null, text:String = "")
      {
         super();
         this._type = type;
         this._content = content;
         this._attributes = attributes;
         this._text = text;
      }
      
      public function get type() : TokenType
      {
         return this._type;
      }
      
      public function get content() : String
      {
         return this._content;
      }
      
      public function get attributes() : Dictionary
      {
         return this._attributes;
      }
      
      public function get text() : String
      {
         return this._text;
      }
      
      public function toString() : String
      {
         if(this._type == TokenType.TEXT)
         {
            return this._content + " (TEXT)";
         }
         if(this._type == TokenType.STARTTAG)
         {
            return this._content + " (STARTTAG)";
         }
         if(this._type == TokenType.ENDTAG)
         {
            return this._content + " (ENDTAG)";
         }
         return this._content + " (NO TAG)";
      }
      
      public function equals(token:Token) : Boolean
      {
         return this._type == token.type && this._content == token.content;
      }
      
      public function convertToTextToken() : void
      {
         if(this._type == TokenType.STARTTAG)
         {
            this._content = this._text;
            this._type = TokenType.TEXT;
         }
         else if(this._type == TokenType.ENDTAG)
         {
            this._content = "[/$" + this._content;
            this._type = TokenType.TEXT;
         }
      }
   }
}
