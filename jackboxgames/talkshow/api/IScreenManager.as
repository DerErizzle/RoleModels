package jackboxgames.talkshow.api
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public interface IScreenManager
   {
      function addToScreen(param1:DisplayObject, param2:String = null, param3:String = "front", param4:String = "") : DisplayObject;
      
      function addTags(param1:DisplayObject, param2:String) : void;
      
      function removeTags(param1:DisplayObject, param2:String) : void;
      
      function getTagged(param1:String) : Array;
      
      function get screen() : MovieClip;
   }
}

