package jackboxgames.engine.componenets
{
   import flash.display.*;
   import flash.events.*;
   import jackboxgames.engine.*;
   import jackboxgames.localizy.LocalizationManager;
   import jackboxgames.nativeoverride.Platform;
   import jackboxgames.settings.*;
   import jackboxgames.utils.*;
   import jackboxgames.video.*;
   
   public class SettingsComponent extends PausableEventDispatcher implements IComponent
   {
       
      
      private var _engine:GameEngine;
      
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
         var initialValues:Object = {};
         initialValues[SettingsConstants.SETTING_FULL_SCREEN] = BuildConfig.instance.configVal("supportsFullScreen") == true;
         initialValues[SettingsConstants.SETTING_VOLUME] = 1;
         initialValues[SettingsConstants.SETTING_VOLUME_HOST] = 1;
         initialValues[SettingsConstants.SETTING_VOLUME_SFX] = 1;
         initialValues[SettingsConstants.SETTING_VOLUME_MUSIC] = 1;
         initialValues[LocalizationManager.SETTING_LOCALE] = BuildConfig.instance.hasConfigVal("defaultLocale") ? BuildConfig.instance.configVal("defaultLocale") : LocalizationManager.DEFAULT_LOCALE;
         SettingsManager.initialize(initialValues);
         var fullScreenVal:SettingsValue = SettingsManager.instance.getValue(SettingsConstants.SETTING_FULL_SCREEN);
         fullScreenVal.addEventListener(SettingsValue.EVENT_VALUE_CHANGED,this._onFullscreenChanged);
         var volumeVal:SettingsValue = SettingsManager.instance.getValue(SettingsConstants.SETTING_VOLUME);
         volumeVal.addEventListener(SettingsValue.EVENT_VALUE_CHANGED,this._onVolumeChanged);
         if(!EnvUtil.isConsole())
         {
            SettingsManager.instance.reloadFromSave();
            LocalizationManager.instance.currentLocale = SettingsManager.instance.getValue(LocalizationManager.SETTING_LOCALE).val;
            if(!Platform.instance.supportsWindow && BuildConfig.instance.configVal("supportsFullScreen") == true)
            {
               fullScreenVal.val = true;
            }
            else
            {
               this._engine.setFullscreen(fullScreenVal.val);
            }
            this._engine.setVolume(volumeVal.val);
         }
         doneFn();
      }
      
      public function dispose() : void
      {
         var fullScreenVal:SettingsValue = SettingsManager.instance.getValue(SettingsConstants.SETTING_FULL_SCREEN);
         fullScreenVal.removeEventListener(SettingsValue.EVENT_VALUE_CHANGED,this._onFullscreenChanged);
         var volumeVal:SettingsValue = SettingsManager.instance.getValue(SettingsConstants.SETTING_VOLUME);
         volumeVal.removeEventListener(SettingsValue.EVENT_VALUE_CHANGED,this._onVolumeChanged);
      }
      
      public function startGame(doneFn:Function) : void
      {
         SettingsManager.instance.setInitialValues(this._engine.activeGame.initialSettings);
         SettingsManager.instance.reloadFromSave();
         LocalizationManager.instance.currentLocale = SettingsManager.instance.getValue(LocalizationManager.SETTING_LOCALE).val;
         doneFn();
      }
      
      public function disposeGame() : void
      {
      }
      
      private function _onFullscreenChanged(evt:Event) : void
      {
         var fullScreenVal:SettingsValue = SettingsManager.instance.getValue(SettingsConstants.SETTING_FULL_SCREEN);
         this._engine.setFullscreen(fullScreenVal.val);
      }
      
      private function _onVolumeChanged(evt:Event) : void
      {
         var volumeVal:SettingsValue = SettingsManager.instance.getValue(SettingsConstants.SETTING_VOLUME);
         this._engine.setVolume(volumeVal.val);
      }
   }
}
