package jackboxgames.expressionparser
{
   public class Tokenizer
   {
      public function Tokenizer()
      {
         super();
      }
      
      private function _charInAsciiRange(s:String, lower:int, upper:int) : Boolean
      {
         return lower <= s.charCodeAt(0) && upper >= s.charCodeAt(0);
      }
      
      private function _charIsUpperCase(s:String) : Boolean
      {
         return this._charInAsciiRange(s,65,90);
      }
      
      private function _charIsLowerCase(s:String) : Boolean
      {
         return this._charInAsciiRange(s,97,122);
      }
      
      private function _charIsAlpha(s:String) : Boolean
      {
         return this._charIsUpperCase(s) || this._charIsLowerCase(s);
      }
      
      private function _charIsNumeric(s:String) : Boolean
      {
         return this._charInAsciiRange(s,48,57);
      }
      
      private function _charIsAlphaNumeric(s:String) : Boolean
      {
         return this._charIsAlpha(s) || this._charIsNumeric(s);
      }
      
      private function _charInVar(s:String) : Boolean
      {
         return this._charIsAlphaNumeric(s) || s == "_";
      }
      
      private function _charInNumber(s:String) : Boolean
      {
         return this._charIsNumeric(s) || s == ".";
      }
      
      private function _charCanLeadVar(s:String) : Boolean
      {
         return this._charInVar(s) || s == "$";
      }
      
      private function _charIsQuote(s:String) : Boolean
      {
         return s == "\"" || s == "\'";
      }
      
      private function _charIsWhitespace(s:String) : Boolean
      {
         return s.length == 0 || s.charAt(0) == " ";
      }
      
      private function _getTokenFromSymbol(s:String) : Token
      {
         switch(s)
         {
            case "==":
               return new Token(TokenType.EQUAL);
            case "!=":
               return new Token(TokenType.NOT_EQUAL);
            case ">":
               return new Token(TokenType.GREATER_THAN);
            case ">=":
               return new Token(TokenType.GREATER_THAN_OR_EQUAL_TO);
            case "<":
               return new Token(TokenType.LESS_THAN);
            case "<=":
               return new Token(TokenType.LESS_THAN_OR_EQUAL_TO);
            case "-":
               return new Token(TokenType.MINUS);
            case "+":
               return new Token(TokenType.PLUS);
            case "*":
               return new Token(TokenType.MULTIPLY);
            case "/":
               return new Token(TokenType.DIVIDE);
            case "!":
               return new Token(TokenType.NOT);
            case "(":
               return new Token(TokenType.PAREN_START);
            case ")":
               return new Token(TokenType.PAREN_END);
            default:
               return null;
         }
      }
      
      private function _getTokenFromKeyword(s:String) : Token
      {
         var k:String = s.toLowerCase();
         switch(k)
         {
            case "true":
               return new Token(TokenType.TRUE);
            case "false":
               return new Token(TokenType.FALSE);
            case "and":
               return new Token(TokenType.AND);
            case "or":
               return new Token(TokenType.OR);
            case "null":
               return new Token(TokenType.NULL);
            default:
               return new Token(TokenType.VAR,s);
         }
      }
      
      public function tokenize(s:String) : Result
      {
         var tokens:Array;
         var state:TokenizerState;
         var decimalFound:Boolean;
         var err:String;
         var i:int = 0;
         var currentToken:String = null;
         var c:String = null;
         var peek:String = null;
         var isVar:Boolean = false;
         var isNum:Boolean = false;
         var peekForward:Function = function(forward:int):String
         {
            var idx:int = i + forward;
            return idx >= s.length ? "" : s.charAt(idx);
         };
         var consumeCurrentCharacter:Function = function():void
         {
            currentToken += s.charAt(i);
            ++i;
         };
         var resetState:Function = function(consume:Boolean = false):void
         {
            currentToken = "";
            state = TokenizerState.BASE;
            if(consume)
            {
               ++i;
            }
         };
         if(s == "")
         {
            return new Result(false,"EMPTY STRING: Empty string passed to parser.");
         }
         i = 0;
         tokens = [];
         currentToken = "";
         state = TokenizerState.BASE;
         decimalFound = false;
         err = "";
         while(i < s.length)
         {
            c = s.charAt(i);
            peek = "";
            if(state == TokenizerState.BASE)
            {
               resetState();
               if(c == "=" || c == ">" || c == "<" || c == "!")
               {
                  peek = peekForward(1);
                  if(peek == "=")
                  {
                     c += peek;
                     i++;
                  }
                  tokens.push(this._getTokenFromSymbol(c));
                  i++;
               }
               else if(c == "-")
               {
                  peek = peekForward(1);
                  isVar = this._charCanLeadVar(peek);
                  isNum = this._charInNumber(peek);
                  if(isVar || isNum)
                  {
                     if(isNum)
                     {
                        state = TokenizerState.NUMBER;
                     }
                     else if(isVar)
                     {
                        state = TokenizerState.KEYWORD;
                     }
                     tokens.push(new Token(TokenType.NEGATIVE));
                     i++;
                  }
                  else
                  {
                     tokens.push(this._getTokenFromSymbol(c));
                     i++;
                  }
               }
               else if(c == "+" || c == "*" || c == "/" || c == "(" || c == ")")
               {
                  tokens.push(this._getTokenFromSymbol(c));
                  i++;
               }
               else if(c == "\"" || c == "\'")
               {
                  state = TokenizerState.STRING;
                  if(i == s.length - 1)
                  {
                     err = "UNTERMINATED STRING";
                     return new Result(false,err);
                  }
                  i++;
               }
               else if(this._charIsWhitespace(c))
               {
                  i++;
               }
               else if(this._charInNumber(c))
               {
                  state = TokenizerState.NUMBER;
               }
               else
               {
                  if(!this._charCanLeadVar(c))
                  {
                     err = "UNKNOWN CHARACTER: Unknown character at position: " + i;
                     return new Result(false,err);
                  }
                  state = TokenizerState.KEYWORD;
                  if(c == "$")
                  {
                     consumeCurrentCharacter();
                  }
               }
            }
            else if(state == TokenizerState.NUMBER)
            {
               if(c == ".")
               {
                  if(decimalFound)
                  {
                     err = "DECIMAL ERROR: Extra decimal at position: " + i;
                     return new Result(false,err);
                  }
                  decimalFound = true;
                  consumeCurrentCharacter();
               }
               else if(!this._charIsNumeric(c) || i >= s.length)
               {
                  tokens.push(new Token(TokenType.NUMBER,Number(currentToken)));
                  resetState();
                  decimalFound = false;
               }
               else
               {
                  consumeCurrentCharacter();
               }
            }
            else if(state == TokenizerState.STRING)
            {
               if(c == "\"" || c == "\'")
               {
                  tokens.push(new Token(TokenType.STRING,currentToken));
                  resetState(true);
               }
               else
               {
                  if(i == s.length - 1)
                  {
                     err = "UNTERMINATED STRING";
                     return new Result(false,err);
                  }
                  if(c == "\\")
                  {
                     peek = peekForward(1);
                     if(peek == "\"" || peek == "\'")
                     {
                        i++;
                        consumeCurrentCharacter();
                     }
                     else
                     {
                        consumeCurrentCharacter();
                     }
                  }
                  else
                  {
                     consumeCurrentCharacter();
                  }
               }
            }
            else if(state == TokenizerState.KEYWORD)
            {
               if(!this._charInVar(c) && c != ".")
               {
                  tokens.push(this._getTokenFromKeyword(currentToken));
                  resetState();
               }
               else
               {
                  consumeCurrentCharacter();
               }
            }
         }
         if(state != null)
         {
            if(state == TokenizerState.STRING)
            {
               tokens.push(new Token(TokenType.STRING,currentToken));
            }
            else if(state == TokenizerState.NUMBER)
            {
               tokens.push(new Token(TokenType.NUMBER,Number(currentToken)));
            }
            else if(state == TokenizerState.KEYWORD)
            {
               tokens.push(this._getTokenFromKeyword(currentToken));
            }
         }
         tokens.push(new Token(TokenType.EOF,"EOF"));
         return new Result(true,tokens);
      }
   }
}

class TokenizerState
{
   public static const BASE:TokenizerState = new TokenizerState();
   
   public static const NUMBER:TokenizerState = new TokenizerState();
   
   public static const STRING:TokenizerState = new TokenizerState();
   
   public static const KEYWORD:TokenizerState = new TokenizerState();
   
   private static var _enumCreated:Boolean = false;
   
   _enumCreated = true;
   
   public function TokenizerState()
   {
      super();
      if(_enumCreated)
      {
         throw new Error("The Enum is already defined.");
      }
   }
}

