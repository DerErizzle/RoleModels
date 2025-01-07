package jackboxgames.talkshow.api
{
   import flash.display.DisplayObject;
   
   public interface ICanvas
   {
      function addChild(param1:DisplayObject) : DisplayObject;
      
      function addChildAt(param1:DisplayObject, param2:int) : DisplayObject;
      
      function removeChild(param1:DisplayObject) : DisplayObject;
   }
}

