package jackboxgames.ui.menu.components
{
   public interface IMainMenuSelectButton
   {
      function reset() : void;
      
      function show(param1:Function, param2:Object) : void;
      
      function dismiss(param1:Function, param2:Object) : void;
      
      function disableMenu() : void;
      
      function enableMenu() : void;
   }
}

