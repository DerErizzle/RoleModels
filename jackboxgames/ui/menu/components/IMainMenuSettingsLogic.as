package jackboxgames.ui.menu.components
{
   public interface IMainMenuSettingsLogic
   {
      function reset() : void;
      
      function init(param1:Function) : void;
      
      function dismiss(param1:Function, param2:Object) : void;
      
      function onSettingsShown() : void;
   }
}

