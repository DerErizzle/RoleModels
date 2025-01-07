package jackboxgames.ui.menu.components
{
   import flash.events.Event;
   import jackboxgames.ui.menu.IMainMenu;
   import jackboxgames.ui.settings.SettingsMenu;
   import jackboxgames.utils.JBGUtil;
   
   public class DefaultMainMenuSettingsLogic implements IMainMenuSettingsLogic
   {
      private var _mainMenu:IMainMenu;
      
      public function DefaultMainMenuSettingsLogic(mainMenu:IMainMenu)
      {
         super();
         this._mainMenu = mainMenu;
      }
      
      public function reset() : void
      {
      }
      
      public function init(doneFn:Function) : void
      {
         doneFn();
      }
      
      public function onSettingsShown() : void
      {
         JBGUtil.eventOnce(SettingsMenu.instance,SettingsMenu.EVENT_CLOSING,function(evt:Event):void
         {
            _mainMenu.onSettingsClosing();
         });
         JBGUtil.eventOnce(SettingsMenu.instance,SettingsMenu.EVENT_CLOSED,function(evt:Event):void
         {
            _mainMenu.enableMenu();
            _mainMenu.onSettingsClosed();
         });
         SettingsMenu.instance.prepare("menu","main");
         SettingsMenu.instance.open();
      }
      
      public function dismiss(doneFn:Function, params:Object) : void
      {
         doneFn();
      }
   }
}

