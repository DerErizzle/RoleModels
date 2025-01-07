package jackboxgames.ui.menu.components
{
   public interface IMainMenuListLogic
   {
      function get itemsInUse() : Array;
      
      function set listenForInput(param1:Boolean) : void;
      
      function init(param1:Function) : void;
      
      function reset() : void;
      
      function show(param1:Function, param2:Object) : void;
      
      function dismiss(param1:Function, param2:Object) : void;
   }
}

