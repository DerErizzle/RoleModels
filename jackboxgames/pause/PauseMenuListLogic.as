package jackboxgames.pause
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.ui.menu.*;
   import jackboxgames.ui.menu.components.*;
   import jackboxgames.userinput.*;
   import jackboxgames.utils.*;
   
   public class PauseMenuListLogic extends DefaultMainMenuListLogic
   {
      public function PauseMenuListLogic(mc:MovieClip, mainMenu:IMainMenu, itemClass:Class, animationDelay:Duration = null)
      {
         super(mc,mainMenu,itemClass,animationDelay);
      }
      
      override protected function _onGamepad(evt:EventWithData) : void
      {
         var newSelected:int = 0;
         var items:Array = itemsInUse;
         if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_SELECT))
         {
            _mainMenu.onMainMenuSelect(_mainMenu.selectedIndex,_mainMenu.selectedItem.action);
         }
         else if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_DOWN))
         {
            newSelected = _mainMenu.selectedIndex == itemsInUse.length - 1 ? 0 : int(_mainMenu.selectedIndex + 1);
            _mainMenu.onMainMenuHighlight(_mainMenu.selectedIndex,newSelected);
         }
         else if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_UP))
         {
            newSelected = _mainMenu.selectedIndex == 0 ? itemsInUse.length - 1 : int(_mainMenu.selectedIndex - 1);
            _mainMenu.onMainMenuHighlight(_mainMenu.selectedIndex,newSelected);
         }
      }
   }
}

