package jackboxgames.utils
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
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
   }
}
