package jackboxgames.rolemodels.actionpackages.delegates
{
   import flash.display.MovieClip;
   import jackboxgames.rolemodels.*;
   import jackboxgames.widgets.RoomPasswordWidget;
   import jackboxgames.widgets.mainmenu.MainMenu;
   
   public class RoleModelsMainMenu extends MainMenu
   {
       
      
      private var _roomPasswordWidget:RoomPasswordWidget;
      
      public function RoleModelsMainMenu(mc:MovieClip)
      {
         super(mc);
         this._roomPasswordWidget = new RoomPasswordWidget(mc.settings.base.roomPassword,GameState.instance.passwordManager);
      }
   }
}
