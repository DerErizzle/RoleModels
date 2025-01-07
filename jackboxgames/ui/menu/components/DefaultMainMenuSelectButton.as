package jackboxgames.ui.menu.components
{
   import flash.display.MovieClip;
   import jackboxgames.ui.menu.IMainMenu;
   import jackboxgames.utils.MovieClipShower;
   import jackboxgames.utils.Nullable;
   
   public class DefaultMainMenuSelectButton implements IMainMenuSelectButton
   {
      private var _selectShower:MovieClipShower;
      
      public function DefaultMainMenuSelectButton(mc:MovieClip, mainMenu:IMainMenu)
      {
         super();
         this._selectShower = new MovieClipShower(mc);
      }
      
      public function reset() : void
      {
         this._selectShower.reset();
      }
      
      public function show(doneFn:Function, params:Object) : void
      {
         this._selectShower.setShown(true,doneFn);
      }
      
      public function dismiss(doneFn:Function, params:Object) : void
      {
         this._selectShower.setShown(false,doneFn);
      }
      
      public function disableMenu() : void
      {
         this._selectShower.setShown(false,Nullable.NULL_FUNCTION);
      }
      
      public function enableMenu() : void
      {
         this._selectShower.setShown(true,Nullable.NULL_FUNCTION);
      }
   }
}

