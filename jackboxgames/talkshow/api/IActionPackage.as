package jackboxgames.talkshow.api
{
   import flash.display.DisplayObject;
   
   public interface IActionPackage extends ICodeSpace
   {
       
      
      function get ts() : IEngineAPI;
      
      function get type() : String;
      
      function init(param1:IEngineAPI, ... rest) : void;
      
      function isInit() : Boolean;
      
      function handleAction(param1:IActionRef, param2:Object) : void;
      
      function getDuration(param1:IActionRef) : uint;
      
      function getDisplayObject(param1:IActionRef, param2:Object, param3:Boolean = false) : DisplayObject;
   }
}
