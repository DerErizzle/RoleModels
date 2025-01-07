package jackboxgames.utils
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import jackboxgames.logger.Logger;
   
   public final class SpriteUtil
   {
      public function SpriteUtil()
      {
         super();
      }
      
      public static function removeAllChildren(parent:Sprite, recursive:Boolean = false) : void
      {
         var len:int = 0;
         var i:int = 0;
         var child:DisplayObject = null;
         if(Boolean(parent))
         {
            len = parent.numChildren;
            for(i = 0; i < len; i++)
            {
               child = parent.getChildAt(0);
               if(child is MovieClip)
               {
                  (child as MovieClip).stop();
               }
               if(recursive && child is Sprite)
               {
                  SpriteUtil.removeAllChildren(child as Sprite);
               }
               parent.removeChildAt(0);
            }
         }
      }
      
      public static function destroy(object:DisplayObject) : void
      {
         if(Boolean(object))
         {
            if(Boolean(object.parent))
            {
               object.parent.removeChild(object);
            }
            if(object is Bitmap)
            {
               Bitmap(object).bitmapData.dispose();
            }
            else if(object is Sprite)
            {
               removeAllChildren(object as Sprite);
            }
         }
      }
      
      public static function addChildWithResize(root:*, addMe:DisplayObject) : void
      {
         addMe.width = root.size.width;
         addMe.height = root.size.height;
         root.addChild(addMe);
      }
      
      public static function logAllChildren(parent:Sprite, recursive:Boolean = false) : void
      {
         var len:int = 0;
         var i:int = 0;
         var child:DisplayObject = null;
         if(Boolean(parent))
         {
            len = parent.numChildren;
            for(i = 0; i < len; i++)
            {
               child = parent.getChildAt(i);
               log(child);
               if(recursive && child is Sprite)
               {
                  SpriteUtil.logAllChildren(child as Sprite);
               }
            }
         }
      }
      
      public static function log(object:DisplayObject) : void
      {
         Logger.debug("SpriteUtil::log:  " + TraceUtil.object({
            "name":object.name,
            "parentName":object.parent.name,
            "x":object.x,
            "y":object.y,
            "width":object.width,
            "height":object.height,
            "alpha":object.alpha,
            "visible":object.visible,
            "scaleX":object.scaleX,
            "scaleY":object.scaleY,
            "rotation":object.rotation
         },object.name));
      }
   }
}

