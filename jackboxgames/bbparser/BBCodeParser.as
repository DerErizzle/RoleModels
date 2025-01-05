package jackboxgames.bbparser
{
   import flash.utils.Dictionary;
   
   public class BBCodeParser
   {
      
      private static var _tagsToReplace:Dictionary = new Dictionary();
      
      {
         _tagsToReplace["&"] = "&amp";
         _tagsToReplace["<"] = "&lt";
         _tagsToReplace[">"] = "&gt";
      }
      
      private var _tags:Dictionary;
      
      private var _escapeHTML:Boolean = false;
      
      public function BBCodeParser(tags:Dictionary, escapeHTML:Boolean = false)
      {
         super();
         this._tags = tags;
         this._escapeHTML = escapeHTML;
      }
      
      private static function _simpleHtmlMarkupGenerator(tag:Tag, attr:Dictionary, content:String) : String
      {
         return "<" + tag.tagName + ">" + content + "</" + tag.tagName + ">";
      }
      
      public static function get defaultTags() : Dictionary
      {
         var tags:Dictionary = new Dictionary();
         tags["b"] = Tag.create("b",_simpleHtmlMarkupGenerator);
         tags["i"] = Tag.create("i",_simpleHtmlMarkupGenerator);
         tags["u"] = Tag.create("u",_simpleHtmlMarkupGenerator);
         tags["color"] = Tag.create("color",function(tag:Tag, attr:Dictionary, content:String):String
         {
            if("color" in attr)
            {
               return "<font color=\"" + attr["color"] + "\">" + content + "</font>";
            }
            return content;
         });
         return tags;
      }
      
      private static function escapeHTML(content:String) : String
      {
         var tag:String = null;
         for each(tag in _tagsToReplace)
         {
            content.replace(/[&<>]/g,tag);
         }
         return content;
      }
      
      public function parse(content:String, stripTags:Boolean = false, insertLineBreaks:Boolean = true, escapingHtml:Boolean = true) : String
      {
         var parseTree:ParseTree = ParseTree.buildTree(content,this._tags);
         if(parseTree == null || !parseTree.isValid)
         {
            return content;
         }
         return this.treeToHtml(parseTree.subTrees,insertLineBreaks,escapingHtml,stripTags);
      }
      
      public function addTag(name:String, tag:Tag) : void
      {
         this._tags[name] = tag;
      }
      
      private function treeToHtml(subTrees:Array, insertLineBreaks:Boolean, escapingHtml:Boolean, stripTags:Boolean = false) : String
      {
         var tree:ParseTree = null;
         var textContent:String = null;
         var tag:Tag = null;
         var content:String = null;
         var htmlString:String = "";
         var suppressLineBreaks:Boolean = false;
         for each(tree in subTrees)
         {
            if(tree.type == ParseTreeType.TEXT)
            {
               textContent = tree.content;
               if(escapingHtml)
               {
                  textContent = this._escapeHTML ? escapeHTML(textContent) : textContent;
               }
               if(insertLineBreaks && !suppressLineBreaks)
               {
                  textContent = textContent.replace(/(\r\n|\n|\r)/gm,"<br>");
                  suppressLineBreaks = false;
               }
               htmlString += textContent;
            }
            else
            {
               tag = this._tags[tree.content];
               content = this.treeToHtml(tree.subTrees,Boolean(tag) ? tag.insertLineBreaks : false,escapingHtml,stripTags);
               if(Boolean(tag) && !stripTags)
               {
                  htmlString += tag.markupGenerator(tag,tree.attributes,content);
               }
               else
               {
                  htmlString += content;
               }
               if(Boolean(tag))
               {
                  suppressLineBreaks = tag.suppressLineBreaks;
               }
            }
         }
         return htmlString;
      }
   }
}
