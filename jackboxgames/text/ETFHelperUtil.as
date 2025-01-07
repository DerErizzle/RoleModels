package jackboxgames.text
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import jackboxgames.bbparser.BBCodeParser;
   import jackboxgames.flash.ETFHelperComponent;
   import jackboxgames.logger.Logger;
   import jackboxgames.utils.ArrayUtil;
   import jackboxgames.utils.DisplayObjectUtil;
   
   public final class ETFHelperUtil
   {
      private static const BBCODE_PARSER:BBCodeParser = new BBCodeParser(BBCodeParser.defaultTags);
      
      public function ETFHelperUtil()
      {
         super();
      }
      
      public static function buildExtendableTextFieldFromRoot(root:DisplayObjectContainer) : ExtendableTextField
      {
         var helper:ETFHelperComponent = null;
         if(!root)
         {
            Logger.warning("Warning: ETFHelperUtil received null");
            return new ExtendableTextField(new Sprite(),[],[]);
         }
         var helpers:Array = findETFHelpersInChildren(root,false);
         if(helpers.length > 0)
         {
            helper = ArrayUtil.first(helpers);
            if(helpers.length > 1)
            {
               Logger.warning("Warning: ETFHelperUtil found multiple helpers on: " + DisplayObjectUtil.getPathTo(root));
            }
            return buildExtendableTextFieldFromHelper(helper);
         }
         Logger.warning("Warning: ETFHelperUtil cannot find a helper on: " + DisplayObjectUtil.getPathTo(root));
         return new ExtendableTextField(root,[],[]);
      }
      
      public static function buildExtendableTextFieldFromHelper(helper:ETFHelperComponent) : ExtendableTextField
      {
         var mappers:Array = [];
         var postEffects:Array = [];
         if(helper.resize)
         {
            postEffects.push(PostEffectFactory.createDynamicResizerEffect(helper.minSize,helper.maxSize));
         }
         if(helper.balance)
         {
            postEffects.push(PostEffectFactory.createBalancerEffect(helper.balanceType));
         }
         if(helper.supportsEmoji)
         {
         }
         mappers.push(function(s:String, data:*):String
         {
            return BBCODE_PARSER.parse(s);
         });
         switch(helper.letterCase)
         {
            case "upper":
               mappers.push(function(s:String, data:*):String
               {
                  return s.toUpperCase();
               });
               break;
            case "lower":
               mappers.push(function(s:String, data:*):String
               {
                  return s.toLowerCase();
               });
         }
         return new ExtendableTextField(helper.parent,mappers,postEffects);
      }
      
      public static function findETFHelpersInChildren(root:DisplayObjectContainer, deep:Boolean) : Array
      {
         var child:DisplayObject = null;
         if(!root)
         {
            return [];
         }
         var helpers:Array = [];
         for(var i:int = 0; i < root.numChildren; i++)
         {
            child = root.getChildAt(i);
            if(child is ETFHelperComponent)
            {
               helpers.push(child);
            }
            if(deep && child is DisplayObjectContainer)
            {
               helpers = helpers.concat(findETFHelpersInChildren(DisplayObjectContainer(child),true));
            }
         }
         return helpers;
      }
   }
}

