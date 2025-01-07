package jackboxgames.talkshow.display
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import jackboxgames.talkshow.api.ICanvas;
   
   public class Canvas extends Sprite implements ICanvas
   {
      public function Canvas()
      {
         super();
      }
      
      override public function addChild(child:DisplayObject) : DisplayObject
      {
         return super.addChild(child);
      }
      
      override public function addChildAt(child:DisplayObject, index:int) : DisplayObject
      {
         return super.addChildAt(child,index);
      }
      
      override public function removeChild(child:DisplayObject) : DisplayObject
      {
         return super.removeChild(child);
      }
   }
}

