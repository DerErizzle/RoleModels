package jackboxgames.expressionparser
{
   import jackboxgames.expressionparser.expressions.*;
   
   public class ExpressionParser
   {
      private var _tokenizer:Tokenizer;
      
      private var _tokens:Array;
      
      private var _currentTokenIndex:int;
      
      public function ExpressionParser()
      {
         super();
         this._tokenizer = new Tokenizer();
      }
      
      private function _currentToken() : Token
      {
         return this._tokens[this._currentTokenIndex];
      }
      
      private function _previous() : Token
      {
         return this._currentTokenIndex > 0 ? this._tokens[this._currentTokenIndex - 1] : null;
      }
      
      private function _isAtStart() : Boolean
      {
         return this._currentTokenIndex == 0;
      }
      
      private function _isAtEnd() : Boolean
      {
         var t:Token = this._currentToken();
         return t.type == TokenType.EOF;
      }
      
      private function _check(type:TokenType) : Boolean
      {
         if(this._isAtEnd())
         {
            return false;
         }
         var t:Token = this._currentToken();
         return t.type == type;
      }
      
      private function _advance() : Token
      {
         if(!this._isAtEnd())
         {
            ++this._currentTokenIndex;
         }
         return this._previous();
      }
      
      private function _match(... types) : Boolean
      {
         var type:TokenType = null;
         var t:Token = this._currentToken();
         for each(type in types)
         {
            if(this._check(type))
            {
               this._advance();
               return true;
            }
         }
         return false;
      }
      
      private function _consume(type:TokenType) : Token
      {
         return this._check(type) ? this._advance() : null;
      }
      
      private function _parseBinaryExpression(parseOperand:Function, ... types) : Result
      {
         var opStart:int = 0;
         var op:Token = null;
         var right:Result = null;
         var expr:Result = parseOperand();
         if(expr == null)
         {
            return new Result(false,"UNEXPECTED BINARY OP: Binary operator appears before a valid expression at position " + this._currentTokenIndex);
         }
         if(!expr.succeeded)
         {
            return expr;
         }
         while(Boolean(this._match.apply(this,types)))
         {
            opStart = this._currentTokenIndex - 1;
            if(this._isAtEnd())
            {
               return new Result(false,"UNTERMINATED BINARY: File terminates before binary operator at position " + opStart + " terminates.");
            }
            op = this._previous();
            right = parseOperand();
            if(!right.succeeded)
            {
               return right;
            }
            expr = Binary.CREATE_RESULT(expr,op,right);
         }
         return expr;
      }
      
      private function _primary() : Result
      {
         var parenStart:int = 0;
         var expr:Result = null;
         if(this._match(TokenType.FALSE))
         {
            return Literal.CREATE_RESULT(false);
         }
         if(this._match(TokenType.TRUE))
         {
            return Literal.CREATE_RESULT(true);
         }
         if(this._match(TokenType.NULL))
         {
            return Literal.CREATE_RESULT(null);
         }
         if(this._match(TokenType.NUMBER))
         {
            return Literal.CREATE_RESULT(this._previous().data);
         }
         if(this._match(TokenType.VAR))
         {
            return Keyword.CREATE_RESULT(this._previous().data);
         }
         if(this._match(TokenType.STRING))
         {
            return Literal.CREATE_RESULT(this._previous().data);
         }
         if(this._match(TokenType.PAREN_START))
         {
            parenStart = this._currentTokenIndex;
            expr = this._expression();
            if(this._consume(TokenType.PAREN_END) == null)
            {
               return new Result(false,"MISSING PARENTHESIS: Expect \')\' after expression beginning at " + parenStart);
            }
            return Grouping.CREATE_RESULT(expr);
         }
         if(this._match(TokenType.PAREN_END))
         {
            return new Result(false,"UNEXPECTED PARENTHESIS: Unexpected \')\' without a matching \'(\' at " + this._currentTokenIndex);
         }
         return undefined;
      }
      
      private function _unary() : Result
      {
         var op:Token = null;
         var right:Result = null;
         if(this._match(TokenType.NOT,TokenType.NEGATIVE))
         {
            if(this._isAtEnd())
            {
               return new Result(false,"UNTERMINATED UNARY: File terminates before unary operator terminates.");
            }
            op = this._previous();
            right = this._unary();
            return Unary.CREATE_RESULT(op,right);
         }
         return this._primary();
      }
      
      private function _factor() : Result
      {
         return this._parseBinaryExpression(this._unary,TokenType.MULTIPLY,TokenType.DIVIDE);
      }
      
      private function _term() : Result
      {
         return this._parseBinaryExpression(this._factor,TokenType.PLUS,TokenType.MINUS);
      }
      
      private function _comparison() : Result
      {
         return this._parseBinaryExpression(this._term,TokenType.GREATER_THAN,TokenType.GREATER_THAN_OR_EQUAL_TO,TokenType.LESS_THAN,TokenType.LESS_THAN_OR_EQUAL_TO);
      }
      
      private function _equality() : Result
      {
         return this._parseBinaryExpression(this._comparison,TokenType.EQUAL,TokenType.NOT_EQUAL);
      }
      
      private function _junction() : Result
      {
         return this._parseBinaryExpression(this._equality,TokenType.AND,TokenType.OR);
      }
      
      private function _expression() : Result
      {
         return this._junction();
      }
      
      public function parse(s:String) : Result
      {
         var tokenized:Result = this._tokenizer.tokenize(s);
         this._currentTokenIndex = 0;
         if(!tokenized.succeeded)
         {
            return tokenized;
         }
         this._tokens = tokenized.payload;
         var topOfTree:Result = this._expression();
         if(topOfTree.succeeded && this._currentTokenIndex < this._tokens.length - 1)
         {
            return new Result(false,"Last " + (this._tokens.length - this._currentTokenIndex - 1) + " tokens are unused.");
         }
         return topOfTree;
      }
   }
}

