package jackboxgames.engine.componenets
{
   import jackboxgames.engine.GameEngine;
   import jackboxgames.localizy.LocalizationManager;
   import jackboxgames.settings.RoomPasswordManager;
   import jackboxgames.settings.SettingsDataStore;
   import jackboxgames.settings.SettingsManager;
   import jackboxgames.ui.settings.SettingsMenu;
   import jackboxgames.ui.settings.SettingsMenuConfigSet;
   import jackboxgames.utils.PausableEventDispatcher;
   import jackboxgames.utils.PromiseUtil;
   
   public class SettingsComponent extends PausableEventDispatcher implements IComponent
   {
      private var _engine:GameEngine;
      
      private var _settingsConfigs:SettingsMenuConfigSet;
      
      public function SettingsComponent(engine:GameEngine)
      {
         super();
         this._engine = engine;
      }
      
      public function get priority() : uint
      {
         return 0;
      }
      
      public function init(doneFn:Function) : void
      {
         SettingsDataStore.initialize();
         SettingsManager.initialize();
         SettingsMenu.initialize();
         RoomPasswordManager.initialize();
         doneFn();
      }
      
      public function dispose() : void
      {
      }
      
      public function startGame(doneFn:Function) : void
      {
         SettingsDataStore.instance.setSettingConfigs(this._engine.activeGame.settings);
         SettingsDataStore.instance.reloadFromSave();
         RoomPasswordManager.instance.reloadFromSave();
         LocalizationManager.instance.currentLocale = SettingsManager.instance.getValue(LocalizationManager.SETTING_LOCALE).val;
         this._settingsConfigs = new SettingsMenuConfigSet();
         PromiseUtil.ALL([this._settingsConfigs.add("main","settings.json")]).then(function():void
         {
            SettingsMenu.instance.setConfigs(_settingsConfigs);
            doneFn();
         });
      }
      
      public function disposeGame() : void
      {
         SettingsMenu.instance.setConfigs(null);
      }
   }
}

