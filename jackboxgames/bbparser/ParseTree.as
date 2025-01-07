package jackboxgames.bbparser
{
   import flash.utils.Dictionary;
   
   public class ParseTree
   {
      private var _type:ParseTreeType;
      
      private var _content:String;
      
      private var _attributes:Dictionary;
      
      private var _subTrees:Array;
      
      public function ParseTree(type:ParseTreeType, content:String, attributes:Dictionary = null, subTrees:Array = null)
      {
         super();
         this._type = type;
         this._content = content;
         this._attributes = attributes;
         if(this._subTrees == null)
         {
            this._subTrees = new Array();
         }
         else
         {
            this._subTrees = subTrees;
         }
      }
      
      public static function buildTree(str:String, tags:Dictionary) : ParseTree
      {
         var tokenizer:Tokenizer = null;
         tokenizer = new Tokenizer(tags);
         var tokens:Array = tokenizer.tokenizeString(str);
         var tree:ParseTree = new ParseTree(ParseTreeType.ROOT,str);
         return buildTreeFromTokens(tree,tokens.reverse());
      }
      
      private static function buildTreeFromTokens(rootTree:ParseTree, tokens:Array, currentTag:String = "") : ParseTree
      {
         var newTree:ParseTree = null;
         var tagName:String = null;
         var newParseTree:ParseTree = null;
         var tokenTree:ParseTree = null;
         var endTagName:String = null;
         if(rootTree == null)
         {
            return null;
         }
         if(tokens.length == 0)
         {
            return rootTree;
         }
         var currentToken:Token = tokens.pop();
         if(currentToken == null)
         {
            return null;
         }
         if(currentToken.type == TokenType.TEXT)
         {
            newTree = new ParseTree(ParseTreeType.TEXT,currentToken.content);
            rootTree.subTrees.push(newTree);
         }
         else if(currentToken.type == TokenType.STARTTAG)
         {
            tagName = currentToken.content;
            newParseTree = new ParseTree(ParseTreeType.TAG,tagName,currentToken.attributes);
            tokenTree = ParseTree.buildTreeFromTokens(newParseTree,tokens,tagName);
            if(tokenTree == null)
            {
               return null;
            }
            rootTree.subTrees.push(tokenTree);
         }
         else if(currentToken.type == TokenType.ENDTAG)
         {
            endTagName = currentToken.content;
            if(endTagName == currentTag)
            {
               return rootTree;
            }
            return null;
         }
         if(tokens.length == 0 && currentTag != "")
         {
            return null;
         }
         return buildTreeFromTokens(rootTree,tokens,currentTag);
      }
      
      public function get type() : ParseTreeType
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
      
      public function get subTrees() : Array
      {
         return this._subTrees;
      }
      
      public function get isValid() : Boolean
      {
         var tree:ParseTree = null;
         for each(tree in this._subTrees)
         {
            if(!tree.isValid)
            {
               return false;
            }
         }
         return true;
      }
      
      public function toString() : String
      {
         return this._type + "-" + this._content;
      }
   }
}

